#!/bin/bash

#
#   cs-lvmserv.sh
#
#       LVM data services.
#
#   Copyright © 2024 cSkyLab.com
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
  LVM data services.
  Use this script to create or delete directory data services with independent 
  thin logical volumes suitable for snapshot operations.
  A volume group and thin-pool must have been created before using the 
  script "cs-volgroup.sh".

Usage:
  sudo cs-lvmserv.sh  [-l] [-m <execution_mode>]
                      [-d <data_path>] [-v <vg_name>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List status of existing logical volumes.
  -m  <execution_mode>  - Valid modes are:
  
      [create]          - Create data service.
                          (Thin logical volume + directory mount)
      [delete]          - Delete data service.
                          (Thin logical volume + directory mount)
      [snap-create]     - Create snapshot and mount to read-only directory.
      [snap-remove]     - Remove snapshot and unmount from read-only directory.
      [snap-merge]      - Roll back logical volume to snapshot status
                           and discard all changes.
      [trim-space]      - Free space inside thin-pools
                          discarding unused blocks on all mounted filesystems.

Options and arguments:  
  -d  <data_path>       - Data service directory path.
                          (Thin LV will be mounted on it)
  -v  <vg_name>         - Volume group name. (Default value)
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # List logical volume status
    sudo cs-lvmserv.sh -l

  # Create thin logical volume data service "/srv/gitlab-postgresql"
  # in default volume group.
    sudo cs-lvmserv.sh -m create -d /srv/gitlab-postgresql

  # Create snapshot of data service "/srv/gitlab-postgresql"
  # in default volume group.
  # Snapshot will be mounted read-only in /tmp/gitlab-postgresql_snap
    sudo cs-lvmserv.sh -m snap-create -d /srv/gitlab-postgresql

  # Remove snapshot of data service "/srv/gitlab-postgresql"
  # in default volume group
    sudo cs-lvmserv.sh -m snap-remove -d /srv/gitlab-postgresql

  # Merge snapshot of data service "/srv/gitlab-postgresql"
  # in default volume group
    sudo cs-lvmserv.sh -m snap-merge -d /srv/gitlab-postgresql

  # Delete thin logical volume data service "/srv/gitlab-postgresql"
  # in default volume group
    sudo cs-lvmserv.sh -m delete -d /srv/gitlab-postgresql

  # Free space inside thin-pools
    sudo cs-lvmserv.sh -m trim-space

EOF
)"

################################################################################
# Variable initialization
################################################################################

# Administrator (sudoer) user name
# Must be declared in all scripts because it could be referenced in templates
# shellcheck disable=SC2034
sudo_username="{{ .machine.localadminusername }}"

# Setup directory
# Must be declared in all scripts because it could be referenced in templates
# WARNING: Content will be deleted and replaced with every new configuration.
# Must be accesible by sudo_username. Use the same in all scripts.
# shellcheck disable=SC2034
setup_dir="{{ .machine.setupdir }}"

# Volume Group Name
vg_name="vgdata"

# User and group default ownership for data directories
user_owner=${sudo_username}
group_owner=${sudo_username}

# Command to create filesystem (ext4)
command_to_format="sudo mkfs -t ext4"

# Options for fstab LV mount (ext4)
options_lv_mount="ext4  defaults    0  2"

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

# Data service full path (must be initialized empty)
data_path=

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
  # Data path service option
  d)
    # Remove trailing slashes in data_path
    # sed used intentionally
    # shellcheck disable=SC2001
    data_path="$(echo "$OPTARG" | sed 's:/*$::')"
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

