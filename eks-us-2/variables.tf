variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "region" {
  type    = string
  default = "us-west-2"
}
variable "argocd" {
  description = ""
  type = map(string)
  default = {
    "ssh_key" = ""
  }
}
# variable "aws_role_arn" {
#   type    = string
# }

# variable "rancher_password" {
#   type = string
# }