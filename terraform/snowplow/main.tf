resource "aws_kinesis_stream" "collector_good" {
  name        = "collector-good"
  shard_count = 1
}

resource "aws_kinesis_stream" "collector_bad" {
  name        = "collector-bad"
  shard_count = 1
}

resource "aws_kinesis_stream" "enriched_good" {
  name        = "enriched-good"
  shard_count = 1
}

resource "aws_kinesis_stream" "enriched_bad" {
  name        = "enriched-bad"
  shard_count = 1
}

resource "aws_kinesis_stream" "enriched_incomplete" {
  name        = "enriched-incomplete"
  shard_count = 1
}

resource "aws_kinesis_stream" "pii" {
  name        = "pii"
  shard_count = 1
}

resource "aws_dynamodb_table" "snowbridge_clients" {
  name         = local.collector-clients-table
  hash_key     = "ID"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "ID"
    type = "S"
  }
}

resource "aws_dynamodb_table" "snowbridge_checkpoints" {
  name         = local.collector-chekpoints-table
  hash_key     = "Shard"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "Shard"
    type = "S"
  }
}

resource "aws_dynamodb_table" "snowbridge_metadata" {
  name         = local.collector-metadata-table
  hash_key     = "Key"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "Key"
    type = "S"
  }
}

resource "aws_dynamodb_table" "snowplow-enrich-kinesis" {
  name         = "snowplow-enrich-kinesis"
  hash_key     = "Key"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "Key"
    type = "S"
  }
}
