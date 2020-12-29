
locals {
  ws = terraform.workspace == "default" ? "dev" : terraform.workspace
}