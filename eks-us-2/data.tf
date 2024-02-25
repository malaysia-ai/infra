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

data "aws_subnet" "default_az_public_a" {
  id = "subnet-08c83b443d6185bd5"
}
data "aws_subnet" "default_az_public_b" {
  id = "subnet-0bf64f00fce048ca1"
}
data "aws_subnet" "default_az_public_c" {
  id = "subnet-0440bbc5ba8484cef"
}
