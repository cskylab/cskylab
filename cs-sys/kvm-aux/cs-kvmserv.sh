#!/bin/bash

#
#   cs-kvmserv.sh
#
#       KVM Services.
#
#   Copyright © 2021 cSkyLab.com
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

# Shell options
set -e          # Exit immediately if a command exits with a non-zero status.
set -u          # Treat unset variables as an error when substituting.
set -o pipefail # Exit with a non-zero status in any pipelined command.
# set -x        # Print commands and their arguments as they are executed.

################################################################################
# Usage message
################################################################################

usage_msg="$(
  cat <<EOF

Purpose:
  KVM Services.

Usage:
  sudo cs-kvmserv.sh  [-l] [-m <execution_mode>] [-n <vmachine_name>]
                      [-p <vmachines_path>] [-i <cloud_image>]
                      [-s <vmachine_hd_size>] [-r <dvd_iso_file>] [-h] [-q]

Execution modes:
  -l  [list-status]       - List virtual machines and kvm server status.
  -m  <execution_mode>    - Valid modes are:
  
      [set-bridges]       - Create virtual bridges from brvlan file list.
                            Netplan bridges must have been created before.
      [set-stpools]       - Create storage pools from dirpool file list.
                            LVM Data service directory must have been created before.
      [vm-create]         - Create virtual machines from file list
                            or single machine if [-n ] is specified.
      [vm-delete]         - Delete virtual machines from file list
                            or single machine if [-n ] is specified.
      [vm-define]         - Define virtual machines in path [-p] 
                            or single machine if [-n ] is specified.
      [vm-undefine]       - Undefine virtual machines in path [-p] 
                            or single machine if [-n ] is specified.
      [vm-dumpcfg]        - Dump virtual machines xml configurations in path [-p] 
                            or single machine if [-n ] is specified.
      [vm-startall]       - Start all virtual machines with --autostart option defined.
      [vm-stopall]        - Stops all running virtual machines.

Options and arguments:
  -n  <vmachine_name>     - Virtual machine name. If set, single machine mode is used. If not, batch mode.

Options and arguments (Single machine creation mode):
  -p  <vmachines_path>    - Virtual machine path. Optional. If not set, default value in variable is used.
  -i  <cloud_image>       - Cloud image full path name Optional. Use "NONE" for no image (boot with blank disk. 
                            If not set, default value in variable is used.
  -s  <vmachine_hd_size>  - Virtual machine system HD size Optional. Use "NONE" for direct copy without resizing. 
                            If not set, default value in variable is used.
  -r  <dvd_iso_file>      - DVD iso file at startup. Required when booting from blank disk.

Options and arguments (General):
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Apply virtual bridges:
    sudo cs-kvmserv.sh -m set-bridges
  
  # Apply storage pools:
    sudo cs-kvmserv.sh -m set-stpools

  # Create virtual machines in batch mode:
    sudo cs-kvmserv.sh -m vm-create 

  # Create virtual machine "srvtest" in single mode from default cloud image. 
  # Directory "srvtest" must exist in setup containing cloud values files):
    sudo cs-kvmserv.sh -m vm-create -n srvtest

  # Create virtual machine "srvtest" in single mode from blank disk and DVD setup. 
  # Directory "srvtest" must exist in setup containing cloud values files):
    sudo cs-kvmserv.sh -m vm-create -n srvtest -i NONE \
      -r /srv/setup/OPNsense-20.7-OpenSSL-dvd-amd64.iso

  # Delete virtual machines in batch mode:
    sudo cs-kvmserv.sh -m vm-delete

  # Delete virtual machine "srvtest" in single mode:
    sudo cs-kvmserv.sh -m vm-delete -n srvtest

  # Define virtual machines in a path from xml config files:
    sudo cs-kvmserv.sh -m vm-define -p /srv/vmachines

  # Define virtual machine srvtest from xml config file:
    sudo cs-kvmserv.sh -m vm-define -p /srv/vmachines -n srvtest

  # Undefine virtual machines in a path from xml config files:
    sudo cs-kvmserv.sh -m vm-undefine -p /srv/vmachines

  # Undefine virtual machine srvtest:
    sudo cs-kvmserv.sh -m vm-undefine  -n srvtest

  # Update xml dump of virtual machines in a path:
    sudo cs-kvmserv.sh -m vm-dumpcfg -p /srv/vmachines

  # Dump xml configuration file of virtual machine "srvtest" in path /srv/vmachines
    sudo cs-kvmserv.sh -m vm-dumpcfg -n srvtest -p /srv/vmachines

  # Start all virtual machines with --autostart option defined
    sudo cs-kvmserv.sh -m vm-startall

  # Stop all running virtual machines
    sudo cs-kvmserv.sh -m vm-stopall

EOF
)"

################################################################################
# Variable initialization
################################################################################

# Administrator (sudoer) user name
# Must be declared in all scripts because it could be referenced in templates
# shellcheck disable=SC2034
sudo_username="kos"

# Setup directory
# Must be declared in all scripts because it could be referenced in templates
# WARNING: Content will be deleted and replaced with every new configuration.
# Must be accesible by sudo_username. Use the same in all scripts.
# shellcheck disable=SC2034
setup_dir="/etc/csky-setup"

# Virtual network bridges
# =======================
# Bridge list file
br_list_file="${setup_dir}/brvlan_list.txt"
# Bridge template file
br_tpl_file="${setup_dir}/brvlan.0000.xml"
# Bridge network template file
br_net_tpl_file="${setup_dir}/brvlan.0000.network"

# Directory pool list file
dir_pool_list_file="${setup_dir}/dirpool_list.txt"
# Directory pool template file
dir_pool_tpl_file="${setup_dir}/dirpool.0000.xml"

# Single mode vm-create
# ====================
# Virtual machine name
vmachine_name=
# Default cloud image full path name
cloud_image="/srv/setup/focal-server-cloudimg-amd64.img"
# DVD iso file at startup
dvd_iso_file="/srv/setup/ubuntu-20.04-live-server-amd64.iso"
# Default vmachines path
vmachines_path="/srv/vmachines"
# Default vmachine system HD size
vmachine_hd_size="120G"
# Cloud init virtual machine file
cloud_init_file=
# Cloud netcfg virtual machine file
cloud_netcfg_file=
# Virtual machine virt-install script file
virtinstall_script_file=

