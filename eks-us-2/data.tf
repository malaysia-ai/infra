data "tls_certificate" "deployment-2" {
  url = aws_eks_cluster.deployment-2.identity[0].oidc[0].issuer
}
data "aws_eks_cluster_auth" "deployment-2" {
  name = aws_eks_cluster.deployment-2.name
}
data "tls_certificate" "deployment-3" {
  url = aws_eks_cluster.deployment-3.identity[0].oidc[0].issuer
}
data "aws_eks_cluster_auth" "deployment-3" {
  name = aws_eks_cluster.deployment-3.name
}
data "aws_subnets" "us-west-2-subnets" {
  filter {
    name   = "vpc-id"
    values = ["vpc-038c715c3ba51de5b"]
  }
}