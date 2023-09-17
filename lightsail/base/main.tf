terraform {
    required_version = ">= 1.1.0"
    cloud {
        organization = "<organization_name"

        workspaces {
          name = "<workspace_name>"
        }
    }

    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.16.0"
      }
    }
}

variable "aws_access_key" {
    type = string
}

variable "aws_secret_key" {
    type = string
}

variable "aws_region" {
    type = string
    default = "ap-southeast-1"
}

variable "aws_ssh_key_pair" {
    type = string
}

provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.aws_region
}

resource "aws_lightsail_instance" "light_sail_instance" {
  name              = "<instance_name>"
  availability_zone = "ap-southeast-1a"
  
  # Available Blueprint Options:
  # - "ubuntu_22_04"
  # - "amazon_linux_2"
  # - "debian_10"
  # - "centos_8"
  # - "ubuntu_20_04"
  # - "lamp_7_4"
  # - "nginx_1_18"
  # - "nodejs_14_17"
  blueprint_id      = "ubuntu_22_04"
  
  # Available Bundle Options:
  # - "nano_2_0"
  # - "micro_2_0"
  # - "small_2_0"
  # - "medium_2_0"
  # - "large_2_0"
  # - "xlarge_2_0"
  bundle_id         = "nano_2_0"
  
  key_pair_name     = var.aws_ssh_key_pair # Specify the name of your Lightsail key pair
}

# Create a Lightsail static IP
resource "aws_lightsail_static_ip" "static_ip_creation" {
  name = "<static_ip>"
}

# Attach the static IP to the Lightsail instance
resource "aws_lightsail_static_ip_attachment" "static_ip_attachment" {
  static_ip_name  = aws_lightsail_static_ip.static_ip_creation.name
  instance_name   = aws_lightsail_instance.light_sail_instance.name
}


