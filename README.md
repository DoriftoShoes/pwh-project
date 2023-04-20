[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<h3 align="center">pwh-project</h3>

  <p align="center">
    <a href="https://github.com/doriftoshoes/pwh-project"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    ·
    <a href="https://github.com/doriftoshoes/pwh-project/issues">Report Bug</a>
    ·
    <a href="https://github.com/doriftoshoes/pwh-project/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#deployment">Deployment</a></li>
      </ul>
    </li>
    <li><a href="#terraform">Terraform</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

This is a small project that utilizes Terraform to create a Kubernetes cluster and deploy a sample Python application

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

Use the following steps to deploy t his project.

### Prerequisites

The following items are required to use this project.

* AWS Account
* ECR Repository
* AWS CLI Installed
* Docker

### Deployment

1. Create the app image and push to your ECR repository
    1. [Building a Docker image](https://docs.docker.com/engine/reference/commandline/build/)
    2. [Pushing a Docker image](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html)
    3. Get the image URI from the AWS console or CLI
2. Copy the example.tfvars file
3. Update your tfvars file with all of your environment information
4. Run `terraform plan --out=plan.out --var-file=YOUR_TFVARS_FILE`
5. Verify plan looks correct
6. Run `terraform apply --var-file=YOUR_TFVARS_FILE plan.out`

### Destroying
The following command will tear down the environment

1. `terraform destroy --var-file=YOUR_TFVARS_FILE`

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Terraform
<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.57.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | ~> 2.2.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0.4 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.57.1 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.9.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.19.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 19.13.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | n/a |
| <a name="module_vpc_cni_irsa"></a> [vpc\_cni\_irsa](#module\_vpc\_cni\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 4.12 |

### Resources

| Name | Type |
|------|------|
| [helm_release.alb_ingress](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_deployment.project](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_ingress_v1.project](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_namespace.project](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service.project](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [aws_availability_zones.zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `any` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes version to be deployed | `string` | `"1.25"` | no |
| <a name="input_main_instance_types"></a> [main\_instance\_types](#input\_main\_instance\_types) | List of instance types to be used in the main node group | `list(string)` | <pre>[<br>  "t3.medium"<br>]</pre> | no |
| <a name="input_main_size"></a> [main\_size](#input\_main\_size) | Scaling specifications for the main node group | <pre>object({<br>        min = number<br>        max = number<br>        desired = number<br>    })</pre> | <pre>{<br>  "desired": 1,<br>  "max": 1,<br>  "min": 1<br>}</pre> | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | Private Subnet CIDR values | `list(string)` | <pre>[<br>  "10.0.4.0/24",<br>  "10.0.5.0/24",<br>  "10.0.6.0/24"<br>]</pre> | no |
| <a name="input_project_image"></a> [project\_image](#input\_project\_image) | Container image for deployment | `any` | n/a | yes |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | Public Subnet CIDR values | `list(string)` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24",<br>  "10.0.3.0/24"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy in to | `string` | `"us-west-2"` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | VPC CIDR block | `string` | `"10.0.0.0/16"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | n/a |
| <a name="output_load_balancer_role_arn"></a> [load\_balancer\_role\_arn](#output\_load\_balancer\_role\_arn) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
<!-- END_TF_DOCS -->
<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

Patrick Hoolboom - patrick@hoolboom.com

Project Link: [https://github.com/doriftoshoes/pwh-project](https://github.com/doriftoshoes/pwh-project)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/doriftoshoes/pwh-project.svg?style=for-the-badge
[contributors-url]: https://github.com/doriftoshoes/pwh-project/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/doriftoshoes/pwh-project.svg?style=for-the-badge
[forks-url]: https://github.com/doriftoshoes/pwh-project/network/members
[stars-shield]: https://img.shields.io/github/stars/doriftoshoes/pwh-project.svg?style=for-the-badge
[stars-url]: https://github.com/doriftoshoes/pwh-project/stargazers
[issues-shield]: https://img.shields.io/github/issues/doriftoshoes/pwh-project.svg?style=for-the-badge
[issues-url]: https://github.com/doriftoshoes/pwh-project/issues
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/pwhoolboom
[product-screenshot]: images/screenshot.png