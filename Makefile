
PACKER_VARIABLES := binary_bucket_name binary_bucket_region eks_version eks_build_date cni_plugin_version root_volume_size data_volume_size hardening_flag http_proxy https_proxy no_proxy
VPC_ID := vpc-75*****
SUBNET_ID := subnet-061*******
AWS_REGION := us-east-1
PACKER_FILE := 

EKS_BUILD_DATE := 2020-11-02
EKS_115_VERSION := 1.15.12
EKS_116_VERSION := 1.16.15
EKS_117_VERSION := 1.17.12
EKS_118_VERSION := 1.18.9
EKS_119_VERSION := 1.19.6
EKS_120_VERSION := 1.20.11
EKS_121_VERSION := 1.21.14

EKS_122_VERSION := 1.22.15
EKS_123_VERSION := 1.23.12

build:
	packer build \
		--var 'aws_region=$(AWS_REGION)' \
		--var 'vpc_id=$(VPC_ID)' \
		--var 'subnet_id=$(SUBNET_ID)' \
		$(foreach packerVar,$(PACKER_VARIABLES), $(if $($(packerVar)),--var $(packerVar)='$($(packerVar))',)) \
		$(PACKER_FILE)


# Debian 10
#-----------------------------------------------------

build-debian10-1.19:
	$(MAKE) build PACKER_FILE=amazon-eks-node-debian10.json eks_version=$(EKS_119_VERSION) eks_build_date=2021-01-05

build-debian10-1.20:
	$(MAKE) build PACKER_FILE=amazon-eks-node-debian10.json eks_version=$(EKS_120_VERSION) eks_build_date=2021-11-10

build-debian10-1.21:
	$(MAKE) build PACKER_FILE=amazon-eks-node-debian10-hardened.json eks_version=$(EKS_121_VERSION) eks_build_date=2022-07-27

build-debian10-1.22:
	$(MAKE) build PACKER_FILE=amazon-eks-node-debian10-hardened.json eks_version=$(EKS_122_VERSION) eks_build_date=2022-10-05

build-debian10-1.23:
	$(MAKE) build PACKER_FILE=amazon-eks-node-debian10-hardened.json eks_version=$(EKS_123_VERSION) eks_build_date=2022-10-05


# Debian 10 - ARM
#-----------------------------------------------------

build-debian10-arm-1.21:
	$(MAKE) build PACKER_FILE=amazon-eks-node-debian10-arm-hardened.json eks_version=1.21.12 eks_build_date=2022-05-20

build-debian10-arm-1.22:
	$(MAKE) build PACKER_FILE=amazon-eks-node-debian10-arm-hardened.json eks_version=$(EKS_122_VERSION) eks_build_date=2022-10-05

build-debian10-arm-1.23:
	$(MAKE) build PACKER_FILE=amazon-eks-node-debian10-arm-hardened.json eks_version=$(EKS_123_VERSION) eks_build_date=2022-10-05



# Debian 11
#-----------------------------------------------------

build-debian11-1.19:
	$(MAKE) build PACKER_FILE=amazon-eks-node-debian11.json eks_version=$(EKS_119_VERSION) eks_build_date=2021-01-05

build-debian11-1.20:
	$(MAKE) build PACKER_FILE=amazon-eks-node-debian11.json eks_version=$(EKS_120_VERSION) eks_build_date=2021-11-10

build-debian11-1.21:
	$(MAKE) build PACKER_FILE=amazon-eks-node-debian11.json eks_version=$(EKS_121_VERSION) eks_build_date=2022-01-21

