license {
  accept = true
}

source {
  use "stdin" {}
}

target {
  use "kafka" {
    brokers    = "kafka:9093"
    topic_name = "snowplow-enriched-good"
  }
}