# LVM parameters
# Data service name
data_service_name="$(basename "${data_path}")"
# LV Device Name
lv_dev_name="/dev/${vg_name}/${data_service_name}"
# Snapshot name
snap_name="${data_service_name}_snap"
# Snapshot device name
snap_dev_name="/dev/${vg_name}/${snap_name}"
# Snap mount point path (should be mounted under /mnt)
snap_path_name="/tmp/${snap_name}"

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
  # Check volume group exist
  if ! vgs | grep -q " ${vg_name} "; then
    echo
    echo "${msg_error} Volume group ${vg_name} does not exist." >&2
    echo
    exit 1
  fi
  # Check data service directory path not empty
  if [[ -z "${data_path}" ]]; then
    echo
    echo "${msg_error} Data service directory path must be provided." >&2
    echo
    exit 1
  fi

  # Check data service directory path does not exist
  if [[ -d "${data_path}" ]]; then
    echo
    echo "${msg_error} Data service directory path ${data_path} already exists." >&2
    echo
    exit 1
  fi

  # Check LV Device Name does not exist
  if [[ -e "${lv_dev_name}" ]]; then
    echo
    echo "${msg_error} Logical Volume ${lv_dev_name} already exist." >&2
    echo
    exit 1
  fi
  ;;
"delete")
  # Check data service directory path not empty
  if [[ -z "${data_path}" ]]; then
    echo
    echo "${msg_error} Data service directory path must be provided." >&2
    echo
    exit 1
  fi

  # Check LV Device Name exist
  if ! [[ -e "${lv_dev_name}" ]]; then
    echo
    echo "${msg_error} Logical Volume ${lv_dev_name} does not exist." >&2
    echo
    exit 1
  fi

  # Check snapshot does not exist
  if [[ -e "${snap_dev_name}" ]]; then
    echo
    echo "${msg_error} Snapshot ${snap_dev_name} exist. Must be deleted before logical volume." >&2
    echo
    exit 1
  fi
  ;;
"snap-create")
  # Check data service directory path not empty
  if [[ -z "${data_path}" ]]; then
    echo
    echo "${msg_error} Data service directory path must be provided." >&2
    echo
    exit 1
  fi
  # Check LV Device Name exist
  if ! [[ -e "${lv_dev_name}" ]]; then
    echo
    echo "${msg_error} Logical Volume ${lv_dev_name} does not exist." >&2
    echo
    exit 1
  fi
  # Check snapshot does not exist
  if [[ -e "${snap_dev_name}" ]]; then
    echo
    echo "${msg_error} Snapshot ${snap_dev_name} already exist." >&2
    echo
    exit 1
  fi
  ;;
"snap-remove")
  # Check data service directory path not empty
  if [[ -z "${data_path}" ]]; then
    echo
    echo "${msg_error} Data service directory path must be provided." >&2
    echo
    exit 1
  fi
  # No more validations performed because snapshot could be inactive after a possible machine reboot.
  # If snapshot does not exist, the error will be trapped in execution block.
  ;;
"snap-merge")
  # Check data service directory path not empty
  if [[ -z "${data_path}" ]]; then
    echo
    echo "${msg_error} Data service directory path must be provided." >&2
    echo
    exit 1
  fi

  # Check LV Device Name exist
  if ! [[ -e "${lv_dev_name}" ]]; then
    echo
    echo "${msg_error} Logical Volume ${lv_dev_name} does not exist." >&2
    echo
    exit 1
  fi
  # Check snapshot exists
  if ! [[ -e "${snap_dev_name}" ]]; then
    echo
    echo "${msg_error} Snapshot ${snap_dev_name} does not exist." >&2
    echo
    exit 1
  fi
  ;;

"trim-space") ;;

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
  echo "  LVM data services"
  echo
  echo "      execution_mode:  ${execution_mode}"
  if ! [[ "${execution_mode}" == "trim-space" ]]; then

    echo
    echo "      Full data service path:     ${data_path}"
    echo "      Volume group name:          ${vg_name}"
    echo "      Thin LV name:               ${lv_dev_name}"
    if [[ "${execution_mode}" == "snap-create" ]] ||
      [[ "${execution_mode}" = "snap-remove" ]] ||
      [[ "${execution_mode}" = "snap-merge" ]]; then
      echo "      Snapshot Name:              ${snap_dev_name}"
      echo "      Snapshot mount point:       ${snap_path_name}"
    fi
  fi
  echo
  echo "*********************************************************************"
  echo

  read -r -s -p $'Press Enter to continue or Ctrl+C to abort...'
  echo

  if [[ "${execution_mode}" == "delete" ]]; then
    echo
    echo "******** WARNING!!!: All data on logical volume will be PERMANENTLY DELETED."
    echo
    read -r -s -p $'Press Enter to continue or Ctrl+C to abort...'
    echo
  fi

  if [[ "${execution_mode}" == "snap-merge" ]]; then
    echo
    echo "******** WARNING!!!: All data changes on logical volume will be DISCARDED AND ROLLED BACK TO THE SNAPSHOT."
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
# Create LVM data service
################################################################################

