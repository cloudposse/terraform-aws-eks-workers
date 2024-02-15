provider "aws" {
  region = var.region
}

locals {
  # The usage of the specific kubernetes.io/cluster/* resource tags below are required
  # for EKS and Kubernetes to discover and manage networking resources
  # https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html#base-vpc-networking
  tags = { "kubernetes.io/cluster/${var.cluster_name}" = "shared" }
}

module "vpc" {
  source                  = "cloudposse/vpc/aws"
  version                 = "2.1.1"

  ipv4_primary_cidr_block = "172.16.0.0/16"
  tags       = local.tags

  context                 = module.this.context
}

module "subnets" {
  source               = "cloudposse/dynamic-subnets/aws"
  version              = "2.4.1"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = [module.vpc.igw_id]
  ipv4_cidr_block      = [module.vpc.vpc_cidr_block]
  nat_gateway_enabled  = false
  nat_instance_enabled = false

  context              = module.this.context
}

module "eks_workers" {
  source = "../../"

  instance_type                          = var.instance_type
  vpc_id                                 = module.vpc.vpc_id
  subnet_ids                             = module.subnets.public_subnet_ids
  health_check_type                      = var.health_check_type
  min_size                               = var.min_size
  max_size                               = var.max_size
  wait_for_capacity_timeout              = var.wait_for_capacity_timeout
  cluster_name                           = var.cluster_name
  cluster_endpoint                       = var.cluster_endpoint
  cluster_certificate_authority_data     = var.cluster_certificate_authority_data
  cluster_security_group_id              = var.cluster_security_group_id
  cluster_security_group_ingress_enabled = var.cluster_security_group_ingress_enabled
  bootstrap_extra_args                   = "--use-max-pods false"
  kubelet_extra_args                     = "--node-labels=purpose=ci-worker"

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = var.autoscaling_policies_enabled
  cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
  cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent

  context = module.this.context
}
