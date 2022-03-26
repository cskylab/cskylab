#!/bin/bash

#
#   cs-rsync.sh
#
#       RSync copies for LVM data services
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
  RSync copies for LVM data services.
  Use this script to perform RSync operations with data services supported by
  thin-logical volumes created with the script "cs-lvmserv.sh".
  Snapshots will be created automatically for rsync-to copies 
  and removed when finished.

Usage:
  sudo cs-rsync.sh  [-m <execution_mode>] [-d <data_path>] [-v <vg_name>] 
                    [-r <remote_data_path>] [-t <hostname.domain.com>] [-h] [-q]

Execution modes:
  -m  <execution_mode>  - Valid modes are:

      [rsync-to]        - RSync data from local directory TO remote directory.
      [rsync-from]      - RSync data FROM remote directory to local directory.

Options and arguments:  
  -d  <data_path>           - Local data service directory path.
  -v  <vg_name>             - Volume group name. (Default value)
  -r  <remote_data_path>    - Remote directory path. (Default is same as local)
  -t  <hostname.domain.com> - Backup host (Default value)
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # RSync data service "/srv/gitlab-postgresql"
  # TO same remote directory at host "bckpoint.cskylab.com"
    sudo cs-rsync.sh -m rsync-to -d /srv/gitlab-postgresql \
      -t bckpoint.cskylab.com

  # RSync data service "/srv/gitlab-postgresql"
  # FROM remote directory "/srv/gitlab-postgresql" at host "bckpoint.cskylab.com"
    sudo cs-rsync.sh -m rsync-from -d /srv/gitlab-postgresql \
      -t bckpoint.cskylab.com

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

# Backup host (localhost or host.domain.com)
backup_host="localhost"

# Volume Group Name
vg_name="vgdata"

# User account for remote connections
remote_usr="kos"

# File with exclude patterns for rsync and restic
exclude_file="${setup_dir}/excludefile.conf"

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
# Directory path at backup host for rsync operation (must be initialized empty)
remote_data_path=

# Display usage if no arguments supplied
if (($# == 0)); then
  echo
  echo "${usage_msg}"
  echo
  exit 0
fi

# Parse command options
while getopts ":m:d:v:r:t:hq" opt; do
  case $opt in
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
  # Remote Data Path option
  r)
    # Remove trailing slashes in remote_data_path
    # sed used intentionally
    # shellcheck disable=SC2001
    remote_data_path="$(echo "$OPTARG" | sed 's:/*$::')"
    ;;
  # Backup host option
  t)
    backup_host="$OPTARG"
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

# Update variables after command options
# Copy data_path to remote_data_path if empty
if [[ -z "${remote_data_path}" ]]; then
  remote_data_path="${data_path}"
fi
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

# Check data service directory exists
if ! [[ -d "${data_path}" ]]; then
  echo
  echo "${msg_error} Data service directory path ${data_path} does not exist." >&2
  echo
  exit 1
fi

# Check remote_data_path
if [[ "${backup_host}" == "localhost" ]]; then
  if [[ "${data_path}" == "${remote_data_path}" ]]; then
    echo
    echo "${msg_error} Data directory path and remote directory path must be different in localhost" >&2
    echo
    exit 1
  fi

  # Check remote_data_path exists
  if ! [[ -d "${remote_data_path}" ]]; then
    echo
    echo "${msg_error} Remote directory path ${remote_data_path} does not exist in ${backup_host}" >&2
    echo
    exit 1
  fi
else
  # Validate backup host is reachable and ssh key authentication
  if ! [ "${backup_host}" == localhost ]; then
    echo
    echo "${msg_info} Validating backup host reachable and ssh authentication as ${remote_usr}@${backup_host}"
    echo
    ssh -T -o ConnectTimeout=3 -o PasswordAuthentication=no "${remote_usr}"@"${backup_host}" sh <<EOF
echo "Connected successfuly"
EOF
  fi

  # Check remote_data_path exists
  remote_command="! [[ -d ${remote_data_path} ]]"
  # Variable $remote_command expanded client side trailing slashes in data_path
  # No quotes intentionally
  # shellcheck disable=SC2029
  if ssh "${remote_usr}"@"${backup_host}" "${remote_command}"; then
    echo
    echo "${msg_error} Path ${remote_data_path} does not exist in ${backup_host}" >&2
    echo
    exit 1
  fi
