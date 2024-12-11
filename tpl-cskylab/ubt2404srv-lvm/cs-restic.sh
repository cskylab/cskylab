#!/bin/bash

#
#   cs-restic.sh
#
#       Restic backup for LVM data services
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
# usage_msg message
################################################################################

usage_msg="$(
  cat <<EOF

Purpose:
  Restic backup for LVM data services.
  Use this script to perform Restic operations with data services supported by
  thin-logical volumes created with the script "cs-lvmserv.sh".
  Snapshots will be created automatically for backups and removed when finished.

Usage:
  sudo cs-restic.sh [-m <execution_mode>] [-d <data_path>] [-v <vg_name>] [-t <tag_name>] 
                    [-r <RESTIC_REPOSITORY>] [-i <restic_snap_id>]
                    [-p <RESTIC_PASSWORD>] [-a <AWS_ACCESS_KEY_ID>]
                    [-k <AWS_SECRET_ACCESS_KEY>] [-f <forget_options>] [-h] [-q]

Execution modes:
  -m  <execution_mode>   - Valid modes are:
  
      [restic-bck]       - Backup to local or remote repository.
      [restic-list]      - List snapshots in repository.
      [restic-mount]     - Mount repository to /mnt directory.
      [restic-res]       - Restore from repository to directory data service.
                           (Directory must be empty).
      [repo-init]        - Initialize repository (Directory or bucket must exist).
      [restic-forget]    - Maintain repository and remove snapshots with forget option.

Options and arguments:  
  -d  <data_path>             - Local data service directory path. (Mandatory)
  -v  <vg_name>               - Volume group name. (Default value)
  -t  <tag_name>              - Tag name for the snapshot. (Default value)
  -r  <RESTIC_REPOSITORY>     - Restic repository (Default value)
  -i  <restic_snap_id>        - Snapshot ID to restore (Default latest)
  -p  <RESTIC_PASSWORD>       - Restic password (Default value)
  -a  <AWS_ACCESS_KEY_ID>     - S3 access key (Default value)
  -k  <AWS_SECRET_ACCESS_KEY> - S3 secret key (Default value)
  -f  <forget_options>        - Options to execute (Default value)
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Backup data service "/srv/gitlab-postgresql"
  # TO local repository "/srv/restic/gitlab-postgresql/" 
    sudo cs-restic.sh -m restic-bck -d /srv/gitlab-postgresql \
                                  -r "/srv/restic/gitlab-postgresql/"

  # Backup data service "/srv/gitlab-postgresql"
  # TO remote sftp repository "sftp:kos@backup.cskylab.com:/srv/restic/gitlab-postgresql/" 
    sudo cs-restic.sh -m restic-bck -d /srv/gitlab-postgresql \
                                  -r "sftp:kos@backup.cskylab.com:/srv/restic/gitlab-postgresql/"

  # Backup data service "/srv/gitlab-postgresql" tagged "gitlab-postgresql"
  # TO shared repository in MinIO bucket "s3:https://minio-standalone.cskylab.com/restic-test/" 
    sudo cs-restic.sh -m restic-bck -d /srv/gitlab-postgresql \
                                  -t gitlab-postgresql -r "s3:https://minio-standalone.cskylab.com/restic-test/"

  # List snapshots in repository "s3:https://minio-standalone.cskylab.com/restic-test/" 
    sudo cs-restic.sh -m restic-list -r "s3:https://minio-standalone.cskylab.com/restic-test/"

  # Restore data service "/srv/gitlab-postgresql"
  # FROM latest snapshot in repository "/srv/restic/gitlab-postgresql" 
    sudo cs-restic.sh -m restic-res -d /srv/gitlab-postgresql \
                                  -r "/srv/restic/gitlab-postgresql"

  # Create repository in directory "/srv/restic/gitlab-postgresql"
    sudo cs-restic.sh -m repo-init -r "/srv/restic/gitlab-postgresql"

  # Maintain repository "/srv/restic/gitlab-postgresql" applying host, tag and forget options
    sudo cs-restic.sh -m restic-forget -r "/srv/bck/gitlab-postgresql" \
              -t "gitlab-postgresql" -f "--keep-hourly 6 --keep-daily 31 --keep-weekly 5 --keep-monthly 13 --keep-yearly 10"

  # Mount repository "/srv/bck/gitlab-postgresql"   
  # in /mnt directory
    sudo cs-restic.sh -m restic-mount -r "s3:https://minio-standalone.cskylab.com/restic-test/"

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

# File with exclude patterns for rsync and restic
exclude_file="${setup_dir}/excludefile.conf"

# Restic repository mount point path (should be mounted under /tmp)
restic_mount_point="/tmp/restic"

# forget_options - Restic repository maintenance forget options
# https://restic.readthedocs.io/en/stable/060_forget.html
declare -a forget_options=(--keep-hourly 6 --keep-daily 31 --keep-weekly 5 --keep-monthly 13 --keep-yearly 10)

