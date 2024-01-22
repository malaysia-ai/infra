resource "kubernetes_namespace" "nginx-ingress" {
  metadata {
    name = "nginx-ingress"
  }
}

resource "helm_release" "nginx-ingress" {
    name       = "nginx-ingress"
    chart      = "nginx-ingress"
    repository = "oci://ghcr.io/nginxinc/charts"
    version    = "4.9.0"
    namespace  = kubernetes_namespace.nginx-ingress.id

    values = [templatefile("nginx-helm/values.yaml", {
       
    })]
}