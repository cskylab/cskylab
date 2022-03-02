#!/bin/bash

#
#   csdeploy.sh
#
#       MetalLB v0.12.1 configuration.
#
#   Copyright © 2020 cSky.cloud authors
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
  MetalLB v0.12.1 configuration.
  Use this script to deploy and configure metallb-system namespace.

Usage:
  sudo csdeploy.sh [-l] [-m <execution_mode>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List current status.
  -m  <execution_mode>  - Valid modes are:

      [install]         - Install metallb-system namespace and manifests.
      [remove]          - Remove manifests and metallb-system namespace.
      [update]          - Update config-map with address pools and options.

Options and arguments:  
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Install namespace and mainfests:
    ./csdeploy.sh -m install

  # Update config-map with address pools and options in file config.yaml:
    ./csdeploy.sh -m update

  # Remove manifests and metallb-system namespace
    ./csdeploy.sh -m remove

  # Display namespace status:
    ./csdeploy.sh -l

EOF
)"

################################################################################
# Variable initialization
################################################################################

# Kubernetes namespace (name of current directory)
# namespace="${PWD##*/}"
namespace="metallb-system" # must follow this name and be unique in cluster

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
while getopts ":lm:hq" opt; do
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

# Validate execution modes
case "${execution_mode}" in
"install") ;;
"remove") ;;
"update") ;;
"list-status") ;;
*)
  echo
  echo "${msg_error} Execution mode not valid ${command_line}" >&2
  echo
  exit 1
  ;;
esac

# Check namespace exists
if [[ "${execution_mode}" != "install" ]]; then
  kubectl get namespace "${namespace}"
fi

################################################################################
# Execution info and user confirmation (quiet_mode=false)
################################################################################

if [[ ${quiet_mode} == false ]]; then
  echo
  echo "*********************************************************************"
  echo
  echo "  Kubernetes cluster context: $(tput setaf 2)$(kubectl config current-context)$(tput sgr0)"
  echo "                Command line: [${command_line}]"
  echo
  echo "      Execution mode: [${execution_mode}]"
  echo
  echo "           Namespace: ${namespace}"
  echo
  echo "*********************************************************************"
  echo

  read -r -s -p $'Press Enter to continue or Ctrl+C to abort...'
  echo
  if [[ "${execution_mode}" == "remove" ]]; then
    echo
    echo "******** WARNING: Services will be REMOVED FROM CLUSTER."
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
# Install MetalLB
################################################################################

if [[ "${execution_mode}" == "install" ]]; then
  echo
  echo "${msg_info} Install ${namespace}"
  echo

  # Create namespace
  kubectl create namespace "${namespace}"

  # MetalLB installation manifests
  # https://metallb.universe.tf/installation/#installation-by-manifest

  # Local manifest metallb.yaml is copied from
  # https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml
  kubectl apply -f metallb.yaml

  # Create memberlist secret
  # The memberlist secret contains the secretkey to encrypt the communication
  # between speakers for the fast dead node detection
  # kubectl create secret generic -n ${namespace} memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
fi

################################################################################
# Update config-map
################################################################################

if [[ "${execution_mode}" == "update" ]] ||
  [[ "${execution_mode}" == "install" ]]; then

  # Update configmap
  echo
  echo "${msg_info} Update config-map"
  echo
  kubectl apply -f config.yaml
fi

################################################################################
# Remove manifests and namespace
################################################################################

if [[ "${execution_mode}" == "remove" ]]; then

  # Remove namespace
  echo
  echo "${msg_info} Remove ${namespace}"
  echo
  # Remove manifests
  kubectl delete -f metallb.yaml
  # Remove namespace
  kubectl delete namespace "${namespace}"
fi

################################################################################
# Display status information
################################################################################

if [[ "${execution_mode}" == "list-status" ]] ||
  [[ "${execution_mode}" == "install" ]] ||
  [[ "${execution_mode}" == "update" ]]; then

  # Display namespace status
  echo
  echo "${msg_info} ${namespace} status information"
  echo
  kubectl -n "${namespace}" get all
  echo
  echo "${msg_info} Address pools and options configmap"
  echo
  kubectl -n "${namespace}" describe configmaps config
fi

#### END OF EXECUTION (EOE) ####################################################
echo
echo "${msg_info} END OF EXECUTION (EOE)"
echo
exit 0
