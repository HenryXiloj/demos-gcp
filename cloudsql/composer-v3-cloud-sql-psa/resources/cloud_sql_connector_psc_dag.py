# Import dependencies 
from airflow.utils.dates import days_ago
from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import PythonOperator
from google.cloud.sql.connector import Connector
import logging

# Setup logger
logger = logging.getLogger("test_cloudsql")
logger.setLevel(logging.DEBUG)
handler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

# Cloud SQL connection variables
IP_CONNECTION = '10.113.0.3'
DB_NAME = 'my-database2'
DB_USER = 'henry'
DB_PASSWORD = 'hxi123'
DB_PORT = 5432


# Define default_args for DAG
default_args = {
    'owner': 'airflow',
    'start_date': days_ago(1),
}

# Define DAG
dag = DAG(
    dag_id='cloud_sql_connector_psc_dag',
    default_args=default_args,
    schedule_interval=None,  # You can set your own schedule here
    catchup=False,
)

# Cloud SQL Connector instance
connector = Connector()

def get_connection():
    import psycopg2
    conn = psycopg2.connect(
        host=IP_CONNECTION,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )
    logger.info("Successfully connected to the Cloud SQL instance.")
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT version();")
        result = cursor.fetchone()
        logger.info(f"Query successful, result: {result}")
    except Exception as e:
        logger.error(f"Error executing SQL query: {str(e)}")
        raise
    finally:
        cursor.close()
        conn.close()

# Dummy Start task
start = DummyOperator(
    task_id='start',
    dag=dag,
)

# Python operator task to query Cloud SQL PostgreSQL
python_task = PythonOperator(
    task_id='python_task',
    python_callable=get_connection,
    dag=dag
)

# Setting up Task dependencies using Airflow standard notations        
start >> python_task
