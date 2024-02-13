resource "aws_efs_file_system" "jupyter" {
  creation_token = "jupyter-usage"

  tags = {
    Name = "jupyter"
  }
}

resource "aws_efs_mount_target" "jupyter-west-2a" {
  file_system_id = aws_efs_file_system.jupyter.id
  subnet_id      = aws_default_subnet.subnet1.id
}
resource "aws_efs_mount_target" "jupyter-west-2b" {
  file_system_id = aws_efs_file_system.jupyter.id
  subnet_id      = aws_default_subnet.subnet2.id
}
resource "aws_efs_mount_target" "jupyter-west-2c" {
  file_system_id = aws_efs_file_system.jupyter.id
  subnet_id      = aws_default_subnet.subnet3.id
}