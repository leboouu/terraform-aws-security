# modules/eks-addons/main.tf
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

# resource "helm_release" "metrics_server" {
#   name       = "metrics-server"
#   repository = "https://kubernetes-sigs.github.io/metrics-server/"
#   chart      = "metrics-server"
#   namespace  = "kube-system"
#   version    = "3.11.0"
#   
#   set {
#     name  = "args[0]"
#     value = "--kubelet-insecure-tls"
#   }
# }

# resource "helm_release" "cluster_autoscaler" {
#   name       = "cluster-autoscaler"
#   repository = "https://kubernetes.github.io/autoscaler"
#   chart      = "cluster-autoscaler"
#   namespace  = "kube-system"
#   
#   set {
#     name  = "autoDiscovery.clusterName"
#     value = var.cluster_name
#   }
#   
#   set {
#     name  = "awsRegion"
#     value = var.aws_region
#   }
# }
