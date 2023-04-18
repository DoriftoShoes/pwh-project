region = "us-west-2"

vpc_cidr_block = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

cluster_name = "pwh-project"
cluster_version = "1.25"
main_instance_types = ["t3.medium"]
main_size = {min = 1, max = 1, desired = 1}

project_image = "610214208494.dkr.ecr.us-west-2.amazonaws.com/pwh-project:latest"