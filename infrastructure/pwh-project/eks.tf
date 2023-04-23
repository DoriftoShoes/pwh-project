module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.13.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    main = {
      name = "main"

      # Hack to get needed permissions on managed node group for ALB ingress.  Managed node groups should be provisioned separately with correct IAM policy
      iam_role_additional_policies = {
        1: "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
        2: "arn:aws:iam::aws:policy/AmazonVPCReadOnlyAccess",
        3: "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
        4: "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        }

      instance_types = var.main_instance_types

      min_size     = var.main_size.min
      max_size     = var.main_size.max
      desired_size = var.main_size.desired

      key_name = "ark_west_1"
    }
  }
}

module "vpc_cni_irsa" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 4.12"

  role_name_prefix      = "vpc-cni-irsa-"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node","aws-alb-ingress:aws-alb-ingress-controller-aws-load-balancer-controller"]
    }
  }

}