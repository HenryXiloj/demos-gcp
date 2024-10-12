import os
from airflow import DAG
from airflow.operators.python import PythonOperator  # Updated import for Airflow 2+
from airflow.utils.dates import days_ago
import subprocess
import time
import logging
import glob
from google.cloud import storage
import stat
import psutil
import signal
#import requests  # Add requests for GET request

# Setup logger
logger = logging.getLogger("test_cloudsql")
logger.setLevel(logging.DEBUG)
handler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

# Variables
CLOUD_SQL_PROXY_PATH = '/tmp/proxy'
CLOUD_SQL_PROXY_BINARY = f'{CLOUD_SQL_PROXY_PATH}/cloud-sql-proxy'  # Binary file path
LOG_FILE_PATH = f'{CLOUD_SQL_PROXY_PATH}/cloud-sql-proxy.log'
GCS_BUCKET_NAME = 'gcs_cloud_sql_proxy_v2_13_0'
BINARY_NAME = "cloud-sql-proxy"
INSTANCE_CONNECTION_NAME = 'terraform-workspace-437404:us-central1:psc-instance'
DB_NAME = 'my-database3'
DB_USER = 'henry'
DB_PASSWORD = 'hxi123'
DB_PORT = 5432

# Command and arguments
command = [
    CLOUD_SQL_PROXY_BINARY,
    "--gcloud-auth",
    "--psc",
    INSTANCE_CONNECTION_NAME,
    "--port",
    "5432"
]

# Define default_args for DAG
default_args = {
    'owner': 'airflow',
    'start_date': days_ago(1),
}

# Define DAG
dag = DAG(
    dag_id='cloud_sql_proxy_psc_dag',
    default_args=default_args,
    schedule_interval=None,  # You can set your own schedule here
    catchup=False,
)

# Task 1: Download the Cloud SQL Proxy from GCS
def download_cloud_sql_proxy():
    # Create the directory if it doesn't exist
    try:
        os.mkdir(CLOUD_SQL_PROXY_PATH)
        os.chmod(CLOUD_SQL_PROXY_PATH, stat.S_IRWXU | stat.S_IRWXG | stat.S_IRWXO)
        logger.info(f"Directory {CLOUD_SQL_PROXY_PATH} created with 777 permissions.")
        logger.info(f"Directory '{CLOUD_SQL_PROXY_PATH}' created successfully.")
    except FileExistsError:
        os.chmod(CLOUD_SQL_PROXY_PATH, stat.S_IRWXU | stat.S_IRWXG | stat.S_IRWXO)
        logger.info(f"Directory '{CLOUD_SQL_PROXY_PATH}' already exists.")
    
    # Check contents of the directory (equivalent to 'ls /tmp/proxy/')
    logger.info("Contents of /tmp/proxy/:")
    logger.info(glob.glob("/tmp/proxy/*"))
    logger.info("End Contents of /tmp/proxy/:")
   
    if not os.path.exists(CLOUD_SQL_PROXY_BINARY):
        # Initialise a client
        storage_client = storage.Client()
        # Create a bucket object for our bucket
        bucket = storage_client.get_bucket(GCS_BUCKET_NAME)
        # Create a blob object from the filepath
        blob = bucket.blob(BINARY_NAME)
        # Download the file to a destination
        blob.download_to_filename(CLOUD_SQL_PROXY_BINARY)
        # After placing the binary, make it executable
        os.chmod(CLOUD_SQL_PROXY_BINARY, stat.S_IRWXU | stat.S_IXGRP | stat.S_IXOTH)
        logger.info(f"Binary has been placed at {CLOUD_SQL_PROXY_BINARY} and made executable")
    else:
        logger.info(f"The cloud-sql-proxy binary already exists at {CLOUD_SQL_PROXY_BINARY}")
        # Check if the file is already executable
        current_mode = os.stat(CLOUD_SQL_PROXY_BINARY).st_mode
        if not (current_mode & stat.S_IXUSR):
            # If not executable, make it executable
            os.chmod(CLOUD_SQL_PROXY_BINARY, current_mode | stat.S_IRWXU | stat.S_IXGRP | stat.S_IXOTH)
            logger.info("Existing binary has been made executable")
        else:
            logger.info("Existing binary is already executable")

