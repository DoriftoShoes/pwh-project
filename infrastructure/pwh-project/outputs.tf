# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value = module.vpc.vpc_id
}

output "azs" {
  description = "A list of availability zones used by the VPC"
  value       = module.vpc.azs
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value = distinct(compact([for s in module.vpc.public_subnets: s]))
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value = distinct(compact([for s in module.vpc.private_subnets: s]))
}

# EKS
output "load_balancer_role_arn" {
  description = "ARN of the IAM role used by the load balancer controller"
  value = module.vpc_cni_irsa.iam_role_arn
}

output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value = module.eks.cluster_endpoint
}

output "eks_cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = module.eks.cluster_primary_security_group_id
}

output "eks_cluster_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the cluster security group"
  value       = module.eks.cluster_security_group_arn
}

output "eks_cluster_security_group_id" {
  description = "ID of the cluster security group"
  value       = module.eks.cluster_security_group_id
}

output "eks_node_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the node shared security group"
  value       = module.eks.node_security_group_arn
}

output "eks_node_security_group_id" {
  description = "ID of the node shared security group"
  value       = module.eks.node_security_group_id
}

output "eks_oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = module.eks.oidc_provider
}

output "eks_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = module.eks.oidc_provider_arn
}

output "eks_cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

output "eks_managed_node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value       = module.eks.eks_managed_node_groups
}

output "load_balancer_hostname" {
  description = "Hostname of the load balancer for the pwh-project Kubernetes service"
  value = kubernetes_ingress_v1.project.status.0.load_balancer.0.ingress.0.hostname
}
