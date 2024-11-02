resource "google_dataproc_job" "pyspark_bq" {
  depends_on = [google_dataproc_cluster.mycluster,
  google_storage_bucket_object.scripts]
  region       = google_dataproc_cluster.mycluster.region
  force_delete = true
  placement {
    cluster_name = google_dataproc_cluster.mycluster.name
  }

  labels = {
    job = "pyspark_bq"
  }
  pyspark_config {
    main_python_file_uri = "gs://${google_storage_bucket.static.name}/bq_compare_insert.py"
    properties = {
      "spark.logConf" = "true"
    }
    # Pass the project_id as an argument
    args = [var.project_id]
  }
}

resource "google_dataproc_job" "hadoop" {
  depends_on = [google_dataproc_cluster.mycluster,
  google_storage_bucket_object.scripts]
  region = google_dataproc_cluster.mycluster.region
  placement {
    cluster_name = google_dataproc_cluster.mycluster.name
  }
  labels = {
    job = "hadoop"
  }

  hadoop_config {
    main_jar_file_uri = "file:///usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar"
    args = [
      "wordcount",
      "file:///usr/lib/spark/NOTICE",
      "gs://${google_dataproc_cluster.mycluster.cluster_config[0].bucket}/hadoopjob_output",
    ]
  }
}

resource "google_dataproc_job" "spark_random_numbers" {
  depends_on = [google_dataproc_cluster.mycluster,
  google_storage_bucket_object.scripts]
  region = google_dataproc_cluster.mycluster.region
  placement {
    cluster_name = google_dataproc_cluster.mycluster.name
  }
  labels = {
    job = "spark_random_numbers"
  }
  pyspark_config {
    main_python_file_uri = "gs://${google_storage_bucket.static.name}/spark_random_numbers.py"

    # Pass the bucket name as an argument
    args = [google_storage_bucket.static.name]
  }
}

# Submit a hive job to the cluster
resource "google_dataproc_job" "hive" {
  depends_on = [google_dataproc_cluster.mycluster,
  google_storage_bucket_object.scripts]
  region = google_dataproc_cluster.mycluster.region
  placement {
    cluster_name = google_dataproc_cluster.mycluster.name
  }
  labels = {
    job = "hive"
  }
  hive_config {
    query_list = [
      "DROP TABLE IF EXISTS dprocjob_test",
      "CREATE EXTERNAL TABLE dprocjob_test(bar int) LOCATION 'gs://${google_dataproc_cluster.mycluster.cluster_config[0].bucket}/hive_dprocjob_test/'",
      "SELECT * FROM dprocjob_test WHERE bar > 2",
    ]
  }
}

# Submit a pig job to the cluster
resource "google_dataproc_job" "pig" {
  depends_on = [google_dataproc_cluster.mycluster,
  google_storage_bucket_object.scripts]
  region = google_dataproc_cluster.mycluster.region
  placement {
    cluster_name = google_dataproc_cluster.mycluster.name
  }
  labels = {
    job = "pig"
  }
  pig_config {
    query_list = [
      "LNS = LOAD 'file:///usr/lib/pig/LICENSE.txt ' AS (line)",
      "WORDS = FOREACH LNS GENERATE FLATTEN(TOKENIZE(line)) AS word",
      "GROUPS = GROUP WORDS BY word",
      "WORD_COUNTS = FOREACH GROUPS GENERATE group, COUNT(WORDS)",
      "DUMP WORD_COUNTS",
    ]
  }
}

# Submit a spark SQL job to the cluster
resource "google_dataproc_job" "sparksql" {
  depends_on = [google_dataproc_cluster.mycluster,
  google_storage_bucket_object.scripts]
  region = google_dataproc_cluster.mycluster.region
  placement {
    cluster_name = google_dataproc_cluster.mycluster.name
  }
  labels = {
    job = "sparksql"
  }
  sparksql_config {
    query_list = [
      "DROP TABLE IF EXISTS dprocjob_test",
      "CREATE TABLE dprocjob_test(bar int)",
      "SELECT * FROM dprocjob_test WHERE bar > 2",
    ]
  }
}
