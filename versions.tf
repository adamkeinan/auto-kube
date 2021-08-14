terraform {
  required_version = "~> 0.14"
  
  backend "local" {
    path = "/lab/terraform/terraform.tfstate"
  }

  backend "remote" {
    hostname = "app.terraform.io"
    organization = "paladin"
    workspaces {
      name = "auto-kube"
    }
  }

  backend "swift" {
    container         = "terraform-state"
    archive_container = "terraform-state-archive"
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      "version = ">= 3.22.0"
    },
    local = ">= 1.4"
    random = ">= 2.1"
    kubernetes = "~> 1.18"
    helm = "~> 2.1.2"
  }
}