output "vpc_id" {
    value = module.vpc.vpc_id
}

output "load_balancer_role_arn" {
    value = module.vpc_cni_irsa.iam_role_arn
}

output "eks_cluster_endpoint" {
    value = module.eks.cluster_endpoint
}