fi

# Validate ExecutionModes
case "${execution_mode}" in
"rsync-to")
  # Check logical volume exists
  if ! [[ -e "${lv_dev_name}" ]]; then
    echo
    echo "${msg_error} Volume ${lv_dev_name} does not exist." >&2
    echo
    exit 1
  fi

  # Check snapshot does not exist
  if [[ -e "${snap_dev_name}" ]]; then
    echo
    echo "${msg_error} Snapshot ${snap_dev_name} already exist. Must be deleted before rsync-to." >&2
    echo
    exit 1
  fi
  ;;
"rsync-from") ;;
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
  echo "  RSync copies for LVM data services."
  echo
  echo "      execution_mode:         ${execution_mode}"
  if [[ "${execution_mode}" == "rsync-to" ]]; then
    echo "      Snapshot mount path:    ${snap_path_name}"
    echo "      rsync-to directory:     ${backup_host}:${remote_data_path}"
  fi
  if [[ "${execution_mode}" == "rsync-from" ]]; then
    echo "      rsync-from directory:   ${backup_host}:${remote_data_path}"
    echo "      Data directory path:    ${data_path}"
  fi
  echo
  echo "*********************************************************************"
  echo

  read -r -s -p $'Press Enter to continue or Ctrl+C to abort...'
  echo
  echo
  echo "******** FINAL WARNING!!!: All data on destination directory will be REPLACED."
  echo
  read -r -s -p $'Press Enter to continue or Ctrl+C to abort...'
  echo
fi

#### START OF EXECUTION (SOE) ##################################################
echo
echo "${msg_info} START OF EXECUTION (SOE)"
echo

################################################################################
# RSync data TO remote directory
################################################################################

if [[ "${execution_mode}" == "rsync-to" ]]; then

  # Create Snapshot
  echo
  echo "${msg_info} Create snapshot ${snap_dev_name}"
  echo
  lvcreate --snapshot --name "${snap_name}" "${vg_name}/${data_service_name}"
  lvchange -ay -K "${snap_dev_name}"

  # Manage snapshot mount moint
  if ! [[ -e "${snap_path_name}" ]]; then
    # Create mount point if doesn't exist
    mkdir -pv "${snap_path_name}"
  fi
  mount --read-only "${snap_dev_name}" "${snap_path_name}"

  # Execute rsync
  echo
  echo "${msg_info} rsync from ${snap_path_name} to ${backup_host}:${remote_data_path}"
  echo
  if [[ ${backup_host} = "localhost" ]]; then
    rsync -ahAX --stats --delete --exclude-from="${exclude_file}" --progress --numeric-ids "${snap_path_name}/" "${remote_data_path}/"
  else
    rsync -ahAXz --stats --delete --exclude-from="${exclude_file}" --progress --rsync-path="sudo rsync" --numeric-ids "${snap_path_name}/" "${remote_usr}@${backup_host}:${remote_data_path}/"
  fi

  # Checking if Snapshot is mounted (space needed behind variable ${snap_path_name})
  if grep -qs "${snap_path_name} " /proc/mounts; then
    # Unmount data_service_name
    echo
    echo "${msg_info} Unmount snapshot ${snap_dev_name} from ${snap_path_name} directory"
    echo
    umount "${snap_path_name}"
  fi

  # Remove Snapshot
  echo
  echo "${msg_info} Remove snapshot"
  echo
  lvremove --yes "${vg_name}/${snap_name}"

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
# RSync data FROM remote directory
################################################################################

if [[ "${execution_mode}" == "rsync-from" ]]; then

  # Execute rsync
  echo
  echo "${msg_info} rsync from ${backup_host}:${remote_data_path}"
  echo
  if [[ ${backup_host} = "localhost" ]]; then
    rsync -ahAX --stats --delete --exclude-from="${exclude_file}" --progress --numeric-ids "${remote_data_path}/" "${data_path}/"
  else
    rsync -ahAXz --stats --delete --exclude-from="${exclude_file}" --progress --rsync-path="sudo rsync" --numeric-ids "${remote_usr}@${backup_host}:${remote_data_path}/" "${data_path}/"
  fi
fi

#### END OF EXECUTION (EOE) ####################################################
echo
echo "${msg_info} END OF EXECUTION (EOE)"
echo
exit 0
