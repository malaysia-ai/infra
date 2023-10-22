# Airflow

## Deploying Airflow end-to-end

Let's dive into deploying Airflow end-to-end using kubernetes.

### Installing the Helm Chart

This chart will bootstrap an Airflow deployment on a Kubernetes cluster using the Helm package manager.

You need to go to airflow repo first

```bash
cd airflow
```

To install this chart using Helm 3, run the following commands:

```bash
helm repo add apache-airflow https://airflow.apache.org
helm upgrade --install airflow apache-airflow/airflow \
-f airflow.yaml
```

## configure remote logging to our s3 bucket

1. create iam role to get s3 bucket full access,

```bash
eksctl create iamserviceaccount --cluster=deployment --name=airflow-sa --namespace=default --attach-policy-arn=arn:aws:iam::aws:policy/AmazonS3FullAccess --approve
```

2. configure remote logging in yaml file,

```yaml
workers:
    create: false
    name: 'airflow-sa'
    annotations:
        eks.amazonaws.com/role-arn: 'arn:aws:iam::896280034829:role/eksctl-deployment-addon-iamserviceaccount-de-Role1-DU6JB1S0FU1J'
```

```yaml
serviceAccount:
    create: false
    name: 'airflow-sa'
    annotations:
        eks.amazonaws.com/role-arn: 'arn:aws:iam::896280034829:role/eksctl-deployment-addon-iamserviceaccount-de-Role1-DU6JB1S0FU1J'
```

```yaml
 core:
    remote_logging: 'True'
```

```yaml
 logging:
    remote_logging: 'True'
    logging_level: 'INFO'
    remote_base_log_folder: 's3://airflow-eks-learn/log'
    remote_log_conn_id: 'aws_conn'
    delete_worker_pods: 'False'
    encrypt_s3_logs: 'False'
```

3. create connections under Airflow UI,

go to admin -> connection and add a new record, in our case we use `aws_conn` that we have configured in `remote_log_conn_id` (logging).
