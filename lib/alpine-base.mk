SshOpts = -i var/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=1 -o BatchMode=yes
Ssh222 = ssh $(SshOpts) -Tp 222
Wait = function wt { touch $@.w && while ! $(SHELL) -c "$$*"; do echo -e "Waiting for '$@'. $$(( $$(date +%s) - $$(stat -c %Y $@.w) )) seconds." && sleep 4; done && rm -f $@.w; } && wt

define AlpineBaseInstall
cat > answer << EOF
KEYMAPOPTS="us us"
HOSTNAMEOPTS=alpine-base
DEVDOPTS=mdev
INTERFACESOPTS="auto lo
iface lo inet loopback
auto eth0
iface eth0 inet dhcp
	hostname alpine-base
"
TIMEZONEOPTS=none
PROXYOPTS=none
APKREPOSOPTS="-1"
USEROPTS=none
SSHDOPTS=openssh
ROOTSSHKEY="http://10.0.2.2:8000/id_ed25519.pub"
NTPOPTS=none
DISKOPTS="-m sys /dev/sda"
#LBUOPTS="LABEL=APKOVL"
LBUOPTS=none
#APKCACHEOPTS="/media/LABEL=APKOVL/cache"
APKCACHEOPTS=none
EOF
echo y | setup-alpine -ef answer
mount /dev/sda3 /mnt
mount /dev/sda1 /mnt/boot
cd /mnt/root/.ssh
wget http://10.0.2.2:8000/id_ed25519.pub
wget http://10.0.2.2:8000/id_ed25519
chmod 600 id_ed25519
sed -i "s/ quiet / modprobe.blacklist=bochs /" /mnt/boot/extlinux.conf
sed -i "s/AllowTcpForwarding no/AllowTcpForwarding yes/" /mnt/etc/ssh/sshd_config
poweroff
endef
export AlpineBaseInstall

var/alpine-base : var/netboot/initramfs-virt var/netboot/modloop-virt var/netboot/vmlinuz-virt var/id_ed25519 var/daiker 
	-fuser -k $@.qcow2 $(Port)/tcp 8000/tcp && sleep 2
	rm -f $@.qcow2
	cd $(@D); python -m http.server & 
	var/daiker build -T 22-2220 -Q '-kernel var/netboot/vmlinuz-virt -initrd var/netboot/initramfs-virt -append alpine_repo=https://dl-cdn.alpinelinux.org/alpine/edge/main	modloop=http://10.0.2.2:8000/netboot/modloop-virt	ssh_key=http://10.0.2.2:8000/id_ed25519.pub	modprobe.blacklist=bochs' $$PWD/$@.qcow2 &
	$(Wait) $(Ssh222)0 root@localhost id
	echo "$$AlpineBaseInstall" | $(Ssh222)0 root@localhost 
	$(Wait) ! fuser $@.qcow2 $(Port)/tcp
	fuser -k 8000/tcp
	touch $@

var/netboot/% :
	mkdir -p $(@D)
	wget -qcO $@.tmp https://dl-cdn.alpinelinux.org/alpine/edge/releases/x86_64/netboot/$(@F)
	mv $@.tmp $@


var/id_ed25519 :
	mkdir -p $(@D)
	ssh-keygen -t ed25519 -C "$$PWD" -f $@ -N ""

var/daiker :
	mkdir -p $(@D)
	wget -cO $@.tmp https://raw.githubusercontent.com/daimh/daiker/master/daiker
	chmod +x $@.tmp
	mv $@.tmp $@
