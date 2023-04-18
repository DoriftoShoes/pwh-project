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

      # Hack to get elasticloadbalancing:DescribeLoadBalancers
      iam_role_additional_policies = {1: "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess", 2: "arn:aws:iam::aws:policy/AmazonVPCReadOnlyAccess"}

      instance_types = var.main_instance_types

      min_size     = var.main_size.min
      max_size     = var.main_size.max
      desired_size = var.main_size.desired
    }
  }
}