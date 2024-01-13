# The process 

1. use instance and ami types as mentioned in prerequisite. [link here](https://awsdocs-neuron.readthedocs-hosted.com/en/latest/containers/)
```
ami_type = "AL2_x86_64_GPU"
capacity_type = "SPOT"
instance_types = ["inf2.xlarge"]
disk_size = 100
```

2. Apply the Neuron device plugin as a daemonset on the cluster with the following command. [link here](https://awsdocs-neuron.readthedocs-hosted.com/en/latest/containers/)
```bash
cd neuron-device-plugin/
kubectl apply -f k8s-neuron-device-plugin-rbac.yml
kubectl apply -f k8s-neuron-device-plugin.yml
```


## Reference 

1. https://www.eksworkshop.com/docs/aiml/inferentia/

2. https://catalog.us-east-1.prod.workshops.aws/workshops/1a666ed2-776c-4e26-bc09-bfc073098239/en-US/eks

3. https://awsdocs-neuron.readthedocs-hosted.com/en/latest/containers/tutorials/k8s-setup.html
