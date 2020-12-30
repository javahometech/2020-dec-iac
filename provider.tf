# we have to say terraform which cloud we are using

provider "aws" {
  region = var.region
}