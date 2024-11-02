from pyspark.sql import SparkSession
import sys

# Initialize Spark session
spark = SparkSession.builder.appName("RandomNumbers").getOrCreate()

# Capture the bucket name from the first argument
bucket_name = sys.argv[1]

# Generate a DataFrame with random numbers and convert the column to STRING
df = spark.range(1000).toDF("number").selectExpr("CAST(number AS STRING) as number")

# Write the DataFrame to the specified bucket
df.write.text(f"gs://{bucket_name}/random_numbers.txt")
