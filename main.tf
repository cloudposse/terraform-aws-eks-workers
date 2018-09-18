locals {
  tags = "${merge(var.tags, map("kubernetes.io/cluster/${var.cluster_name}", "owned"))}"

  # userdata for EKS worker nodes to properly configure Kubernetes applications on EC2 instances
  # https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
  userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${var.cluster_endpoint}' --b64-cluster-ca '${var.cluster_certificate_authority_data}' '${var.cluster_name}'
USERDATA

  # The EKS service does not provide a cluster-level API parameter or resource to automatically configure the underlying Kubernetes cluster to allow worker nodes to join the cluster via AWS IAM role authentication.
  # This is a Kubernetes ConfigMap configuration for worker nodes to join the cluster
  # https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html#required-kubernetes-configuration-to-join-worker-nodes
  config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.default.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.5.3"
  namespace   = "${var.namespace}"
  name        = "${var.name}"
  stage       = "${var.stage}"
  environment = "${var.environment}"
  delimiter   = "${var.delimiter}"
  attributes  = "${var.attributes}"
  tags        = "${local.tags}"
  enabled     = "${var.enabled}"
}

data "aws_iam_policy_document" "assume_role" {
  count = "${var.enabled == "true" ? 1 : 0}"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "default" {
  count              = "${var.enabled == "true" ? 1 : 0}"
  name               = "${module.label.id}"
  assume_role_policy = "${join("", data.aws_iam_policy_document.assume_role.*.json)}"
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  count      = "${var.enabled == "true" ? 1 : 0}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.default.name}"
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  count      = "${var.enabled == "true" ? 1 : 0}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${join("", aws_iam_role.default.*.name)}"
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  count      = "${var.enabled == "true" ? 1 : 0}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${join("", aws_iam_role.default.*.name)}"
}

resource "aws_iam_instance_profile" "default" {
  count = "${var.enabled == "true" ? 1 : 0}"
  name  = "${module.label.id}"
  role  = "${join("", aws_iam_role.default.*.name)}"
}

resource "aws_security_group" "default" {
  count       = "${var.enabled == "true" ? 1 : 0}"
  name        = "${module.label.id}"
  description = "Security Group for worker nodes"
  vpc_id      = "${var.vpc_id}"
  tags        = "${module.label.tags}"
}

resource "aws_security_group_rule" "egress" {
  count             = "${var.enabled == "true" ? 1 : 0}"
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${join("", aws_security_group.default.*.id)}"
  type              = "egress"
}

resource "aws_security_group_rule" "ingress_self" {
  count                    = "${var.enabled == "true" ? 1 : 0}"
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = "${join("", aws_security_group.default.*.id)}"
  source_security_group_id = "${aws_security_group.default.id}"
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_cluster" {
  count                    = "${var.enabled == "true" ? 1 : 0}"
  description              = "Allow worker kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = "${join("", aws_security_group.default.*.id)}"
  source_security_group_id = "${var.cluster_security_group_id}"
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = "${var.enabled == "true" ? length(var.allowed_security_groups) : 0}"
  description              = "Allow inbound traffic from existing Security Groups"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${element(var.allowed_security_groups, count.index)}"
  security_group_id        = "${join("", aws_security_group.default.*.id)}"
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count             = "${var.enabled == "true" && length(var.allowed_cidr_blocks) > 0 ? 1 : 0}"
  description       = "Allow inbound traffic from CIDR blocks"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["${var.allowed_cidr_blocks}"]
  security_group_id = "${join("", aws_security_group.default.*.id)}"
  type              = "ingress"
}

module "autoscale_group" {
  source = "git::https://github.com/cloudposse/terraform-aws-ec2-autoscale-group.git?ref=tags/0.1.1"

  enabled    = "${var.enabled}"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"

  iam_instance_profile_name = "${join("", aws_iam_instance_profile.default.*.name)}"
  security_group_ids        = ["${join("", aws_security_group.default.*.id)}"]
  user_data_base64          = "${base64encode(local.userdata)}"
  tags                      = "${module.label.tags}"

  image_id                                = "${var.image_id}"
  instance_type                           = "${var.instance_type}"
  subnet_ids                              = ["${var.subnet_ids}"]
  min_size                                = "${var.min_size}"
  max_size                                = "${var.max_size}"
  associate_public_ip_address             = "${var.associate_public_ip_address}"
  block_device_mappings                   = ["${var.block_device_mappings}"]
  credit_specification                    = ["${var.credit_specification}"]
  disable_api_termination                 = "${var.disable_api_termination}"
  ebs_optimized                           = "${var.ebs_optimized}"
  elastic_gpu_specifications              = ["${var.elastic_gpu_specifications}"]
  instance_initiated_shutdown_behavior    = "${var.instance_initiated_shutdown_behavior}"
  instance_market_options                 = ["${var.instance_market_options }"]
  key_name                                = "${var.key_name}"
  placement                               = ["${var.placement}"]
  enable_monitoring                       = "${var.enable_monitoring}"
  max_size                                = "${var.max_size}"
  min_size                                = "${var.min_size}"
  load_balancers                          = ["${var.load_balancers}"]
  health_check_grace_period               = "${var.health_check_grace_period}"
  health_check_type                       = "${var.health_check_type}"
  min_elb_capacity                        = "${var.min_elb_capacity}"
  wait_for_elb_capacity                   = "${var.wait_for_elb_capacity}"
  target_group_arns                       = ["${var.target_group_arns}"]
  default_cooldown                        = "${var.default_cooldown}"
  force_delete                            = "${var.force_delete}"
  termination_policies                    = "${var.termination_policies}"
  suspended_processes                     = "${var.suspended_processes}"
  placement_group                         = "${var.placement_group}"
  enabled_metrics                         = ["${var.enabled_metrics}"]
  metrics_granularity                     = "${var.metrics_granularity}"
  wait_for_capacity_timeout               = "${var.wait_for_capacity_timeout}"
  protect_from_scale_in                   = "${var.protect_from_scale_in}"
  service_linked_role_arn                 = "${var.service_linked_role_arn}"
  autoscaling_policies_enabled            = "${var.autoscaling_policies_enabled}"
  scale_up_cooldown_seconds               = "${var.scale_up_cooldown_seconds}"
  scale_up_scaling_adjustment             = "${var.scale_up_scaling_adjustment}"
  scale_up_adjustment_type                = "${var.scale_up_adjustment_type}"
  scale_up_policy_type                    = "${var.scale_up_policy_type}"
  scale_down_cooldown_seconds             = "${var.scale_down_cooldown_seconds}"
  scale_down_scaling_adjustment           = "${var.scale_down_scaling_adjustment}"
  scale_down_adjustment_type              = "${var.scale_down_adjustment_type}"
  scale_down_policy_type                  = "${var.scale_down_policy_type}"
  cpu_utilization_high_evaluation_periods = "${var.cpu_utilization_high_evaluation_periods}"
  cpu_utilization_high_period_seconds     = "${var.cpu_utilization_high_period_seconds}"
  cpu_utilization_high_threshold_percent  = "${var.cpu_utilization_high_threshold_percent}"
  cpu_utilization_high_statistic          = "${var.cpu_utilization_high_statistic}"
  cpu_utilization_low_evaluation_periods  = "${var.cpu_utilization_low_evaluation_periods}"
  cpu_utilization_low_period_seconds      = "${var.cpu_utilization_low_period_seconds}"
  cpu_utilization_low_statistic           = "${var.cpu_utilization_low_statistic}"
  cpu_utilization_low_threshold_percent   = "${var.cpu_utilization_low_threshold_percent}"
}
