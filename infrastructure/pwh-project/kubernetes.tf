provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}

resource "helm_release" "alb_ingress" {
  depends_on = [
    module.eks
  ]
  count = var.deploy_app ? 1 : 0
  name       = "aws-alb-ingress-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.5.1"
  namespace          = "aws-alb-ingress"
  create_namespace   = true

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.lb_irsa.iam_role_arn
  }

  set {
    name = "awsRegion"
    value = var.region
  }

  set {
    name = "awsVpcID"
    value = module.vpc.vpc_id
  }
}

resource "kubernetes_namespace" "project" {
  count = var.deploy_app ? 1 : 0
  depends_on = [
    module.eks
  ]
  metadata {
    name = var.cluster_name
  }
}

resource "kubernetes_deployment" "project" {
  count = var.deploy_app ? 1 : 0
  depends_on = [
    module.eks
  ]
  metadata {
    namespace = kubernetes_namespace.project.0.metadata.0.name
    name = var.cluster_name
    labels = {
      app = var.cluster_name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.cluster_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.cluster_name
        }
      }

      spec {
        container {
          image = var.project_image
          name  = var.cluster_name

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
          port { 
            container_port = 5000
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 5000
            }
          }
        }
      }
    }
  }
}



resource "kubernetes_service" "project" {
  count = var.deploy_app ? 1 : 0
  depends_on = [
    module.eks
  ]
  metadata {
    namespace = kubernetes_namespace.project.0.metadata.0.name
    name = var.cluster_name
  }
  spec {
    selector = {
      app =  kubernetes_deployment.project.0.metadata.0.labels.app
    }
    port {
      port        = 80
      target_port = 5000
    }

    type = "NodePort"
  }
}

resource "time_sleep" "wait_1_minute" {
  count = var.deploy_app ? 1 : 0
  depends_on = [
    helm_release.alb_ingress
  ]

  create_duration = "60s"
}

resource "kubernetes_ingress_v1" "project" {
  count = var.deploy_app ? 1 : 0
  depends_on = [
    kubernetes_service.project,
    time_sleep.wait_1_minute
  ]
  metadata {
    namespace = kubernetes_namespace.project.0.metadata.0.name
    name = var.cluster_name
    annotations = {
        "alb.ingress.kubernetes.io/scheme" = "internet-facing"
        "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }

  spec {
    ingress_class_name = "alb"
    default_backend {
      service {
        name = var.cluster_name
        port {
          number = 80
        }
      }
    }

    rule {
      http {
        path {
          backend {
            service {
              name = var.cluster_name
              port {
                number = 80
              }
            }
          }

          path = "/"
        }
      }
    }
  }
}