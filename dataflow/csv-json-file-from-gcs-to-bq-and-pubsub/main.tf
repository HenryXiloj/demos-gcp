resource "google_storage_bucket" "data_bucket" {
  depends_on    = [google_project_iam_member.member_role]
  name          = "${var.project_id}-data-bucket"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket_object" "temp_dir_placeholder" {
  name    = "temp-dir/" # trailing slash indicates a folder
  bucket  = google_storage_bucket.data_bucket.name
  content = " " # Single space instead of empty string
}

resource "google_storage_bucket_object" "customers_csv" {
  name   = "customers.csv"
  bucket = google_storage_bucket.data_bucket.name
  source = "resources/customers.csv"
}

resource "google_storage_bucket_object" "customers_json" {
  name   = "customers.json"
  bucket = google_storage_bucket.data_bucket.name
  source = "resources/customers.json"
}

resource "google_storage_bucket_object" "customers_script" {
  name   = "customers.js"
  bucket = google_storage_bucket.data_bucket.name
  source = "resources/customers.js"
}

resource "google_storage_bucket_object" "customers_schema" {
  name   = "bq_customers_schema.json"
  bucket = google_storage_bucket.data_bucket.name
  source = "resources/bq_customers_schema.json"
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id = "sample_dataset"
  location   = var.region
}

resource "google_bigquery_table" "customer_table" {
  depends_on          = [google_project_iam_member.member_role]
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = "customer_table"
  deletion_protection = false
  schema = jsonencode([
    { "name" : "customer_id", "type" : "INTEGER" },
    { "name" : "first_name", "type" : "STRING" },
    { "name" : "last_name", "type" : "STRING" },
    { "name" : "email", "type" : "STRING" }
  ])
}


###########Text Files on Cloud Storage to BigQuery with BigQuery Storage API support  ######
############CSV file########################################################################
############GCS_Text_to_BigQuery_Flex JS Transform Supported ###############################
/*
gcloud dataflow flex-template run first-job \
  --template-file-gcs-location "gs://dataflow-templates-us-central1/latest/flex/GCS_Text_to_BigQuery_Flex" \
  --region "us-central1" \
  --additional-user-labels "" \
  --parameters \
    inputFilePattern="gs://${var.project_id}-data-bucket/customers.csv",\
    JSONPath="gs://${var.project_id}-data-bucket/bq_customers_schema.json",\
    outputTable="${var.project_id}:ds1.completed_orders",\
    javascriptTextTransformGcsPath="gs://${var.project_id}-data-bucket/customers.js",\
    javascriptTextTransformFunctionName="transform",\
    bigQueryLoadingTemporaryDirectory="gs://${var.project_id}-data-bucket/temp-dir",\
    useStorageWriteApi=false

*/
resource "google_dataflow_flex_template_job" "first_job" {

  depends_on = [
    google_storage_bucket_object.customers_csv,
    google_storage_bucket_object.customers_script,
    google_storage_bucket_object.customers_schema,
    google_bigquery_table.customer_table,
    google_storage_bucket.data_bucket
  ]

  name                    = "first-job"
  region                  = var.region
  project                 = var.project_id
  provider                = google-beta
  container_spec_gcs_path = "gs://dataflow-templates-us-central1/latest/flex/GCS_Text_to_BigQuery_Flex"

  parameters = {
    inputFilePattern                    = "gs://${var.project_id}-data-bucket/customers.csv"
    JSONPath                            = "gs://${var.project_id}-data-bucket/bq_customers_schema.json"
    outputTable                         = "${var.project_id}:${google_bigquery_dataset.dataset.dataset_id}.${google_bigquery_table.customer_table.table_id}"
    javascriptTextTransformGcsPath      = "gs://${var.project_id}-data-bucket/customers.js"
    javascriptTextTransformFunctionName = "transform"
    bigQueryLoadingTemporaryDirectory   = "gs://${var.project_id}-data-bucket/temp-dir"
    useStorageWriteApi                  = "false"
  }

  labels = {
    # Add any labels you want here. You mentioned `--additional-user-labels ""`, so leaving empty
  }

  lifecycle {
    ignore_changes = [parameters["bigQueryLoadingTemporaryDirectory"]]
  }
}

