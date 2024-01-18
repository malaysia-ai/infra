resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
    name       = "argo-cd"
    chart      = "argo-cd"
    repository = "https://argoproj.github.io/argo-helm"
    version    = "5.51.6"
    namespace  = kubernetes_namespace.argocd.id

    values = [templatefile("argocd-helm/values.yaml", {
        ssh_key = "${var.github_ssh_key}"
    })]
}