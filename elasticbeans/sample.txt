# Define the Terraform Cloud organization and workspace
terraform {
  cloud {
    organization = "malaysia-ai"
    workspaces {
      name = "infra"
    }
  }
}

# Specify the required AWS provider and version
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.16.0"
  }
}

# Define the AWS provider configuration using variables
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

# Define variables if needed (e.g., aws_access_key, aws_secret_key, aws_region)
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

# Create an Elastic Beanstalk application
resource "aws_elastic_beanstalk_application" "example_app" {
  name        = var.eb_app_name
  description = "Example Elastic Beanstalk Application"
}

# Create an Elastic Beanstalk environment
resource "aws_elastic_beanstalk_environment" "example_env" {
  name        = var.eb_env_name
  application = aws_elastic_beanstalk_application.example_app.name
  solution_stack_name = "64bit Amazon Linux 2 v5.6.0 running Ruby 2.7 (Puma)" # Change this to your desired platform
  wait_for_ready_timeout = "20m" # Adjust the timeout as needed

  # Define environment settings and variables as needed
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance" # Change to "LoadBalanced" for a load-balanced environment
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "WebServer"
    value     = "nginx" # Change this to your desired web server (e.g., "nginx", "apache")
  }

  # You can add more settings as required

  # Optional: Specify an EC2 key pair for SSH access
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "your-key-pair-name" # Change to your EC2 key pair name
  }

  # Optional: Specify security groups and subnets
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "subnet-12345678,subnet-23456789" # Comma-separated list of subnet IDs
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "SecurityGroups"
    value     = "sg-12345678,sg-23456789" # Comma-separated list of security group IDs
  }

  # Optional: Attach an RDS database instance (if needed)
  setting {
    namespace = "aws:rds:dbinstance"
    name      = "DBInstanceIdentifier"
    value     = "your-db-instance-identifier" # Change to your RDS instance ID
  }

  # Optional: Auto-scaling configuration (if needed)
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "MeasureName"
    value     = "NetworkOut"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Statistic"
    value     = "Average"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Unit"
    value     = "Bytes"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperThreshold"
    value     = "20000000" # Adjust as needed
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerThreshold"
    value     = "10000000" # Adjust as needed
  }
}

# Output the URL of the Elastic Beanstalk application
output "eb_url" {
  value = aws_elastic_beanstalk_environment.example_env.endpoint_url
}
