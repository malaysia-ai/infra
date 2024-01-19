resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert-manager" {
    name       = "cert-manager"
    chart      = "cert-manager"
    repository = "https://charts.jetstack.io"
    version    = "v1.13.3"
    namespace  = kubernetes_namespace.cert-manager.id

    values = [templatefile("cert-manager-helm/values.yaml", {
        ssh_key = "${replace(var.github_ssh_key, "\n", "\\n")}"
    })]
}
resource "kubernetes_manifest" "cloudflare-api-key-secret" {
  depends_on = [resource.helm_release.cert-manager]
  manifest = yamldecode(templatefile("cert-manager-helm/cloudflare-api-key-secret.yaml", {
    cloudflare_api_key = var.cloudflare_api_key,
    namespace = kubernetes_namespace.cert-manager.id
  }))
}
resource "kubernetes_manifest" "cluster-issuer" {
  depends_on = [resource.helm_release.cert-manager]
  manifest = yamldecode(templatefile("cert-manager-helm/cluster-issuer.yaml", {
    namespace = kubernetes_namespace.cert-manager.id
  }))
}