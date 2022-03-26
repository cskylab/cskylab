#!/bin/bash

#
#   csconnect.sh
#
#       SSH remote connection.
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
  SSH remote connection.
  Use this script to remote login into the machine and establish a ssh session.

Usage:
  csconnect.sh [-u <sudo_username>] [-r <remote_machine>] [-h]

Options and arguments:  
  -u  <sudo_username>   - Remote user name (Default value).
  -r  <remote_machine>  - Machine hostname or IPAddress (Default value).
  -h  Help

Examples:
  # Connect to the machine with default values
    ./csconnect.sh

  # Connect to IPAddress with specific user
    ./csconnect.sh -u sudo_username -r 192.168.2.99

EOF
)"

################################################################################
# Variable initialization
################################################################################

# Remote user name (sudoer)
sudo_username="kos"
# Host FQDN or IP address
remote_machine="k8s-pro-master.cskylab.net"
# ssh connection timeout
ssh_timeout=3


# Color code for messages
# https://robotmoon.com/256-colors/
msg_info="$(tput setaf 2 -T xterm-256color)[$(hostname)] [$(basename "$0")] $(date -R)
Info:$(tput sgr0 -T xterm-256color)" # Green
msg_error="$(tput setaf 1 -T xterm-256color)[$(hostname)] [$(basename "$0")] $(date -R)
Error:$(tput sgr0 -T xterm-256color)" # Red

################################################################################
# Options and arguments
################################################################################

# Command line called
command_line="$(basename "$0") $*"

# Parse command options
while getopts ":u:r:h" opt; do
  case $opt in
  # sudo_username option
  u)
    # Set sudo_username
    sudo_username="$OPTARG"
    ;;
  # Machine hostname
  r)
    # Set remote_machine
    remote_machine="$OPTARG"
    ;;
  # Help option: Display usage_msg
  h)
    echo
    echo "${usage_msg}"
    echo
    exit 0
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
# Execution info
################################################################################

echo
echo "*********************************************************************"
echo
echo "  $(hostname):"
echo
echo "      ${command_line}"
echo
echo "  SSH remote connection"
echo
echo "      User name:  ${sudo_username}"
echo "      Machine:    ${remote_machine}"
echo
echo "*********************************************************************"
echo

#### START OF EXECUTION (SOE) ##################################################
echo
echo "${msg_info} START OF EXECUTION (SOE)"
echo

################################################################################
# Perform ssh connection
################################################################################

ssh -t \
  -o ConnectTimeout=${ssh_timeout} \
  -o PasswordAuthentication=no \
  "${sudo_username}"@"${remote_machine}"

#### END OF EXECUTION (EOE) ####################################################
echo
echo "${msg_info} END OF EXECUTION (EOE)"
echo
exit 0
