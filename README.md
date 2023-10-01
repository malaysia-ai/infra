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

configure remote logging to our s3 bucket
1. create iam role to get s3 bucket full access 
```bash
eksctl create iamserviceaccount --cluster=deployment --name=airflow-sa --namespace=default --attach-policy-arn=arn:aws:iam::aws:policy/AmazonS3FullAccess --approve
```

2. configure remote logging in yaml file
```bash
logging:
    remote_logging: 'True'
    remote_base_log_folder: 's3://airflow-eks-learn'
    remote_log_conn_id: 'my_s3_conn'
    # Use server-side encryption for logs stored in S3
    encrypt_s3_logs: 'False'
```

```bash
workers:
    create: false
    name: 'airflow-sa'
    annotations:
        eks.amazonaws.com/role-arn: 'arn:aws:iam::896280034829:role/eksctl-deployment-addon-iamserviceaccount-de-Role1-DU6JB1S0FU1J'
```
```bash
serviceAccount:
    create: false
    name: 'airflow-sa'
    annotations:
        eks.amazonaws.com/role-arn: 'arn:aws:iam::896280034829:role/eksctl-deployment-addon-iamserviceaccount-de-Role1-DU6JB1S0FU1J'
```

```bash
 logging:
    remote_logging: 'True'
    logging_level: 'INFO'
    remote_base_log_fo  lder: 's3://airflow-eks-learn/log'
    remote_log_conn_id: 'aws_conn'
    delete_worker_pods: 'False'
    encrypt_s3_logs: 'False'
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