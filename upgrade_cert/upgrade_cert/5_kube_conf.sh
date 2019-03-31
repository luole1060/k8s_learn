mv ~/.kube/config ~/.kube/config.old
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo chmod 777 $HOME/.kube/config
export KUBECONFIG=.kube/config
