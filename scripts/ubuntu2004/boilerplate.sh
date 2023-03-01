#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -o errexit

source /etc/packer/files/functions.sh

# wait for cloud-init to finish
wait_for_cloudinit

# upgrade the operating system
sudo apt-get update && sleep 120 && sudo apt-get upgrade -y && sudo apt-get clean && sudo apt-get autoremove -y

# install dependencies
apt-get install -y \
    ca-certificates \
    curl \
    parted \
    unzip \
    lsb-release


### uncomment the below lines to install NVIDIA Tesla Driver and NVIDIA docker2
#
#
# sleep 20
# echo "deb http://deb.debian.org/debian buster-backports main contrib non-free" | sudo tee -a /etc/apt/sources.list

# sudo apt-get update && sudo apt install linux-headers-$(uname -r) -y
# sleep 10
# sudo apt-get clean && sudo apt-get autoremove -y
# sudo DEBIAN_FRONTEND=noninteractive apt-get install nvidia-tesla-470-driver -yqq

# sleep 10
# distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
#       && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
#       && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
#             sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
#             sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# sudo apt-get update && sudo apt-get install -y nvidia-docker2 && sudo systemctl restart docker

sudo apt-get clean && sudo apt-get autoremove -y

install_jq

# enable audit log
# systemctl enable auditd && systemctl start auditd

# enable the /etc/environment
configure_http_proxy

# install aws cli
install_awscliv2

# install ssm agent
# install_ssmagent

# partition the disks
systemctl stop rsyslog #irqbalance polkit
#partition_disks /dev/nvme1n1

reboot
