# How-to 

## Provide default certificate with cert-manager and CloudFlare DNS

1. Add and update cert-manager Helm repository 
```
helm repo add jetstack https://charts.jetstack.io --force-update
helm repo update
```

2. Install cert-manager with CRD
```
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.14.4 --set installCRDs=true
```

3. Install Traefik Helm
we deploy traefik first to spawn the dedicated load balancer on ingress controller 
```
helm install traefik traefik/traefik
```

4. Create `Secret` and `Issuer` needed by `cert-manager` with your API Token.
See [cert-manager documentation](https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/)
for creating this token with needed rights:

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare
  namespace: traefik
type: Opaque
stringData:
  api-token: XXX
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: cloudflare
  namespace: traefik
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: email@example.com
    privateKeySecretRef:
      name: cloudflare-key
    solvers:
      - dns01:
          cloudflare:
            apiTokenSecretRef:
              name: cloudflare
              key: api-token
```

5. Create `Certificate` in traefik namespace

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: wildcard-example-com
  namespace: traefik
spec:
  secretName: wildcard-example-com-tls
  dnsNames:
    - "example.com"
    - "*.example.com"
  issuerRef:
    name: cloudflare
    kind: Issuer
```

6. Check that it's ready

```bash
kubectl get certificate -n traefik
```

7. Create ```TLSStore``` that point  the certificates.

```yaml
apiVersion: traefik.io/v1alpha1
kind: TLSStore
metadata:
  name: default
  namespace: traefik
spec:
  certificates:
    - secretName: wildcard-example-com-tls
  defaultCertificate:
    secretName: wildcard-example-com-tls
```

8. Enjoy. All your `IngressRoute` use this certificate by default now. They should use websecure entrypoint like this:

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: example-com-tls
spec:
  entryPoints:
    - websecure
  routes:
  - match: Host(`test.example.com`)
    kind: Rule
    services:
    - name: XXXX
      port: 80
```
