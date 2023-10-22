# Airflow

## Deploying Airflow end-to-end

Let's dive into deploying Airflow end-to-end using kubernetes.


### 1. Custom Airflow Docker Image with PySpark and Java

First, we need to put pyspark and java into airflow default image.

This [repository](https://github.com/malaysia-ai/apache-airflow/blob/main/README.md) explains how to build a custom Apache Airflow image that integrates both PySpark and Java.

### 2. Installing the Helm Chart

#### - Using custom image

Before installing the Helm Chart, provide the Docker image you made and uploaded to the registry. 

This image will run your Airflow setup stated in [airflow.yaml](https://github.com/malaysia-ai/infra/blob/main/airflow/airflow.yaml#L68): 


```bash
# Default airflow repository -- overridden by all the specific images below
defaultAirflowRepository: malaysiaai/airflow

# Default airflow tag to deploy
defaultAirflowTag: "2.7.1"
```

To install this chart using Helm 3, run the following commands:

```bash
helm repo add apache-airflow https://airflow.apache.org
helm upgrade --install airflow apache-airflow/airflow \
-f airflow.yaml
```

#### - Using remote logging

1. Create s3 bucket.

2. This step is creating IAM role and service account using eksctl

```bash
eksctl create iamserviceaccount --cluster=deployment --name=airflow-sa --namespace=default --attach-policy-arn=arn:aws:iam::aws:policy/AmazonS3FullAccess --approve
```

3. Update Helm Chart airflow.yaml with Service Account

```yaml
workers:
    serviceAccount:
        create: false
        name: 'airflow-sa'
        annotations:
            eks.amazonaws.com/role-arn: 'arn:aws:iam::896280034829:role/eksctl-deployment-addon-iamserviceaccount-de-Role1-DU6JB1S0FU1J'

webserver:
    serviceAccount:
        create: false
        name: 'airflow-sa'
        annotations:
          eks.amazonaws.com/role-arn: 'arn:aws:iam::896280034829:role/eksctl-deployment-addon-iamserviceaccount-de-Role1-DU6JB1S0FU1J'
 core:
    remote_logging: 'True'

 logging:
    remote_logging: 'True'
    logging_level: 'INFO'
    remote_base_log_folder: 's3://airflow-eks-learn/log'
    remote_log_conn_id: 'aws_conn'
    delete_worker_pods: 'False'
    encrypt_s3_logs: 'False'
```

4. Create Amazon Web Services connection

Login to Airflow Web UI 

go to admin -> connection and add a new record, in our case we use `aws_conn` that we have configured in `remote_log_conn_id` (logging).

### 3. Airflow Ingress Setup

This [repository](https://github.com/malaysia-ai/nginx/tree/main/eks/airflow) provides a quick guide on how to set up Ingress for the Airflow service within a Kubernetes cluster.

### 4. Monitoring Airflow with Prometheus and Grafana

This [repository](https://github.com/malaysia-ai/alerts) provides steps to set up Prometheus metrics in Airflow and visualize them in Grafana.
