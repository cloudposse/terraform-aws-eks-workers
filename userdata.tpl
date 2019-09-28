#!/bin/bash

# userdata for EKS worker nodes to properly configure Kubernetes applications on EC2 instances
# https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html

${before_cluster_joining_userdata}

/etc/eks/bootstrap.sh --apiserver-endpoint '${cluster_endpoint}' --b64-cluster-ca '${certificate_authority_data}' ${bootstrap_extra_args} '${cluster_name}'

${after_cluster_joining_userdata}