###########Text Files on Cloud Storage to BigQuery with BigQuery Storage API & Python UDF support ######
############NDJSON (JSON lines)#########################################################################
###########GCS_Text_to_BigQuery_Xlang###################################################################
/*
gcloud dataflow flex-template run second-job \
  --template-file-gcs-location "gs://dataflow-templates-us-central1/latest/flex/GCS_Text_to_BigQuery_Xlang" \
  --region "us-central1" \
  --additional-user-labels "" \
  --parameters \
    inputFilePattern="gs://${var.project_id}-data-bucket/customers.json",\
    JSONPath="gs://${var.project_id}-data-bucket/bq_customers_schema.json",\
    outputTable="${var.project_id}:sample_dataset.customer_table",\
    bigQueryLoadingTemporaryDirectory="gs://${var.project_id}-data-bucket",\
    useStorageWriteApi=false
*/
resource "google_dataflow_flex_template_job" "second_job" {
  name     = "second-job"
  region   = var.region
  project  = var.project_id
  provider = google-beta

  container_spec_gcs_path = "gs://dataflow-templates-us-central1/latest/flex/GCS_Text_to_BigQuery_Xlang"

  parameters = {
    inputFilePattern                  = "gs://${var.project_id}-data-bucket/customers.json"
    JSONPath                          = "gs://${var.project_id}-data-bucket/bq_customers_schema.json"
    outputTable                       = "${var.project_id}:${google_bigquery_dataset.dataset.dataset_id}.${google_bigquery_table.customer_table.table_id}"
    bigQueryLoadingTemporaryDirectory = "gs://${var.project_id}-data-bucket"
    useStorageWriteApi                = "false"
  }

  labels = {
    job_type = "ndjson-xlang"
  }

  depends_on = [
    google_bigquery_table.customer_table,
    google_storage_bucket_object.customers_json,
    google_storage_bucket_object.customers_schema,
    google_storage_bucket.data_bucket
  ]
}


########### Text Files on Cloud Storage to BigQuery  ######
############NDJSON (JSON lines)#########################################################################
/*
gcloud dataflow jobs run third-job \
  --gcs-location "gs://dataflow-templates-us-central1/latest/GCS_Text_to_BigQuery" \
  --region "us-central1" \
  --num-workers 2 \
  --staging-location "gs://${var.project_id}-data-bucket/temp-dir" \
  --additional-experiments "use_runner_v2" \
  --parameters \
    inputFilePattern="gs://${var.project_id}-data-bucket/customers.json",\
    JSONPath="gs://${var.project_id}-data-bucket/bq_customers_schema.json",\
    outputTable="${var.project_id}:sample_dataset.customer_table",\
    bigQueryLoadingTemporaryDirectory="gs://${var.project_id}-data-bucket"

*/
resource "google_dataflow_job" "third_job" {
  name              = "third-job"
  template_gcs_path = "gs://dataflow-templates-us-central1/latest/GCS_Text_to_BigQuery"
  region            = var.region
  project           = var.project_id

  on_delete = "cancel"

  parameters = {
    inputFilePattern                  = "gs://${var.project_id}-data-bucket/customers.json"
    JSONPath                          = "gs://${var.project_id}-data-bucket/bq_customers_schema.json"
    outputTable                       = "${var.project_id}:${google_bigquery_dataset.dataset.dataset_id}.${google_bigquery_table.customer_table.table_id}"
    bigQueryLoadingTemporaryDirectory = "gs://${var.project_id}-data-bucket"
  }

  max_workers            = 2
  temp_gcs_location      = "gs://${var.project_id}-data-bucket/temp-dir"
  additional_experiments = ["use_runner_v2"]

  depends_on = [
    google_bigquery_table.customer_table,
    google_storage_bucket_object.customers_json,
    google_storage_bucket_object.customers_schema,
    google_storage_bucket.data_bucket,
    google_storage_bucket_object.temp_dir_placeholder
  ]

}


########### Text Files on Cloud Storage to Pub Sub  ######
############NDJSON (JSON lines)#########################################################################
/*
gcloud dataflow jobs run fourth-job \
  --gcs-location "gs://dataflow-templates-us-central1/latest/GCS_Text_to_Cloud_PubSub" \
  --region "us-central1" \
  --num-workers 2 \
  --staging-location "gs://${var.project_id}-data-bucket/temp-dir/" \
  --additional-experiments "use_runner_v2" \
  --parameters \
    inputFilePattern="gs://${var.project_id}-data-bucket/customers.json",\
    outputTopic="projects/${var.project_id}/topics/dataflow-job"
*/

resource "google_pubsub_topic" "topic" {
  name = "dataflow-job"
}

resource "google_dataflow_job" "fourth_job" {
  name              = "fourth-job"
  template_gcs_path = "gs://dataflow-templates-us-central1/latest/GCS_Text_to_Cloud_PubSub"
  region            = var.region
  project           = var.project_id

  on_delete = "cancel"

  parameters = {
    inputFilePattern = "gs://${var.project_id}-data-bucket/customers.json"
    outputTopic      = "projects/${var.project_id}/topics/${google_pubsub_topic.topic.name}"
  }

  max_workers            = 2
  temp_gcs_location      = "gs://${var.project_id}-data-bucket/temp-dir"
  additional_experiments = ["use_runner_v2"]

  depends_on = [
    google_storage_bucket_object.customers_json,
    google_storage_bucket_object.customers_schema,
    google_pubsub_topic.topic,
    google_storage_bucket.data_bucket,
    google_storage_bucket_object.temp_dir_placeholder
  ]

}
