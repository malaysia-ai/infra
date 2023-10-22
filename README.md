# infra

Terraform manifests for Malaysia-AI infrastructure.

## Connect to EKS

**EKS required user access for aws-auth, create a github issue**.

```bash
aws eks update-kubeconfig --region ap-southeast-1 --name deployment
```

## Terraform Cloud

Access at https://app.terraform.io/app/malaysia-ai/