# Rancher

## Helm Installation

```bash
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
kubectl create namespace cattle-system
helm upgrade rancher rancher-latest/rancher \
--install \
--namespace cattle-system \
--set global.cattle.psp.enabled=false \
--set hostname="rancher.aws.mesolitica.com" \
--set replicas=1 \
--set bootstrapPassword="huseincomel123" \
--set ingress.extraAnnotations.'kubernetes\.io/ingress\.class'=nginx \
--set tls="external"
```

Anything messed up,

```bash
helm delete rancher -n cattle-system
kubectl delete namespace cattle-system
kubectl patch ns cattle-system -p '{"metadata":{"finalizers":null}}'
```