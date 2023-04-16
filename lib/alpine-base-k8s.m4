echo -e "192.168.222.1\talpine-k8s-control" >> /etc/hosts
echo -e "192.168.222.2\talpine-k8s-worker1" >> /etc/hosts
echo -e "192.168.222.3\talpine-k8s-worker2" >> /etc/hosts
sed -i "s/^#//" /etc/apk/repositories
#https://wiki.alpinelinux.org/wiki/K8s
#add kernel module for networking stuff
echo "br_netfilter" > /etc/modules-load.d/k8s.conf
modprobe br_netfilter
echo net.ipv4.ip_forward=1 > /etc/sysctl.d/m4Hostname.conf
sysctl net.ipv4.ip_forward=1
echo net.bridge.bridge-nf-call-iptables=1 >> /etc/sysctl.d/m4Hostname.conf
sysctl net.bridge.bridge-nf-call-iptables=1
apk add cni-plugin-flannel
apk add cni-plugins
apk add flannel
apk add flannel-contrib-cni
apk add kubelet
apk add kubeadm
apk add kubectl
apk add containerd
apk add uuidgen
apk add nfs-utils
#get rid of swap
cat /etc/fstab | grep -v swap > temp.fstab
cat temp.fstab > /etc/fstab
rm temp.fstab
swapoff -a
#Fix prometheus errors
mount --make-rshared /
echo "#!/bin/sh" > /etc/local.d/sharemetrics.start
echo "mount --make-rshared /" >> /etc/local.d/sharemetrics.start
chmod +x /etc/local.d/sharemetrics.start
rc-update add local
#Fix id error messages
uuidgen > /etc/machine-id
#Add services
rc-update add containerd
rc-update add kubelet
#Sync time
rc-update add ntpd
/etc/init.d/ntpd start
/etc/init.d/containerd start
##fix flannel
#ln -s /usr/libexec/cni/flannel-amd64 /usr/libexec/cni/flannel
#Pin your versions!  If you update and the nodes get out of sync, it implodes.
apk add 'kubelet=~1.26'
apk add 'kubeadm=~1.26'
apk add 'kubectl=~1.26'
#Note that in the future you will manually have to add a newer version the same way to upgrade.
poweroff
