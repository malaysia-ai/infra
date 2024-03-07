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
  default     = "us-west-2"
}

variable "subnet_id_1" {
  description = "subnet id 1"
  type        = string
  default     = "subnet-0685b740fe605891a"
}

variable "subnet_id_2" {
  description = "subnet id 2"
  type        = string
  default     = "subnet-05f8f0ff23585c420"
}

variable "subnet_id_3" {
  description = "subnet id 3"
  type        = string
  default     = "	subnet-01e13cdd7a40425bd"
}