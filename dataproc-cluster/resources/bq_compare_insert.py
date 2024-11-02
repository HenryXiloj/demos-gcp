from pyspark.sql import SparkSession
from pyspark.sql.functions import col
import sys

# Capture the bucket name from the first argument
project_id = sys.argv[1]

# Initialize Spark session with BigQuery support
spark = SparkSession.builder \
    .appName("BigQueryIncrementalInsert") \
    .config("spark.jars.packages", "com.google.cloud.spark:spark-bigquery-with-dependencies_2.12:0.29.0") \
    .getOrCreate()

# Define the BigQuery table paths
table1 = f"{project_id}.example_dataset.table1"
table2 = f"{project_id}.example_dataset.table2"
table3 = f"{project_id}.example_dataset.table3"

# Define the temporary GCS bucket
temporary_bucket = f"dataproc-staging-{project_id}"  # Ensure this bucket exists

# Load data from table1 and table2
df1 = spark.read.format("bigquery").option("table", table1).load()
df2 = spark.read.format("bigquery").option("table", table2).load()

# Select the ID column to identify new records
id_column = "id"

# Identify new records in table1 that are not in table2
new_records = df1.join(df2, on=id_column, how="left_anti")

# If this is the first run, `table2` may be empty, so new_records would be all of df1
if new_records.count() == 0:
    new_records = df1  # All records are new for the first run

# Insert new records into table2 (cumulative storage)
new_records.write \
    .format("bigquery") \
    .option("table", table2) \
    .option("temporaryGcsBucket", temporary_bucket) \
    .mode("append") \
    .save()

# Insert the same new records into table3 (latest batch storage with accumulation)
new_records.write \
    .format("bigquery") \
    .option("table", table3) \
    .option("temporaryGcsBucket", temporary_bucket) \
    .mode("append") \
    .save()

print("Incremental data insertion complete.")

# Stop Spark session
spark.stop()
