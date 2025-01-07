license {
  accept = env("ACCEPT_LICENSE")
}

source {
  use "kinesis" {
    stream_name         = "enriched-good"
    region              = env("AWS_REGION")
    app_name            = "snowbridge"
    custom_aws_endpoint = "http://localhost.localstack.cloud:4566"
  }
}

transform {
  use "spEnrichedFilter" {
    atomic_field  = "event"
    regex         = "^unstruct$"
    filter_action = "keep"
  }
}

transform {
  use "spEnrichedFilter" {
    atomic_field  = "event_name"
    regex         = "^(play|pause|ping|end|ad_break.*)_event$"
    filter_action = "keep"
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
    brokers    = "kafka:9094"
    topic_name = "snowplow-enriched-good"
  }
}

failure_target {
  use "stdout" {}
}

log_level = "debug"

disable_telemetry = true
