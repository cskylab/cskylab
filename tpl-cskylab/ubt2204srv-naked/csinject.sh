#!/bin/bash

#
#   csinject.sh
#
#       Inject & Deploy configuration files into remote machine
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
  Inject & Deploy configuration files into remote machine.
  This script runs from the management (DevOps) computer, copying all configuration
  files to the remote machine, and calling the script 'cs-deploy.sh' to run from
  inside the remote machine if 'deploy' mode [-d] is selected.

Usage:
  ./csinject.sh [-k] [-i] [-d] [-m <deploy_mode>] [-u <sudo_username>] [-r <remote_machine>] [-h] [-q]

Execution modes:
  -k  [ssh-sudoers] - install ssh key and sudoers file into the machine. Required before other actions.
  -i  [inject]      - Inject only. Inject configuration files into the machine for manual deployment.
  -d  [deploy]      - Inject & Deploy configuration. Calls 'cs-deploy.sh' to run from inside the machine.

Options and arguments:  
  -m  <deploy_mode>       - Deploy mode passed to 'cs-deploy.sh'. Valid modes are:

      [net-config]        - Network configuration. (Reboot when finished).
      [install]           - Package installation, updates and configuration tasks (Reboot when finished).
      [config]            - Redeploy config files and perform configuration tasks (Default mode).
  
  -u  <sudo_username>     - Remote administrator (sudoer) user name (Default value).
  -r  <remote_machine>    - Machine hostname or IPAddress (Default value).
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Copy ssh key and sudoers file into the machine:
    ./csinject.sh -k

  # Inject & Deploy configuration in [net-config] mode:
    ./csinject.sh -dm net-config

  # Inject & Deploy configuration in [install] mode:
    ./csinject.sh -dm install

  # Inject & Deploy configuration in [config] mode (default):
    ./csinject.sh -d

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

# Host FQDN
remote_machine="{{ .machine.hostname }}.{{ .machine.domainname }}"
# IP address
ip_address="{{ .machine.ipaddress }}"

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

# Deploy default mode
deploy_mode="config"
# Script to execute inside the machine when deploy option selected
deploy_script="sudo cs-deploy.sh"

# Display usage if no arguments supplied
if (($# == 0)); then
  echo
  echo "${usage_msg}"
  echo
  exit 0
fi

# Parse command options
while getopts ":kidm:u:r:hq" opt; do
  case $opt in
  # ssh-sudoers option
  k)
    # Set execution_mode
    if [[ -z "${execution_mode}" ]]; then
      execution_mode="ssh-sudoers"
    else
      echo
      echo "${msg_error} Execution mode not valid ${command_line}" >&2
      echo
      exit 1
    fi
    ;;
  # inject option
  i)
    # Set execution_mode
    if [[ -z "${execution_mode}" ]]; then
      execution_mode="inject"
    else
      echo
      echo "${msg_error} Execution mode not valid ${command_line}" >&2
      echo
      exit 1
    fi
    ;;
  # deploy option
  d)
    # Set execution_mode
    if [[ -z "${execution_mode}" ]]; then
      execution_mode="deploy"
    else
      echo
      echo "${msg_error} Execution mode not valid ${command_line}" >&2
      echo
      exit 1
    fi
    ;;
  # Mode option
  m)
    # Set deploy mode
    deploy_mode="$OPTARG"
    ;;
  # sudo_username option
  u)
    # Set sudo_username
    sudo_username="$OPTARG"
    ;;
  # Machine hostname option
  r)
    # Set remote_machine
    remote_machine="$OPTARG"
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
  # Unknown option
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

# Validate execution modes
case "${execution_mode}" in
"ssh-sudoers")
  # Validate domadminsudo file exist
  if ! [[ -f ./domadminsudo ]]; then
    echo
    echo "${msg_error} Sudoers file configuration 'domadminsudo' must exist." >&2
    echo
    exit 1
  fi
  ;;
