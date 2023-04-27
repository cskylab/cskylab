#!/bin/bash

#
#   cs-k8init.sh
#
#       Kubernetes cluster initialization.
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
  Kubernetes cluster initialization.
  Use this script to initialize a kubernetes cluster with kubeadm.

Usage:
  sudo cs-k8init.sh [-l] [-m <execution_mode>] [-h] [-q]

Execution modes:
  -l  [list-status]       - Display current cluster status.
  -m  <execution_mode>    - Valid modes are:

      [init-master]       - Initialize cluster master node.
      [init-kubestalone]  - Initialize kubestalone single node cluster.

Options and arguments:  
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Initialize a new master node and kubernetes cluster":
    sudo cs-k8init.sh -m init-master

  # Initialize a new kubestalone single node kubernetes cluster":
    sudo cs-k8init.sh -m init-kubestalone

  # Display current cluster status:
    sudo cs-k8init.sh -l

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

# Check if running as root (sudo)
if ! [[ "$(id -u)" == 0 ]]; then
  echo
  echo "${msg_error} The script $0 need to be run with sudo option" >&2
  echo
  exit 1
fi

# Validate execution modes
case "${execution_mode}" in
"init-master") ;;
"init-kubestalone") ;;
"list-status") ;;
*)
  echo
  echo "${msg_error} Execution mode not valid ${command_line}" >&2
  echo
  exit 1
  ;;
esac

# Validate previous kubernetes cluster initialization
if [[ "${execution_mode}" == "init-master" ]] ||
  [[ "${execution_mode}" == "init-kubestalone" ]]; then

  if [[ -f /etc/kubernetes/admin.conf ]]; then
    echo
    echo "${msg_error} Found previous kubernetes cluster file /etc/kubernetes/admin.conf" >&2
    echo
    exit 1
  fi
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
  echo "      Execution mode:     ${execution_mode}"
  echo
  echo "*********************************************************************"
  echo

  read -r -s -p $'Press Enter to continue or Ctrl+C to abort...'
  echo
  if [[ "${execution_mode}" = "init-master" ]] ||
    [[ "${execution_mode}" = "init-kubestalone" ]]; then
    echo
    echo "******** WARNING: A new Kubernetes Cluster will be initialized in this machine."
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
# Initialize kubernetes cluster
################################################################################

if [[ "${execution_mode}" == "init-master" ]] ||
  [[ "${execution_mode}" == "init-kubestalone" ]]; then

  # Deploy internal CA to be used in kubernetes
  if [[ -f "${setup_dir}"/ca.crt ]] && [[ -f "${setup_dir}"/ca.key ]]; then

    # Check if kubernetes ca already exists
    if ! [[ -f /etc/kubernetes/pki/ca.crt ]] && ! [[ -f /etc/kubernetes/pki/ca.key ]]; then
      echo
      echo "${msg_info} Deploy internal CA to be used in kubernetes"
      echo

      # Create kubernetes pki directory if not exists
      if ! [[ -d /etc/kubernetes/pki/ ]]; then
        mkdir -p /etc/kubernetes/pki/
      fi

      # Copy CA certificate to /etc/kubernetes
      cp -v "${setup_dir}"/ca.crt /etc/kubernetes/pki/
      chmod 644 /etc/kubernetes/pki/ca.crt
      chown root:root /etc/kubernetes/pki/ca.crt

      # Copy CA key to /etc/kubernetes
      cp -v "${setup_dir}"/ca.key /etc/kubernetes/pki/
      chmod 600 /etc/kubernetes/pki/ca.key
      chown root:root /etc/kubernetes/pki/ca.key
    fi
  fi

  # Download kube-system images
  echo
  echo "${msg_info} Download kube-system images"
  echo
  kubeadm config images pull

  # Initialize cluster with kubeadm
  echo
  echo "${msg_info} Initializing kubernetes cluster with Kubeadm init"
  echo
  kubeadm init --config "${setup_dir}/kubeadm-config.yaml"

  # Copy .kube/config key store for administrative user
  echo
  echo "${msg_info} Copy .kube/config for root and administrative user"
  echo
  # Copy for root
  mkdir -pv "$HOME"/.kube
  cp -iv /etc/kubernetes/admin.conf "$HOME"/.kube/config
  # Copy for administrative user
  mkdir -pv /home/"$SUDO_USER"/.kube
  cp -iv /etc/kubernetes/admin.conf /home/"$SUDO_USER"/.kube/config
  chown "${sudo_username}":"${sudo_username}" /home/"$SUDO_USER"/.kube/config

  # Initialize pod weave network
  # https://www.weave.works/docs/net/latest/kubernetes/kube-addon/#configuration-options
  echo
  echo "${msg_info} Initialize weave Pod Network"
  echo
  # kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.NO_MASQ_LOCAL=1"
  kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
fi

################################################################################
# Initialize kubestalone mode
################################################################################

if [[ "${execution_mode}" == "init-kubestalone" ]]; then

  # Set cluster to run pods at master node
  echo
  echo "${msg_info} Set KubeStalone mode (run pods at master node)."
  echo
  # kubectl taint nodes --all node-role.kubernetes.io/master-
  kubectl taint nodes --all node-role.kubernetes.io/control-plane-
fi

################################################################################
# Display cluster status information
################################################################################

if [[ "${execution_mode}" == "list-status" ]] ||
  [[ "${execution_mode}" == "init-master" ]] ||
  [[ "${execution_mode}" == "init-kubestalone" ]]; then

  # Display nodes
  echo
  echo "${msg_info} Kubernetes cluster status:"
  echo
  kubectl get nodes
  echo
  # Display pods
  kubectl get pod --all-namespaces
  echo
  echo "${msg_info} To copy config key store for cluster administration,"
  echo "execute from config directory:"
  echo
  echo "    < scp ${sudo_username}@$(hostname -f):.kube/config ./ >"
  echo
fi

#### END OF EXECUTION (EOE) ####################################################
echo
echo "${msg_info} END OF EXECUTION (EOE)"
echo
exit 0
