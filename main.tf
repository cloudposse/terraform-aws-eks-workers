locals {
  tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )

  workers_role_arn  = var.use_existing_aws_iam_instance_profile ? join("", data.aws_iam_instance_profile.default.*.role_arn) : join("", aws_iam_role.default.*.arn)
  workers_role_name = var.use_existing_aws_iam_instance_profile ? join("", data.aws_iam_instance_profile.default.*.role_name) : join("", aws_iam_role.default.*.name)
}

module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.15.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  delimiter  = var.delimiter
  attributes = compact(concat(var.attributes, ["workers"]))
  tags       = local.tags
  enabled    = var.enabled
}

data "aws_iam_policy_document" "assume_role" {
  count = var.enabled && var.use_existing_aws_iam_instance_profile == false ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "default" {
  count              = var.enabled && var.use_existing_aws_iam_instance_profile == false ? 1 : 0
  name               = module.label.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role.*.json)
  tags               = module.label.tags
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  count      = var.enabled && var.use_existing_aws_iam_instance_profile == false ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  count      = var.enabled && var.use_existing_aws_iam_instance_profile == false ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  count      = var.enabled && var.use_existing_aws_iam_instance_profile == false ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_role_policy_attachment" "existing_policies_attach_to_eks_workers_role" {
  count      = var.enabled && var.use_existing_aws_iam_instance_profile == false ? var.workers_role_policy_arns_count : 0
  policy_arn = var.workers_role_policy_arns[count.index]
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_instance_profile" "default" {
  count = var.enabled && var.use_existing_aws_iam_instance_profile == false ? 1 : 0
  name  = module.label.id
  role  = join("", aws_iam_role.default.*.name)
}

resource "aws_security_group" "default" {
  count       = var.enabled && var.use_existing_security_group == false ? 1 : 0
  name        = module.label.id
  description = "Security Group for EKS worker nodes"
  vpc_id      = var.vpc_id
  tags        = module.label.tags
}

resource "aws_security_group_rule" "egress" {
  count             = var.enabled && var.use_existing_security_group == false ? 1 : 0
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default.*.id)
  type              = "egress"
}

resource "aws_security_group_rule" "ingress_self" {
  count                    = var.enabled && var.use_existing_security_group == false ? 1 : 0
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = join("", aws_security_group.default.*.id)
  source_security_group_id = join("", aws_security_group.default.*.id)
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_cluster" {
  count                    = var.enabled && var.cluster_security_group_ingress_enabled && var.use_existing_security_group == false ? 1 : 0
  description              = "Allow worker kubelets and pods to receive communication from the cluster control plane"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = join("", aws_security_group.default.*.id)
  source_security_group_id = var.cluster_security_group_id
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = var.enabled && var.use_existing_security_group == false ? length(var.allowed_security_groups) : 0
  description              = "Allow inbound traffic from existing Security Groups"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = var.allowed_security_groups[count.index]
  security_group_id        = join("", aws_security_group.default.*.id)
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count             = var.enabled && length(var.allowed_cidr_blocks) > 0 && var.use_existing_security_group == false ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.default.*.id)
  type              = "ingress"
}

data "aws_ami" "eks_worker" {
  count = var.enabled && var.use_custom_image_id == false ? 1 : 0

  most_recent = true
  name_regex  = var.eks_worker_ami_name_regex

  filter {
    name   = "name"
    values = [var.eks_worker_ami_name_filter]
  }

  owners = ["602401143452"] # Amazon
}

data "template_file" "userdata" {
  count    = var.enabled ? 1 : 0
  template = file("${path.module}/userdata.tpl")

  vars = {
    cluster_endpoint                = var.cluster_endpoint
    certificate_authority_data      = var.cluster_certificate_authority_data
    cluster_name                    = var.cluster_name
    bootstrap_extra_args            = var.bootstrap_extra_args
    before_cluster_joining_userdata = var.before_cluster_joining_userdata
    after_cluster_joining_userdata  = var.after_cluster_joining_userdata
  }
}

