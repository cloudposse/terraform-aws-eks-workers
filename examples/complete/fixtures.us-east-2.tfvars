region = "us-east-2"

availability_zones = ["us-east-2a", "us-east-2b"]

namespace = "eg"

stage = "test"

name = "suite"

instance_type = "t2.small"

health_check_type = "EC2"

wait_for_capacity_timeout = "10m"

max_size = 3

min_size = 2

autoscaling_policies_enabled = true

cpu_utilization_high_threshold_percent = 80

cpu_utilization_low_threshold_percent = 20

cluster_name = "eg-test-eks-workers-cluster"

cluster_endpoint = ""

cluster_certificate_authority_data = ""

cluster_security_group_ingress_enabled = false
