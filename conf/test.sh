#!/bin/bash

# Checking box_configs.yaml
BOX_CONFIGS=$(yq '.[].k8s_component' < /vagrant/conf/box_configs.yaml | wc -l)

for ((i=0; i<${BOX_CONFIGS}; i++)) 
do 
  HOSTS[$i]=$(yq ".[$i].k8s_component" < /vagrant/conf/box_configs.yaml)
  echo ${HOSTS[$i]}
done

echo ${HOSTS[*]}
