
terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    local = {
      source = "hashicorp/local"
    }
    mysql = {
      source = "terraform-providers/mysql"
    }
    random = {
      source = "hashicorp/random"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}
