# Mage.ai with Spark

## how-to

1. Build and push image,

```bash
docker build -t malaysiaai/mageai_malaysiaai:0.9.28 .
docker push malaysiaai/mageai_malaysiaai:0.9.28
```

**Make sure pyspark version same as pyspark cluster version at https://github.com/malaysia-ai/infra/blob/main/spark.yaml**.