set -xeEuo pipefail
hostname m4Hostname
echo m4Hostname > /etc/hostname
sleep 1
killall getty
