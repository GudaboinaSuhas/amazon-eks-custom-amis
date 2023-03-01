#!/usr/bin/env bash

sudo apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install containerd.io -y && sudo apt-get clean && sudo apt-get autoremove -y

sudo mkdir -p /etc/eks/containerd
sudo curl -sL -o /etc/containerd/config.toml https://raw.githubusercontent.com/awslabs/amazon-eks-ami/master/files/containerd-config.toml

sudo curl -sL -o /etc/eks/containerd/sandbox-image.service https://raw.githubusercontent.com/awslabs/amazon-eks-ami/master/files/sandbox-image.service

sudo curl -sL -o /etc/eks/containerd/pull-sandbox-image.sh https://raw.githubusercontent.com/awslabs/amazon-eks-ami/master/files/pull-sandbox-image.sh
sudo chmod +x /etc/eks/containerd/pull-sandbox-image.sh

sudo curl -sL -o /etc/eks/iptables-restore.service https://raw.githubusercontent.com/awslabs/amazon-eks-ami/master/files/iptables-restore.service

sudo curl -sL -o /etc/eks/containerd/pull-image.sh https://raw.githubusercontent.com/awslabs/amazon-eks-ami/master/files/pull-image.sh
sudo chmod +x /etc/eks/containerd/pull-image.sh

sudo curl -sL -o /etc/eks/containerd/kubelet-containerd.service https://raw.githubusercontent.com/awslabs/amazon-eks-ami/master/files/kubelet-containerd.service

sudo mkdir -p /etc/eks/ecr-credential-provider && cd /etc/eks/ecr-credential-provider
sudo wget https://amazon-eks.s3.us-west-2.amazonaws.com/1.24.7/2022-10-31/bin/linux/amd64/ecr-credential-provider
sudo chmod +x ecr-credential-provider

sudo curl -sL -o /etc/eks/ecr-credential-provider/ecr-credential-provider-config https://raw.githubusercontent.com/awslabs/amazon-eks-ami/master/files/ecr-credential-provider-config
###

sudo mkdir -p /etc/systemd/system/containerd.service.d
cat << EOF | sudo tee /etc/systemd/system/containerd.service.d/10-compat-symlink.conf
[Service]
ExecStartPre=/bin/ln -sf /run/containerd/containerd.sock /run/dockershim.sock
EOF

cat << EOF | sudo tee -a /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

cat << EOF | sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF