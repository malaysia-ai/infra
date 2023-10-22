# minikube
Minikube!

## how-to Install

1. Install Podman, https://podman.io/getting-started/installation

2. Install Minikube, https://minikube.sigs.k8s.io/docs/start/

3. Run Minikube using Podman,

```bash
minikube start --driver=podman --kubernetes-version=1.22.2
```

```bash
podman -v
```

```text
podman version 3.4.2
```

**I tried latest kubernetes version, but not able to work for current Podman version**.

## how-to access

1. Make sure already install `kubectl` in your local, if not, go to https://kubernetes.io/docs/tasks/tools/

2. Access Malaysia-AI VPN using Tailscale, https://github.com/malaysia-ai/tailscale-vpn

3. Download [kubernetes](kubernetes) and [kube_config](kube_config),

```bash
chmod 400 kubernetes
```

4. Tunnel Minikube endpoint to localhost,

```bash
ssh -i 'kubernetes' -NL localhost:8443:192.168.49.2:8443 kubernetes@100.105.246.81 -p 8000
```

5. Access Minikube using `kubectl`,

```bash
kubectl get all --kubeconfig kube_config
```

```text
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   22h
```

6. Try to deploy a simple deployment with a service,

```bash
kubectl create deployment hello-minikube --image=k8s.gcr.io/echoserver:1.4 --kubeconfig kube_config
kubectl expose deployment hello-minikube --type=NodePort --port=8080 --kubeconfig kube_config
kubectl port-forward service/hello-minikube 7080:8080 --kubeconfig kube_config
```

After that, CURL it,

```bash
curl http://localhost:7080
```

```text
CLIENT VALUES:
client_address=127.0.0.1
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://localhost:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=localhost:7080
user-agent=curl/7.64.1
BODY:
```

Do cleanup,

```bash
kubectl delete deployment/hello-minikube --kubeconfig kube_config
kubectl delete service/hello-minikube --kubeconfig kube_config
```
