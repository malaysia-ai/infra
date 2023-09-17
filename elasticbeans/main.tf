terraform {

  cloud {
    organization = "malaysia-ai"

    workspaces {
      name = "infra-elastic-beanstalk"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.16.0"
    }
  }

  required_version = ">= 1.1.0"
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "ap-southeast-1" # Change this to your desired AWS region
}

# https://www.youtube.com/watch?v=x2IN28DKK3o
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "eb-fastapi"
}
resource "aws_s3_object" "s3_object" {
  bucket = aws_s3_bucket.s3_bucket.id
  key    = "fastapi/fastapi.zip" 
  source = "fastapi.zip"
}

# Define Elastic Beanstalk application
resource "aws_elastic_beanstalk_application" "eb_app" {
  name        = "eb-fastapi"
}

# Create Elastic Beanstalk environment
resource "aws_elastic_beanstalk_application_version" "eb_app_ver" {
  bucket      = aws_s3_bucket.s3_bucket.id                    
  key         = aws_s3_object.s3_object.id         
  application = aws_elastic_beanstalk_application.eb_app.name 
  name        = "v1"                
}

resource "aws_elastic_beanstalk_environment" "tfenv" {
  name                = "eb-fastapi-env"
  cname_prefix        = "eb-fastapi-env"
  application         = aws_elastic_beanstalk_application.eb_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.0.4 running Python 3.11"    # Define current version of the platform
  version_label       = aws_elastic_beanstalk_application_version.eb_app_ver.name

  setting {
    namespace = "aws:autoscaling:launchconfiguration" # Define namespace
    name      = "IamInstanceProfile"                  # Define name
    value     = "aws-elasticbeanstalk-ec2-role"       # Define value
  }
}