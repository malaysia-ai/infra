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

resource "kubernetes_secret" "cloudflare-api-key-secret" {
    depends_on = [resource.helm_release.cert-manager]
    metadata {
        name = "cloudflare-api-key-secret"
        namespace = kubernetes_namespace.cert-manager.id
    }

    data = {
        api-key = var.cloudflare_api_key
    }

}

# resource "kubernetes_manifest" "cluster-issuer" {
#   depends_on = [resource.helm_release.cert-manager]
#   manifest = yamldecode(templatefile("cert-manager-helm/cluster-issuer.yaml", {
#     namespace = kubernetes_namespace.cert-manager.id
#   }))
# }

resource "kubernetes_manifest" "cert-manager-letsencrypt-production-cloudflare" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "ClusterIssuer"
    "metadata" = {
      "name" = "cert-manager-letsencrypt-production-cloudflare"
    }
    "spec" = {
      "acme" = {
        "email" = "husein.zol05@gmail.com"
        "privateKeySecretRef" = {
          "name" = "cert-manager-letsencrypt-production-cloudflare"
        }
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "dns01" = {
              "cloudflare" = {
                "email" = "husein.zol05@gmail.com"
                "apiKeySecretRef" = {
                    "name" = "cloudflare-api-key-secret"
                    "key" = "api-key"
                }
              }
            }
          },
        ]
      }
    }
  }
}