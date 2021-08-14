provider "aws" {
  region = "eu-west-1"

# Only For Test Purpeses
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
}

data "aws_vpc" "eks_vpc" {
  default    = true
  cidr_block = "172.0.0.0/16"
  id         = var.vpc_id
}

data "aws_security_group" "lab" {
  name = "ec2_sg"
  id   = "sg-00fef9ad5630361ad"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = var.vpc_id
  id     = "sg-c02d4992"
}


data "default_security_group_ingress" "ingress_sg" {
  name = "ingress_sg"
  id   = "sg-0aa3d3f3ed8dbec37"
}

data "default_security_group_egress" "egrees_sg" {
  name = "egress_sg"
  id   = "sg-06252c51df1370f27"
}

data "aws_route_table" "defualt_route_table" {
  subnet_id      = [var.subnet_id]
  route_table_id = "rtb-e835ea90"
}


data "aws_subnet_ids" "vpc_subnets" {
  vpc_id = var.vpc_id

  filter {
  # db_subnets
    tag {
      key = "Name"
      value = "Service"
    }

    values = {
      db_az3_dev = ["subnet-064411794f1a4ff9f"]
      db_az1_prod = ["subnet-0977ceb3b69e10a8e"]
      db_az2_admin = ["subnet-0758297b34f0a5713"]
    }
  }

  # elastic_cache_subnets
  filter {
    tag {
      key = "Name"
      value = "Service"
    }

    values = {
      ecache_az3_dev      = ["subnet-0df148ab16a1a2c6c"]
      ecache_az3_admin    = ["subnet-08fbae7a108c34260"]
      ecache_az1_prod     = ["subnet-0ec04edfeec36edaa"]
    }
  }

  # redshif_subnets
  filter {
    tag {
      key = "Name"
      value = "Service"
    }

    values = {
      rds_az3_dev         = ["subnet-0e8077176976c27c9"]
      rds_az2_admin       = ["subnet-0507706478f584e4a"]
      rds_az1_prod        = ["subnet-04ad7a748bf900ce0"]
    }
  }

  # Intra_subnets
  filter {
    tag {
      key = "Name"
      value = "Service"
    }

    values = {
      intra_az3_dev       = ["subnet-0579b3837c4523204"]
      intra_az2_admin     = ["subnet-00252f557c882001a"]
      intra_az1_prod      = ["subnet-0745b11b23b303056"]
    }
  }
}

# vpc_db_subnets
data "aws_subnet" "db_az3_dev" {
  vpc_id              = var.vpc_id
  id                  = ["subnet-064411794f1a4ff9f"]

  tags                = {
    Name = "db_az3_dev"
  }
}

data "aws_subnet" "db_az1_prod" {
  vpc_id              = var.vpc_id
  id                  = ["subnet-0977ceb3b69e10a8e"]

  tags                = {
    Name = "db_az1_prod"
  }
}

data "aws_subnet" "db_az2_admin" {
  vpc_id              = var.vpc_id
  id                  = ["subnet-0758297b34f0a5713"]

  tags                = {
    Name = "db_az2_admin"
  }
}
# Elasticache_Subnets
data "aws_subnet" "ecache_az3_dev" {
  vpc_id              = var.vpc_id
  id                  = ["subnet-0df148ab16a1a2c6c"]

}

data "aws_subnet" "ecache_az3_admin" {
  vpc_id              = var.vpc_id
  id                  = ["subnet-08fbae7a108c34260"]
}

data "aws_subnet" "ecache_az1_prod" {
  vpc_id              = var.vpc_id
  id                  = ["subnet-0ec04edfeec36edaa"]
}

# Redshift_Subnets
data "aws_subnet" "rds_az3_dev" {
  vpc_id              = var.vpc_id
  id                  = ["subnet-0e8077176976c27c9"]
}

data "aws_subnet" "rds_az2_admin" {
  vpc_id              = var.vpc_id
  id                  = ["subnet-0507706478f584e4a"]
}

data "aws_subnet" "rds_az1_prod" {
  vpc_id              = var.vpc_id
  id                  = ["subnet-04ad7a748bf900ce0"]
}

# Intra_Subnets
data "aws_subnet" "intra_az3_dev" {
  vpc_id              = var.vpc_id
  id                  = ["subnet-0579b3837c4523204"]
}

data "aws_subnet" "intra_az2_admin" {
  vpc_id              = var.vpc_id
  id                  = ["subnet-00252f557c882001a"]
}

