license {
  accept = env("ACCEPT_LICENSE")
}

source {
  use "kinesis" {
    stream_name         = "enriched-good"
    region              = "eu-west-2"
    app_name            = "snowbridge"
    custom_aws_endpoint = "http://localhost.localstack.cloud:4566"
  }
}

transform {
  use "js" {
    script_path   = env.JS_SCRIPT_PATH
    snowplow_mode = true
  }
}

target {
  use "kafka" {
    brokers    = "kafka:9093"
    topic_name = "snowplow-enriched-good"
  }
}

failure_target {
  use "stdout" {}
}

log_level = "debug"

disable_telemetry = true
