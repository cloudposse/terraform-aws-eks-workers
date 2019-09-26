output "launch_template_id" {
  description = "The ID of the launch template"
  value       = module.autoscale_group.launch_template_id
}

output "launch_template_arn" {
  description = "ARN of the launch template"
  value       = module.autoscale_group.launch_template_arn
}

output "autoscaling_group_id" {
  description = "The AutoScaling Group ID"
  value       = module.autoscale_group.autoscaling_group_id
}

output "autoscaling_group_name" {
  description = "The AutoScaling Group name"
  value       = module.autoscale_group.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "ARN of the AutoScaling Group"
  value       = module.autoscale_group.autoscaling_group_arn
}

output "autoscaling_group_min_size" {
  description = "The minimum size of the AutoScaling Group"
  value       = module.autoscale_group.autoscaling_group_min_size
}

output "autoscaling_group_max_size" {
  description = "The maximum size of the AutoScaling Group"
  value       = module.autoscale_group.autoscaling_group_max_size
}

output "autoscaling_group_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  value       = module.autoscale_group.autoscaling_group_desired_capacity
}

output "autoscaling_group_default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  value       = module.autoscale_group.autoscaling_group_default_cooldown
}

output "autoscaling_group_health_check_grace_period" {
  description = "Time after instance comes into service before checking health"
  value       = module.autoscale_group.autoscaling_group_health_check_grace_period
}

output "autoscaling_group_health_check_type" {
  description = "`EC2` or `ELB`. Controls how health checking is done"
  value       = module.autoscale_group.autoscaling_group_health_check_type
}

output "security_group_id" {
  description = "ID of the worker nodes Security Group"
  value       = join("", aws_security_group.default.*.id)
}

output "security_group_arn" {
  description = "ARN of the worker nodes Security Group"
  value       = join("", aws_security_group.default.*.arn)
}

output "security_group_name" {
  description = "Name of the worker nodes Security Group"
  value       = join("", aws_security_group.default.*.name)
}

output "workers_role_arn" {
  description = "ARN of the worker nodes IAM role"
  value       = local.workers_role_arn
}

output "workers_role_name" {
  description = "Name of the worker nodes IAM role"
  value       = local.workers_role_name
}
