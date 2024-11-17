license {
  accept = true
}

source {
  use "stdin" {}
}

transform {
  use "js" {
    script_path = env.JS_SCRIPT_PATH
    snowplow_mode = true
  }
}

target {
  use "kafka" {
    brokers    = "kafka:9093"
    topic_name = "snowplow-enriched-good"
  }
}