# Batch list mode vm-create
# ========================
vmachines_list_file="${setup_dir}/vmachines_list.txt" # Virtual Machines list file (Batch mode vm-create)
vm_name=                                              # Virtual machine hostname
vm_ipaddress=                                         # IPAddress
vm_network=                                           # Virtual network interface
vm_memory=                                            # Memory in MiB
vm_vcpus=                                             # Number of virtual CPU’s
vm_disk_size=                                         # Disk size
vm_disk_path=                                         # Virtual machine disk path.
vm_osvariant=                                         # OS optimization. Use “osinfo-query os” to see options available
wm_cloud_image=                                       # Cloud image full path name
# Cloud init template file
cloud_init_tpl_file="${setup_dir}/cloud_init.0000.yaml"
# Cloud netcfg template file
cloud_netcfg_tpl_file="${setup_dir}/cloud_netcfg.0000.yaml"
# Cloud netcfg DHCP template file
cloud_netcfg_dhcp_tpl_file="${setup_dir}/cloud_netcfg.DHCP.yaml"

# Execution Mode (Must be initialized empty)
execution_mode=
# Command line called
command_line="$(basename "$0") $*"
# Quiet mode execution (false by default)
quiet_mode=false

# Color code for messages
# https://robotmoon.com/256-colors/
msg_info="$(tput setaf 2 -T xterm-256color)[$(hostname)] [$(basename "$0")] $(date -R)
Info:$(tput sgr0 -T xterm-256color)" # Green
msg_error="$(tput setaf 1 -T xterm-256color)[$(hostname)] [$(basename "$0")] $(date -R)
Error:$(tput sgr0 -T xterm-256color)" # Red

################################################################################
# Options and arguments
################################################################################

# Display usage if no arguments supplied
if (($# == 0)); then
  echo
  echo "${usage_msg}"
  echo
  exit 0
fi

# Parse command options
while getopts ":lm:n:p:i:s:r:hq" opt; do
  case $opt in
  # List status option
  l)
    # Set execution mode if empty (not previously set)
    if [[ -z "${execution_mode}" ]]; then
      execution_mode="list-status"
      quiet_mode=true
    else
      echo
      echo "${msg_error} Execution mode not valid ${command_line}" >&2
      echo
      exit 1
    fi
    ;;
  # Mode option
  m)
    # Set execution mode if empty (not previously set)
    if [[ -z "${execution_mode}" ]]; then
      execution_mode="$OPTARG"
    else
      echo
      echo "${msg_error} Execution mode not valid ${command_line}" >&2
      echo
      exit 1
    fi
    ;;
  # Virtual machine name
  n)
    # Mandatory for single machine creation mode.
    # If not set, virtual machine list file is used).
    vmachine_name="$OPTARG"
    # Set Cloud init virtual machine file
    cloud_init_file="${setup_dir}/${vmachine_name}/cloud_init.yaml"
    # Set Cloud netcfg virtual machine file
    cloud_netcfg_file="${setup_dir}/${vmachine_name}/cloud_netcfg.yaml"
    # Set Virtual machine virt-install script file
    virtinstall_script_file="${setup_dir}/${vmachine_name}/cloud-virt-install.sh"
    ;;
    # Virtual machine path
  p)
    # Optional. If not set, default value in variable is used
    # Remove trailing slashes in vmachines_path
    # sed used intentionally
    # shellcheck disable=SC2001
    vmachines_path="$(echo "$OPTARG" | sed 's:/*$::')"
    ;;
  # Cloud image full path name
  i)
    # Optional. If not set, default value in variable is used
    cloud_image="$OPTARG"
    ;;
  # Virtual machine system HD size
  s)
    # Optional. If not set, default value in variable is used.
    vmachine_hd_size="$OPTARG"
    ;;
  # DVD iso file at startup.
  r)
    # Optional. If not set, cloud-init iso seed disk is configured.
    dvd_iso_file="$OPTARG"
    ;;
  h) # Help
    echo
    echo "${usage_msg}"
    echo
    exit 0
    ;;
  q) # Quiet (Nonstop) execution
    quiet_mode=true
    ;;
  \?)
    echo
    echo "${msg_error} Bad parameters" >&2
    echo "${usage_msg}"
    echo
    exit 1
    ;;
    # Option with empty argument
  :)
    echo
    echo "${msg_error} Missing argument $*" >&2
    echo "${usage_msg}"
    echo
    exit 1
    ;;
  esac
done

# Check if any arguments out of options were passed
shift "$((OPTIND - 1))"
if [[ -n "$*" ]]; then
  echo
  echo "${msg_error} Bad parameters $*" >&2
  echo "${usage_msg}"
  echo
  exit 1
fi

################################################################################
# Validations before execution
################################################################################

# Check if running as root (sudo)
if ! [[ "$(id -u)" == 0 ]]; then
  echo
  echo "${msg_error} The script $0 need to be run with sudo option" >&2
  echo
  exit 1
fi

# Check KVM virtualization
if [[ "$(grep -Eoc '(vmx|svm)' /proc/cpuinfo)" == "0" ]]; then
  echo
  echo "${msg_error} KVM virtualization not supported. Check if VT is enabled in the BIOS " >&2
  echo
  exit 1
fi

# Validate ExecutionModes
case "${execution_mode}" in
"set-bridges")
  # Validate Bridge list file exist
  if ! [[ -f "${br_list_file}" ]]; then
    echo
    echo "${msg_error} Bridge list file ${br_list_file} must exist." >&2
    echo
    exit 1
  fi
  # Validate Bridge template file exist
  if ! [[ -f "${br_tpl_file}" ]]; then
    echo
    echo "${msg_error} Bridge template file ${br_tpl_file} must exist." >&2
    echo
    exit 1
  fi
  ;;
"set-stpools")
  # Validate Directory pool list file exist
  if ! [[ -f "${dir_pool_list_file}" ]]; then
    echo
    echo "${msg_error} Directory pool list file ${dir_pool_list_file} must exist." >&2
    echo
    exit 1
  fi
  # Validate Directory pool template file exist
  if ! [[ -f "${dir_pool_tpl_file}" ]]; then
    echo
    echo "${msg_error} Directory pool template file ${dir_pool_tpl_file} must exist." >&2
    echo
    exit 1
  fi
  # Validate directories exists as /srv/dirpool in directory pool list file ${dir_pool_list_file}
  while read -r dirName; do
    if ! [[ "${dirName}" == "default" ]]; then
      if ! [[ -d "/srv/${dirName}" ]]; then
        echo
        echo "${msg_error} Directory /srv/${dirName} does not exist." >&2
        echo
        exit 1
      fi
    fi
  done <"${dir_pool_list_file}"
  ;;
