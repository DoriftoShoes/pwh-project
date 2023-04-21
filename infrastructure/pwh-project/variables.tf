variable "region" {
    description = "AWS region to deploy in to"
    default = "us-west-2"
}

##########
# VPC
##########
variable "vpc_cidr_block" {
    description = "VPC CIDR block"
    default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
 
variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

##########
# EKS
##########
variable "cluster_name" {
    description = "Name of the EKS cluster"
}

variable "cluster_version" {
    description = "Kubernetes version to be deployed"
    default = "1.25"
}

variable "main_instance_types" {
    description = "List of instance types to be used in the main node group"
    type = list(string)
    default = ["t3.medium"]
}

variable "main_size" {
    description = "Scaling specifications for the main node group"
    type = object({
        min = number
        max = number
        desired = number
    })
    default = {
        min = 1
        max = 1
        desired = 1
    }
}

variable "project_image" {
    description = "Container image for deployment"
}