"inject" | "deploy")
  # Validate deploy script (cs-deploy.sh) exist
  if ! [[ -f ./cs-deploy.sh ]]; then
    echo
    echo "${msg_error} Deploy script 'cs-deploy.sh' must exist." >&2
    echo
    exit 1
  fi
  # Validate machine is reachable and ssh key authentication
  echo
  echo "${msg_info} Validating machine reachable and ssh authentication as ${sudo_username}@${remote_machine}"
  echo
  ssh -T -o ConnectTimeout=3 -o PasswordAuthentication=no "${sudo_username}"@"${remote_machine}" sh <<EOF
echo "Connected successfuly"
EOF
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
  echo "  Inject & Deploy configuration files into remote machine"
  echo
  echo "      Execution mode:     ${execution_mode}"
  if [[ "${execution_mode}" == "deploy" ]]; then
    echo "      Deploy mode:        ${deploy_script} -m ${deploy_mode}"
  fi
  echo "      Remote user name:   ${sudo_username}"
  echo "      Machine hostname:   ${remote_machine}"
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
# Inject ssh key and sudoers file
################################################################################

if [[ "${execution_mode}" == "ssh-sudoers" ]]; then

  # Clean known_host file from previous entries
  if [[ -f ${HOME}/.ssh/known_hosts ]]; then

    echo
    echo "${msg_info} Cleaning ${HOME}/.ssh/known_hosts file entries"
    echo
    ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "${remote_machine}"
    ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "${ip_address}"

  fi

  # Perform ssh-copy-id
  echo
  echo "${msg_info} Copying ssh key for ssh authentication as ${sudo_username}@${remote_machine}"
  echo
  ssh-copy-id "${sudo_username}"@"${remote_machine}"

  # deploy sudoers file
  echo
  echo "${msg_info} Deploying sudoers file for further passwordless operation."
  echo "      You may be asked for [sudo] password for ${sudo_username}."
  echo

  # Delete /tmp/domadminsudo
  ssh -T -o PasswordAuthentication=no "${sudo_username}"@"${remote_machine}" sh <<EOF
touch /tmp/domadminsudo
rm -f /tmp/domadminsudo
EOF

  # Copy domadminsudo
  scp -o PasswordAuthentication=no ./domadminsudo "${sudo_username}"@"${remote_machine}":/tmp/

  # Change domadminsudo permission and file mode
  ssh -T -o PasswordAuthentication=no "${sudo_username}"@"${remote_machine}" sh <<EOF
chmod 0440 /tmp/domadminsudo
EOF

  # deploy domadminsudo
  ssh -tt -o PasswordAuthentication=no "${sudo_username}"@"${remote_machine}" "sudo cp -v /tmp/domadminsudo /etc/sudoers.d/domadminsudo"

  # Set permissions and file mode to /etc/sudoers.d/domadminsudo and check configuration
  ssh -T -o PasswordAuthentication=no "${sudo_username}"@"${remote_machine}" sh <<EOF
sudo chown root:root /etc/sudoers.d/domadminsudo
sudo chmod 0440 /etc/sudoers.d/domadminsudo
sudo visudo -c
EOF

  # Delete /tmp/domadminsudo
  ssh -T -o PasswordAuthentication=no "${sudo_username}"@"${remote_machine}" sh <<EOF
touch /tmp/domadminsudo
rm -f /tmp/domadminsudo
EOF

fi

################################################################################
# Copy config files and deploy scripts
################################################################################

