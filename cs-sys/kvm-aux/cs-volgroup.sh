#!/bin/bash

#
#   cs-volgroup.sh
#
#       Disk volume group and management
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
# usage_msg message
################################################################################

usage_msg="$(
  cat <<EOF

Purpose:
  Disk volume group management.
  Use this script to create and delete volume groups
  from one or several disk devices.
  Each volume group will have a thin-pool associated to hold
  data services that will be created with the script "cs-lvmserv.sh".

Usage:
  sudo cs-volgroup.sh [-l] [-m <execution_mode>] [-d  <block_dev_names>]
                      [-v <vg_name>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List volume group and disk status.
  -m  <execution_mode>  - Valid modes are:
  
      [create]          - Create volume group and thin pool.
      [delete]          - Delete volume group and erase disks.

Options and arguments:  
  -d  <block_dev_names> - Disk device names to be added into volume group.
                          (Array quoted list and space separated values)
                          (Optional. Default value)
  -v  <vg_name>         - Volume group name. (Optional. Default value)
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # List current status
    sudo cs-volgroup.sh -l

  # Create volume group with default variable values 
    sudo cs-volgroup.sh -m create

  # create volume group with name "ssd"
  # from disk devices "/dev/sdb /dev/sdc /dev/sdd"
    sudo cs-volgroup.sh -m create -d "/dev/sdb /dev/sdc /dev/sdd" -v ssd

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

## Block device names in volume group (String array space separated)
## Physical device
declare -a block_dev_names=(/dev/sdb)
## Virtual device
# declare -a block_dev_names=(/dev/vdb)

# Volume Group Name
vg_name="vgdata"

# LVM Parameters
# https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.4/html/administration_guide/brick_configuration
# https://serverfault.com/questions/783611/thin-lvm-reducing-the-metadata-size-and-performance/783623

# Volume group physicalextentsize (Optional)
# physical_extent_size="32M"
physical_extent_size=
# Physical volume data alignment (Optional)
# data_alignment="256K"
data_alignment=
# Thin Pool Metadata Size (Optional. Maximum 16G)
pool_metadata_size=
# Thin Pool chunk size (Optional)
# chunk_size="256K"
chunk_size=
# ThinPool volume size. (Mandatory)
# Ex: "90%VG" - percetage of volume group,  "100%FREE" - all space free
tpool_size="100%FREE"

# Color code for messages
# https://robotmoon.com/256-colors/
msg_info="$(tput setaf 2 -T xterm-256color)[$(hostname)] [$(basename "$0")] $(date -R)
Info:$(tput sgr0 -T xterm-256color)" # Green
msg_error="$(tput setaf 1 -T xterm-256color)[$(hostname)] [$(basename "$0")] $(date -R)
Error:$(tput sgr0 -T xterm-256color)" # Red

################################################################################
# Options and arguments
################################################################################

# Execution Mode (Must be initialized empty)
execution_mode=
# Command line called
command_line="$(basename "$0") $*"
# Quiet mode (false by default)
quiet_mode=false

# Display usage if no arguments supplied
if (($# == 0)); then
  echo
  echo "${usage_msg}"
  echo
  exit 0
fi

# Parse command options
while getopts ":lm:d:v:hq" opt; do
  case $opt in
  # List status option
  l)
    # Set execution_mode
    if [[ -z "${execution_mode}" ]]; then
      execution_mode="list-status"
    else
      echo
      echo "${msg_error} Execution mode not valid ${command_line}" >&2
      echo
      exit 1
    fi
    ;;
  # Mode option
  m)
    # Set execution_mode
    if [[ -z "${execution_mode}" ]]; then
      execution_mode="$OPTARG"
    else
      echo
      echo "${msg_error} Execution mode not valid ${command_line}" >&2
      echo
      exit 1
    fi
    ;;
  # Disk device names option
  d)
    # $OPTARG to populate array block_dev_names not quoted intentionally
    # shellcheck disable=SC2206
    declare -a block_dev_names=($OPTARG)
    ;;
  # Volume group name option
  v)
    vg_name="$OPTARG"
    ;;
  # Help option: Display usage
  h)
    echo
    echo "${usage_msg}"
    echo
    exit 0
    ;;
  # Quiet option: No prompt for confirmation messages
  q)
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

# Validate ExecutionModes
case "${execution_mode}" in
"create")
  # Check volume group does not exist
  if vgs | grep -q " ${vg_name} "; then
    echo
    echo "${msg_error} Volume group ${vg_name} already exist." >&2
    echo
    exit 1
  fi

  # Check block device names exist
  for block_dev in "${block_dev_names[@]}"; do
    if ! [[ -e "${block_dev}" ]]; then
      echo
      echo "${msg_error} Device ${block_dev} does not exist." >&2
      echo
      exit 1
    fi
  done
  ;;
