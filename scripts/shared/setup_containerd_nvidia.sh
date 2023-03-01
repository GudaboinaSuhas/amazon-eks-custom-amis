#!/usr/bin/env bash

# install runc and lock version
# sudo apt install -y runc-${RUNC_VERSION}
# sudo apt versionlock runc-*

# # install containerd and lock version
# sudo apt install -y containerd-${CONTAINERD_VERSION}
# sudo apt versionlock containerd-*

# sudo mkdir -p /etc/eks/containerd
# if [ -f "/etc/eks/containerd/containerd-config.toml" ]; then
#   ## this means we are building a gpu ami and have already placed a containerd configuration file in /etc/eks
#   echo "containerd config is already present"
# else
#   sudo mv $TEMPLATE_DIR/containerd-config.toml /etc/eks/containerd/containerd-config.toml
# fi

# if vercmp "$KUBERNETES_VERSION" gteq "1.22.0"; then
#   # enable CredentialProviders features in kubelet-containerd service file
#   IMAGE_CREDENTIAL_PROVIDER_FLAGS='\\\n    --image-credential-provider-config /etc/eks/ecr-credential-provider/ecr-credential-provider-config \\\n   --image-credential-provider-bin-dir /etc/eks/ecr-credential-provider'
#   sudo sed -i s,"aws","aws $IMAGE_CREDENTIAL_PROVIDER_FLAGS", $TEMPLATE_DIR/kubelet-containerd.service
# fi

# sudo mv $TEMPLATE_DIR/kubelet-containerd.service /etc/eks/containerd/kubelet-containerd.service
# sudo mv $TEMPLATE_DIR/sandbox-image.service /etc/eks/containerd/sandbox-image.service
# sudo mv $TEMPLATE_DIR/pull-sandbox-image.sh /etc/eks/containerd/pull-sandbox-image.sh
# sudo mv $TEMPLATE_DIR/pull-image.sh /etc/eks/containerd/pull-image.sh
# sudo chmod +x /etc/eks/containerd/pull-sandbox-image.sh
# sudo chmod +x /etc/eks/containerd/pull-image.sh

###

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

# cat << EOF | sudo tee -a /etc/eks/containerd/pull-sandbox-image.sh
# #!/usr/bin/env bash

# ### fetching sandbox image from /etc/containerd/config.toml
# sandbox_image=$(awk -F'[ ="]+' '$1 == "sandbox_image" { print $2 }' /etc/containerd/config.toml)
# region=$(echo "$sandbox_image" | cut -f4 -d ".")
# ecr_password=$(aws ecr get-login-password --region $region)
# API_RETRY_ATTEMPTS=5

# for attempt in $(seq 0 $API_RETRY_ATTEMPTS); do
#   rc=0
#   if [[ $attempt -gt 0 ]]; then
#     echo "Attempt $attempt of $API_RETRY_ATTEMPTS"
#   fi
#   ### pull sandbox image from ecr
#   ### username will always be constant i.e; AWS
#   sudo ctr --namespace k8s.io image pull $sandbox_image --user AWS:$ecr_password
#   rc=$?
#   if [[ $rc -eq 0 ]]; then
#     break
#   fi
#   if [[ $attempt -eq $API_RETRY_ATTEMPTS ]]; then
#     exit $rc
#   fi
#   jitter=$((1 + RANDOM % 10))
#   sleep_sec="$(($((5 << $((1 + $attempt)))) + $jitter))"
#   sleep $sleep_sec
# done
# EOF

# sudo chmod +x /etc/eks/containerd/pull-sandbox-image.sh


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

sudo rm /etc/containerd/config.toml

cat << EOF | sudo tee -a /etc/containerd/config.toml
version = 2
root = "/var/lib/containerd"
state = "/run/containerd"

[grpc]
address = "/run/containerd/containerd.sock"

[plugins."io.containerd.grpc.v1.cri".containerd]
default_runtime_name = "nvidia"

[plugins."io.containerd.grpc.v1.cri"]
sandbox_image = "602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/pause:3.5"

[plugins."io.containerd.grpc.v1.cri".registry]
config_path = "/etc/containerd/certs.d:/etc/docker/certs.d"

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
runtime_type = "io.containerd.runc.v2"

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
SystemdCgroup = true

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
privileged_without_host_devices = false
runtime_engine = ""
runtime_root = ""
runtime_type = "io.containerd.runc.v1"
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
BinaryName = "/usr/bin/nvidia-container-runtime"
SystemdCgroup = true

[plugins."io.containerd.grpc.v1.cri".cni]
bin_dir = "/opt/cni/bin"
conf_dir = "/etc/cni/net.d"
EOF
