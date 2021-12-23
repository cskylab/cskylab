# This script is designed to be sourced from cs-kvmserv.sh
# No shebang intentionally
# shellcheck disable=SC2148
# Variables not checked intentionally
# shellcheck disable=SC2154

#
# sudo cs-kvmserv.sh -m vm-create -n opn-aux -i /srv/setup/opn-tpl-sysdisk.qcow2 -s NONE -p /srv/vm-aux
#

virt-install --name "${vmachine_name}" \
    --virt-type kvm --memory 4096 --vcpus 2 \
    --boot hd,cdrom,menu=on --autostart \
    --disk path="${vmachines_path}/${vmachine_name}-setup.iso",device=cdrom \
    --disk path="${vmachines_path}/${vmachine_name}-sysdisk.qcow2",device=disk \
    --os-variant freebsd12.0 \
    --network network=br_sys \
    --network network=br_wan \
    --network network=br_sys_pfsync \
    --network network=br_mod_srv \
    --network network=br_pro_srv \
    --network network=br_usr \
    --network network=br_setup \
    --console pty,target_type=serial \
    --noautoconsole
