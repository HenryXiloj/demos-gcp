from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.contrib.operators.gcp_sql_operator import CloudSqlQueryOperator
from google.cloud import storage

# Connection ID (as created in Airflow UI)
#airflow connections add 'proxy_postgres_tcp' \
#    --conn-type 'gcpcloudsql' \
#    --conn-login '<myuser>' \     
#    --Host: Cloud SQL instance    
#    --conn-password '<mypass>' \
#    --conn-schema 'my-database3' \
#    --conn-extra '{"project_id": "<myproject>", "location": "us-central1", "instance": "psc-instance", "database_type": "postgres", "use_proxy": true, "sql_proxy_use_tcp": true}'
CONNECTION_ID = 'proxy_postgres_tcp'

# Default arguments
default_args = {
    'start_date': datetime(2024, 10, 5),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Define the DAG
with DAG(
    dag_id='cloud_sql_proxy_airflow_config',
    default_args=default_args,
    description='A DAG that connects to the SQL server using a UI-created connection.',
    schedule_interval=timedelta(days=1),
    catchup=False,
) as dag:

    def print_client(ds, **kwargs):
        client = storage.Client()
        print(client)

    print_task = PythonOperator(
        task_id='print_the_client',
        python_callable=print_client,
        dag=dag,
    )

    sql_query = """
    SELECT version();  -- Sample SQL query to fetch the PostgreSQL version
    """

    # Cloud SQL task using the UI-created connection
    sql_task = CloudSqlQueryOperator(
        gcp_cloudsql_conn_id=CONNECTION_ID,
        task_id=f"example_gcp_sql_task_{CONNECTION_ID}",
        sql=sql_query,
        dag=dag
    )

    # Set task dependency
    print_task >> sql_task