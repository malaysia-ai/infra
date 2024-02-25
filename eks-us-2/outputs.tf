output "default_subned_ids" {
  value = data.aws_subnets.us-west-2-subnets.ids
}

output "jupyter-efs-id" {
  value = aws_efs_file_system.jupyter.id
}