# restic-environment
export RESTIC_REPOSITORY="{{ .restic.repo }}"
export RESTIC_PASSWORD="{{ .restic.password }}"
export AWS_ACCESS_KEY_ID="{{ .restic.aws_access }}"
export AWS_SECRET_ACCESS_KEY="{{ .restic.aws_secret }}"

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
# Backup tag name (must be initialized empty)
tag_name=
# Restic snapshot ID to restore
restic_snap_id="latest"

# Display usage if no arguments supplied
if (($# == 0)); then
  echo
  echo "${usage_msg}"
  echo
  exit 0
fi

# Parse command options
while getopts ":m:d:v:t:r:i:p:a:k:f:hq" opt; do
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
  # Backup tag option
  t)
    tag_name="$OPTARG"
    ;;
  # Restic repository path option
  r)
    export RESTIC_REPOSITORY="$OPTARG"
    ;;
  # Restic snapshot ID option
  i)
    # Modify restic_snap_id from default value
    restic_snap_id="$OPTARG"
    ;;
  # Restic password
  p)
    # Modify RESTIC_PASSWORD from default value
    export RESTIC_PASSWORD="$OPTARG"
    ;;
  # S3 access key option
  a)
    # Modify S3 access key from default value
    export AWS_ACCESS_KEY_ID="$OPTARG"
    ;;
  # S3 secret key option
  k)
    # Modify S3 secret key from default value
    export AWS_SECRET_ACCESS_KEY="$OPTARG"
    ;;
  # S3 secret key option
  f)
    # Modify forget_options from default value
    declare -a forget_options
    IFS=', ' read -r -a forget_options <<<"$OPTARG"
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

# Data service name
data_service_name="$(basename "${data_path}")"

# Set tag_name if value is not given
if [[ -z "${tag_name}" ]]; then
  tag_name="${data_service_name}"
fi

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
"restic-bck")
  # Check data service directory exists
  if ! [[ -d "${data_path}" ]]; then
    echo
    echo "${msg_error} Data service directory path ${data_path} does not exist." >&2
    echo
    exit 1
  fi

  # Check snapshot does not exist
  if [[ -e "${snap_dev_name}" ]]; then
    echo
    echo "${msg_error} Snapshot ${snap_dev_name} already exist. Must be deleted before restic-bck." >&2
    echo
    exit 1
  fi
  # Check logical volume
  if ! [[ -e "${lv_dev_name}" ]]; then
    echo
    echo "${msg_error} Volume ${lv_dev_name} does not exist." >&2
    echo
    exit 1
  fi
  ;;
"restic-list")
  # Set quiet_mode
  quiet_mode=true
  ;;
"restic-mount") ;;
"restic-res")
  # Check data service directory exists
  if ! [[ -d "${data_path}" ]]; then
    echo
    echo "${msg_error} Data service directory path ${data_path} does not exist." >&2
    echo
    exit 1
  fi
  # Check empty data service directory
  if [[ -n "$(ls -A "${data_path}")" ]]; then
    echo
    echo "${msg_error} Data service directory path ${data_path} is not empty." >&2
    echo
    exit 1
  fi
  # Check restic snapshot
  echo
  echo "${msg_info} Restic snapshot selected for restore:"
  echo
  restic snapshots "${restic_snap_id}"
  ;;
"repo-init") ;;
"restic-forget") ;;
*)
  echo
  echo "${msg_error} Execution mode not valid ${command_line}" >&2
  echo
  exit 1
  ;;
esac

# Check RESTIC_REPOSITORY
if
  [[ "${execution_mode}" != "repo-init" ]] &&
    [[ "${execution_mode}" != "restic-res" ]] &&
    [[ "${execution_mode}" != "restic-list" ]]
then
  echo
  echo "${msg_info} Validating access to repository ${RESTIC_REPOSITORY}"
  echo
  restic snapshots
fi

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
  echo "  Restic backup for LVM data services."
  echo
  echo "         execution_mode: ${execution_mode}"
  echo "      Restic repository: ${RESTIC_REPOSITORY}"
  if [[ "${execution_mode}" == "restic-bck" ]]; then
    echo "                    Tag: ${tag_name}"
    echo "    Snapshot mount path: ${snap_path_name}"
  fi
  if [[ "${execution_mode}" == "restic-mount" ]]; then
    echo " Repository mount point: ${restic_mount_point}"
    echo
    echo "  To list contents of latest snapshot, open another terminal and run:"
    echo "      < sudo ls -lah  ${restic_mount_point}/snapshots/latest/ >"
  fi
  if [[ "${execution_mode}" == "restic-res" ]]; then
    echo "            Snapshot ID: ${restic_snap_id}"
    echo "      Data service path: ${data_path}"
    echo
    echo "  To see progress, open another terminal and run:"
    echo "      < sudo du -sh ${data_path} >"
  fi
  if [[ "${execution_mode}" == "restic-forget" ]]; then
    echo "                    Tag: ${tag_name}"
    echo "         Forget Options: ${forget_options[*]}"
  fi
  echo
  echo "*********************************************************************"
  echo

  read -r -s -p $'Press Enter to continue or Ctrl+C to abort...'
  echo
