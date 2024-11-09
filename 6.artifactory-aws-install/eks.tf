# This file is used to create an AWS EKS cluster and the managed node group(s)

locals {
    cluster_name = var.cluster_name
}

resource "aws_security_group_rule" "allow_management_from_my_ip" {
    type              = "ingress"
    from_port         = 0
    to_port           = 65535
    protocol          = "-1"
    cidr_blocks       = [var.cluster_public_access_cidrs]
    security_group_id = module.eks.cluster_security_group_id
    description       = "Allow all traffic from my public IP for management"
}

module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    # version = "20.28.0"

    cluster_name    = local.cluster_name
    cluster_version = "1.31"

    enable_cluster_creator_admin_permissions = true
    cluster_endpoint_public_access           = true
    cluster_endpoint_public_access_cidrs     = [var.cluster_public_access_cidrs]

    cluster_addons = {
        aws-ebs-csi-driver = {
            service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
        }
    }

    vpc_id     = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets

    eks_managed_node_group_defaults = {
        ami_type = "AL2_x86_64"
    }

    eks_managed_node_groups = {
        one = {
            name = "node-group-artifactory"

            instance_types = ["t3.small"]

            min_size     = 1
            max_size     = 3
            desired_size = 1
        }

        two = {
            name = "node-group-nginx"

            instance_types = ["t3.small"]

            min_size     = 1
            max_size     = 2
            desired_size = 1
        }
    }
}


# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/
data "aws_iam_policy" "ebs_csi_policy" {
    arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
    source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
    # version = "5.39.0"

    create_role                   = true
    role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
    provider_url                  = module.eks.oidc_provider
    role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
    oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}
