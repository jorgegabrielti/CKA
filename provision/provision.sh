#!/bin/bash 
#
# ##########################################################################
# +----------------------------------------------------------------------+ #
# |                 Cluster Kubernetes - Kubeadm                         | #
# +----------------------------------------------------------------------+ #
# |                                                                      | #
# | Name          : provision.sh                                         | #
# | Function      : Cluster Kubernetes install and                       | #
# |                      configuration with Kubeadm.                     | #
# | Version       : 1.0                                                  | #
# | Author        : Jorge Gabriel (DevOps Engineer)                      | #
# +----------------------------------------------------------------------+ #
# ##########################################################################
#
# Description:
#
# Algortimo do script :
#  Automation to aws iam management.
# --------------------------------------------------------------------------
### Alias eXpands
shopt -s expand_aliases

### Workdir
WORK_DIR="/vagrant"

### Requirements
# yq
yq --version && echo "yq already install." \
|| wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq

### Import functions
for FUNCTION in $(grep -F 'Test: [OK]' -l -r ${WORK_DIR}/provision/function/); do
  sed -i 's/\r$//' ${FUNCTION}
  source ${FUNCTION}
done

### Distro Detect
_distro_detect

### Packages installations
_packages_install

### Kubernetes component detect
echo -e "\e[40;32;1m[TASK]: Kubernetes Component Detect\e[m\n"

# Get count total objects in /vagrant/conf/box_configs.yaml
BOX_CONFIGS=$(yq e '.[].kubernetes_component' - < ${WORK_DIR}/conf/box_configs.yaml | wc -l)

for ((i=0; i<${BOX_CONFIGS}; i++)) 
do 
  yq e ".[$i]" - < /vagrant/conf/box_configs.yaml | grep -E "${HOSTNAME}" > /dev/null \
  && KUBERNETES_COMPONENT=$(yq e ".[$i].kubernetes_component" - < /vagrant/conf/box_configs.yaml)
done

case ${KUBERNETES_COMPONENT} in
  "control-plane")
    echo -e "\tComponent: [Control-plane]\n"
    _container_runtime_install
    _kubeadm_install
    _cluster_init
  ;;
  "worker-node")
    echo -e "\tComponent: [Worker-node]\n"
    _container_runtime_install
    _kubeadm_install
  ;;
  *)
    echo "Invalid config. Check key: "kubernetes_component" in box_configs.yaml"
    exit 0
  ;;
esac

