# infra

Terraform manifests for Malaysia-AI infrastructure, we use Terraform Cloud https://app.terraform.io/app/malaysia-ai/

## Connect to the cluster

```bash
aws eks update-kubeconfig --region ap-southeast-1 --name deployment
```

## Helm install

### Apache Airflow

```bash
helm repo add apache-airflow https://airflow.apache.org
helm upgrade --install airflow apache-airflow/airflow \
-f airflow.yaml
```

### Rancher

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

### Spark cluster

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade --install spark bitnami/spark \
-f spark.yaml
```