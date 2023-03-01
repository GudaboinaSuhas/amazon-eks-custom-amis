#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -o errexit

source /etc/packer/files/functions.sh

# wait for cloud-init to finish
wait_for_cloudinit

sudo sleep 180 && apt purge git -y

# upgrade the operating system
sudo apt-get update && sleep 180 && sudo apt-get upgrade -y && sudo apt-get clean && sudo apt-get autoremove -y

# removing auditd as it's not required now as Wazuh is getting removed
# install dependencies
apt-get install -y \
    ca-certificates \
    curl \
    audispd-plugins \
    parted \
    unzip \
    lsb-release

sudo apt purge git

#######################################################

### uncomment the below lines to install NVIDIA Tesla Driver and NVIDIA docker2

### will write functions later

##### for K8s <= 1.23 - Debian 10 #####
# sleep 20
# echo "deb http://deb.debian.org/debian buster-backports main contrib non-free" | sudo tee -a /etc/apt/sources.list

# sudo apt-get update && sudo apt install linux-headers-$(uname -r) -y
# sleep 10
# sudo apt-get clean && sudo apt-get autoremove -y
# sudo DEBIAN_FRONTEND=noninteractive apt-get install nvidia-tesla-470-driver -yqq

# # sleep 10
# distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
#       && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
#       && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
#             sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
#             sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# sudo apt-get update && sudo apt-get install -y nvidia-docker2 && sudo systemctl restart docker


##### for K8s >= 1.24 - Debian 11 #####
# sleep 20
# echo "deb http://cdn-aws.deb.debian.org/debian bullseye main contrib non-free" | sudo tee -a /etc/apt/sources.list

# sudo apt-get update && sudo apt install linux-headers-$(uname -r) -y
# sleep 10
# sudo apt-get clean && sudo apt-get autoremove -y
# sudo DEBIAN_FRONTEND=noninteractive apt-get install nvidia-tesla-470-driver -yqq

# sleep 10
# distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
#     && curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add - \
#     && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# # sudo apt-get update && sudo apt-get install -y nvidia-docker2 && sudo systemctl restart docker
# sudo apt-get update \
#     && sudo apt-get install -y nvidia-container-toolkit

# sudo apt list --installed *nvidia*


#######################################################

### Uncomment to install wazuh agents on nodes
# sudo apt-get install gpg -y
# curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg
# echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
# sudo apt-get update
# export WAZUH_MANAGER="URL"
# sudo apt-get install wazuh-agent ## && sudo systemctl stop wazuh-agent 
# sudo systemctl daemon-reload # necessary?
# # sudo systemctl enable wazuh-agent
# # sudo systemctl start wazuh-agent
# sed -i "s/^deb/#deb/" /etc/apt/sources.list.d/wazuh.list ## use mark hold instead.
# sudo apt-get update

#######################################################

# Setting system to use iptables-legacy instead of nftables on Debian
# this is required for the proper functioning of Kubernetes network setup
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy 
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

#######################################################


# removing the key came from hardened image.
# sudo sed -i '/eks/d' /home/admin/.ssh/authorized_keys

# removing debian-cis folder which was used for hardening on the base image.
sudo rm -rf /home/admin/debian-cis

sudo apt-get clean && sudo apt-get autoremove -y

install_jq

# enable audit log
# systemctl enable auditd && systemctl start auditd ## disable for wazuh?

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