if [[ "${execution_mode}" == "create" ]]; then

  # Preserve original fstab
  if ! [[ -f "/etc/fstab.naked" ]]; then
    echo
    echo "${msg_info} Copy /etc/fstab to /etc/fstab.naked"
    echo
    cp -v /etc/fstab /etc/fstab.naked
  fi

  # Create thin logical volume
  echo
  echo "${msg_info} Create thin logical volume"
  echo

  # Calculated ThinPool volume size will be assigned as LV size
  # Parameter --virtualsize must be numeric
  # Intentionally no quotes on calculated result
  # shellcheck disable=SC2046
  lvcreate --thin --name "${data_service_name}" "${vg_name}/tpool" --virtualsize $(sudo lvs "/dev/${vg_name}/tpool" -o LV_SIZE --noheadings --units g)
  lvs

  # create file system
  echo
  echo "${msg_info} Create file system: ${command_to_format} ${lv_dev_name}"
  echo
  ${command_to_format} "${lv_dev_name}"

  # Mount logical volume
  if ! [[ -e "${data_path}" ]]; then
    # create mount point if doesn't exist
    mkdir -pv "${data_path}"
  else
    # Get directory ownership
    user_owner=$(stat -c '%U' "${data_path}")
    group_owner=$(stat -c '%G' "${data_path}")

    # create empty temp directory
    if [[ -e "/tmp/${data_service_name}" ]]; then
      rm -rv "/tmp/${data_service_name}"
    fi
    mkdir -p "/tmp/${data_service_name}"

    # Copy existing data if exists
    echo
    echo "${msg_info} Copying existing data in ${data_path} directory to logical volume ${lv_dev_name}"
    echo
    mount "${lv_dev_name}" /tmp/"${data_service_name}"
    cp -av "${data_path}"/* /tmp/"${data_service_name}"/
    umount /tmp/"${data_service_name}"
  fi

  # Update /etc/fstab
  echo
  echo "${msg_info} Update /etc/fstab and mount"
  echo
  echo "${lv_dev_name}  ${data_path}  ${options_lv_mount}" | sudo tee -a /etc/fstab
  mount -a

  # Delete lost+found directory if exists
  if [[ -d "${data_path}"/lost+found ]]; then
    rm -rv "${data_path}"/lost+found
  fi

  # Create data directory if doesn't exist
  if ! [[ -d "${data_path}"/data ]]; then
    mkdir "${data_path}"/data
  fi

  # Set directory ownership
  chown "${user_owner}":"${group_owner}" -R "${data_path}"

fi

################################################################################
# Delete data service
################################################################################

if [[ "${execution_mode}" == "delete" ]]; then

  # Checking if data_service_name is mounted (space needed behind variable ${data_path})
  if grep -qs "${data_path} " /proc/mounts; then
    # Unmount data_service_name
    echo
    echo "${msg_info} Unmount logical volume ${lv_dev_name} from ${data_path} directory"
    echo
    umount "${data_path}"
  fi

  # delete thin logical volume
  echo
  echo "${msg_info} delete thin logical volume"
  echo
  lvremove "${lv_dev_name}"
  lvs

  # Update /etc/fstab
  echo
  echo "${msg_info} Update /etc/fstab"
  echo
  # Update /etc/fstab to remove mount (space needed behind variable ${lv_dev_name})
  sed -i "\#${lv_dev_name} #d" /etc/fstab

  # delete service directory if empty
  if [[ -d "${data_path}" ]]; then
    shopt -s nullglob
    declare -a dir_files=("${data_path}"/*)
    shopt -u nullglob
    count=${#dir_files[@]}
    if ((count == 0)); then
      rm -rv "${data_path}"
    fi
  fi
fi

################################################################################
# Create snapshot
################################################################################

if [[ "${execution_mode}" == "snap-create" ]]; then

  # create Snapshot
  echo
  echo "${msg_info} Create snapshot"
  echo
  lvcreate --snapshot --name "${snap_name}" "${vg_name}/${data_service_name}"
  lvchange -ay -K "${snap_dev_name}"
  lvs

  # Manage snapshot mount moint
  if ! [[ -e "${snap_path_name}" ]]; then
    # create mount point if doesn't exist
    mkdir -pv "${snap_path_name}"
  fi
  mount --read-only "${snap_dev_name}" "${snap_path_name}"
fi

################################################################################
# Remove snapshot
################################################################################

if [[ "${execution_mode}" == "snap-remove" ]]; then

  # Checking if Snapshot is mounted (space needed behind variable ${snap_path_name})
  if grep -qs "${snap_path_name} " /proc/mounts; then
    # Unmount snapshot
    echo
    echo "${msg_info} Unmount snapshot ${snap_dev_name} from ${snap_path_name} directory"
    echo
    umount "${snap_path_name}"
  fi

  # Remove snapshot
  echo
  echo "${msg_info} Remove snapshot"
  echo
  lvremove --yes "${vg_name}/${snap_name}"
  lvs

  # Delete snapshot directory if empty
  if [[ -d "${snap_path_name}" ]]; then
    shopt -s nullglob
    declare -a dir_files=("${snap_path_name}"/*)
    shopt -u nullglob
    count=${#dir_files[@]}
    if ((count == 0)); then
      rm -rv "${snap_path_name}"
    fi
  fi
fi

################################################################################
# Merge snapshot
################################################################################

if [[ "${execution_mode}" == "snap-merge" ]]; then

  # Merge Snapshot
  echo
  echo "${msg_info} Merge snapshot"
  echo
  lvconvert --merge "${vg_name}/${snap_name}"
  lvs

  # Checking if Snapshot is mounted (space needed behind variable ${snap_path_name})
  if grep -qs "${snap_path_name} " /proc/mounts; then
    # Unmount data_service_name
    echo
    echo "${msg_info} Unmount snapshot ${snap_dev_name} from ${snap_path_name} directory"
    echo
    umount "${snap_path_name}"
  fi

  # Checking if data_service_name is mounted (space needed behind variable ${data_path})
  if grep -qs "${data_path} " /proc/mounts; then
    # Unmount data_service_name
    echo
    echo "${msg_info} Unmount logical volume ${lv_dev_name} from ${data_path} directory"
    echo
    umount "${data_path}"
  fi

  # Deactivate and activate logical volume
  echo
  echo "${msg_info} Deactivate and activate logical volume"
  echo
  lvchange -an -K "${vg_name}/${data_service_name}"
  lvchange -ay -K "${vg_name}/${data_service_name}"

  # Mount /etc/fstab volumes
  echo
  echo "${msg_info} Mount /etc/fstab volumes"
  echo
  mount -a

  # Delete snapshot directory if empty
  if [[ -d "${snap_path_name}" ]]; then
    shopt -s nullglob
    declare -a dir_files=("${snap_path_name}"/*)
    shopt -u nullglob
    count=${#dir_files[@]}
    if ((count == 0)); then
      rm -rv "${snap_path_name}"
    fi
  fi
fi
################################################################################
# Trim filesystem
################################################################################

if [[ "${execution_mode}" == "trim-space" ]]; then

  # Trim all filesystems
  fstrim -a

  echo
  echo "${msg_info} Trim completed. Check volume status with sudo cs-lvmserv.sh -l"
  echo
fi

################################################################################
# Display LVM and filesystem status
################################################################################

if [[ "${execution_mode}" == "list-status" ]]; then

  # Logical volumes
  echo
  echo "${msg_info} Logical volumes"
  echo
  lvs

  ## File systems
  # echo
  # echo "${msg_info} File systems"
  # echo
  # df -Th

fi

#### END OF EXECUTION (EOE) ####################################################
echo
echo "${msg_info} END OF EXECUTION (EOE)"
echo
exit 0
