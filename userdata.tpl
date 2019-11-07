#!/bin/bash

# userdata for EKS worker nodes to properly configure Kubernetes applications on EC2 instances
# https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
# https://aws.amazon.com/blogs/opensource/improvements-eks-worker-node-provisioning/
# https://github.com/awslabs/amazon-eks-ami/blob/master/files/bootstrap.sh#L97

${before_cluster_joining_userdata}

export KUBELET_EXTRA_ARGS=${bootstrap_extra_args}

/etc/eks/bootstrap.sh --apiserver-endpoint '${cluster_endpoint}' --b64-cluster-ca '${certificate_authority_data}' '${cluster_name}'

${after_cluster_joining_userdata}
