variable "instance_type" {
  description = "Instance type to build and run the containers s-tracker, s-viewer and s-backend"
  type        = string
  default     = "t3.large"
}

variable "table_name" {
  description = "Remote DynamoDB table name"
  type        = string
  default     = "video_events"
}
