# Import dependencies 
import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from google.cloud.sql.connector import Connector
import logging
#import requests  # Add requests for GET request

# Setup logger
logger = logging.getLogger("test_cloudsql")
logger.setLevel(logging.DEBUG)
handler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

# Python logic to derive yesterday's date
yesterday = datetime.combine(datetime.today() - timedelta(1), datetime.min.time())

# Default arguments
default_args = {
    'start_date': yesterday,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

connector = Connector()

def get_connection():
    try:
        logger.debug("Attempting to connect to Cloud SQL PostgreSQL instance.")
        
        # Create a connection to the Cloud SQL PostgreSQL instance using PSC
        conn = connector.connect(
            "<my-project>:us-central1:psc-instance",  # Cloud SQL instance name
            "pg8000",
            user="<myuser>",
            password="<mypass>",
            db="my-database3",
            ip_type="psc"
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
            logger.debug("Closed the database cursor.")
        
        conn.close()  # Close the connection after cursor
        logger.debug("Closed the database connection.")

    except Exception as e:
        logger.error(f"Failed to connect to the Cloud SQL instance: {str(e)}")
        raise

# DAG definition
with DAG(dag_id='gcs_to_cloud_sql_psc_test',
         catchup=False,
         schedule_interval=timedelta(days=1),
         default_args=default_args
         ) as dag:

    # Dummy Start task
    start = DummyOperator(
        task_id='start',
        dag=dag,
    )

    # Bash operator task
    bash_task = BashOperator(
        task_id='bash_task',
        bash_command="date;echo 'Hey I am bash operator'",
    )

    # Python operator task to query Cloud SQL PostgreSQL
    python_task = PythonOperator(
        task_id='python_task',
        python_callable=get_connection,
        #execution_timeout=timedelta(seconds=600),
        dag=dag
    )


    # Dummy end task
    end = DummyOperator(
        task_id='end',
        dag=dag,
    )

# Setting up Task dependencies using Airflow standard notations        
start >> bash_task  >> python_task >> end