data "aws_iam_instance_profile" "default" {
  count = var.enabled && var.use_existing_aws_iam_instance_profile ? 1 : 0
  name  = var.aws_iam_instance_profile_name
}

module "autoscale_group" {
  source = "git::https://github.com/cloudposse/terraform-aws-ec2-autoscale-group.git?ref=tags/0.2.0"

  enabled    = var.enabled
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = module.label.tags

  image_id                  = var.use_custom_image_id ? var.image_id : join("", data.aws_ami.eks_worker.*.id)
  iam_instance_profile_name = var.use_existing_aws_iam_instance_profile == false ? join("", aws_iam_instance_profile.default.*.name) : var.aws_iam_instance_profile_name

  security_group_ids = compact(
    concat(
      [
        var.use_existing_security_group == false ? join("", aws_security_group.default.*.id) : var.workers_security_group_id
      ],
      var.additional_security_group_ids
    )
  )

  user_data_base64 = base64encode(join("", data.template_file.userdata.*.rendered))

  instance_type                           = var.instance_type
  subnet_ids                              = var.subnet_ids
  min_size                                = var.min_size
  max_size                                = var.max_size
  associate_public_ip_address             = var.associate_public_ip_address
  block_device_mappings                   = var.block_device_mappings
  credit_specification                    = var.credit_specification
  disable_api_termination                 = var.disable_api_termination
  ebs_optimized                           = var.ebs_optimized
  elastic_gpu_specifications              = var.elastic_gpu_specifications
  instance_initiated_shutdown_behavior    = var.instance_initiated_shutdown_behavior
  instance_market_options                 = var.instance_market_options
  key_name                                = var.key_name
  placement                               = var.placement
  enable_monitoring                       = var.enable_monitoring
  load_balancers                          = var.load_balancers
  health_check_grace_period               = var.health_check_grace_period
  health_check_type                       = var.health_check_type
  min_elb_capacity                        = var.min_elb_capacity
  wait_for_elb_capacity                   = var.wait_for_elb_capacity
  target_group_arns                       = var.target_group_arns
  default_cooldown                        = var.default_cooldown
  force_delete                            = var.force_delete
  termination_policies                    = var.termination_policies
  suspended_processes                     = var.suspended_processes
  placement_group                         = var.placement_group
  enabled_metrics                         = var.enabled_metrics
  metrics_granularity                     = var.metrics_granularity
  wait_for_capacity_timeout               = var.wait_for_capacity_timeout
  protect_from_scale_in                   = var.protect_from_scale_in
  service_linked_role_arn                 = var.service_linked_role_arn
  autoscaling_policies_enabled            = var.autoscaling_policies_enabled
  scale_up_cooldown_seconds               = var.scale_up_cooldown_seconds
  scale_up_scaling_adjustment             = var.scale_up_scaling_adjustment
  scale_up_adjustment_type                = var.scale_up_adjustment_type
  scale_up_policy_type                    = var.scale_up_policy_type
  scale_down_cooldown_seconds             = var.scale_down_cooldown_seconds
  scale_down_scaling_adjustment           = var.scale_down_scaling_adjustment
  scale_down_adjustment_type              = var.scale_down_adjustment_type
  scale_down_policy_type                  = var.scale_down_policy_type
  cpu_utilization_high_evaluation_periods = var.cpu_utilization_high_evaluation_periods
  cpu_utilization_high_period_seconds     = var.cpu_utilization_high_period_seconds
  cpu_utilization_high_threshold_percent  = var.cpu_utilization_high_threshold_percent
  cpu_utilization_high_statistic          = var.cpu_utilization_high_statistic
  cpu_utilization_low_evaluation_periods  = var.cpu_utilization_low_evaluation_periods
  cpu_utilization_low_period_seconds      = var.cpu_utilization_low_period_seconds
  cpu_utilization_low_statistic           = var.cpu_utilization_low_statistic
  cpu_utilization_low_threshold_percent   = var.cpu_utilization_low_threshold_percent
}
