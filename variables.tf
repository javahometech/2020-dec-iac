variable "region" {
  default     = "us-east-1"
  description = "Choose region for your stack"
}

variable "vpc_cidr" {
  default     = "10.192.0.0/16"
  description = "Choose CIDR for your VPC"
}

variable "ami_ids" {
  type = map(any)
  default = {
    ap-south-1 = "ami-04b1ddd35fd71475a",
    us-east-1  = "ami-0be2609ba883822ec"

  }
}

variable "s3_bucket_arn" {
  default = "arn:aws:s3:::javahome2020.dev.in.k8s"
}