# Task 2: Start the Cloud SQL Proxy with PSC flag
def start_cloud_sql_proxy():

    #kill pid
    #bool_val = kill_cloud_sql_proxy()
    #if bool_val:
    #     logger.info(f"Cloud SQL Proxy was killing")
    # Check if the proxy is already running
    #time.sleep(120)
    
    # Check if the proxy is already running
    logger.info("Checking if Cloud SQL Proxy is already running...")
    existing_pid = is_cloud_sql_proxy_running()
    if existing_pid:
        logger.info(f"Cloud SQL Proxy is already running with PID {existing_pid}. Reading logs...")
        # Use the new generic function to read the log file
        read_log_file(LOG_FILE_PATH)
        return

    # If no existing PID, proceed to start the proxy
    logger.info("Cloud SQL Proxy is not running. Starting a new instance...")

    # Construct the proxy command using PSC without equal signs
    try:
        # Run the command in background and redirect output to log file
        with open(LOG_FILE_PATH, 'w') as log_file:
            process = subprocess.Popen(
                command,
                stdout=log_file,
                stderr=log_file,
                start_new_session=True
            )
        
        # Wait for a few seconds to allow the process to start and write to the log
        time.sleep(60)

        logger.info(f"Cloud SQL Proxy started with PID {process.pid}. Output is being logged to {LOG_FILE_PATH}")

        # Check the log file for successful startup
        read_log_file(LOG_FILE_PATH)
        #with open(LOG_FILE_PATH, 'r') as log_file:
        #    log_content = log_file.read()
        #    logger.info(log_content)
            #if "Ready for new connections" in log_content:
            #    logger.info("Cloud SQL Proxy is running successfully.")
            #else:
            #    logger.info("Cloud SQL Proxy might not have started correctly. Please check the log file.")

    except FileNotFoundError:
        logger.info(f"Error: The cloud-sql-proxy binary was not found at {CLOUD_SQL_PROXY_PATH}")
    except PermissionError:
        logger.info(f"Error: Permission denied when trying to execute {CLOUD_SQL_PROXY_PATH}")
    except Exception as e:
        logger.info(f"An error occurred: {str(e)}")

     # Read the log file again after starting the process
    read_log_file(LOG_FILE_PATH)

    logger.info(f"To stop the proxy, run: kill {process.pid}")

# Task 3: Execute the SQL Query
def execute_sql_query():
    import psycopg2
    # Connect to PostgreSQL database using psycopg2
    conn = psycopg2.connect(
        host='127.0.0.1',  # Localhost as Cloud SQL proxy is running locally
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )
    
    logger.info("Successfully connected to the Cloud SQL instance.")
    cursor = conn.cursor()  # Manually create the cursor
    try:
        logger.debug("Executing SQL query to fetch PostgreSQL version.")
        cursor.execute("SELECT version();")
        result = cursor.fetchone()
        logger.info(f"Query successful, result: {result}")
    except Exception as e:
        logger.error(f"Error executing SQL query: {str(e)}")
        raise
    finally:
        cursor.close()  # Ensure the cursor is closed
        conn.close()
        logger.debug("Closed the database cursor.")

    # Use the new generic function to read the log file
    read_log_file(LOG_FILE_PATH)    

def is_cloud_sql_proxy_running():
    for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
        try:
            # Check if the process name contains 'cloud-sql-proxy'
            if 'cloud-sql-proxy' in proc.name().lower():
                # Check if the command line arguments match
                if any(INSTANCE_CONNECTION_NAME in arg for arg in proc.cmdline()):
                    return proc.pid
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass
    return None

def kill_cloud_sql_proxy():
    for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
        try:
            if 'cloud-sql-proxy' in proc.name().lower():
                if any(INSTANCE_CONNECTION_NAME in arg for arg in proc.cmdline()):
                    pid = proc.pid
                    os.kill(pid, signal.SIGTERM)
                    logger.info(f"Sent termination signal to Cloud SQL Proxy process with PID {pid}")
                    
                    # Wait for the process to terminate
                    try:
                        psutil.Process(pid).wait(timeout=10)
                        logger.info(f"Cloud SQL Proxy process with PID {pid} has been terminated")
                        return True
                    except psutil.TimeoutExpired:
                        logger.warning(f"Cloud SQL Proxy process with PID {pid} did not terminate within the timeout. Forcing termination.")
                        os.kill(pid, signal.SIGKILL)
                        return True
                    except psutil.NoSuchProcess:
                        logger.info(f"Cloud SQL Proxy process with PID {pid} has already terminated")
                        return True
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass
    
    logger.info("No matching Cloud SQL Proxy process found")
    return False

def read_log_file(log_file_path):
    """
    Reads and logs the content of the log file.
    """
    try:
        with open(log_file_path, "r") as file:
            content = file.read()
            logger.info("Start Cloud SQL Proxy log************.")
            logger.info(content)
            logger.info("End Cloud SQL Proxy log************.")
    except FileNotFoundError:
        logger.error(f"Log file not found: {log_file_path}")
    except Exception as e:
        logger.error(f"An error occurred while reading the log file: {str(e)}")

# Define the tasks in the DAG
download_task = PythonOperator(
    task_id='download_cloud_sql_proxy',
    python_callable=download_cloud_sql_proxy,
    dag=dag,
)

start_proxy_task = PythonOperator(
    task_id='start_cloud_sql_proxy',
    python_callable=start_cloud_sql_proxy,
    dag=dag,
)

execute_sql_task = PythonOperator(
    task_id='execute_sql_query',
    python_callable=execute_sql_query,
    dag=dag,
)

# Set task dependencies
download_task >> start_proxy_task >> execute_sql_task
