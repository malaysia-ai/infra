data "tls_certificate" "cluster" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.cluster.name
}