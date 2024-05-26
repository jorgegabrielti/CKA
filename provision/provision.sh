#!/bin/bash 

### Cluster Kubernetes install and configuration 
## Requirements:
# - ContainerD
# - CNI Plugins
# - kubeadm

# References:
# - https://v1-26.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
# - https://v1-26.docs.kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd-systemd
# - https://github.com/containerd/containerd/blob/main/docs/getting-started.md
# - https://docs.docker.com/engine/install/ubuntu/
# - https://v1-26.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
# - https://github.com/rajch/weave#using-weave-on-kubernetes

## Forwarding IPv4 and letting iptables see bridged traffic
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

lsmod | grep br_netfilter
lsmod | grep overlay

sudo sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

## containerd install
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo mkdir -m 755 /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y containerd.io

# Installing CNI plugins
wget https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz
wget https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz.sha256

sha256sum -c cni-plugins-linux-amd64-v1.2.0.tgz.sha256

sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.2.0.tgz

sudo sed -i 's/disabled_plugins \= \["cri"\]/#disabled_plugins \= \["cri"\]/g' /etc/containerd/config.toml

cat <<EOF | sudo tee /etc/containerd/config.toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
 [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
EOF

sudo systemctl restart containerd && sudo systemctl status containerd

## Installing kubeadm, kubelet and kubectl
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.26/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.26/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

### Swap disable
sudo swapoff -a 
grep swap /etc/fstab && sudo sed -i '/swap/d' /etc/fstab

#### Kubeadm requiriments install
sudo kubeadm config images pull

## kubeadm init
sudo kubeadm init --kubernetes-version=1.26.15
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl get nodes && kubectl get pods -n kube-system

## Network plugin install
kubectl apply -f https://reweave.azurewebsites.net/k8s/v1.26/net.yaml