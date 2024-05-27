# Test: [OK]
_cluster_init () { 

    #### Kubeadm requiriments install
    kubeadm config images pull
    
    ## kubeadm init
    kubeadm init --kubernetes-version=1.26.15
    export KUBECONFIG=/etc/kubernetes/admin.conf
    
    mkdir -p /home/vagrant/.kube
    sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
    sudo chown vagrant:vagrant /home/vagrant/.kube/config
    
    kubectl get nodes && kubectl get pods -n kube-system
    
    ## Network plugin install
    kubectl apply -f https://reweave.azurewebsites.net/k8s/v1.26/net.yaml

}