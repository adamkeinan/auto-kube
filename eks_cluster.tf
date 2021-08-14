data "aws_caller_identity" "current" {
  account_id = var.aws_account_id
}

data "aws_eks_cluster" "cluster" {
    name     = module.eks.cluster_id
    role_arn = aws_iam_role.eks_cluster.arn

    # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
    # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
    depends_on = [
        aws_iam_role_policy_attachment.terracluster-AmazonEKSClusterPolicy,
        aws_iam_role_policy_attachment.terracluster-AmazonEKSVPCResourceController,
    ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "terraform_remote_state" "swift_backend" {
  backend = "swift"
  config = {
    container         = "terraform_state"
    archive_container = "terraform_state-archive"
    # auth_url        = var.swift_auth_url
    # cloud
    region_name       = "eu-west-1"
    state_name        = "tfstate.tf"
    # user_name       = var.tf_user_name
    allow_reauth      = true
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

locals {
  cluster_name = "test-refresh-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

data "aws_availability_zones" "available" {
  names = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

locals {
  cluster_name = "terracluster-${random_string.suffix.result}"
}

data "aws_iam_policy_document" "aws_node_termination_handler" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeTags",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:CompleteLifecycleAction",
    ]
    resources = module.eks.workers_asg_arns
  }
  statement {
    effect = "Allow"
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage"
    ]
    resources = [
      module.aws_node_termination_handler_sqs.sqs_queue_arn
    ]
  }
}

resource "aws_iam_policy" "aws_node_termination_handler" {
  name   = "${var.cluster_name}-aws-node-termination-handler"
  policy = data.aws_iam_policy_document.aws_node_termination_handler.json
}

data "aws_iam_policy_document" "aws_node_termination_handler_events" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "sqs.amazonaws.com",
      ]
    }
    actions = [
      "sqs:SendMessage",
    ]
    resources = [
      "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${var.cluster_name}",
    ]
  }
}

module "aws_node_termination_handler_sqs" {
  source                    = "terraform-aws-modules/sqs/aws"
  version                   = "~> 3.0.0"
  name                      = local.cluster_name
  message_retention_seconds = 300
  policy                    = data.aws_iam_policy_document.aws_node_termination_handler_events.json
}

resource "aws_cloudwatch_event_rule" "aws_node_termination_handler_asg" {
  name        = "${var.cluster_name}-asg-termination"
  description = "Node termination event rule"
  event_pattern = jsonencode(
    {
      "source" : [
        "aws.autoscaling"
      ],
      "detail-type" : [
        "EC2 Instance-terminate Lifecycle Action"
      ]
      "resources" : module.eks.workers_asg_arns
    }
  )
}

resource "aws_cloudwatch_event_target" "aws_node_termination_handler_asg" {
  target_id = "${var.cluster_name}-asg-termination"
  rule      = aws_cloudwatch_event_rule.aws_node_termination_handler_asg.name
  arn       = module.aws_node_termination_handler_sqs.sqs_queue_arn
}

resource "aws_cloudwatch_event_rule" "aws_node_termination_handler_spot" {
  name        = "${var.cluster_name}-spot-termination"
  description = "Node termination event rule"
  event_pattern = jsonencode(
    {
      "source" : [
        "aws.ec2"
      ],
      "detail-type" : [
        "EC2 Spot Instance Interruption Warning"
      ]
      "resources" : module.eks.workers_asg_arns
    }
  )
}

resource "aws_cloudwatch_event_target" "aws_node_termination_handler_spot" {
  target_id = "${var.cluster_name}-spot-termination"
  rule      = aws_cloudwatch_event_rule.aws_node_termination_handler_spot.name
  arn       = module.aws_node_termination_handler_sqs.sqs_queue_arn
}

module "aws_node_termination_handler_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.1.0"
  create_role                   = true
  role_description              = "IRSA role for ANTH, cluster ${local.cluster_name}"
  role_name_prefix              = local.cluster_name
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.aws_node_termination_handler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:${var.serviceaccount}"]
}

