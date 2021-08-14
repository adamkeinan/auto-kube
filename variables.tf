variable "vpc_name" {
  default     = true
  name        = "EKSCloudVPC"
}

variable "cluster_name" {
  name        = "terracluster"
}

variable "vpc_id" {
  default     = "vpc-1bd56162"
}

variable "region" {
  description = "Region in which AWS Resources to be created"
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "EC2 Instance Type - Instance Sizing"
  type        = string
  #default = "t2.micro"
  default     = "t2.small"
}

variable "aws_ami" {
  id          = "ami-0ec23856b3bad62d3"
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = [
    "labadmin",
    "root"
  ]
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::240301687828:role/ekstackClusterRole"
      username = "labadmin"
      groups   = ["system:masters"]
    },
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::240301687828:user/labadmin"
      username = "labadmin"
      groups   = ["system:masters"]
    }
  ]
}

variable "aws_node_termination_handler_chart_version" {
  description = "Version of the aws-node-termination-handler Helm chart to install."
  default     = "0.15.1"
}

variable "namespace" {
  description = "Namespace for the aws-node-termination-handler."
  default     = "kube-system"
}

variable "serviceaccount" {
  description = "Serviceaccount for the aws-node-termination-handler."
  default     = "aws-node-termination-handler"
}

variable "aws_account_id" {
  account_id  = "240301687828"
}