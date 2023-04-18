resource "kubernetes_namespace" "project" {
  metadata {
    name = var.cluster_name
  }
}

resource "kubernetes_deployment" "project" {
  depends_on = [
    module.eks
  ]
  metadata {
    namespace = kubernetes_namespace.project.metadata.0.name
    name = var.cluster_name
    labels = {
      app = var.cluster_name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        test = var.cluster_name
      }
    }

    template {
      metadata {
        labels = {
          test = var.cluster_name
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
        }
      }
    }
  }
}

resource "kubernetes_service" "project" {
  metadata {
    namespace = kubernetes_namespace.project.metadata.0.name
    name = var.cluster_name
  }
  spec {
    selector = {
      app =  kubernetes_deployment.project.metadata.0.labels.app
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      target_port = 5000
    }

    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "project" {
  metadata {
    namespace = kubernetes_namespace.project.metadata.0.name
    name = var.cluster_name
    annotations = {
        "kubernetes.io/ingress.class" = "alb"
        "alb.ingress.kubernetes.io/scheme" = "internet-facing"
        "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }

  spec {
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

    tls {
      secret_name = var.cluster_name
    }
  }
}