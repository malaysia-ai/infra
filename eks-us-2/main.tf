terraform {

  cloud {
    organization = "malaysia-ai"

    workspaces {
      name = "eks-us-west-2-aws"
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
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "controlplane" {
  name               = "eks-cluster-us-2"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "controlplane_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.controlplane.name
}

resource "aws_default_vpc" "default" {
}

resource "aws_default_subnet" "subnet1" {
  availability_zone = "us-west-2a"
}

resource "aws_default_subnet" "subnet2" {
  availability_zone = "us-west-2b"
}

resource "aws_default_subnet" "subnet3" {
  availability_zone = "us-west-2c"
}

resource "aws_eks_cluster" "cluster" {
  name     = "deployment-2"
  role_arn = aws_iam_role.controlplane.arn

  vpc_config {
    subnet_ids = [
      aws_default_subnet.subnet1.id, 
      aws_default_subnet.subnet2.id, 
      aws_default_subnet.subnet3.id
    ]
  }

  version = "1.26"
}

resource "aws_iam_role" "nodegroup" {
  name = "eks-nodegroup-us-2"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "nodegroup_attachment-worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodegroup.name
}

resource "aws_iam_role_policy_attachment" "nodegroup_attachment-cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodegroup.name
}

resource "aws_iam_role_policy_attachment" "nodegroup_attachment-ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodegroup.name
}

# resource "aws_eks_node_group" "node1" {
#   cluster_name    = aws_eks_cluster.cluster.name
#   node_group_name = "node1"
#   node_role_arn   = aws_iam_role.nodegroup.arn
#   subnet_ids      = [aws_default_subnet.subnet1.id, aws_default_subnet.subnet2.id, aws_default_subnet.subnet3.id]
#
#   scaling_config {
#     desired_size = 1
#     max_size     = 1
#     min_size     = 1
#   }
#
#   ami_type = "AL2_x86_64_GPU"
#   capacity_type = "SPOT"
#   instance_types = ["inf2.xlarge"]
#   disk_size = 100
#
# }

# resource "aws_eks_node_group" "node1" {
#   cluster_name    = aws_eks_cluster.cluster.name
#   node_group_name = "node1"
#   node_role_arn   = aws_iam_role.nodegroup.arn
#   subnet_ids      = [aws_default_subnet.subnet1.id, aws_default_subnet.subnet2.id, aws_default_subnet.subnet3.id]
#
#   scaling_config {
#     desired_size = 1
#     max_size     = 1
#     min_size     = 1
#   }
#
#   ami_type = "AL2_x86_64_GPU"
#   capacity_type = "SPOT"
#   instance_types = ["inf2.xlarge"]
#   disk_size = 100
#
# }


# resource "aws_eks_node_group" "node1" {
#   cluster_name    = aws_eks_cluster.cluster.name
#   node_group_name = "node1"
#   node_role_arn   = aws_iam_role.nodegroup.arn
#   subnet_ids      = [aws_default_subnet.subnet1.id, aws_default_subnet.subnet2.id, aws_default_subnet.subnet3.id]
#
#   scaling_config {
#     desired_size = 1
#     max_size     = 1
#     min_size     = 1
#   }
#
#   ami_type = "AL2_x86_64_GPU"
#   capacity_type = "SPOT"
#   instance_types = ["inf2.xlarge"]
#   disk_size = 100
#
# }

resource "aws_eks_node_group" "node7" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "node7"
  node_role_arn   = aws_iam_role.nodegroup.arn
  subnet_ids      = [aws_default_subnet.subnet2.id]

  labels = {
    arep = "owned" 
  }

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  ami_type = "AL2_x86_64_GPU"
  capacity_type = "SPOT"
  instance_types = ["trn1.32xlarge"]
  disk_size = 100

}


resource "aws_iam_openid_connect_provider" "this" {
  client_id_list = ["sts.amazonaws.com"]
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
  # https://github.com/terraform-providers/terraform-provider-tls/issues/52
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

data "aws_iam_policy_document" "ebs_cni_controller" {
  statement {
    sid = "EBSCNIAssumeRole"

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      identifiers = [aws_iam_openid_connect_provider.this.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
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
  cluster_name             = aws_eks_cluster.cluster.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_cni.arn
}

resource "aws_acm_certificate" "mesolitica" {
  domain_name       = "us1.peacehotel.my"
  subject_alternative_names = ["*.us1.peacehotel.my"]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
