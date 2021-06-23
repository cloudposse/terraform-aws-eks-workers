<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.0 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.0 |
| <a name="provider_template"></a> [template](#provider\_template) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_autoscale_group"></a> [autoscale\_group](#module\_autoscale\_group) | cloudposse/ec2-autoscale-group/aws | 0.26.0 |
| <a name="module_label"></a> [label](#module\_label) | cloudposse/label/null | 0.24.1 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | cloudposse/security-group/aws | 0.3.1 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.24.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.amazon_eks_cni_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.amazon_eks_worker_node_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.existing_policies_attach_to_eks_workers_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_ami.eks_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_instance_profile.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_instance_profile) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [template_file.userdata](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| <a name="input_after_cluster_joining_userdata"></a> [after\_cluster\_joining\_userdata](#input\_after\_cluster\_joining\_userdata) | Additional commands to execute on each worker node after joining the EKS cluster (after executing the `bootstrap.sh` script). For mot info, see https://kubedex.com/90-days-of-aws-eks-in-production | `string` | `""` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Associate a public IP address with an instance in a VPC | `bool` | `false` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_autoscaling_group_tags"></a> [autoscaling\_group\_tags](#input\_autoscaling\_group\_tags) | Additional tags only for the autoscaling group, e.g. "k8s.io/cluster-autoscaler/node-template/taint/dedicated" = "ci-cd:NoSchedule". | `map(string)` | `{}` | no |
| <a name="input_autoscaling_policies_enabled"></a> [autoscaling\_policies\_enabled](#input\_autoscaling\_policies\_enabled) | Whether to create `aws_autoscaling_policy` and `aws_cloudwatch_metric_alarm` resources to control Auto Scaling | `bool` | `true` | no |
| <a name="input_aws_iam_instance_profile_name"></a> [aws\_iam\_instance\_profile\_name](#input\_aws\_iam\_instance\_profile\_name) | The name of the existing instance profile that will be used in autoscaling group for EKS workers. If empty will create a new instance profile. | `string` | `""` | no |
| <a name="input_before_cluster_joining_userdata"></a> [before\_cluster\_joining\_userdata](#input\_before\_cluster\_joining\_userdata) | Additional commands to execute on each worker node before joining the EKS cluster (before executing the `bootstrap.sh` script). For mot info, see https://kubedex.com/90-days-of-aws-eks-in-production | `string` | `""` | no |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | Specify volumes to attach to the instance besides the volumes specified by the AMI | <pre>list(object({<br>    device_name  = string<br>    no_device    = bool<br>    virtual_name = string<br>    ebs = object({<br>      delete_on_termination = bool<br>      encrypted             = bool<br>      iops                  = number<br>      kms_key_id            = string<br>      snapshot_id           = string<br>      volume_size           = number<br>      volume_type           = string<br>    })<br>  }))</pre> | `[]` | no |
| <a name="input_bootstrap_extra_args"></a> [bootstrap\_extra\_args](#input\_bootstrap\_extra\_args) | Extra arguments to the `bootstrap.sh` script to enable `--enable-docker-bridge` or `--use-max-pods` | `string` | `""` | no |
| <a name="input_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#input\_cluster\_certificate\_authority\_data) | The base64 encoded certificate data required to communicate with the cluster | `string` | n/a | yes |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | EKS cluster endpoint | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the EKS cluster | `string` | n/a | yes |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| <a name="input_cpu_utilization_high_evaluation_periods"></a> [cpu\_utilization\_high\_evaluation\_periods](#input\_cpu\_utilization\_high\_evaluation\_periods) | The number of periods over which data is compared to the specified threshold | `number` | `2` | no |
| <a name="input_cpu_utilization_high_period_seconds"></a> [cpu\_utilization\_high\_period\_seconds](#input\_cpu\_utilization\_high\_period\_seconds) | The period in seconds over which the specified statistic is applied | `number` | `300` | no |
| <a name="input_cpu_utilization_high_statistic"></a> [cpu\_utilization\_high\_statistic](#input\_cpu\_utilization\_high\_statistic) | The statistic to apply to the alarm's associated metric. Either of the following is supported: `SampleCount`, `Average`, `Sum`, `Minimum`, `Maximum` | `string` | `"Average"` | no |
| <a name="input_cpu_utilization_high_threshold_percent"></a> [cpu\_utilization\_high\_threshold\_percent](#input\_cpu\_utilization\_high\_threshold\_percent) | The value against which the specified statistic is compared | `number` | `90` | no |
| <a name="input_cpu_utilization_low_evaluation_periods"></a> [cpu\_utilization\_low\_evaluation\_periods](#input\_cpu\_utilization\_low\_evaluation\_periods) | The number of periods over which data is compared to the specified threshold | `number` | `2` | no |
| <a name="input_cpu_utilization_low_period_seconds"></a> [cpu\_utilization\_low\_period\_seconds](#input\_cpu\_utilization\_low\_period\_seconds) | The period in seconds over which the specified statistic is applied | `number` | `300` | no |
| <a name="input_cpu_utilization_low_statistic"></a> [cpu\_utilization\_low\_statistic](#input\_cpu\_utilization\_low\_statistic) | The statistic to apply to the alarm's associated metric. Either of the following is supported: `SampleCount`, `Average`, `Sum`, `Minimum`, `Maximum` | `string` | `"Average"` | no |
| <a name="input_cpu_utilization_low_threshold_percent"></a> [cpu\_utilization\_low\_threshold\_percent](#input\_cpu\_utilization\_low\_threshold\_percent) | The value against which the specified statistic is compared | `number` | `10` | no |
| <a name="input_credit_specification"></a> [credit\_specification](#input\_credit\_specification) | Customize the credit specification of the instances | <pre>object({<br>    cpu_credits = string<br>  })</pre> | `null` | no |
| <a name="input_default_cooldown"></a> [default\_cooldown](#input\_default\_cooldown) | The amount of time, in seconds, after a scaling activity completes before another scaling activity can start | `number` | `300` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | If `true`, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | If true, the launched EC2 instance will be EBS-optimized | `bool` | `false` | no |
| <a name="input_eks_worker_ami_name_filter"></a> [eks\_worker\_ami\_name\_filter](#input\_eks\_worker\_ami\_name\_filter) | AMI name filter to lookup the most recent EKS AMI if `image_id` is not provided | `string` | `"amazon-eks-node-*"` | no |
| <a name="input_eks_worker_ami_name_regex"></a> [eks\_worker\_ami\_name\_regex](#input\_eks\_worker\_ami\_name\_regex) | A regex string to apply to the AMI list returned by AWS | `string` | `"^amazon-eks-node-[0-9,.]+-v[0-9]{8}$"` | no |
| <a name="input_elastic_gpu_specifications"></a> [elastic\_gpu\_specifications](#input\_elastic\_gpu\_specifications) | Specifications of Elastic GPU to attach to the instances | <pre>object({<br>    type = string<br>  })</pre> | `null` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enable/disable detailed monitoring | `bool` | `true` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_enabled_metrics"></a> [enabled\_metrics](#input\_enabled\_metrics) | A list of metrics to collect. The allowed values are `GroupMinSize`, `GroupMaxSize`, `GroupDesiredCapacity`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupTerminatingInstances`, `GroupTotalInstances` | `list(string)` | <pre>[<br>  "GroupMinSize",<br>  "GroupMaxSize",<br>  "GroupDesiredCapacity",<br>  "GroupInServiceInstances",<br>  "GroupPendingInstances",<br>  "GroupStandbyInstances",<br>  "GroupTerminatingInstances",<br>  "GroupTotalInstances"<br>]</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | Allows deleting the autoscaling group without waiting for all instances in the pool to terminate. You can force an autoscaling group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling | `bool` | `false` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Time (in seconds) after instance comes into service before checking health | `number` | `300` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | Controls how health checking is done. Valid values are `EC2` or `ELB` | `string` | `"EC2"` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | EC2 image ID to launch. If not provided, the module will lookup the most recent EKS AMI. See https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html for more details on EKS-optimized images | `string` | `""` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | Shutdown behavior for the instances. Can be `stop` or `terminate` | `string` | `"terminate"` | no |
| <a name="input_instance_market_options"></a> [instance\_market\_options](#input\_instance\_market\_options) | The market (purchasing) option for the instances | <pre>object({<br>    market_type = string<br>    spot_options = object({<br>      block_duration_minutes         = number<br>      instance_interruption_behavior = string<br>      max_price                      = number<br>      spot_instance_type             = string<br>      valid_until                    = string<br>    })<br>  })</pre> | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to launch | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | SSH key name that should be used for the instance | `string` | `""` | no |
| <a name="input_kubelet_extra_args"></a> [kubelet\_extra\_args](#input\_kubelet\_extra\_args) | Extra arguments to pass to kubelet, like "--register-with-taints=dedicated=ci-cd:NoSchedule --node-labels=purpose=ci-worker" | `string` | `""` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | The letter case of output label values (also used in `tags` and `id`).<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_load_balancers"></a> [load\_balancers](#input\_load\_balancers) | A list of elastic load balancer names to add to the autoscaling group. Only valid for classic load balancers. For ALBs, use `target_group_arns` instead | `list(string)` | `[]` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The maximum size of the autoscale group | `number` | n/a | yes |
| <a name="input_metadata_http_endpoint_enabled"></a> [metadata\_http\_endpoint\_enabled](#input\_metadata\_http\_endpoint\_enabled) | Set false to disable the Instance Metadata Service. | `bool` | `true` | no |
| <a name="input_metadata_http_put_response_hop_limit"></a> [metadata\_http\_put\_response\_hop\_limit](#input\_metadata\_http\_put\_response\_hop\_limit) | The desired HTTP PUT response hop limit (between 1 and 64) for Instance Metadata Service requests.<br>The default is `2` to support containerized workloads. | `number` | `2` | no |
| <a name="input_metadata_http_tokens_required"></a> [metadata\_http\_tokens\_required](#input\_metadata\_http\_tokens\_required) | Set true to require IMDS session tokens, disabling Instance Metadata Service Version 1. | `bool` | `true` | no |
| <a name="input_metrics_granularity"></a> [metrics\_granularity](#input\_metrics\_granularity) | The granularity to associate with the metrics to collect. The only valid value is 1Minute | `string` | `"1Minute"` | no |
| <a name="input_min_elb_capacity"></a> [min\_elb\_capacity](#input\_min\_elb\_capacity) | Setting this causes Terraform to wait for this number of instances to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes | `number` | `0` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | The minimum size of the autoscale group | `number` | n/a | yes |
| <a name="input_mixed_instances_policy"></a> [mixed\_instances\_policy](#input\_mixed\_instances\_policy) | policy to used mixed group of on demand/spot of differing types. Launch template is automatically generated. https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#mixed_instances_policy-1 | <pre>object({<br>    instances_distribution = object({<br>      on_demand_allocation_strategy            = string<br>      on_demand_base_capacity                  = number<br>      on_demand_percentage_above_base_capacity = number<br>      spot_allocation_strategy                 = string<br>      spot_instance_pools                      = number<br>      spot_max_price                           = string<br>    })<br>    override = list(object({<br>      instance_type     = string<br>      weighted_capacity = number<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| <a name="input_placement"></a> [placement](#input\_placement) | The placement specifications of the instances | <pre>object({<br>    affinity          = string<br>    availability_zone = string<br>    group_name        = string<br>    host_id           = string<br>    tenancy           = string<br>  })</pre> | `null` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | The name of the placement group into which you'll launch your instances, if any | `string` | `""` | no |
| <a name="input_protect_from_scale_in"></a> [protect\_from\_scale\_in](#input\_protect\_from\_scale\_in) | Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events | `bool` | `false` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_scale_down_adjustment_type"></a> [scale\_down\_adjustment\_type](#input\_scale\_down\_adjustment\_type) | Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are `ChangeInCapacity`, `ExactCapacity` and `PercentChangeInCapacity` | `string` | `"ChangeInCapacity"` | no |
| <a name="input_scale_down_cooldown_seconds"></a> [scale\_down\_cooldown\_seconds](#input\_scale\_down\_cooldown\_seconds) | The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start | `number` | `300` | no |
| <a name="input_scale_down_policy_type"></a> [scale\_down\_policy\_type](#input\_scale\_down\_policy\_type) | The scalling policy type, either `SimpleScaling`, `StepScaling` or `TargetTrackingScaling` | `string` | `"SimpleScaling"` | no |
| <a name="input_scale_down_scaling_adjustment"></a> [scale\_down\_scaling\_adjustment](#input\_scale\_down\_scaling\_adjustment) | The number of instances by which to scale. `scale_down_scaling_adjustment` determines the interpretation of this number (e.g. as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity | `number` | `-1` | no |
| <a name="input_scale_up_adjustment_type"></a> [scale\_up\_adjustment\_type](#input\_scale\_up\_adjustment\_type) | Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are `ChangeInCapacity`, `ExactCapacity` and `PercentChangeInCapacity` | `string` | `"ChangeInCapacity"` | no |
| <a name="input_scale_up_cooldown_seconds"></a> [scale\_up\_cooldown\_seconds](#input\_scale\_up\_cooldown\_seconds) | The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start | `number` | `300` | no |
| <a name="input_scale_up_policy_type"></a> [scale\_up\_policy\_type](#input\_scale\_up\_policy\_type) | The scalling policy type, either `SimpleScaling`, `StepScaling` or `TargetTrackingScaling` | `string` | `"SimpleScaling"` | no |
| <a name="input_scale_up_scaling_adjustment"></a> [scale\_up\_scaling\_adjustment](#input\_scale\_up\_scaling\_adjustment) | The number of instances by which to scale. `scale_up_adjustment_type` determines the interpretation of this number (e.g. as an absolute number or as a percentage of the existing Auto Scaling group size). A positive increment adds to the current capacity and a negative value removes from the current capacity | `number` | `1` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | The Security Group description. | `string` | `"Security Group for EKS worker nodes"` | no |
| <a name="input_security_group_enabled"></a> [security\_group\_enabled](#input\_security\_group\_enabled) | Whether to create default Security Group for EKS worker nodes. | `bool` | `true` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | A list of maps of Security Group rules. <br>The values of map is fully complated with `aws_security_group_rule` resource. <br>To get more info see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule . | `list(any)` | <pre>[<br>  {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "description": "Allow all outbound traffic",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "to_port": 65535,<br>    "type": "egress"<br>  }<br>]</pre> | no |
| <a name="input_security_group_use_name_prefix"></a> [security\_group\_use\_name\_prefix](#input\_security\_group\_use\_name\_prefix) | Whether to create a default Security Group with unique name beginning with the normalized prefix. | `bool` | `false` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list of Security Group IDs to associate with EKS worker nodes. | `list(string)` | `[]` | no |
| <a name="input_service_linked_role_arn"></a> [service\_linked\_role\_arn](#input\_service\_linked\_role\_arn) | The ARN of the service-linked role that the ASG will use to call other AWS services | `string` | `""` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs to launch resources in | `list(string)` | n/a | yes |
| <a name="input_suspended_processes"></a> [suspended\_processes](#input\_suspended\_processes) | A list of processes to suspend for the AutoScaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`. Note that if you suspend either the `Launch` or `Terminate` process types, it can prevent your autoscaling group from functioning properly. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | A list of aws\_alb\_target\_group ARNs, for use with Application Load Balancing | `list(string)` | `[]` | no |
| <a name="input_termination_policies"></a> [termination\_policies](#input\_termination\_policies) | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `Default` | `list(string)` | <pre>[<br>  "Default"<br>]</pre> | no |
| <a name="input_use_custom_image_id"></a> [use\_custom\_image\_id](#input\_use\_custom\_image\_id) | If set to `true`, will use variable `image_id` for the EKS workers inside autoscaling group | `bool` | `false` | no |
| <a name="input_use_existing_aws_iam_instance_profile"></a> [use\_existing\_aws\_iam\_instance\_profile](#input\_use\_existing\_aws\_iam\_instance\_profile) | If set to `true`, will use variable `aws_iam_instance_profile_name` to run EKS workers using an existing AWS instance profile that was created outside of this module, workaround for error like `count cannot be computed` | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for the EKS cluster | `string` | n/a | yes |
| <a name="input_wait_for_capacity_timeout"></a> [wait\_for\_capacity\_timeout](#input\_wait\_for\_capacity\_timeout) | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior | `string` | `"10m"` | no |
| <a name="input_wait_for_elb_capacity"></a> [wait\_for\_elb\_capacity](#input\_wait\_for\_elb\_capacity) | Setting this will cause Terraform to wait for exactly this number of healthy instances in all attached load balancers on both create and update operations. Takes precedence over `min_elb_capacity` behavior | `number` | `0` | no |
| <a name="input_workers_role_policy_arns"></a> [workers\_role\_policy\_arns](#input\_workers\_role\_policy\_arns) | List of policy ARNs that will be attached to the workers default role on creation | `list(string)` | `[]` | no |
| <a name="input_workers_role_policy_arns_count"></a> [workers\_role\_policy\_arns\_count](#input\_workers\_role\_policy\_arns\_count) | Count of policy ARNs that will be attached to the workers default role on creation. Needed to prevent Terraform error `count can't be computed` | `number` | `0` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_group_arn"></a> [autoscaling\_group\_arn](#output\_autoscaling\_group\_arn) | ARN of the AutoScaling Group |
| <a name="output_autoscaling_group_default_cooldown"></a> [autoscaling\_group\_default\_cooldown](#output\_autoscaling\_group\_default\_cooldown) | Time between a scaling activity and the succeeding scaling activity |
| <a name="output_autoscaling_group_desired_capacity"></a> [autoscaling\_group\_desired\_capacity](#output\_autoscaling\_group\_desired\_capacity) | The number of Amazon EC2 instances that should be running in the group |
| <a name="output_autoscaling_group_health_check_grace_period"></a> [autoscaling\_group\_health\_check\_grace\_period](#output\_autoscaling\_group\_health\_check\_grace\_period) | Time after instance comes into service before checking health |
| <a name="output_autoscaling_group_health_check_type"></a> [autoscaling\_group\_health\_check\_type](#output\_autoscaling\_group\_health\_check\_type) | `EC2` or `ELB`. Controls how health checking is done |
| <a name="output_autoscaling_group_id"></a> [autoscaling\_group\_id](#output\_autoscaling\_group\_id) | The AutoScaling Group ID |
| <a name="output_autoscaling_group_max_size"></a> [autoscaling\_group\_max\_size](#output\_autoscaling\_group\_max\_size) | The maximum size of the AutoScaling Group |
| <a name="output_autoscaling_group_min_size"></a> [autoscaling\_group\_min\_size](#output\_autoscaling\_group\_min\_size) | The minimum size of the AutoScaling Group |
| <a name="output_autoscaling_group_name"></a> [autoscaling\_group\_name](#output\_autoscaling\_group\_name) | The AutoScaling Group name |
| <a name="output_autoscaling_group_tags"></a> [autoscaling\_group\_tags](#output\_autoscaling\_group\_tags) | A list of tag settings associated with the AutoScaling Group |
| <a name="output_launch_template_arn"></a> [launch\_template\_arn](#output\_launch\_template\_arn) | ARN of the launch template |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | The ID of the launch template |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | ARN of the worker nodes Security Group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the worker nodes Security Group |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | Name of the worker nodes Security Group |
| <a name="output_workers_role_arn"></a> [workers\_role\_arn](#output\_workers\_role\_arn) | ARN of the worker nodes IAM role |
| <a name="output_workers_role_name"></a> [workers\_role\_name](#output\_workers\_role\_name) | Name of the worker nodes IAM role |
<!-- markdownlint-restore -->
