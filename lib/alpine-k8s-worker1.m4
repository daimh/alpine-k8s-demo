set -xeEuo pipefail
hostname m4Hostname
echo m4Hostname > /etc/hostname
ip a a 192.168.222.m4Id/24 dev eth1
ip l s eth1 up
