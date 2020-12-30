
locals {
  ws  = terraform.workspace == "default" ? "dev" : terraform.workspace
  azs = data.aws_availability_zones.available.names
}