# Amazon EKS Custom AMIs

## This is a forked repository from aws-samples/amazon-eks-custom-amis
## Customized to support generate EKS Optimized images for Debian 10/11 for EKS v1.21 to v1.24

#
#

This repository contains [Packer](https://packer.io/) configurations to create custom AMIs based on the [Amazon EKS optimized AMI](https://github.com/awslabs/amazon-eks-ami). The Amazon EKS Optimized AMI remains the preferred way to deploy containers on Amazon EKS and the configurations provided here are intended to provide a starting point for customers looking to implement custom EKS Optimized AMIs to meet additional security and compliance requirements.

This project applies the Docker CIS Benchmark and Amazon EKS CIS Benchmark to all AMIs. It also provides a number of additional hardening benchmarks such as DISA STIG, PCI-DSS, and HIPAA. These are based on [OpenSCAP](https://www.open-scap.org/) and other open source hardening guidelines.

_Scripts and artifacts created by this repository do not guarantee compliance nor are these AMIs are not officially supported by AWS. It is up to users to review and validate for their individual use cases._



## Prerequisites

- [Packer](https://packer.io/) v1.7+ - [installation instructions](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli)



## Use AMI

The AMI can be used with [self-managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/worker.html) and [EKS managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) within EKS. The AMIs built in this repository use the same [bootstrap script](https://github.com/awslabs/amazon-eks-ami/blob/master/files/bootstrap.sh) used in the EKS Optimized AMI. To join the cluster, run the following command on boot:

```bash
/etc/eks/bootstrap.sh <cluster name> --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup=<node group name>,eks.amazonaws.com/nodegroup-image=<ami id>'
```

## License

This library is licensed under the MIT-0 License. See the [LICENSE file](./LICENSE).
