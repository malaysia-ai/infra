# The process 

I learned all these through 
https://www.eksworkshop.com/docs/aiml/inferentia/
https://catalog.us-east-1.prod.workshops.aws/workshops/1a666ed2-776c-4e26-bc09-bfc073098239/en-US/eks
https://awsdocs-neuron.readthedocs-hosted.com/en/latest/containers/tutorials/k8s-setup.html

### 1. I read the second link and get to know which EKS Optimized accelerated AMIs is being used there by running this 2 scripts 

```bash
aws ssm get-parameter \
    --name /aws/service/eks/optimized-ami/1.26/amazon-linux-2-gpu/recommended/image_id \
    --region us-west-2 \
    --query "Parameter.Value" \
    --output text
```

Turns out we cannot do that using BottleRocket AMIs but to use Amazon Linux 2.
