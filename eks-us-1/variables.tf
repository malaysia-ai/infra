variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "aws_role_arn" {
  type    = string
}

variable "rancher_password" {
  type = string
}