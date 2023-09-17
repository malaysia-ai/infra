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
data "aws_s3_bucket" "eb_bucket" {
  bucket = "elasticbeanstalk-ap-southeast-1-896280034829"
}
data "aws_s3_object" "eb_bucket_obj" {
  bucket = data.aws_s3_bucket.eb_bucket.id
  key    = "elasticbeanstalk-ap-southeast-1-896280034829/fastapi/app-230917_004110810067.zip" 
}

# Define Elastic Beanstalk application
resource "aws_elastic_beanstalk_application" "eb_app" {
  name        = "fastapi-meso"
  description = "simple fastapi app"
}

# Create Elastic Beanstalk environment
resource "aws_elastic_beanstalk_application_version" "eb_app_ver" {
  bucket      = data.aws_s3_bucket.eb_bucket.id                    
  key         = data.aws_s3_object.eb_bucket_obj.id         
  application = aws_elastic_beanstalk_application.eb_app.name 
  name        = "fastapiv1"                
}

resource "aws_elastic_beanstalk_environment" "tfenv" {
  name                = "fastapi-meso-env"
  application         = aws_elastic_beanstalk_application.eb_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.4.4 running Python 3.8"    # Define current version of the platform
  description         = "environment for fastapi app"
  version_label       = aws_elastic_beanstalk_application_version.eb_app_ver.name

  setting {
    namespace = "aws:autoscaling:launchconfiguration" # Define namespace
    name      = "IamInstanceProfile"                  # Define name
    value     = "aws-elasticbeanstalk-ec2-role"       # Define value
  }
}