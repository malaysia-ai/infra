resource "kubernetes_namespace" "traefik-ingress" {
  metadata {
    name = "traefik-ingress"
  }
}

resource "helm_release" "traefik" {
    name       = "traefik"
    chart      = "traefik"
    repository = "https://traefik.github.io/charts"
    namespace  = kubernetes_namespace.traefik-ingress.id

    values = [templatefile("traefik-helm/values.yaml", {
       
    })]
}