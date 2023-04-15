set -xeEuo pipefail
hostname m4Hostname
echo m4Hostname > /etc/hostname
ip a a 192.168.222.m4Id/24 dev eth1
ip l s eth1 up
#do not change subnet
kubeadm init --pod-network-cidr=10.244.0.0/16 --node-name=$(hostname) --apiserver-advertise-address=192.168.222.m4Id
mkdir ~/.kube
ln -s /etc/kubernetes/admin.conf /root/.kube/config
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
