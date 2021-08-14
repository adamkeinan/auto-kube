locals {
  cluster_name                  = var.cluster_name
  k8s_service_account_namespace = var.namespace
  k8s_service_account_name      = "cluster-autoscaler-aws-cluster-autoscaler-chart"
}