"delete")
  # Check volume group exist
  if ! vgs | grep -q " ${vg_name} "; then
    echo
    echo "${msg_error} Volume group ${vg_name} does not exist." >&2
    echo
    exit 1
  fi
  # Check block device names exist
  for block_dev in "${block_dev_names[@]}"; do
    if ! [[ -e "${block_dev}" ]]; then
      echo
      echo "${msg_error} Device ${block_dev} does not exist." >&2
      echo
      exit 1
    fi
  done
  ;;
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
  echo "  Disk volume group management"
  echo
  echo "      Execution mode:     ${execution_mode}"
  echo
  echo "      Block device names  ${block_dev_names[*]}"
  echo "      Volume group name:  ${vg_name}"
  echo "      Thin Pool size:     ${tpool_size}"
  echo
  echo "*********************************************************************"
  echo

  read -r -s -p $'Press Enter to continue or Ctrl+C to abort...'
  echo
  if [[ "${execution_mode}" == "create" ]] ||
    [[ "${execution_mode}" == "delete" ]]; then
    echo
    echo "******** WARNING!!!: All data on affected disks will be PERMANENTLY DELETED."
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
# Create volume group
################################################################################
if [[ "${execution_mode}" == "create" ]]; then

  # Prepare devices
  # Wipe signatures
  echo
  echo "${msg_info} Wipe signatures"
  echo
  for block_dev in "${block_dev_names[@]}"; do
    wipefs --all "${block_dev}"
  done

  # Erase partition tables
  echo
  echo "${msg_info} Erase partition tables"
  echo
  for block_dev in "${block_dev_names[@]}"; do
    echo "${block_dev}"
    dd if=/dev/zero of="${block_dev}" bs=512 count=1
  done

  # Create physical volumes
  echo
  echo "${msg_info} Create physical volumes ${block_dev_names[*]}"
  echo
  for block_dev in "${block_dev_names[@]}"; do
    echo "${block_dev}"
    if [[ -z "${data_alignment}" ]]; then
      # Default data alignment
      pvcreate "${block_dev}"
    else
      # Specific data alignment
      pvcreate --dataalignment "${data_alignment}" "${block_dev}"
    fi
  done
  pvs

  # Create volume group
  echo
  echo "${msg_info} Create volume group"
  echo
  if [[ -z "${physical_extent_size}" ]]; then
    # Default physicalextentsize
    # Array block_dev_names[*] not quoted intentionally
    # shellcheck disable=SC2086
    vgcreate "${vg_name}" ${block_dev_names[*]}
  else
    # Specific physicalextentsize
    # Array block_dev_names[*] not quoted intentionally
    # shellcheck disable=SC2086
    vgcreate --physicalextentsize "${physical_extent_size}" "${vg_name}" ${block_dev_names[*]}
  fi
  vgs
  # Create thin pool
  echo
  echo "${msg_info} Create thin pool"
  echo
  if [[ -z "${chunk_size}" ]]; then
    # Default chunksize
    if [[ -z "${pool_metadata_size}" ]]; then
      # Default pool metadata size
      lvcreate --type thin-pool --thinpool "${vg_name}"/tpool --extents "${tpool_size}"

    else
      # Specific pool metadata size
      lvcreate --type thin-pool --thinpool "${vg_name}"/tpool --extents "${tpool_size}" --poolmetadatasize "${pool_metadata_size}"
    fi
  else
    # Specific chunksize
    if [[ -z "${pool_metadata_size}" ]]; then
      # Default pool metadata size
      lvcreate --type thin-pool --thinpool "${vg_name}"/tpool --extents "${tpool_size}" --chunksize "${chunk_size}"

    else
      # Specific pool metadata size
      lvcreate --type thin-pool --thinpool "${vg_name}"/tpool --extents "${tpool_size}" --chunksize "${chunk_size}" --poolmetadatasize "${pool_metadata_size}"
    fi
  fi
  lvs
fi

################################################################################
# Delete volume group
################################################################################
if [[ "${execution_mode}" == "delete" ]]; then

  # delete Volume group
  echo
  echo "${msg_info} delete ${vg_name}"
  echo
  vgremove "${vg_name}"

  # Wipe Devices
  # Wipe signatures
  echo
  echo "${msg_info} Wipe signagures"
  echo
  for block_dev in "${block_dev_names[@]}"; do
    wipefs --all "${block_dev}"
  done

  # Erase partition tables
  echo
  echo "${msg_info} Erase partition tables"
  echo
  for block_dev in "${block_dev_names[@]}"; do
    echo "${block_dev}"
    dd if=/dev/zero of="${block_dev}" bs=512 count=1
  done

  # Update /etc/fstab to remove mounts from volume group (NO SPACE needed behind variable ${vg_name})
  sed -i "\#/dev/${vg_name}#d" /etc/fstab

  # delete completed
  echo
  echo "${msg_info} delete completed."
  echo
fi

################################################################################
# Display disk and volume group status
################################################################################

if [ "${execution_mode}" = "list-status" ]; then

  # Disks status
  echo
  echo "${msg_info} Disks and partitions"
  echo
  fdisk -l

  # Physical volumes
  echo
  echo "${msg_info} Physical volumes"
  echo
  pvs

  # Volume groups
  echo
  echo "${msg_info} Volume groups"
  echo
  vgs

fi

#### END OF EXECUTION (EOE) ####################################################
echo
echo "${msg_info} END OF EXECUTION (EOE)"
echo
exit 0
