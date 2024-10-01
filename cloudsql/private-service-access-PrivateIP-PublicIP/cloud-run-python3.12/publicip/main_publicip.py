import os
from flask import Flask
from google.cloud.sql.connector import Connector
import logging

app = Flask(__name__)

# Setup logger
logger = logging.getLogger("test_cloudsql")
logger.setLevel(logging.DEBUG)
handler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

# Initialize the connector
logger.debug("Initializing Cloud SQL connector.")
connector = Connector()

def get_connection():
    try:
        logger.debug("Attempting to connect to Cloud SQL PostgreSQL instance.")
        
        # Create a connection to the Cloud SQL PostgreSQL instance using PUBLIC
        conn = connector.connect(
            "<PROJECT-ID>:<REGION>:main-instance",  # Cloud SQL instance name
            "pg8000",
            user="<user>",
            password="<passoword>",
            db="<my-database>",
            ip_type="PUBLIC"
        )
        logger.info("Successfully connected to the Cloud SQL instance.")
        return conn
    except Exception as e:
        logger.error(f"Failed to connect to the Cloud SQL instance: {str(e)}")
        raise

# Example: Query the database
def query_db():
    try:
        conn = get_connection()
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
        return result
    except Exception as e:
        logger.error(f"Error during database query: {str(e)}")
        raise

@app.route("/")
def hello_world():
    """Example Hello World route."""
    name = os.environ.get("NAME", "World")
    logger.debug(f"Handling request for '/' route, NAME={name}")
    return f"Hello {name}!"

@app.route("/db-version")
def db_version():
    """Route to query and return database version."""
    try:
        logger.debug("Handling request for '/db-version' route.")
        version = query_db()
        return f"Database version: {version[0]}"
    except Exception as e:
        logger.error(f"Error while handling '/db-version' request: {str(e)}")
        return f"Error querying database: {str(e)}", 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    logger.debug(f"Starting Flask application on port {port}.")
    app.run(debug=True, host="0.0.0.0", port=port)