"vm-create")
  # Check if single (vmachine_name not empty) of batch mode (vmachine_name empty)
  if [[ -z "${vmachine_name}" ]]; then

    # Batch list mode vm-create
    # =========================

    # Validate vmachines list file exist
    if ! [[ -f "${vmachines_list_file}" ]]; then
      echo
      echo "${msg_error} Virtual machines list file ${vmachines_list_file} must exist." >&2
      echo
      exit 1
    fi

    # Validate cloud-init template file exist
    if ! [[ -f "${cloud_init_tpl_file}" ]]; then
      echo
      echo "${msg_error} Cloud-init template file ${cloud_init_tpl_file} must exist." >&2
      echo
      exit 1
    fi

    # Validate cloud-netcfg template file exist
    if ! [[ -f "${cloud_netcfg_tpl_file}" ]]; then
      echo
      echo "${msg_error} Cloud-netcfg template file ${cloud_netcfg_tpl_file} must exist." >&2
      echo
      exit 1
    fi

    # Validate cloud-netcfg DHCP template file exist
    if ! [[ -f "${cloud_netcfg_dhcp_tpl_file}" ]]; then
      echo
      echo "${msg_error} Cloud-netcfg DHCP template file ${cloud_netcfg_dhcp_tpl_file} must exist." >&2
      echo
      exit 1
    fi

    # Validate virtual machine bach list
    while
      read -r \
        vm_name \
        vm_ipaddress \
        vm_network \
        vm_memory \
        vm_vcpus \
        vm_disk_size \
        vm_disk_path \
        vm_osvariant \
        wm_cloud_image
    do

      # Validate virtual machine does not exist
      for domName in $(virsh list --name --all); do
        if [[ "${domName}" == "${vm_name}" ]]; then
          echo
          echo "${msg_error} Virtual machine ${vm_name} already exist." >&2
          echo
          exit 1
        fi
      done

      # Validate virtual machine path exist
      if ! [[ -d "${vm_disk_path}" ]]; then
        echo
        echo "${msg_error} Directory ${vm_disk_path} must exist." >&2
        echo
        exit 1
      fi

      # Validate cloud image exist
      if ! [[ -f "${wm_cloud_image}" ]]; then
        echo
        echo "${msg_error} Cloud image file ${wm_cloud_image} must exist." >&2
        echo
        exit 1
      fi

    done <"${vmachines_list_file}"

  else

    # Single mode vm-create
    # =====================

    # Validate vmachineName does not exist
    for domName in $(virsh list --name --all); do
      if [[ "${domName}" == "${vmachine_name}" ]]; then
        echo
        echo "${msg_error} Virtual machine ${vmachine_name} already exist." >&2
        echo
        exit 1
      fi
    done

    # Validate cloud image exist
    if ! [[ "${cloud_image}" == "NONE" ]]; then
      if ! [[ -f "${cloud_image}" ]]; then
        echo
        echo "${msg_error} Cloud image file ${cloud_image} must exist." >&2
        echo
        exit 1
      fi
    fi
    # Validate virtual machine path exist
    if ! [[ -d "${vmachines_path}" ]]; then
      echo
      echo "${msg_error} Directory ${vmachines_path} must exist." >&2
      echo
      exit 1
    fi

    # Validate cloud image file exist
    if ! [[ -f "${cloud_init_file}" ]]; then
      echo
      echo "${msg_error} Cloud-init machine file ${cloud_init_file} must exist." >&2
      echo
      exit 1
    fi

    # Validate DVD iso file exist
    if [[ "${cloud_image}" == "NONE" ]]; then
      if ! [[ -f "${dvd_iso_file}" ]]; then
        echo
        echo "${msg_error} DVD iso file ${dvd_iso_file} must exist." >&2
        echo
        exit 1
      fi
    fi

    # Validate cloud-netcfg machine file exist
    if ! [[ -f "${cloud_netcfg_file}" ]]; then
      echo
      echo "${msg_error} Cloud-netcfg machine file ${cloud_netcfg_file} must exist." >&2
      echo
      exit 1
    fi

    # Validate cloud-virt-install script file exist
    if ! [[ -f "${virtinstall_script_file}" ]]; then
      echo
      echo "${msg_error} cloud-virt-install script file ${virtinstall_script_file} must exist." >&2
      echo
      exit 1
    fi
  fi
  ;;
"vm-delete")

  # Check if single (vmachine_name not empty) or batch mode (vmachine_name empty)
  if [[ -z "${vmachine_name}" ]]; then

    # Batch list mode vm-delete
    # =========================

    while
      read -r \
        vm_name \
        vm_ipaddress \
        vm_network \
        vm_memory \
        vm_vcpus \
        vm_disk_size \
        vm_disk_path \
        vm_osvariant \
        wm_cloud_image
    do
      # Validate vmachineName exist
      if [[ -z "$(virsh list --all | grep " ${vm_name} " | awk '{ print $2}')" ]]; then
        echo
        echo "${msg_error} Virtual machine ${vm_name} does not exist." >&2
        echo
        exit 1
      fi

      # Validate vmachineName is inactive
      if [[ -z "$(virsh list --inactive | grep " ${vm_name} " | awk '{ print $2}')" ]]; then
        echo
        echo "${msg_error} Virtual machine ${vm_name} is not inactive." >&2
        echo
        exit 1
      fi

    done <"${vmachines_list_file}"

  else

    # Single mode vm-delete
    # ====================

    # Validate vmachineName exist
    if [[ -z "$(virsh list --all | grep " ${vmachine_name} " | awk '{ print $2}')" ]]; then
      echo
      echo "${msg_error} Virtual machine ${vmachine_name} does not exist." >&2
      echo
      exit 1
    fi

    # Validate vmachineName is inactive
    if [[ -z "$(virsh list --inactive | grep " ${vmachine_name} " | awk '{ print $2}')" ]]; then
      echo
      echo "${msg_error} Virtual machine ${vmachine_name} is not inactive." >&2
      echo
      exit 1
    fi
  fi
  ;;
