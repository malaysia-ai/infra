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
  default     = "subnet-0a36743bf1aa1ab50"
}

variable "subnet_id_2" {
  description = "subnet id 2"
  type        = string
  default     = "subnet-0440bbc5ba8484cef"
}

variable "subnet_id_3" {
  description = "subnet id 3"
  type        = string
  default     = "subnet-08c83b443d6185bd5"
}