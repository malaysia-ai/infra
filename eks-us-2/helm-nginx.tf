resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress-nginx" {
    name       = "ingress-nginx"
    chart      = "ingress-nginx"
    repository = "https://kubernetes.github.io/ingress-nginx"
    version    = "4.9.0"
    namespace  = kubernetes_namespace.ingress-nginx.id

    values = [templatefile("nginx-helm/values.yaml", {
       
    })]
}