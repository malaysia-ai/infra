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
variable "argocd_pan" {
  description = "Github personal access token for accessing argocd repo"
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