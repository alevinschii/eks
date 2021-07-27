#
# EKS Tools
# * Cluster Autoscaler
# * Kube Ops View
# * Metrics Server
#

# Cluster Autoscaler
data "aws_region" "current" {}

resource "kubernetes_namespaces" "cluster-autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  metadata {
    name = "cluster-autoscaler"
  }
}

resource "helm_release" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = var.cluster_autoscaler_version
  name       = "cluster-autoscaler"
  namespace  = "cluster-autoscaler"

  set {
    name  = "autoDiscovery.clusterName"
    value = local.cluster_name
  }

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  } 
}

# Kube-Ops-View
resource "kubernetes_namespace" "kube-ops-view" {
  count = var.enable_kube_ops_view ? 1 : 0

  metadata {
    name = "kube-ops-view"
  }
}

resource "helm_release" "kube-ops-view" {
  count = var.enable_kube_ops_view ? 1 : 0

  repository = "https://charts.helm.sh/stable"
  chart      = "kube-ops-view"
  name       = "kube-ops-view"
  version    = var.kube_ops_view_version
  namespace  = "kube-ops-view"

  set {
    name  = "service.type"
    value = var.kube_ops_view_service
  }

  set {
    name  = "rbac.create"
    value = "true"
  }
}

# Metrics Server
resource "helm_release" "metrics-server" {
  count = var.enable_metrics_server ? 1 : 0

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metrics-server"
  name       = "metrics-server"
  version    = var.metrics_server_version
  namespace  = "kube-system"

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "apiService.create"
    value = "true"
  }
}
