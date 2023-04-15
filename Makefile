all : $(addprefix var/alpine-k8s-worker,1 2)
include lib/alpine-base.mk

define DaikerRun
	-fuser -k $@.qcow2 222$1/tcp
	rm -f $@.qcow2
	daiker run -e random -b $<.qcow2 -T 22-222$1 $@.qcow2 &
	$(Wait) $(Ssh222)$1 root@localhost id
	[ ! -f lib/$(@F).m4 ] || m4 -D m4Hostname=$(@F) -D m4Id=$1 lib/$(@F).m4 | $(Ssh222)$1 root@localhost
endef
define TmplWorker
var/alpine-k8s-worker$1 : var/alpine-base-k8s var/alpine-$3
	$$(call DaikerRun,$2)
	$(Ssh222)$2 root@localhost < var/kubeadm-join.sh
	touch $$@
endef
$(eval $(call TmplWorker,1,2,k8s-control))
$(eval $(call TmplWorker,2,3,k8s-control))
var/alpine-k8s-control : var/alpine-base-k8s
	$(call DaikerRun,1)
	$(Ssh222)1 root@localhost kubeadm token create --print-join-command > var/kubeadm-join.sh
	touch $@
var/alpine-base-k8s : var/alpine-base
	$(call DaikerRun,1)
	$(Wait) ! fuser $@.qcow2
	cd var; echo $(@F).qcow2 | daiker convert $(@F).qcow2
	touch $@

clean :
	-fuser -k var/*.qcow2
	rm -rf var
