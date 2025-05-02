import os
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.io.gcp.bigquery import WriteToBigQuery
from apache_beam import pvalue

class MyOptions(PipelineOptions):
    @classmethod
    def _add_argparse_args(cls, parser):
        parser.add_argument('--output_table', required=True)
        parser.add_argument('--failed_table', required=True)
        parser.add_argument('--gcs_ssl_path', required=True)
        parser.add_argument('--psc_host', required=True)
        parser.add_argument('--db_name', required=True)
        parser.add_argument('--db_user', required=True)
        parser.add_argument('--db_pass', required=True)


class ReadPostgresFn(beam.DoFn):
    def __init__(self, gcs_ssl_path, jdbc_url, db_user, db_pass):
        self.gcs_ssl_path = gcs_ssl_path
        self.jdbc_url = jdbc_url
        self.db_user = db_user
        self.db_pass = db_pass

    def setup(self):
        import tempfile
        from google.cloud import storage

        tmp_dir = tempfile.gettempdir()
        client = storage.Client()
        path = self.gcs_ssl_path.replace("gs://", "")
        bucket_name, prefix = path.split("/", 1) if "/" in path else (path, "")

        for fname in ['server-ca.pem', 'client-cert.pem', 'client-key.pem']:
            local_path = os.path.join(tmp_dir, fname)
            blob_path = f"{prefix}/{fname}" if prefix else fname
            blob = client.bucket(bucket_name).blob(blob_path)
            blob.download_to_filename(local_path)

            # 🔐 Ensure strict permissions
            if fname == 'client-key.pem':
                os.chmod(local_path, 0o600)

    def process(self, element):
        import psycopg2
        import tempfile
        from datetime import datetime
        from apache_beam import pvalue

        conn = None
        try:
            conn = psycopg2.connect(
                self.jdbc_url,
                user=self.db_user,
                password=self.db_pass,
                sslmode='verify-ca',
                sslrootcert=os.path.join(tempfile.gettempdir(), 'server-ca.pem'),
                sslcert=os.path.join(tempfile.gettempdir(), 'client-cert.pem'),
                sslkey=os.path.join(tempfile.gettempdir(), 'client-key.pem')
            )

            cur = conn.cursor()
            cur.execute("""
                SELECT customer_id, first_name, last_name, email, phone, address, registration_date, loyalty_points 
                FROM public.customers
            """)
            for row in cur.fetchall():
                yield {
                    "customer_id": int(row[0]) if row[0] is not None else 0,
                    "first_name": row[1],
                    "last_name": row[2],
                    "email": row[3],
                    "phone": row[4],
                    "address": row[5],
                    "registration_date": row[6].strftime('%Y-%m-%d') if row[6] else None,
                    "loyalty_points": int(row[7])
                }

        except Exception as e:
            yield pvalue.TaggedOutput('errors', {
                "error_message": str(e),
                "timestamp": datetime.utcnow().isoformat(),
                "original_data": str(element)
            })
        finally:
            if conn:
                conn.close()


def run():
    options = MyOptions()
    jdbc_url = f"host={options.psc_host} port=5432 dbname={options.db_name}"

    with beam.Pipeline(options=options) as pipeline:
        records = (
            pipeline
            | "Trigger" >> beam.Create([None])
            | "Read from PostgreSQL" >> beam.ParDo(
                ReadPostgresFn(
                    gcs_ssl_path=options.gcs_ssl_path,
                    jdbc_url=jdbc_url,
                    db_user=options.db_user,
                    db_pass=options.db_pass
                )
            ).with_outputs('errors', main='success')
        )

        records.success | "Write to BigQuery" >> WriteToBigQuery(
            table=options.output_table,
            schema=(
                "customer_id:INTEGER,"
                "first_name:STRING,"
                "last_name:STRING,"
                "email:STRING,"
                "phone:STRING,"
                "address:STRING,"
                "registration_date:DATE,"
                "loyalty_points:INTEGER"
            ),
            write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
            create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED
        )

        records.errors | "Write Errors to BigQuery" >> WriteToBigQuery(
            table=options.failed_table,
            schema="error_message:STRING,timestamp:TIMESTAMP,original_data:STRING",
            write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
            create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED
        )


if __name__ == "__main__":
    run()
