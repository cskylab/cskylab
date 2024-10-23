# This script is designed to be sourced from cs-kvmserv.sh
# No shebang intentionally
# shellcheck disable=SC2148
# Variables not checked intentionally
# shellcheck disable=SC2154

#
# Create virtual machine
#
#   Template lines to customize:
#       --virt-type kvm --memory 2048 --vcpus 2 \
#       --os-variant ubuntu24.04 \
#       --network network=br_mod_srv \
#       --disk path="${vmachines_path}/${vmachine_name}-datadisk.qcow2",device=disk,size=256 \
#
#   Ref.: http://manpages.ubuntu.com/manpages/focal/man1/virt-install.1.html
#

#
#   srvtest: Server test with system and data disks
#
#   Command:
#
#   sudo cs-kvmserv.sh -m vm-create -n srvtest -i /srv/setup/focal-server-cloudimg-amd64.img -s 80G -p /srv/vmachines
#

virt-install --name "${vmachine_name}" \
    --virt-type kvm --memory 2048 --vcpus 2 \
    --boot hd,cdrom,menu=on --autostart \
    --disk path="${vmachines_path}/${vmachine_name}-setup.iso",device=cdrom \
    --disk path="${vmachines_path}/${vmachine_name}-sysdisk.qcow2",device=disk \
    --disk path="${vmachines_path}/${vmachine_name}-datadisk.qcow2",device=disk,size=256 \
    --os-variant ubuntu24.04 \
    --network network=br_mod_srv \
    --console pty,target_type=serial \
    --noautoconsole
