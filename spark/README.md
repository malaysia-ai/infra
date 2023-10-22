# Spark

## Helm install

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade --install spark bitnami/spark \
-f spark.yaml
```

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade --install spark-test bitnami/spark \
-f spark.yaml
```