data "aws_subnet" "intra_az1_prod" {
  vpc_id              = var.vpc_id
  id                  = ["subnet-0745b11b23b303056"]
}

# EKS_Subnets
data "aws_eks_cluster" "subnet_ids" {
  vpc_id              = var.vpc_id

  filter {
    key = "Service"
    value = "eks_private"

    values = {
      eks_dev_private-1a      = ["subnet-0806349cec7bfe1a0"]
      eks_prod_private-1b     = ["subnet-0821e58b6cdab97f0"]
      eks_admin_private-1c    = ["subnet-0df96a93447930e37"]
    }
  }
}

data "aws_subnet" "eks_dev_private-1a" {
  vpc_id              = var.vpc_id
  availability_zone   = "eu-west-1a"
#  cidr_block         = cidrsubnet(data.aws_vpc.eks_vpc.cidr_block, 16, 1)
  id                  = "subnet-0806349cec7bfe1a0"

  tags                = {
    Name            = "eks_dev_private-1a"
    Cluster_Service = "kubernetes.io/cluster/terracluster"
  }
}

data "aws_subnet" "eks_prod_private-1b" {
  vpc_id              = var.vpc_id
  availability_zone   = "eu-west-1b"
#  cidr_block          = cidrsubnet(data.aws_vpc.eks_vpc.cidr_block, 32, 1)
  id                  = "subnet-0821e58b6cdab97f0"

  tags                = {
    Name            = "eks_prod_private-1b"
    Cluster_Service = "kubernetes.io/cluster/terracluster"
  }
}

data "aws_subnet" "eks_admin_private-1c" {
  vpc_id              = var.vpc_id
#  cidr_block          = cidrsubnet(data.aws_vpc.eks_vpc.cidr_block, 48, 1)
  availability_zone   = "eu-west-1c"
  id                  = "subnet-0df96a93447930e37"

  tags                = {
    Name            = "eks_admin_private-1c"
    Cluster_Service = "kubernetes.io/cluster/terracluster"
  }
}

locals {
  name   = var.vpc_name.name
  region = "eu-west-1"

  tags = {
    Owner           = "labadmin"
    Environment     = "development"
    Name            = "EKSCloudVPC"
    Terraform       = "true"
  }
}

################################################################################
# VPC Module
################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  # "hashicorp/aws"
  version = "~> 3.0.0"

  create_vpc                              = false

  manage_default_vpc                      = true

  default_vpc_name                        = var.vpc_name
  name                                    = var.vpc_name
  cidr                                    = "172.0.0.0/16" # 10.0.0.0/8 is reserved for EC2-Classic
  secondary_cidr_blocks                   = ["172.8.0.0/16","172.31.32.0/20"]

  azs                                     = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets                         = ["aws_subnet.eks_dev_private-1a.id", "aws_subnet.eks_prod_private-1a.id", "aws_subnet.eks_admin_private-1a.id"]
  public_subnets                          = ["aws_subnet.eks_dev_public-1a.id", "aws_subnet.eks_prod_public-1a.id", "aws_subnet.eks_admin_public-1a.id"]
  database_subnets                        = var.database_subnets
  elasticache_subnets                     = var.elasticache_subnets
  redshift_subnets                        = var.redshift_subnets
  intra_subnets                           = var.intra_subnets.intra_subnets_ids

  intra_route_table_ids                   = [data.aws_route_table.default_route_table.route_table_id]
  private_route_table_ids                 = [data.aws_route_table.default_route_table.route_table_id]
  public_route_table_ids                  = [data.aws_route_table.default_route_table.route_table_id]

  create_database_subnet_group            = false

  manage_default_route_table              = true
  default_route_table_tags                = { DefaultRouteTable = true }

  enable_dns_hostnames                    = true
  enable_dns_support                      = true

  enable_classiclink                      = true
  enable_classiclink_dns_support          = true

  enable_nat_gateway                      = true
  single_nat_gateway                      = false

  reuse_nat_ips                           = true                    # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids                     = "${aws_eip.nat.*.id}"   # <= IPs specified here as input to the module

  customer_gateways = {
    IP1 = {
      bgp_asn    = 65112
      ip_address = "172.8.0.254"
    },
    IP2 = {
      bgp_asn    = 65112
      ip_address = "172.0.0.254"
    }
  }

  enable_vpn_gateway                      = true

  enable_dhcp_options                     = true
  # dhcp_options_domain_name         = "service.consul"
  # dhcp_options_domain_name_servers = ["127.0.0.1", "10.10.0.2"]

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group           = true
  default_security_group_ingress          = data.default_security_group_ingress.id
  default_security_group_egress           = data.default_security_group_egress.id

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                         = true
  create_flow_log_cloudwatch_log_group    = true
  create_flow_log_cloudwatch_iam_role     = true
  flow_log_max_aggregation_interval       = 60

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

  tags = local.tags
}

