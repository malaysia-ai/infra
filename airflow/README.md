# Apache Airflow

what is airflow? Apache Airflow is an open-source workflow management platform for data engineering pipelines.

## Deploying Airflow end-to-end

Let's dive into deploying Airflow end-to-end using kubernetes.


### 1. Custom Airflow Docker Image with PySpark and Java

First, we need to put pyspark and java into airflow default image.

This [repository](https://github.com/malaysia-ai/apache-airflow/blob/main/README.md) explains how to build a custom Apache Airflow image that integrates both PySpark and Java.

### 2. Installing the Helm Chart

#### - Mounting DAGs from a private GitHub repo using Git-Sync sidecar

Create a private repo that contain DAGs on GitHub if you have not created one already.

Put repo url under `gitSync` in [airflow.yaml](https://github.com/malaysia-ai/infra/blob/main/airflow/airflow.yaml#L68):

```yaml
gitSync:
    enabled: true
    # git repo clone url
    # https example: https://github.com/apache/airflow.git
    repo: https://github.com/malaysia-ai/apache-airflow.git
    branch: main
    # subpath within the repo where dags are located
    # should be "" if dags are at repo root
    subPath: "dags"
```

#### - Using custom image

Before installing the Helm Chart, provide the Docker image you made and uploaded to the registry [airflow.yaml](https://github.com/malaysia-ai/infra/blob/main/airflow/airflow.yaml#L68). This image will run your Airflow setup.


```yaml
# Default airflow repository -- overridden by all the specific images below
defaultAirflowRepository: malaysiaai/airflow

# Default airflow tag to deploy
defaultAirflowTag: "2.7.1"
```

#### - Using remote logging

Remote logging to Amazon S3 uses an existing Airflow connection to read or write logs

1. Create s3 bucket.

2. This step is creating IAM role and service account using eksctl

```bash
eksctl create iamserviceaccount --cluster=deployment --name=airflow-sa --namespace=default --attach-policy-arn=arn:aws:iam::aws:policy/AmazonS3FullAccess --approve
```

3. Update Helm Chart [airflow.yaml](https://github.com/malaysia-ai/infra/blob/main/airflow/airflow.yaml) with Service Account

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
#### - Finally.. Install Helm Chart

You may install the chart after you done with custom image and remote logging configuration.

To install this chart using Helm 3, run the following commands:

```bash
helm repo add apache-airflow https://airflow.apache.org
helm upgrade --install airflow apache-airflow/airflow \
-f airflow.yaml
```

### 3. Create Amazon Web Services connection

If you want to create an AWS connection in Airflow using the Airflow UI, make sure to set up port forwarding for the Airflow web server to your local machine. This allows you to access the Airflow UI on your local system.

```
1. login to airflow web ui
2. go to admin -> connection
3. add a new record
4. use `aws_conn` that we have configured in `remote_log_conn_id` (logging).
```

### 4. Airflow Ingress Setup

This [repository](https://github.com/malaysia-ai/nginx/tree/main/eks/airflow) provides a quick guide on how to set up Ingress for the Airflow service within a Kubernetes cluster.

### 5. Monitoring Airflow with Prometheus and Grafana

This [repository](https://github.com/malaysia-ai/alerts) provides steps to set up Prometheus metrics in Airflow and visualize them in Grafana.

## Checklist

- [x] Ingress
- [x] Grafana
- [ ] Terraform script

## Contributors

- [@huseinzol05](https://github.com/huseinzol05) (who guided us all the way)
- [@KamarulAdha](https://github.com/KamarulAdha)
- [@oscarnz](https://github.com/oscarnz)
