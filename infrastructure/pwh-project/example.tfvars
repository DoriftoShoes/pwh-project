region = "" # AWS Region to deploy in to

vpc_cidr_block = "" # CIDR block for VPC
public_subnet_cidrs = [] # List of the VPC's public subnet CIDRs
private_subnet_cidrs = [] # List of the VPC's private subnet CIDRs

cluster_name = "" # Name of the cluster. This is used in many place for many resources
cluster_version = "" # Kubernetes version
main_instance_types = [] # EC2 instance types to use in the main node group
main_size = {min = 1, max = 1, desired = 1} # minimum, maximum, and desired number of instances in the main node group

deploy_app = true
project_image = "" # container image for the application