################################################################################
# VPC Endpoints Module
################################################################################
module "vpc_endpoints" {
  source                  = "./modules/vpc-endpoints"

  vpc_id                  = var.vpc_id
  security_group_ids      = [data.aws_security_group.default.id]

  endpoints = {
    s3 = {
      service = "s3"
      tags    = { Name = "s3-vpc-endpoint" }
    }
  }

  dynamodb = {
    service         = "dynamodb"
    service_type    = "Gateway"
    route_table_ids = flatten([module.vpc.intra_route_table, module.vpc.private_route_table, module.vpc.public_route_table])
    policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
    tags            = { Name = "dynamodb-vpc-endpoint" }
  }

  ssm = {
    service             = "ssm"
    private_dns_enabled = true
    subnet_ids          = module.vpc.private_subnets
  }

  ssmmessages = {
    service             = "ssmmessages"
    private_dns_enabled = true
    subnet_ids          = module.vpc.private_subnets
  }

  lambda = {
    service             = "lambda"
    private_dns_enabled = true
    subnet_ids          = module.vpc.private_subnets
  }

  ecs = {
    service             = "ecs"
    private_dns_enabled = true
    subnet_ids          = module.vpc.private_subnets
  }

  ecs_telemetry = {
    service             = "ecs-telemetry"
    private_dns_enabled = true
    subnet_ids          = module.vpc.private_subnets
  }

  ec2 = {
    service             = "ec2"
    private_dns_enabled = true
    subnet_ids          = module.vpc.private_subnets
  }

  ec2messages = {
    service             = "ec2messages"
    private_dns_enabled = true
    subnet_ids          = module.vpc.private_subnets
  }

  ecr_api = {
    service             = "ecr.api"
    private_dns_enabled = true
    subnet_ids          = module.vpc.private_subnets
    policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
  }

  ecr_dkr = {
    service             = "ecr.dkr"
    private_dns_enabled = true
    subnet_ids          = module.vpc.private_subnets
    policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
  }

  kms = {
    service             = "kms"
    private_dns_enabled = true
    subnet_ids          = module.vpc.private_subnets
  }

  codedeploy = {
    service             = "codedeploy"
    private_dns_enabled = true
    subnet_ids          = module.vpc.private_subnets
  }

  codedeploy_commands_secure = {
    service             = "codedeploy-commands-secure"
    private_dns_enabled = true
    subnet_ids          = module.vpc.private_subnets
  }

  tags = merge(local.tags,
    {
      Project  = "Secret"
      Endpoint = "true"
    }
  )
}

module "vpc_endpoints_nocreate" {
  source = "./modules/vpc-endpoints"

  create = false
}

################################################################################
# Supporting Resources
################################################################################
# Data source used to avoid race condition
data "aws_vpc_endpoint_service" "dynamodb" {
  service = "dynamodb"

  filter {
    tag {
      key = "Name"
      value = "service-type"
    }
    values = ["Gateway"]
  }
}

data "aws_iam_policy_document" "dynamodb_endpoint_policy" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:sourceVpce"

      values = [data.aws_vpc_endpoint_service.dynamodb.id]
    }
  }
}

data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:sourceVpce"

      values = [data.aws_vpc_endpoint_service.dynamodb.id]
    }
  }
}

resource "aws_internet_gateway" "eks_vpc-igw" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_route_table" "eks_vpc-public-route-table" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_route_table_association" "eks_vpc-public-route-table-associate" {
  route_table_id = aws_route_table.eks_vpc-public-route-table.id
  subnet_id      = aws_subnet.db_az3_dev.id
}

resource "aws_route" "eks_vpc-public-route" {
  route_table_id         = aws_route_table.eks_vpc-public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks_vpc-igw.id
}

resource "aws_eip" "nat" {
  instance = aws_instance.rhel_instance.id
  count = 3
  vpc = true
  depends_on = [aws_internet_gateway.eks_vpc-igw]
}
