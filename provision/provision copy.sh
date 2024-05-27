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
WORK_DIR="${PWD}"

### Import functions
for FUNCTION in $(grep -F 'Test: [OK]' -l -r ${WORK_DIR}/function/); do
  sed -i 's/\r$//' ${FUNCTION}
  source ${FUNCTION}
done

### Distro Detect
_distro_detect

### Kubernetes component detect
echo -e "\e[40;32;1m[TASK]: Kubernetes Component Detect\e[m\n"

case ${HOSTNAME} in
  "master01")
    echo -e "\tComponent: [Control-plane]\n"
    _control_plane_install
  ;;
  *)
    echo -e "\tComponent: [Worker]\n"
    _worker_install
  ;;
esac

