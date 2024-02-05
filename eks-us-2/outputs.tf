output "endpoint" {
  value = aws_eks_cluster.deployment-2
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.deployment-2.certificate_authority[0].data
}

output "default_subned_ids" {
  value = data.aws_subnets.us-west-2-subnets.ids
}