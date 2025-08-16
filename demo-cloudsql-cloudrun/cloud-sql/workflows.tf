resource "google_workflows_workflow" "batch1_workflow" {

  depends_on = [resource.google_service_account.cloudsql_service_account]

  name            = var.batch1_workflow
  region          = var.region
  description     = var.batch1_workflow
  service_account = google_service_account.cloudsql_service_account.id
  call_log_level  = "LOG_ALL_CALLS"
  labels = {
    env = "dev"
  }
  # user_env_vars = {
  #   url = "https://timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam"
  # }
  source_contents = <<-EOF
  # This is a sample workflow to test or replace with your source code.
  #
  # This workflow passes the region where the workflow is deployed
  # to the Wikipedia API and returns a list of related Wikipedia articles.
  # A region is retrieved from the GOOGLE_CLOUD_LOCATION system variable
  # unless you input your own search term; for example, {"searchTerm": "asia"}.
  main:
      params: [input]
      steps:
      - checkSearchTermInInput:
          switch:
              - condition: '$${"searchTerm" in input}'
                assign:
                  - searchTerm: '$${input.searchTerm}'
                next: readWikipedia
      - getLocation:
          call: sys.get_env
          args:
              name: GOOGLE_CLOUD_LOCATION
          result: location
      - setFromCallResult:
          assign:
              - searchTerm: '$${text.split(location, "-")[0]}'
      - readWikipedia:
          call: http.get
          args:
              url: 'https://en.wikipedia.org/w/api.php'
              query:
                  action: opensearch
                  search: '$${searchTerm}'
          result: wikiResult
      - returnOutput:
              return: '$${wikiResult.body[1]}'
EOF
}