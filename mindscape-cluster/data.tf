data "tls_certificate" "mindscape-deployment" {
#  url = aws_eks_cluster.mindscape-deployment.identity[0].oidc[0].issuer
#}
data "aws_eks_cluster_auth" "mindscape-deployment" {
#  name = aws_eks_cluster.mindscape-deployment.name
#}
#
data "aws_subnets" "us-west-2-subnets" {
#  filter {
#    name   = "vpc-id"
#    values = ["vpc-038c715c3ba51de5b"]
#  }
#}