"vm-define")

  # Validate virtual machine path exist
  if ! [[ -d "${vmachines_path}" ]]; then
    echo
    echo "${msg_error} Directory ${vmachines_path} must exist." >&2
    echo
    exit 1
  fi

  # Check if single (vmachine_name not empty) of path mode (vmachine_name empty)
  if [[ -z "${vmachine_name}" ]]; then

    # Path mode vm-define
    # ===================

    # Check if definition files exist on path
    declare -a dump_config_files=("${vmachines_path}"/*-dump.xml)
    count=${#dump_config_files[@]}
    if [[ ${count} == 0 ]]; then
      echo
      echo "${msg_error} No definition files *-dump.xml found on ${vmachines_path}." >&2
      echo
      exit 1
    fi

    # Look for vmachines related to dump_config_files
    for file in "${dump_config_files[@]}"; do
      vm_name="$(basename "${file%"-dump.xml"}")"
      # Validate virtual machine does not exist
      for domName in $(virsh list --name --all); do
        if [[ "${domName}" == "${vm_name}" ]]; then
          echo
          echo "${msg_error} Virtual machine ${vm_name} already exist." >&2
          echo
          exit 1
        fi
      done
    done

  else

    # Single mode vm-define
    # =====================

    # Validate vmachineName does not exist
    for domName in $(virsh list --name --all); do
      if [[ "${domName}" == "${vmachine_name}" ]]; then
        echo
        echo "${msg_error} Virtual machine ${vmachine_name} already exist." >&2
        echo
        exit 1
      fi
    done

    # Validate vmachine_name-dump.xml file exist
    if ! [[ -f "${vmachines_path}/${vmachine_name}-dump.xml" ]]; then
      echo
      echo "${msg_error} Configuration file ${vmachines_path}/${vmachine_name}-dump.xml must exist." >&2
      echo
      exit 1
    fi

  fi
  ;;
"vm-undefine")
  # Validate virtual machine path exist
  if ! [[ -d "${vmachines_path}" ]]; then
    echo
    echo "${msg_error} Directory ${vmachines_path} must exist." >&2
    echo
    exit 1
  fi

  # Check if single (vmachine_name not empty) of path mode (vmachine_name empty)
  if [[ -z "${vmachine_name}" ]]; then

    # Path mode vm-undefine
    # =====================

    # Check if definition files exist on path
    declare -a dump_config_files=("${vmachines_path}"/*-dump.xml)
    count=${#dump_config_files[@]}
    if [[ ${count} == 0 ]]; then
      echo
      echo "${msg_error} No definition files *-dump.xml found on ${vmachines_path}." >&2
      echo
      exit 1
    fi

    # Look for vmachines related to dump_config_files
    for file in "${dump_config_files[@]}"; do
      vm_name="$(basename "${file%"-dump.xml"}")"

      # Validate vmachineName exist
      if [[ -z "$(virsh list --all | grep " ${vm_name} " | awk '{ print $2}')" ]]; then
        echo
        echo "${msg_error} Virtual machine ${vm_name} does not exist." >&2
        echo
        exit 1
      fi

      # Validate vmachineName is inactive
      if [[ -z "$(virsh list --inactive | grep " ${vm_name} " | awk '{ print $2}')" ]]; then
        echo
        echo "${msg_error} Virtual machine ${vm_name} is not inactive." >&2
        echo
        exit 1
      fi

      # Validate vm_name-dump.xml file exist
      if ! [[ -f "${vmachines_path}/${vm_name}-dump.xml" ]]; then
        echo
        echo "${msg_error} Configuration file ${vmachines_path}/${vm_name}-dump.xml must exist." >&2
        echo
        exit 1
      fi

    done

  else

    # Single mode vm-undefine
    # =======================

    # Validate vmachineName exist
    if [[ -z "$(virsh list --all | grep " ${vmachine_name} " | awk '{ print $2}')" ]]; then
      echo
      echo "${msg_error} Virtual machine ${vmachine_name} does not exist." >&2
      echo
      exit 1
    fi

    # Validate vmachineName is inactive
    if [[ -z "$(virsh list --inactive | grep " ${vmachine_name} " | awk '{ print $2}')" ]]; then
      echo
      echo "${msg_error} Virtual machine ${vmachine_name} is not inactive." >&2
      echo
      exit 1
    fi

    # Validate vmachine_name-dump.xml file exist
    if ! [[ -f "${vmachines_path}/${vmachine_name}-dump.xml" ]]; then
      echo
      echo "${msg_error} Configuration file ${vmachines_path}/${vmachine_name}-dump.xml must exist." >&2
      echo
      exit 1
    fi

  fi
  ;;
"vm-dumpcfg")
  # Validate virtual machine path exist
  if ! [[ -d "${vmachines_path}" ]]; then
    echo
    echo "${msg_error} Directory ${vmachines_path} must exist." >&2
    echo
    exit 1
  fi

  # Check if single (vmachine_name not empty) of path mode (vmachine_name empty)
  if [[ -z "${vmachine_name}" ]]; then

    # Path mode vm-dumpcfg
    # ====================

    # Check if definition files exist on path
    declare -a dump_config_files=("${vmachines_path}"/*-dump.xml)
    count=${#dump_config_files[@]}
    if [[ ${count} == 0 ]]; then
      echo
      echo "${msg_error} No definition files *-dump.xml found on ${vmachines_path}." >&2
      echo
      exit 1
    fi

    # Look for vmachines related to dump_config_files
    for file in "${dump_config_files[@]}"; do
      vm_name="$(basename "${file%"-dump.xml"}")"

      # Validate vmachineName exist
      if [[ -z "$(virsh list --all | grep " ${vm_name} " | awk '{ print $2}')" ]]; then
        echo
        echo "${msg_error} Virtual machine ${vm_name} does not exist." >&2
        echo
        exit 1
      fi

      # Validate vm_name-dump.xml file exist
      if ! [[ -f "${vmachines_path}/${vm_name}-dump.xml" ]]; then
        echo
        echo "${msg_error} Configuration file ${vmachines_path}/${vm_name}-dump.xml must exist before dumping new config." >&2
        echo
        exit 1
      fi
    done

  else

    # Single mode vm-dumpcfg
    # ======================

    # Validate vmachineName exist
    if [[ -z "$(virsh list --all | grep " ${vmachine_name} " | awk '{ print $2}')" ]]; then
      echo
      echo "${msg_error} Virtual machine ${vmachine_name} does not exist." >&2
      echo
      exit 1
    fi

    # Validate vmachine_name-dump.xml file exist
    if ! [[ -f "${vmachines_path}/${vmachine_name}-dump.xml" ]]; then
      echo
      echo "${msg_error} Configuration file ${vmachines_path}/${vmachine_name}-dump.xml must exist before dumping new config." >&2
      echo
      exit 1
    fi

  fi
  ;;
"vm-startall") ;;
"vm-stopall") ;;
"list-status")
  # Set quiet_mode
  quiet_mode=true
  ;;
*)
  echo
  echo "${msg_error} Execution mode not valid ${command_line}" >&2
  echo
  exit 1
  ;;
esac

################################################################################
# Execution info and user confirmation (quiet_mode=false)
################################################################################

if [[ ${quiet_mode} == false ]]; then
  echo
  echo "*********************************************************************"
  echo
  echo "  $(hostname):"
  echo
  echo "      ${command_line}"
  echo
  echo "  KVM Services"
  echo "      execution_mode:      ${execution_mode}"
  echo
  if [[ "${execution_mode}" == "set-bridges" ]]; then
    echo "  Create network bridges from list ${br_list_file}"
    echo
    while read -r brName; do
      # Create livbirt network xml files
      echo "      ${brName}"
    done <"${br_list_file}"
    echo
  fi
  if [[ "${execution_mode}" == "set-stpools" ]]; then
    echo "  Create directory pools from list ${dir_pool_list_file}"
    echo
    while read -r dirName; do
      # Create livbirt network xml files
      echo "      ${dirName}"
    done <"${dir_pool_list_file}"
    echo
  fi
  if [[ "${execution_mode}" == "vm-create" ]]; then
    # Check if single (vmachine_name not empty) of batch mode (vmachine_name empty)
    if [[ -z "${vmachine_name}" ]]; then
      # List virtual machines to be created
      echo "  Create virtual machines from list ${vmachines_list_file}"
      echo
      while
        read -r \
          vm_name \
          vm_ipaddress \
          vm_network \
          vm_memory \
          vm_vcpus \
          vm_disk_size \
          vm_disk_path \
          vm_osvariant \
          wm_cloud_image
      do
        echo "    ${vm_name}"
      done <"${vmachines_list_file}"
      echo
    else
      # Show single vMachine parameters
      echo "  Create single virtual machine"
      echo
      echo "    Name:                     ${vmachine_name}"
      echo "    Path:                     ${vmachines_path}"
      echo "    Cloud image:              ${cloud_image}"
      echo "    System HD size:           ${vmachine_hd_size}"
      if [[ "${cloud_image}" == "NONE" ]]; then
        echo "    DVD iso file:             ${dvd_iso_file}"
      fi
      if ! [[ "${cloud_image}" == "NONE" ]]; then
        echo "    Cloud-init file:          ${cloud_init_file}"
        echo "    Cloud-netcfg file:        ${cloud_netcfg_file}"
      fi
      echo "    Virt-install script file: ${virtinstall_script_file}"
      echo
    fi
  fi

  if [[ "${execution_mode}" == "vm-delete" ]]; then
    # Check if single (vmachine_name not empty) of batch mode (vmachine_name empty)
    if [[ -z "${vmachine_name}" ]]; then
      # List virtual machines to be deleted
      echo "  The following virtual machines and its files will be deleted:"
      echo
      while
        read -r \
          vm_name \
          vm_ipaddress \
          vm_network \
          vm_memory \
          vm_vcpus \
          vm_disk_size \
          vm_disk_path \
          vm_osvariant \
          wm_cloud_image
      do
        echo "    ${vm_name}"
      done <"${vmachines_list_file}"
      echo
    else
      # Show single vMachine parameters
      echo "  The following virtual machine and its files will be deleted:"
      echo
      echo "    Name:                     ${vmachine_name}"
      echo "    Path:                     ${vmachines_path}"
      echo "    Files:"
      echo
      ls -lah "${vmachines_path}"/"${vmachine_name}"-*
      echo
    fi
  fi

  if [[ "${execution_mode}" == "vm-define" ]]; then
    # Check if single (vmachine_name not empty) of batch mode (vmachine_name empty)
    if [[ -z "${vmachine_name}" ]]; then
      # List virtual machines to be defined
      echo "  The following virtual machines will be defined:"
      echo
      # Check all definition files "*-dump.xml" on path
      declare -a dump_config_files=("${vmachines_path}"/*-dump.xml)

      # Look for vmachines related to dump_config_files
      for file in "${dump_config_files[@]}"; do
        vm_name="$(basename "${file%"-dump.xml"}")"
        echo "    ${vm_name}"
      done
      echo
    else
      # Show single vMachine definition parameters
      echo "  The following virtual machine and its files will be defined:"
      echo
      echo "    Name:                     ${vmachine_name}"
      echo "    Path:                     ${vmachines_path}"
      echo "    Config file:              ${vmachines_path}/${vmachine_name}-dump.xml"
      echo
    fi
  fi

  if [[ "${execution_mode}" == "vm-undefine" ]]; then
    # Check if single (vmachine_name not empty) of batch mode (vmachine_name empty)
    if [[ -z "${vmachine_name}" ]]; then
      # List virtual machines to be undefined
      echo "  The following virtual machines will be undefined:"
      echo
      # Check all definition files "*-dump.xml" on path
      declare -a dump_config_files=("${vmachines_path}"/*-dump.xml)

      # Look for vmachines related to dump_config_files
      for file in "${dump_config_files[@]}"; do
        vm_name="$(basename "${file%"-dump.xml"}")"
        echo "    ${vm_name}"
      done
      echo
    else
      # Show single vMachine definition parameters
      echo "  The following virtual machine and its files will be undefined:"
      echo
      echo "    Name:                     ${vmachine_name}"
      echo "    Path:                     ${vmachines_path}"
      echo "    Config file:              ${vmachines_path}/${vmachine_name}-dump.xml"
      echo
    fi
  fi

  if [[ "${execution_mode}" == "vm-dumpcfg" ]]; then
    # Check if single (vmachine_name not empty) of batch mode (vmachine_name empty)
    if [[ -z "${vmachine_name}" ]]; then
      # List virtual machines to be undefined
      echo "  Configuration XML Dump will be generated for the following virtual machines:"
      echo
      # Check all definition files "*-dump.xml" on path
      declare -a dump_config_files=("${vmachines_path}"/*-dump.xml)

      # Look for vmachines related to dump_config_files
      for file in "${dump_config_files[@]}"; do
        vm_name="$(basename "${file%"-dump.xml"}")"
        echo "    ${vm_name}"
      done
      echo
    else
      # Show single vMachine dump parameters
      echo "  Configuration XML Dump will be generated for the following virtual machine:"
      echo
      echo "    Name:                     ${vmachine_name}"
      echo "    Path:                     ${vmachines_path}"
      echo "    Config file:              ${vmachines_path}/${vmachine_name}-dump.xml"
      echo
    fi
  fi

  echo "*********************************************************************"
  echo
  read -r -s -p $'Press Enter to continue or Ctrl+C to abort...'
  echo
  if [[ "${execution_mode}" == "vm-delete" ]]; then
    echo
    echo "******** WARNING!!!: Virtual machines and STORAGE files will be PERMANENTLY DELETED."
    echo
    read -r -s -p $'Press Enter to continue or Ctrl+C to abort...'
    echo
  fi

fi

#### START OF EXECUTION (SOE) ##################################################
echo
echo "${msg_info} START OF EXECUTION (SOE)"
echo

################################################################################
# Set virtual network bridges
################################################################################

if [[ "${execution_mode}" == "set-bridges" ]]; then

  # Remove existing virtual network bridges
  echo
  echo "${msg_info} Remove existing virtual network bridges"
  echo
  for brName in $(virsh net-list --name); do
    if ! [[ "${brName}" == "default" ]]; then
      echo "${brName}"
      virsh net-destroy "$brName"
      virsh net-undefine "$brName"
      if [[ -f "/etc/systemd/network/${brName}.network" ]]; then
        rm "/etc/systemd/network/${brName}.network"
      fi
    fi
  done

  # Create virtual network bridges from bridge list file ${br_list_file}
  while read -r brName; do
    # Create livbirt network xml files
    echo
    echo "${msg_info} Creating netplan bridge xml file for: ${brName}"
    echo

    # Copying from template
    cp -v "${br_tpl_file}" "/tmp/${brName}.xml"

    # Changing file contents
    sed -i.bcktemp "s#brvlan.0000#${brName}#g" "/tmp/${brName}.xml"
    if [[ -f "/tmp/${brName}.xml.bcktemp" ]]; then
      rm "/tmp/${brName}.xml.bcktemp"
    else
      echo
      echo "${msg_error} /tmp/${brName}.xml.bcktemp does not exist after file contents change." >&2
      echo
      exit 1
    fi

    # Create systemd .network files (ubuntu 18.04 bug)
    # Ref.: https://djanotes.blogspot.com/2018/04/anonymous-bridges-in-netplan.html
    echo
    echo "${msg_info} Creating systemd network file for: ${brName}"
    echo

    # Copying from template
    cp -v "${br_net_tpl_file}" "/tmp/${brName}.network"

    # Changing file contents
    sed -i.bcktemp "s#brvlan.0000#${brName}#g" "/tmp/${brName}.network"
    if [[ -f "/tmp/${brName}.network.bcktemp" ]]; then
      rm "/tmp/${brName}.network.bcktemp"
    else
      echo
      echo "${msg_error} /tmp/${brName}.network.bcktemp does not exist after file contents change." >&2
      echo
      exit 1
    fi

    # Deploy network file to /etc/systemd/network/
    cp -v "/tmp/${brName}.network" "/etc/systemd/network/${brName}.network"
    chmod 644 "/etc/systemd/network/${brName}.network"
    chown root:root "/etc/systemd/network/${brName}.network"

    # Define and start livbirt network
    echo
    echo "${msg_info} Define and start livbirt network ${brName}"
    echo
    virsh net-define "/tmp/${brName}.xml"
    virsh net-autostart "${brName}"
    virsh net-start "${brName}"

  done <"${br_list_file}"

  # Show livbirt networks
  echo
  echo "${msg_info} Virtual networks created. Reboot recommended."
  echo
  virsh net-list --all
fi

################################################################################
# Set virtual storage pools
################################################################################

if [[ "${execution_mode}" == "set-stpools" ]]; then

  # Remove existing directory pools
  echo
  echo "${msg_info} Remove existing directory pools"
  echo
  for dirName in $(virsh pool-list --name); do
    if ! [[ "${dirName}" == "default" ]]; then
      echo "${dirName}"
      virsh pool-destroy "$dirName"
      virsh pool-undefine "$dirName"
    fi
  done

  # Create directory pools from directory pool list file ${dir_pool_list_file}
  while read -r dirName; do
    # Create directory pool xml file
    echo
    echo "${msg_info} Creating directory pool xml file for: ${dirName}"
    echo

    # Copying from template
    cp -v "${dir_pool_tpl_file}" "/tmp/${dirName}.xml"

    # Changing file contents
    sed -i.bcktemp "s#dirpool.0000#${dirName}#g" "/tmp/${dirName}.xml"
    if [[ -f "/tmp/${dirName}.xml.bcktemp" ]]; then
      rm "/tmp/${dirName}.xml.bcktemp"
    else
      echo
      echo "${msg_error} /tmp/${dirName}.xml.bcktemp does not exist after file contents change." >&2
      echo
      exit 1
    fi

    # Define and start directory pools
    echo
    echo "${msg_info} Define and start directory pool ${dirName}"
    echo
    virsh pool-define "/tmp/${dirName}.xml"
    virsh pool-autostart "${dirName}"
    virsh pool-start "${dirName}"

  done <"${dir_pool_list_file}"

  # Show storage pools
  echo
  echo "${msg_info} Directory pools created. Reboot recommended."
  echo
  virsh pool-list --all
fi

################################################################################
# Create virtual machines
################################################################################

if [[ "${execution_mode}" == "vm-create" ]]; then

  # Check if single (vmachine_name not empty) of batch mode (vmachine_name empty)
  if [[ -z "${vmachine_name}" ]]; then

    # Batch list mode vm-create
    # =========================

    # Process bach list
    while
      read -r \
        vm_name \
        vm_ipaddress \
        vm_network \
        vm_memory \
        vm_vcpus \
        vm_disk_size \
        vm_disk_path \
        vm_osvariant \
        wm_cloud_image
    do

      # Display message for virtual machine creation
      echo
      echo "${msg_info} Creating virtual machine ${vm_name}"
      echo

      # Prepare system disk

      # Check if disk resize is specified
      if [[ "${vm_disk_size}" == "NONE" ]]; then

        # Copy machine HD from image
        echo
        echo "Copying virtual machine HD ${vm_name}-sysdisk.qcow2 from ${wm_cloud_image}"
        echo
        cp -v "${wm_cloud_image}" "${vm_disk_path}/${vm_name}-sysdisk.qcow2"
      else
        # Create machine HD from image
        echo
        echo "Creating virtual machine HD ${vm_name}-sysdisk.qcow2"
        echo
        qemu-img convert -p -O qcow2 "${wm_cloud_image}" "${vm_disk_path}/${vm_name}-sysdisk.qcow2"
        # Resize HD
        echo
        echo "Resize virtual machine HD ${vm_name}-sysdisk.qcow2 to ${vm_disk_size}"
        echo
        qemu-img resize "${vm_disk_path}/${vm_name}-sysdisk.qcow2" "${vm_disk_size}"
      fi

      # Change ownership
      echo
      chown -v "${sudo_username}":"${sudo_username}" "${vm_disk_path}/${vm_name}-sysdisk.qcow2"
      # Show disk info
      echo
      echo "Virtual machine HD ${vm_name}-sysdisk.qcow2 created"
      echo
      ls -lah "${vm_disk_path}/${vm_name}-sysdisk.qcow2"
      echo
      qemu-img info "${vm_disk_path}/${vm_name}-sysdisk.qcow2"

      # Pepare setup DVD iso

      # Create cloud_init.yaml file from template
      echo
      echo "Creating cloud_init.yaml file from template for: ${vm_name}"
      echo
      # Copying from template
      cp -v "${cloud_init_tpl_file}" "/tmp/cloud_init_${vm_name}.yaml"

      # Changing file contents
      sed -i.bcktemp "s#HOSTNAME.0000#${vm_name}#g" "/tmp/cloud_init_${vm_name}.yaml"
      if [[ -f "/tmp/cloud_init_${vm_name}.yaml.bcktemp" ]]; then
        rm "/tmp/cloud_init_${vm_name}.yaml.bcktemp"
      else
        echo
        echo "${msg_error} /tmp/cloud_init_${vm_name}.yaml.bcktemp does not exist after file contents change." >&2
        echo
        exit 1
      fi

      # Create cloud_netcfg.yaml file from template
      echo
      echo "Creating cloud_netcfg.yaml file from template for: ${vm_name}"
      echo
      if [[ "${vm_ipaddress}" == "DHCP" ]]; then
        # Copying from DHCP template
        cp -v "${cloud_netcfg_dhcp_tpl_file}" "/tmp/cloud_netcfg_${vm_name}.yaml"
      else
        # Copying from static address template
        cp -v "${cloud_netcfg_tpl_file}" "/tmp/cloud_netcfg_${vm_name}.yaml"

        # Changing file contents
        sed -i.bcktemp "s#IPADDRESS.0000#${vm_ipaddress}#g" "/tmp/cloud_netcfg_${vm_name}.yaml"
        if [[ -f "/tmp/cloud_netcfg_${vm_name}.yaml.bcktemp" ]]; then
          rm "/tmp/cloud_netcfg_${vm_name}.yaml.bcktemp"
        else
          echo
          echo "${msg_error} /tmp/cloud_netcfg_${vm_name}.yaml.bcktemp does not exist after file contents change." >&2
          echo
          exit 1
        fi
      fi

      # Generate iso seed disk for cloud-init
      echo
      echo "Creating virtual machine setup iso disk ${vm_name}-setup.iso"
      echo
      echo
      cloud-localds -v --network-config=/tmp/cloud_netcfg_"${vm_name}.yaml" "${vm_disk_path}/${vm_name}-setup.iso" /tmp/cloud_init_"${vm_name}.yaml"
      # Change ownership
      echo
      chown -v "${sudo_username}":"${sudo_username}" "${vm_disk_path}/${vm_name}-setup.iso"
      # Show disk info
      echo
      ls -lah "${vm_disk_path}/${vm_name}-setup.iso"
      echo
      qemu-img info "${vm_disk_path}/${vm_name}-setup.iso"

      # Create virtual machine with virt-install
      echo
      echo "Executing virt-install to create ${vm_name}"
      echo
      virt-install --name "${vm_name}" \
        --virt-type kvm --memory "${vm_memory}" --vcpus "${vm_vcpus}" \
        --boot hd,cdrom,menu=on --autostart \
        --disk path="${vm_disk_path}/${vm_name}-setup.iso",device=cdrom \
        --disk path="${vm_disk_path}/${vm_name}-sysdisk.qcow2",device=disk \
        --os-variant "${vm_osvariant}" \
        --network network="${vm_network}" \
        --console pty,target_type=serial \
        --noautoconsole

      # Dump xml configuration
      echo
      echo "Exporting xml configuration ${vm_name}-dump.xml"
      echo
      virsh dumpxml "${vm_name}" --migratable >"${vm_disk_path}/${vm_name}-dump.xml"

      # Show virtual machine info
      echo
      echo "Virtual machine ${vm_name} created."
      echo
      virsh dominfo "${vm_name}"

    done <"${vmachines_list_file}"

  else

    # Single mode vm-create
    # =====================

    # Display message for virtual machine creation
    echo
    echo "${msg_info} Creating virtual machine ${vmachine_name}"
    echo

    # Prepare system disk

    # Check if cloud image is specified
    if [[ "${cloud_image}" == "NONE" ]]; then
      # Create machine HD from image
      echo
      echo "Creating virtual machine empty HD ${vmachine_name}-sysdisk.qcow2"
      echo
      qemu-img create -f qcow2 "${vmachines_path}/${vmachine_name}-sysdisk.qcow2" "${vmachine_hd_size}"
    else
      # Check if disk resize is specified
      if [[ "${vmachine_hd_size}" == "NONE" ]]; then
        # Copy machine HD from image
        echo
        echo "Copying virtual machine HD ${vmachine_name}-sysdisk.qcow2 from ${cloud_image}"
        echo
        cp -v "${cloud_image}" "${vmachines_path}/${vmachine_name}-sysdisk.qcow2"
      else
        # Create machine HD from image
        echo
        echo "Creating virtual machine HD ${vmachine_name}-sysdisk.qcow2"
        echo
        qemu-img convert -p -O qcow2 "${cloud_image}" "${vmachines_path}/${vmachine_name}-sysdisk.qcow2"
        # Resize HD
        echo
        echo "Resize virtual machine HD ${vmachine_name}-sysdisk.qcow2 to ${vmachine_hd_size}"
        echo
        qemu-img resize "${vmachines_path}/${vmachine_name}-sysdisk.qcow2" "${vmachine_hd_size}"
      fi
    fi
    # Change ownership
    echo
    chown -v "${sudo_username}":"${sudo_username}" "${vmachines_path}/${vmachine_name}-sysdisk.qcow2"
    # Show disk info
    echo
    ls -lah "${vmachines_path}/${vmachine_name}-sysdisk.qcow2"
    echo
    qemu-img info "${vmachines_path}/${vmachine_name}-sysdisk.qcow2"

    # Pepare Setup DVD iso

    # Check if cloud image is specified
    if [[ "${cloud_image}" == "NONE" ]]; then
      # Copy DVD iso file as DVD machine setup iso file
      echo
      echo "Copy ${dvd_iso_file} as virtual machine setup iso disk ${vmachine_name}-setup.iso"
      echo
      cp -v "${dvd_iso_file}" "${vmachines_path}/${vmachine_name}-setup.iso"
    else
      # Generate iso seed disk for cloud-init
      echo
      echo "Creating virtual machine setup iso disk ${vmachine_name}-setup.iso"
      echo
      cloud-localds -v --network-config="${cloud_netcfg_file}" "${vmachines_path}/${vmachine_name}-setup.iso" "${cloud_init_file}"
    fi
    # Change ownership
    echo
    chown -v "${sudo_username}":"${sudo_username}" "${vmachines_path}/${vmachine_name}-setup.iso"
    # Show disk info
    echo
    ls -lah "${vmachines_path}/${vmachine_name}-setup.iso"
    echo
    qemu-img info "${vmachines_path}/${vmachine_name}-setup.iso"

    # Create virtual machine with virt-install
    echo
    echo "Executing virt-install to create ${vmachine_name} from script ${virtinstall_script_file}"
    # virtinstall_script_file different for every machine. Bypass shellcheck intentionally.
    # shellcheck source=/dev/null
    source "${virtinstall_script_file}"

    # Dump xml configuration
    echo
    echo "Exporting xml configuration ${vmachine_name}-dump.xml"
    virsh dumpxml "${vmachine_name}" --migratable >"${vmachines_path}/${vmachine_name}-dump.xml"
    echo

    # Show virtual machine info
    echo
    echo "${msg_info} Virtual machine ${vmachine_name} created."
    echo
    virsh dominfo "${vmachine_name}"
  fi
fi

################################################################################
# Delete virtual machines
################################################################################

if [[ "${execution_mode}" == "vm-delete" ]]; then

  # Check if single (vmachine_name not empty) of batch mode (vmachine_name empty)
  if [[ -z "${vmachine_name}" ]]; then

    # Batch list mode vm-delete
    # ========================

    # Process bach list
    while
      read -r \
        vm_name \
        vm_ipaddress \
        vm_network \
        vm_memory \
        vm_vcpus \
        vm_disk_size \
        vm_disk_path \
        vm_osvariant \
        wm_cloud_image
    do

      # Display message for virtual machine creation
      echo
      echo "${msg_info} Deleting virtual machine ${vm_name}"
      echo

      # Delete virtual machine and its storage
      virsh undefine "${vm_name}" --remove-all-storage

      # Delete xml config file if exist
      if [[ -f "${vm_disk_path}/${vm_name}-dump.xml" ]]; then
        rm "${vm_disk_path}/${vm_name}-dump.xml"
      fi

      echo
      echo "Virtual machine ${vm_name} and storage files removed."

    done <"${vmachines_list_file}"

  else

    # Single mode vm-delete
    # =====================

    # Display message for virtual machine deletion
    echo
    echo "${msg_info} Deleting virtual machine ${vmachine_name}"
    echo

    # delete virtual machine and its storage
    virsh undefine "${vmachine_name}" --remove-all-storage

    # Delete xml config file if exist
    if [[ -f "${vmachines_path}/${vmachine_name}-dump.xml" ]]; then
      rm "${vmachines_path}/${vmachine_name}-dump.xml"
    fi

    echo
    echo "${msg_info} Virtual machine ${vmachine_name} and storage files removed."
    echo
  fi
fi

################################################################################
# Define virtual machines from config files
################################################################################

if [[ "${execution_mode}" == "vm-define" ]]; then

  # Check if single (vmachine_name not empty) of path mode (vmachine_name empty)
  if [[ -z "${vmachine_name}" ]]; then

    # Path mode vm-define
    # ===================

    # Check all definition files "*-dump.xml" on path
    declare -a dump_config_files=("${vmachines_path}"/*-dump.xml)

    # Look for vmachines related to dump_config_files
    for file in "${dump_config_files[@]}"; do
      vm_name="$(basename "${file%"-dump.xml"}")"

      # Display message for virtual machine definition
      echo
      echo "${msg_info} Define virtual machine ${vm_name}"
      echo

      # Define and start virtual machine
      virsh define "${vmachines_path}/${vm_name}-dump.xml" --validate
      virsh autostart "${vm_name}"
      # Show virtual machine info
      echo
      echo "Virtual machine ${vm_name} defined."
      echo
      virsh dominfo "${vm_name}"
      echo
    done

  else

    # Single mode vm-define
    # ====================

    # Display message for virtual machine definition
    echo
    echo "${msg_info} Define virtual machine ${vmachine_name}"
    echo

    # Define and start virtual machine
    virsh define "${vmachines_path}/${vmachine_name}-dump.xml" --validate
    virsh autostart "${vmachine_name}"

    # Show virtual machine info
    echo
    echo "${msg_info} Virtual machine ${vmachine_name} defined."
    echo
    virsh dominfo "${vmachine_name}"
  fi
fi

################################################################################
# Undefine virtual machines from config files
################################################################################

if [[ "${execution_mode}" == "vm-undefine" ]]; then

  # Check if single (vmachine_name not empty) of batch mode (vmachine_name empty)
  if [[ -z "${vmachine_name}" ]]; then

    # Path mode vm-undefine
    # =====================

    # Check all definition files "*-dump.xml" on path
    declare -a dump_config_files=("${vmachines_path}"/*-dump.xml)

    # Look for vmachines related to dump_config_files
    for file in "${dump_config_files[@]}"; do
      vm_name="$(basename "${file%"-dump.xml"}")"

      # Display message for virtual machine undefinition
      echo
      echo "${msg_info} Undefining virtual machine ${vm_name}"
      echo

      # Undefine virtual machine
      virsh undefine "${vm_name}"

      # Show virtual machine info
      echo
      echo "Virtual machine ${vm_name} has been undefined."
      echo
    done

  else

    # Single mode vm-undefine
    # ======================

    # Display message for virtual machine undefinition
    echo
    echo "${msg_info} Undefining virtual machine ${vmachine_name}"
    echo

    # Undefine virtual machine
    virsh undefine "${vmachine_name}"

    echo
    echo "${msg_info} Virtual machine ${vmachine_name} has been undefined."
    echo
  fi
fi

################################################################################
# Dump virtual machine configuration files
################################################################################

if [[ "${execution_mode}" == "vm-dumpcfg" ]]; then

  # Check if single (vmachine_name not empty) of batch mode (vmachine_name empty)
  if [[ -z "${vmachine_name}" ]]; then

    # Path mode vm-dumpcfg
    # ====================

    echo
    echo "${msg_info} Exporting configurations for virtual machines in ${vmachines_path}"
    echo

    # Check all definition files "*-dump.xml" on path
    declare -a dump_config_files=("${vmachines_path}"/*-dump.xml)

    # Look for vmachines related to dump_config_files
    for file in "${dump_config_files[@]}"; do
      vm_name="$(basename "${file%"-dump.xml"}")"

      # Display message for virtual machine configuration export
      echo "Exporting xml configuration ${vmachines_path}/${vm_name}-dump.xml"

      # Dump xml configuration
      virsh dumpxml "${vm_name}" --migratable >"${vmachines_path}/${vm_name}-dump.xml"
    done
    echo
    echo "${msg_info} Exported configurations for virtual machines in ${vmachines_path} to files:"
    echo
    ls -lah "${vmachines_path}"/*-dump.xml
  else

    # Single mode vm-dumpcfg
    # ======================

    # Display message for virtual machine undefinition
    echo
    echo "${msg_info} Exporting xml configuration ${vmachines_path}/${vmachine_name}-dump.xml"
    echo

    # Dump xml configuration
    virsh dumpxml "${vmachine_name}" --migratable >"${vmachines_path}/${vmachine_name}-dump.xml"

    echo
    echo "${msg_info} Exported virtual machine ${vmachine_name} configuration to file:"
    echo
    ls -lah "${vmachines_path}/${vmachine_name}-dump.xml"
  fi
fi

################################################################################
# Start virtual machines
################################################################################

if [[ "${execution_mode}" == "vm-startall" ]]; then

  for vm_name in $(virsh list --name --inactive --autostart); do
    virsh start "${vm_name}"
  done
fi

################################################################################
# Stop virtual machines
################################################################################

if [[ "${execution_mode}" == "vm-stopall" ]]; then

  for vm_name in $(virsh list --name --state-running); do
    virsh shutdown "${vm_name}"
  done

fi

################################################################################
# Display KVM server status
################################################################################

if [[ "${execution_mode}" == "list-status" ]]; then

  # Storage pools
  echo
  echo "${msg_info} Storage pools"
  echo
  virsh pool-list --all

  # Virtual networks
  echo
  echo "${msg_info} Virtual networks"
  echo
  virsh net-list --all

  # Virtual machines
  echo
  echo "${msg_info} Virtual machines"
  echo
  virsh list --all

fi

#### END OF EXECUTION (EOE) ####################################################
echo
echo "${msg_info} END OF EXECUTION (EOE)"
echo
exit 0
