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
variable "github_ssh_key" {
  description = "Using Adha's private key to allow argocd to access github repo"
  type        = string
}

variable "cloudflare_api_key" {
  type = string
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