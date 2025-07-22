
terraform {
  required_version = ">= 0.12"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.37.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.84.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.4"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.17.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.1.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.1"
    }
  }
}

