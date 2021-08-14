
resource "aws_eks_cluster" "vpc-cni"{
    name        = "vpc_cni"
    role_arn    = aws_iam_role.terracluster.name
}

resource "aws_eks_addon" "vpc_cni" {
    cluster_name = aws_eks_cluster.terracluster.name
    addon_name   = "vpc-cni"
}

resource "aws_eks_identity_provider_config" "eks_cluster" {
# IMPORT :: $ terraform import aws_eks_identity_provider_config.my_identity_provider_config my_cluster:my_identity_provider_config    
  cluster_name                    = var.cluster_name
  create                          = "60m"
  delete                          = "2h"

  oidc {
    client_id                     = "your client_id"
    identity_provider_config_name = "example"
    issuer_url                    = "your issuer_url"
    group_prefix                  = 
    username_prefix               =

  }
}