terraform {

  cloud {
    organization = "malaysia-ai"

    workspaces {
      name = "ariff-us-west-2"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com", "ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "example" {
  name               = "eks-cluster-iam"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.example.name
}

data "aws_subnet" "default_az1" {
  id = var.subnet_id_1
}

data "aws_subnet" "default_az2" {
  id = var.subnet_id_2
}

data "aws_subnet" "default_az3" {
  id = var.subnet_id_3
}

resource "aws_eks_cluster" "deployment" {
  name     = "deployment-ariff"
  role_arn = aws_iam_role.example.arn

  vpc_config {
    subnet_ids = [
      data.aws_subnet.default_az1.id,
      data.aws_subnet.default_az2.id,
      data.aws_subnet.default_az3.id,
    ]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
  ]
}

resource "aws_eks_node_group" "deployment" {
  cluster_name    = aws_eks_cluster.deployment.name
  node_group_name = "node-1"
  node_role_arn   = aws_iam_role.example.arn
  subnet_ids      = [data.aws_subnet.default_az1.id, data.aws_subnet.default_az2.id]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3a.xlarge"]
  capacity_type = "SPOT"

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_acm_certificate" "validate" {
  domain_name       = "ariff-infra.malaysia-ai.org"
  subject_alternative_names = ["*.ariff-infra.malaysia-ai.org"]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list = ["sts.amazonaws.com"]
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
  # https://github.com/terraform-providers/terraform-provider-tls/issues/52
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.deployment.identity.0.oidc.0.issuer
}


resource "aws_iam_role" "ebs_cni" {
  name               = "AmazonEKS_EBS_CSI_DriverRole_Data-us-2"
  assume_role_policy = data.aws_iam_policy_document.ebs_cni_controller.json

  # tags = module.main.common_tags
}

resource "aws_iam_role_policy_attachment" "ebs_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_cni.name
}

resource "aws_eks_addon" "csi_driver" {
  cluster_name             = aws_eks_cluster.deployment.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_cni.arn
}