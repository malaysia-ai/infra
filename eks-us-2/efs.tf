resource "aws_efs_file_system" "jupyter" {
  creation_token = "jupyter-usage"

  tags = {
    Name = "jupyter"
  }
  throughput_mode = "elastic"
}

# resource "aws_efs_mount_target" "jupyter-west-2a" {
#   file_system_id = aws_efs_file_system.jupyter.id
#   subnet_id      = data.aws_subnet.default_az_public_a.id
# }
# resource "aws_efs_mount_target" "jupyter-west-2b" {
#   file_system_id = aws_efs_file_system.jupyter.id
#   subnet_id      = data.aws_subnet.default_az_public_b.id
# }
# resource "aws_efs_mount_target" "jupyter-west-2c" {
#   file_system_id = aws_efs_file_system.jupyter.id
#   subnet_id      = data.aws_subnet.default_az_public_c.id
# }