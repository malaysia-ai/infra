data "tls_certificate" "cluster" {
  url = aws_eks_cluster.deployment.identity[0].oidc[0].issuer
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