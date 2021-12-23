#!/bin/bash

#
#   cs-helloworld.sh
#
#       Sequential block script model.
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
  Sequential block script model.
  Use this script as a model or skeleton to write other configuration scripts.

Usage:
  sudo cs-helloworld.sh [-l] [-m <execution_mode>] [-n <name>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List current status.
  -m  <execution_mode>  - Valid modes are:

      [install]         - Install.
      [remove]          - Remove.
      [update]          - Update and reconfigure.

Options and arguments:  
  -n <name>             - Name of the person to report status.
                          (Optional in list-status. Default value) 
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Mode "install":
    sudo cs-helloworld.sh -m install

  # Mode "remove":
    sudo cs-helloworld.sh -m remove

  # Mode "list-status":
    sudo cs-helloworld.sh -l

  # Mode "list-status" with special name to report:
    sudo cs-helloworld.sh -l -n Bond

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

# Name of the person to report status
name="Mr Stark"

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
# Quiet mode execution (false by default)
quiet_mode=false

# Display usage if no arguments supplied
if (($# == 0)); then
  echo
  echo "${usage_msg}"
  echo
  exit 0
fi

# Parse command options
while getopts ":lm:n:hq" opt; do
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
  # Name option
  n)
    name="$OPTARG"
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
    echo "${msg_error} Bad parameters $*" >&2
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

# Validate person name not empty
if [[ -z "${name}" ]]; then
  echo
  echo "${msg_error} Name must not be empty" >&2
  echo
  exit 1
fi

# Validate execution modes
case "${execution_mode}" in
"install")
  # TODO: Validations to be made in execution mode "install"
  ;;
"remove")
  # TODO: Validations to be made in execution mode "remove"
  ;;
"update")
  # TODO: Validations to be made in execution mode "update"
  ;;
"list-status")
  # TODO: Validations to be made in execution mode "list-status"
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
  echo "  Sequential block script model."
  echo
  echo "      Execution mode:     ${execution_mode}"
  echo "      Person to report:   ${name}"
  echo
  echo "*********************************************************************"
  echo

  read -r -s -p $'Press Enter to continue or Ctrl+C to abort...'
  echo
  if [[ "${execution_mode}" = "remove" ]]; then
    echo
    echo "******** WARNING: Imaginary apps services and data will be PERMANENTLY DELETED."
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
# Install apps and services
################################################################################

if [[ "${execution_mode}" == "install" ]]; then

  # Task block for installing apps and services
  echo
  echo "${msg_info} Install apps and services"
  echo

  # TODO: Real tasks"
  echo "Task 1"
  echo "Task 2"
  echo "......"
  echo "Task n"

  echo
  echo "${msg_info} Apps and services have been installed"
  echo
fi

################################################################################
# Remove apps and services
################################################################################

if [[ "${execution_mode}" == "remove" ]]; then

  # Task block to remove apps and services
  echo
  echo "${msg_info} Remove apps and services"
  echo

  # TODO: Real tasks"
  echo "Task 1"
  echo "Task 2"
  echo "......"
  echo "Task n"

  echo
  echo "${msg_info} Apps and services have been removed"
  echo
fi

################################################################################
# Update and reconfigure apps and services
################################################################################

if [[ "${execution_mode}" == "update" ]] ||
  [[ "${execution_mode}" == "install" ]]; then

  # Task block to update apps and services
  echo
  echo "${msg_info} Update apps and services"
  echo

  # TODO: Real tasks"
  echo "Task 1"
  echo "Task 2"
  echo "......"
  echo "Task n"

  echo
  echo "${msg_info} Apps and services have been updated"
  echo
fi

################################################################################
# Display status information
################################################################################

if [[ "${execution_mode}" == "list-status" ]] ||
  [[ "${execution_mode}" == "install" ]] ||
  [[ "${execution_mode}" == "update" ]] ||
  [[ "${execution_mode}" == "remove" ]]; then

  # Display variables
  echo
  echo "${msg_info} Display status information"
  echo
  echo "  Hostname:           $(hostname)"
  echo "  Command line:       ${command_line}"
  echo "  Execution mode:     ${execution_mode}"
  echo "  Person to report:   ${name}"

  # Display report message
  if [[ "${name}" == "Bond" ]] ||
    [[ "${name}" == "bond" ]] ||
    [[ "${name}" == "james bond" ]] ||
    [[ "${name}" == "James Bond" ]]; then
    # Special 007 report message
    echo
    echo "${msg_info} Hello 007! This is $(hostname) at your service."
    echo
    # 007 logo
    echo
    base64 -d <<<"H4sIAJM2MVYAA1NQgAEDIIhHBsgCBmgAU8TAQJsL2SgU41AFiDALYRhUF8I0NAEUCbBZUB7MBGRrUXX
g8DC6CagORwkYtDCDcw3IMwDdOBL1IyRRwpBI7cihTlSYkRRNUHcRnUZgXIQGIlOoOQC/4ufk0gIAAA==" | gunzip
    echo
    echo
  else
    # Regular report message
    echo
    echo "${msg_info} Hello ${name}! This is $(hostname) and I´m glad to see you."
    echo
  fi
fi

#### END OF EXECUTION (EOE) ####################################################
echo
echo "${msg_info} END OF EXECUTION (EOE)"
echo
exit 0
