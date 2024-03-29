resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}
resource "helm_release" "argocd" {
    name       = "argo-cd"
    chart      = "argo-cd"
    repository = "https://argoproj.github.io/argo-helm"
    version    = "5.53.14"
    namespace  = kubernetes_namespace.argocd.id

    values = [templatefile("argocd-helm/values.yaml", {
        argocd_pan = "${replace(var.argocd_pan, "\n", "\\n")}"
    })]
}
