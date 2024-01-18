resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
    depends_on = [module.eks_blueprints_kubernetes_addons]

    name       = "argo-cd"
    chart      = "argo-cd"
    repository = "https://argoproj.github.io/argo-helm"
    version    = "5.51.6"
    namespace  = kubernetes_namespace.argocd.id

    values = [templatefile("argocd-helm/values.yaml", {
        ssh_key = "${var.argocd.ssh_key}"
    })]
}