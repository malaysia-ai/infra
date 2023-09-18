locals {
  lambda_build_path = "build"
  lambda_zip_file_name = "aws-lambda.zip"
  lambda_src_path = "./src"
}

variable "lambda_function_name" {
  default = "lambda_function_name"
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}