resource "helm_release" "aws_node_termination_handler" {
  depends_on = [
    module.eks
  ]

  name             = "aws-node-termination-handler"
  namespace        = var.namespace
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-node-termination-handler"
  version          = var.aws_node_termination_handler_chart_version
  create_namespace = true

  set {
    name  = "awsRegion"
    value = var.region
  }
  set {
    name  = "serviceAccount.name"
    value = var.serviceaccount
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws_node_termination_handler_role.iam_role_arn
    type  = "string"
  }
  set {
    name  = "enableSqsTerminationDraining"
    value = "true"
  }
  set {
    name  = "enableSpotInterruptionDraining"
    value = "true"
  }
  set {
    name  = "queueURL"
    value = module.aws_node_termination_handler_sqs.sqs_queue_id
  }
  set {
    name  = "logLevel"
    value = "debug"
  }
}

# Creating the lifecycle-hook outside of the ASG resource's `initial_lifecycle_hook`
# ensures that node termination does not require the lifecycle action to be completed,
# and thus allows the ASG to be destroyed cleanly.
resource "aws_autoscaling_lifecycle_hook" "aws_node_termination_handler" {
  count                  = length(module.eks.workers_asg_names)
  name                   = "aws-node-termination-handler"
  autoscaling_group_name = module.eks.workers_asg_names[count.index]
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  heartbeat_timeout      = 300
  default_result         = "CONTINUE"
}

# resource "random_string" "suffix" {
#   length  = 8
#   special = false
# }

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

resource "aws_iam_role" "cluster" {
    name = "eks-role"

    assume_role_policy = <<POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
            }
        ]
    }
    POLICY
}

resource "aws_iam_role_policy_attachment" "terracluster-AmazonEKSWorkerNodePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role       = aws_iam_role.terracluster.name
}

resource "aws_iam_role_policy_attachment" "terracluster-AmazonEKS_CNI_Policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role       = aws_iam_role.terracluster.name
}

resource "aws_iam_role_policy_attachment" "terracluster-AmazonEC2ContainerRegistryReadOnly" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role       = aws_iam_role.terracluster.name
}

resource "aws_iam_role_policy_attachment" "terracluster-AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role       = aws_iam_role.terracluster.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "terracluster-AmazonEKSVPCResourceController" {
    policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
    role        = aws_iam_role.terracluster.name
}

################################################################################
# Module eks
################################################################################
module "eks" {
  source          = "terraform-aws-eks"
  cluster_name    = var.cluster_name
  cluster_version = "1.21"
  subnets         = module.vpc.public_subnets
  vpc_id          = var.vpc_id
  enable_irsa     = true

  tags = {
    Environment = "developmant"
  }

  vpc_id = var.vpc_id

  worker_groups = [
    {
      name                                  = "cicd_worker-group"
      instance_type                         = "t2.micro"
      additional_userdata                   = "pipelines"
      asg_max_size                          = 2
      asg_desired_capacity                  = 2
      instance_refresh_instance_warmup      = 60
      public_ip                             = true
      metadata_http_put_response_hop_limit  = 3
      update_default_version                = true
      additional_security_group_ids         = [aws_security_group.worker_group_mgmt_one.id]
      instance_refresh_enabled              = true
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "owned"
        }
      ]
    },
    {
      name                                  = "infra_worker-group"
      instance_type                         = "t2.micro"
      additional_userdata                   = "machines"
      asg_max_size                          = 2
      asg_desired_capacity                  = 2
      instance_refresh_instance_warmup      = 60
      public_ip                             = true
      metadata_http_put_response_hop_limit  = 3
      update_default_version                = true
      additional_security_group_ids         = [aws_security_group.worker_group_mgmt_two.id]
      instance_refresh_enabled              = true
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "owned"
        }
      ]
    }
  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  map_roles                            = var.map_roles
  map_users                            = var.map_users
  map_accounts                         = var.map_accounts
}
