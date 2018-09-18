output "launch_template_id" {
  description = "ID of the launch template"
  value       = "${module.eks_workers.launch_template_id}"
}

output "launch_template_arn" {
  description = "ARN of the launch template"
  value       = "${module.eks_workers.launch_template_arn}"
}

output "autoscaling_group_id" {
  description = "The AutoScaling Group ID"
  value       = "${module.eks_workers.autoscaling_group_id}"
}

output "autoscaling_group_name" {
  description = "The AutoScaling Group name"
  value       = "${module.eks_workers.autoscaling_group_name}"
}

output "autoscaling_group_arn" {
  description = "ARN of the AutoScaling Group"
  value       = "${module.eks_workers.autoscaling_group_arn}"
}

output "autoscaling_group_min_size" {
  description = "The minimum size of the AutoScaling Group"
  value       = "${module.eks_workers.autoscaling_group_min_size}"
}

output "autoscaling_group_max_size" {
  description = "The maximum size of the AutoScaling Group"
  value       = "${module.eks_workers.autoscaling_group_max_size}"
}

output "autoscaling_group_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  value       = "${module.eks_workers.autoscaling_group_desired_capacity}"
}

output "autoscaling_group_default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  value       = "${module.eks_workers.autoscaling_group_default_cooldown}"
}

output "autoscaling_group_health_check_grace_period" {
  description = "Time after instance comes into service before checking health"
  value       = "${module.eks_workers.autoscaling_group_health_check_grace_period}"
}

output "autoscaling_group_health_check_type" {
  description = "`EC2` or `ELB`. Controls how health checking is done"
  value       = "${module.eks_workers.autoscaling_group_health_check_type}"
}

output "security_group_id" {
  description = "ID of the worker nodes Security Group"
  value       = "${module.eks_workers.security_group_id}"
}

output "security_group_arn" {
  description = "ARN of the worker nodes Security Group"
  value       = "${module.eks_workers.security_group_arn}"
}

output "security_group_name" {
  description = "Name of the worker nodes Security Group"
  value       = "${module.eks_workers.security_group_name}"
}

output "config_map_aws_auth" {
  description = "Kubernetes ConfigMap configuration for worker nodes to join the EKS cluster. https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html#required-kubernetes-configuration-to-join-worker-nodes"
  value       = "${module.eks_workers.config_map_aws_auth}"
}
