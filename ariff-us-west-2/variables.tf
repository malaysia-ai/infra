variable "access_key" {
  description = "access_key"
  type        = string
}

variable "secret_key" {
  description = "secret_key"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "subnet_id_1" {
  description = "subnet id 1"
  type        = string
  default     = "subnet-03e2e6d05407d4e38"
}

variable "subnet_id_2" {
  description = "subnet id 2"
  type        = string
  default     = "subnet-0ad78399087fe3ef3"
}

variable "subnet_id_3" {
  description = "subnet id 3"
  type        = string
  default     = "subnet-050920cd49df6e67f"
}