# providers.tf ou versions.tf

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    
    # CORRECT: cloudflare/cloudflare
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
    
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
  
  backend "s3" {
    bucket = "amzn-s3-terraform-b"
    key    = "terraform.tfstate"
    region = "us-east-2"
    encrypt = true
  }
}

# Configuration du provider AWS
provider "aws" {
  region = var.aws_region
}

# Configuration du provider Cloudflare
provider "cloudflare" {
  api_token = var.cloudflare_api_token
  # Ou utilisez:
  # email   = var.cloudflare_email
  # api_key = var.cloudflare_api_key
}

# Configuration du provider Kubernetes
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Configuration du provider Helm
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}