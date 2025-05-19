import os
import json
import logging
import psycopg2
import psycopg2.extras
from google.cloud import pubsub_v1
import signal
import sys

# Setup logger
logger = logging.getLogger("cdc_listener")
logger.setLevel(logging.DEBUG)
handler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

# 🔐 Graceful shutdown handler
def shutdown_handler(signum, frame):
    logger.info("🔻 CDC Job received shutdown signal. Exiting gracefully.")
    sys.exit(0)

signal.signal(signal.SIGTERM, shutdown_handler)

# Env/config
GCP_PROJECT = "terraform-workspace-455102"
PUBSUB_TOPIC = "my_topic"
SLOT_NAME = "my_slot"

DB_HOST = "10.10.1.10"
DB_PORT = 5432
DB_NAME = "my-database4"
DB_USER = "henry"
DB_PASSWORD = "hxi123"

def test_basic_query():
    try:
        logger.debug("Testing basic query with normal connection.")
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            sslmode="verify-ca",
            sslrootcert="/certs/server-ca.pem",
            sslcert="/certs/client-cert.pem",
            sslkey="/certs/client-key.pem"
        )
        cursor = conn.cursor()
        cursor.execute("SELECT version();")
        version = cursor.fetchone()
        logger.info(f"✅ Test query result: {version[0]}")
        cursor.close()
        conn.close()
    except Exception as e:
        logger.error(f"❌ Test query failed: {str(e)}")

def start_cdc():
    try:
        logger.debug("Connecting for logical replication.")
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            connection_factory=psycopg2.extras.LogicalReplicationConnection,
            sslmode="verify-ca",
            sslrootcert="/certs/server-ca.pem",
            sslcert="/certs/client-cert.pem",
            sslkey="/certs/client-key.pem"
        )
        cur = conn.cursor()

        publisher = pubsub_v1.PublisherClient()
        topic_path = publisher.topic_path(GCP_PROJECT, PUBSUB_TOPIC)

        def consume(msg):
            try:
                data = json.loads(msg.payload)
                logger.info("🔁 CDC Event:\n%s", json.dumps(data, indent=2))
                publisher.publish(topic_path, json.dumps(data).encode("utf-8"))
                msg.cursor.send_feedback(flush_lsn=msg.data_start)
            except Exception as e:
                logger.error(f"Error handling message: {e}")

        cur.start_replication(slot_name=SLOT_NAME, decode=True)
        cur.consume_stream(consume)
    except Exception as e:
        logger.error(f"❌ CDC failed to start: {str(e)}")

if __name__ == "__main__":
    test_basic_query()
    start_cdc()