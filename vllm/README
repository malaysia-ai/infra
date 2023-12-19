# Nginx

## how-to

1. Deploy using Helm,

```bash
helm repo add nginx https://kubernetes.github.io/ingress-nginx
helm upgrade --cleanup-on-fail --install \
nginx nginx/ingress-nginx \
--namespace ingress-nginx \
--set controller.service.type=LoadBalancer \
--set controller.service.annotations."service\.beta\.kubernetes\.io/{replace-cert-arn} \
--set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-backend-protocol"=tcp \
--set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-ssl-ports"=https \
--set controller.service.targetPorts.https=http \
--set-string controller.config.use-forwarded-headers="true" \
--set-string controller.config.proxy-real-ip-cidr="{replace-vpc-cidr}" \
--set controller.ingressClassResource.name=nginx \
--create-namespace
```

- `{replace-cert}`, replace with AWS Cert Manager Arn.
- `{replace-cidr}`, replace with VPC CIDR.

## Set CNAME

After AWS load balancer succesfully returned A record, example,

```bash
kubectl get all -n ingress-nginx
```

```text
aa1225e3830e147808649f717c201da3-201173784.ap-southeast-1.elb.amazonaws.com
```

Replace this in CNAME records.