fi

#### START OF EXECUTION (SOE) ##################################################
echo
echo "${msg_info} START OF EXECUTION (SOE)"
echo

################################################################################
# Set restic ssh config parameters
################################################################################

if [[ "${execution_mode}" == "restic-bck" ]] ||
  [[ "${execution_mode}" == "restic-res" ]]; then

  # Prepare ssh config parameters
  if ! [[ -f "/root/.ssh/config" ]]; then
    echo
    echo "${msg_info} Generate /root/.ssh/config"
    echo
    touch /root/.ssh/config
    echo "ServerAliveInterval 60" | sudo tee -a /root/.ssh/config
    echo "ServerAliveCountMax 240" | sudo tee -a /root/.ssh/config
  else
    echo
    echo "${msg_info} /root/.ssh/config file exist. Must contain ServerAlive parameters required by restic sftp"
    echo
  fi

fi

################################################################################
# Restic backup
################################################################################

if [[ "${execution_mode}" == "restic-bck" ]]; then

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

  # Execute restic backup
  cd "${snap_path_name}"/
  restic backup . --no-cache --tag "${tag_name}" --exclude-file "${exclude_file}" --verbose
  cd "$HOME"

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
# Restic repository maintenance
################################################################################

if [[ "${execution_mode}" == "restic-forget" ]]; then
  # Maintain Restic repository
  echo
  echo "${msg_info} Maintenance of Restic repository ${RESTIC_REPOSITORY}."
  echo
  restic forget --tag "${tag_name}" "${forget_options[@]}"
fi

################################################################################
# Display snapshots in Restic repository
################################################################################

if [[ "${execution_mode}" == "restic-list" ]] ||
  [[ "${execution_mode}" == "restic-bck" ]] ||
  [[ "${execution_mode}" == "restic-forget" ]]; then

  echo
  echo "${msg_info} Restic snapshots in repository ${RESTIC_REPOSITORY}:"
  echo
  # Display restic snapshots
  if [[ -z "${tag_name}" ]]; then
    restic snapshots
  else
    restic snapshots --tag "${tag_name}"
  fi
  echo
  # Display stats for latest
  restic stats latest --verbose
fi

################################################################################
# Restic restore
################################################################################

if [[ "${execution_mode}" == "restic-res" ]]; then

  # Execute restic restore
  echo
  echo "${msg_info} Restore in progress. Wait until finished."
  echo
  # Display stats for restic_snap_id
  restic restore "${restic_snap_id}" --verbose --target "${data_path}" --verbose
  echo
  echo "${msg_info} Restic restore completed at ${data_path}"
  echo

fi

################################################################################
# Create Restic repository
################################################################################

if [[ "${execution_mode}" == "repo-init" ]]; then
  # Create Restic repository
  echo
  echo "${msg_info} Creating Restic repository ${RESTIC_REPOSITORY}."
  echo
  restic init --verbose
fi

################################################################################
# Change ownership of local restic repository
################################################################################

if [[ "${execution_mode}" == "restic-bck" ]] ||
  [[ "${execution_mode}" == "restic-forget" ]] ||
  [[ "${execution_mode}" == "repo-init" ]]; then

  # Check if restic repository is local
  if [[ -d "${RESTIC_REPOSITORY}" ]]; then
    echo
    echo "${msg_info} Changing ownership of restic repository ${RESTIC_REPOSITORY}."
    echo
    chown -R "${sudo_username}":"${sudo_username}" "${RESTIC_REPOSITORY}"
  fi

fi

################################################################################
# Mount Restic repository
################################################################################

if [[ "${execution_mode}" == "restic-mount" ]]; then

  echo
  echo "${msg_info} Mounting Restic repository in ${restic_mount_point}."
  echo
  # Checking if Restic repository is mounted (space needed behind variable ${restic_mount_point})
  if grep -qs "${restic_mount_point} " /proc/mounts; then
    # Unmount data_service_name
    echo
    echo "${msg_info} Unmount restic repository ${restic_mount_point}"
    echo
    umount "${restic_mount_point}"
  fi

  # Create mount point if doesn't exist
  if ! [[ -d "${restic_mount_point}" ]]; then
    mkdir -pv "${restic_mount_point}"
  fi

  # Mount Restic repository
  echo
  echo "${msg_info} To list contents of latest snapshot, open another terminal and run:"
  echo "              < sudo ls -lah  ${restic_mount_point}/snapshots/latest/ >"
  echo
  restic mount "${restic_mount_point}" --verbose
fi

#### END OF EXECUTION (EOE) ####################################################
echo
echo "${msg_info} END OF EXECUTION (EOE)"
echo
exit 0