if [[ "${execution_mode}" == "inject" ]] || [[ "${execution_mode}" == "deploy" ]]; then

  # Prepare setup directory in remote machine
  echo
  echo "${msg_info} Prepare setup directory ${remote_machine}:${setup_dir}"
  echo

  # Prepare files to be injected
  # machine_os - Operating system running in devops machine
  # Ref.:https://en.wikipedia.org/wiki/Uname#Examples
  machine_os=
  uname_out="$(uname -s)"
  case "${uname_out}" in
  Linux*) machine_os="Linux" ;;
  Darwin*) machine_os="Mac" ;;
  CYGWIN*) machine_os="Cygwin" ;;
  MINGW*) machine_os="MinGw" ;;
  *) machine_os="UNKNOWN:${uname_out}" ;;
  esac
  if [[ "${machine_os}" == "Mac" ]]; then
    xattr -cr ./*
  fi

  # Remove setup directory if exist
  remote_command="sudo /bin/bash -c 'if [[ -d ${setup_dir} ]]; then rm -fv -R ${setup_dir}; fi'"
  ssh -tt -o PasswordAuthentication=no "${sudo_username}"@"${remote_machine}" "${remote_command}"

  # Create empty setup directory with permissions
  remote_command="sudo mkdir -pv ${setup_dir} && sudo chown -R ${sudo_username}:${sudo_username} ${setup_dir}"
  ssh -tt -o PasswordAuthentication=no "${sudo_username}"@"${remote_machine}" "${remote_command}"

  # Inject configuration files
  echo
  echo "${msg_info} inject configuration files from $(hostname -f):$(pwd) to ${remote_machine}:${setup_dir} directory "
  echo

  # Copy files with scp
  scp -r -o PasswordAuthentication=no ./* "${sudo_username}"@"${remote_machine}":"${setup_dir}"/

  # Set permissions to sudo_username
  remote_command="sudo chown -R ${sudo_username}:${sudo_username} ${setup_dir}"
  ssh -tt -o PasswordAuthentication=no "${sudo_username}"@"${remote_machine}" "${remote_command}"

  # Delete unwanted files in setup directory after copy
  echo
  echo "${msg_info} Delete unwanted files in setup directory after copy in ${remote_machine}:${setup_dir} directory "
  echo
  remote_command="touch ${setup_dir}/csconnect.sh && rm -vf ${setup_dir}/csconnect.sh && touch ${setup_dir}/csinject.sh && rm -vf ${setup_dir}/csinject.sh"
  ssh -tt -o PasswordAuthentication=no "${sudo_username}"@"${remote_machine}" "${remote_command}"

  # deploy scripts (cs-*.sh)
  echo
  echo "${msg_info} Delete old cs-*.sh scripts in ${remote_machine}:/usr/local/sbin"
  echo
  ssh -T -o PasswordAuthentication=no "${sudo_username}"@"${remote_machine}" sudo sh <<EOF
touch /usr/local/sbin/cs-somefilewithprefixcreatedjustfordelete.sh
rm -vf /usr/local/sbin/cs-*.sh
EOF

  echo
  echo "${msg_info} Copy cs-*.sh scripts into ${remote_machine}:/usr/local/sbin directory"
  echo
  remote_command="sudo cp -v ${setup_dir}/cs-*.sh /usr/local/sbin/ && sudo chmod 755 /usr/local/sbin/cs-*.sh"
  ssh -tt -o PasswordAuthentication=no "${sudo_username}"@"${remote_machine}" "${remote_command}"

fi

################################################################################
# Run cs-deploy from inside the machine
################################################################################

if [[ "${execution_mode}" == "deploy" ]]; then

  # Prepare remote command to be run
  if [[ ${quiet_mode} == false ]]; then
    remote_command="${deploy_script} -m ${deploy_mode}"
  else
    remote_command="${deploy_script} -q -m ${deploy_mode}"
  fi

  # Execute sudo cs-deploy.sh inside the machine
  echo
  echo "${msg_info} Executing ${remote_command} at ${remote_machine}"
  echo
  ssh -tt -o PasswordAuthentication=no "${sudo_username}"@"${remote_machine}" "${remote_command}"
fi

#### END OF EXECUTION (EOE) ####################################################
echo
echo "${msg_info} END OF EXECUTION (EOE)"
echo
exit 0
