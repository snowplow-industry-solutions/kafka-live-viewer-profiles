variable "instance_type" {
  description = "Instance type to build and run the containers s-tracker, s-viewer and s-backend"
  type        = string
  default     = "t3.medium"
}
