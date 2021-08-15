resource "aws_eks_node_group" "eks_node_group" {
    cluster_name        = aws_eks_cluster.eks_node_group.name
    node_role_arn       = aws_iam_role_policy_attachment.terracluster-AmazonEKSWorkerNodePolicy.role  
    subnet_ids          = "kubernetes.io/cluster/terracluster"
    ami_type            = "ami-0ec23856b3bad62d3"  
    instance_type       = "t2.micro"
    node_group_name     = "terracluster_ng-1"
    remote_access       = {
        ec2_ssh_key     = "./.ssh/id_rsa.pub"
    }

    scaling_config {
        min_size        = 3
        desired_size    = 3
        max_size        = 4
    }
}