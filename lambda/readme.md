# Lambda Function using Terraform


## Create lambda handler function

We write simple script in function called lambda_handler that will be used by 
lambda function.

## Write HCL script

We also write a script to create lambda function that pointed to lamda function script 
that we wrote locally, cloudwatch for lambda logging, and also attach cloudwatch permissions role into lambda aws_iam_role