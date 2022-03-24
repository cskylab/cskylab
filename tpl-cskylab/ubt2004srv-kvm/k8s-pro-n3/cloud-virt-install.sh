# This script is designed to be sourced from cs-kvmserv.sh
# No shebang intentionally
# shellcheck disable=SC2148
# Variables not checked intentionally
# shellcheck disable=SC2154

#
# sudo cs-kvmserv.sh -m vm-create -n k8s-pro-n3 -i /srv/setup/focal-server-cloudimg-amd64.img -s 80G -p /srv/vmachines
#

virt-install --name "${vmachine_name}" \
    --virt-type kvm --memory 32768 --vcpus 4 \
    --boot hd,cdrom,menu=on --autostart \
    --disk path="${vmachines_path}/${vmachine_name}-setup.iso",device=cdrom \
    --disk path="${vmachines_path}/${vmachine_name}-sysdisk.qcow2",device=disk \
    --disk path="${vmachines_path}/${vmachine_name}-datadisk.qcow2",device=disk,size=256 \
    --os-variant ubuntu20.04 \
    --network network=br_pro_srv \
    --console pty,target_type=serial \
    --noautoconsole
