variable "region" {
  default     = "us-east-1"
  description = "Choose region for your stack"
}

variable "vpc_cidr" {
  default     = "10.192.0.0/16"
  description = "Choose CIDR for your VPC"
}
