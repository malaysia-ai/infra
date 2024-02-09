output "endpoint" {
  value = aws_eks_cluster.mindscape-cluster
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.mindscape-cluster.certificate_authority[0].data
}

output "default_subned_ids" {
  value = data.aws_subnets.us-west-2-subnets.ids
}