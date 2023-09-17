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

# Create S3 bucket for Python Flask app

data "aws_s3_bucket" "eb_bucket" {
  bucket = "elasticbeanstalk-ap-southeast-1-896280034829" # Name of S3 bucket to create for Flask app deployment needs to be unique 
}

# Define App files to be uploaded to S3
data "aws_s3_object" "eb_bucket_obj" {
  bucket = data.aws_s3_bucket.eb_bucket.id
  key    = "elasticbeanstalk-ap-southeast-1-896280034829/fastapi/app-230917_004110810067.zip" # S3 Bucket path to upload app files
}

# Define Elastic Beanstalk application
resource "aws_elastic_beanstalk_application" "eb_app" {
  name        = "fastapi-meso"   # Name of the Elastic Beanstalk application
  description = "simple fastapi app" # Description of the Elastic Beanstalk application
}

# Create Elastic Beanstalk environment for application with defining environment settings
resource "aws_elastic_beanstalk_application_version" "eb_app_ver" {
  bucket      = data.aws_s3_bucket.eb_bucket.id                    # S3 bucket name
  key         = data.aws_s3_object.eb_bucket_obj.id         # S3 key path 
  application = aws_elastic_beanstalk_application.eb_app.name # Elastic Beanstalk application name
  name        = "fastapiv1"                # Version label for Elastic Beanstalk application
}

resource "aws_elastic_beanstalk_environment" "tfenv" {
  name                = "fastapi-meso-env"
  application         = aws_elastic_beanstalk_application.eb_app.name             # Elastic Beanstalk application name
  solution_stack_name = "64bit Amazon Linux 2 v3.4.4 running Python 3.8"         # Define current version of the platform
  description         = "environment for fastapi app"                               # Define environment description
  version_label       = aws_elastic_beanstalk_application_version.eb_app_ver.name # Define version label

  setting {
    namespace = "aws:autoscaling:launchconfiguration" # Define namespace
    name      = "IamInstanceProfile"                  # Define name
    value     = "aws-elasticbeanstalk-ec2-role"       # Define value
  }
}