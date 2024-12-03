import os
import socket
import logging
import platform
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.utils.dates import days_ago

# Setup logger
logger = logging.getLogger("ip_checker")
logger.setLevel(logging.DEBUG)
handler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

# Define default_args for DAG
default_args = {
    'owner': 'airflow',
    'start_date': days_ago(1),
}

# Function to get the external IP address (not localhost)
def get_external_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # This doesn't actually send anything; it just gets the correct IP
        s.connect(('8.8.8.8', 80))  # Connect to an external address (Google DNS in this case)
        ip_address = s.getsockname()[0]
    except Exception:
        ip_address = 'Unable to retrieve external IP'
    finally:
        s.close()
    return ip_address

# Function to check network connectivity to the PSC endpoint (or any other host/port)
def check_network_connectivity(ip, port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(5)  # Set a 5-second timeout for the connection attempt
    try:
        logger.info(f"Attempting to connect to {ip}:{port}...")
        s.connect((ip, port))
        logger.info(f"Successfully connected to {ip}:{port}")
        return True
    except Exception as e:
        logger.error(f"Failed to connect to {ip}:{port}: {str(e)}")
        return False
    finally:
        s.close()

# Function to perform DNS lookup for the PSC endpoint
def resolve_dns(psc_dns_name):
    try:
        logger.info(f"Attempting to resolve DNS for {psc_dns_name}.")
        # Perform DNS lookup using socket.gethostbyname
        ip_address = socket.gethostbyname(psc_dns_name)
        logger.info(f"DNS lookup successful. Resolved IP for {psc_dns_name} is {ip_address}.")
        return ip_address
    except socket.gaierror as e:
        logger.error(f"Failed to resolve DNS for {psc_dns_name}: {str(e)}")
        return None

# Task: Check the IP Address, Operating System, and Network Connectivity of the worker
def check_worker_info_and_connectivity():
    try:
        # Get the hostname and external IP address
        hostname = socket.gethostname()
        local_ip = get_external_ip()  # Use the external IP retrieval function
        
        # Get the operating system information
        os_name = platform.system()
        os_version = platform.release()

        # Log the worker info
        logger.info(f"Worker hostname: {hostname}")
        logger.info(f"Worker IP Address: {local_ip}")
        logger.info(f"Worker Operating System: {os_name} {os_version}")

         # Resolve DNS for the PSC endpoint
        psc_dns_name = "413f57e34f15.tslhv9t6fxpt.us-central1.sql.goog."  # Cloud SQL PSC DNS name
        resolved_ip = resolve_dns(psc_dns_name)

        if not resolved_ip:
            raise Exception(f"Unable to resolve DNS for {psc_dns_name}")
        
        # Check network connectivity to the Private Service Connect endpoint (redplace with actual IP)
        psc_ip = resolved_ip  # PSC endpoint IP address (replace if necessary)
        psc_port = 3307  # Cloud SQL Proxy uses 3307 internally

        # Attempt to connect to the PSC endpoint on port 3307
        if not check_network_connectivity(psc_ip, psc_port):
            raise Exception(f"Unable to connect to {psc_ip}:{psc_port}")

    except Exception as e:
        logger.error(f"Error retrieving worker information or testing network: {str(e)}")
        raise

# Define DAG
dag = DAG(
    dag_id='check_worker_ip_and_connectivity_dag',
    default_args=default_args,
    schedule_interval=None,
    catchup=False,
)

# Add the task in the DAG
check_worker_info_and_connectivity_task = PythonOperator(
    task_id='check_worker_info_and_connectivity',
    python_callable=check_worker_info_and_connectivity,
    dag=dag,
)

# Set task dependencies (if any other tasks are added)
check_worker_info_and_connectivity_task
