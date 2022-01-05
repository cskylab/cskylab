#!/bin/bash

#
#   csdeploy.sh
#
#       ingress-nginx kubernetes configuration.
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
  ingress-nginx kubernetes configuration.

Usage:
  sudo csdeploy.sh [-l] [-m <execution_mode>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List current status.
  -m  <execution_mode>  - Valid modes are:

      [pull-charts]     - Pull charts to './charts/' directory.
      [install]         - Create namespace, PV's and install charts.
      [update]          - Redeploy or upgrade charts.
      [uninstall]       - Uninstall charts, remove PV's and namespace.
      [remove]          - Remove PV's namespace and all its contents.

Options and arguments:  
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Pull charts to './charts/' directory
    ./csdeploy.sh -m pull-charts

  # Create namespace, PV's and install charts
    ./csdeploy.sh -m install

  # Redeploy or upgrade charts
    ./csdeploy.sh -m update

  # Uninstall charts, remove PV's and namespace
    ./csdeploy.sh -m uninstall

  # Remove PV's namespace and all its contents
    ./csdeploy.sh -m remove

  # Display namespace, persistence and charts status:
    ./csdeploy.sh -l

EOF
)"

################################################################################
# Variable initialization
################################################################################

# Kubernetes namespace (name of current directory)
# namespace="${PWD##*/}"
namespace="ingress-nginx"

# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Charts
helm pull ingress-nginx/ingress-nginx --version 4.0.13 --untar

EOF
)"


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

# Helm Chart Array
# Charts must be previously fetched with the appropriate version in ./charts/ directory
declare -a helm_charts=()
find ./charts/ -maxdepth 1 -mindepth 1 -type d >/tmp/chartsdir
while IFS= read -r line; do
  chart="$(basename "${line}")"
  helm_charts+=("${chart}")
done </tmp/chartsdir

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
"pull-charts") ;;
"install") ;;
"update") ;;
"uninstall") ;;
"remove") ;;
"list-status") ;;
*)
  echo
  echo "${msg_error} Execution mode not valid ${command_line}" >&2
  echo
  exit 1
  ;;
esac

# Get namespace or trigger an error if not found
if [[ "${execution_mode}" == "update" ]] ||
  [[ "${execution_mode}" == "uninstall" ]] ||
  [[ "${execution_mode}" == "remove" ]] ||
  [[ "${execution_mode}" == "list-status" ]]; then
  kubectl get namespace "${namespace}"
fi

# Check for charts and Chart.yaml files
if [[ "${execution_mode}" == "install" ]] ||
  [[ "${execution_mode}" == "update" ]] ||
  [[ "${execution_mode}" == "uninstall" ]]; then

  # Check for charts in chart array
  count=${#helm_charts[@]}
  if ((count > 0)); then
    for chart in "${helm_charts[@]}"; do
      # Check for file Chart.yaml inside chart directory
      if ! [[ -f ./charts/"${chart}/Chart.yaml" ]]; then
        echo
        echo "${msg_error} ./charts/${chart}/Chart.yaml file does not exist. Fetch chart with the appropriate version" >&2
        echo
        exit 1
      fi
      # Check for values-chart file
      if ! [[ -f "./values-${chart}.yaml" ]]; then
        echo
        echo "${msg_error} ./values-${chart}.yaml file must exist to deploy the chart." >&2
        echo
        exit 1
      fi
    done
  fi
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
  if [[ "${execution_mode}" == "pull-charts" ]]; then
    echo "${source_charts}"
  else
    echo "           Namespace: ${namespace}"
    # Check for charts
    count=${#helm_charts[@]}
    if ((count > 0)); then
      echo "         Helm charts: ${helm_charts[*]}"
    fi
  fi
  echo
  echo "*********************************************************************"
  echo

  read -r -s -p $'Press Enter to continue or Ctrl+C to abort...'
  echo
  if [[ "${execution_mode}" == "remove" ]] ||
    [[ "${execution_mode}" == "uninstall" ]]; then
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
# Pull helm charts from repositories
################################################################################

if [[ "${execution_mode}" == "pull-charts" ]]; then

  # Clean ./charts directory
  echo
  echo "${msg_info} Clean ./charts directory"
  echo
  rm -rv ./charts
  mkdir -v ./charts
  touch ./charts/.gitkeep
  
  echo
  echo "${msg_info} Pull helm charts"
  echo
  # Pull helm charts to ./charts directory
  echo "${source_charts}" >/tmp/source-charts.sh
  cd ./charts
  # Bypass shellcheck intentionally.
  # shellcheck disable=SC1091
  source /tmp/source-charts.sh

  # Show charts
  echo
  echo "${msg_info} Helm charts pulled into ./charts directory:"
  echo
  find . -maxdepth 1 -mindepth 1 -type d
  echo
fi

################################################################################
# Create namespace, certificate, secrets and PV's
################################################################################

if [[ "${execution_mode}" == "install" ]]; then

  # Task block for installing apps and services
  echo
  echo "${msg_info} Create namespace and secret ${namespace}"
  echo

  # Create namespace
  kubectl create namespace "${namespace}"

fi

################################################################################
# Deploy charts
################################################################################

if [[ "${execution_mode}" == "update" ]] ||
  [[ "${execution_mode}" == "install" ]]; then

  # Check for charts
  count=${#helm_charts[@]}
  if ((count > 0)); then
    # Deploy charts
    echo
    echo "${msg_info} Deploy charts"
    echo
    for chart in "${helm_charts[@]}"; do
      helm upgrade --install --namespace "${namespace}" "${chart}" -f "values-${chart}.yaml" "charts/${chart}"
    done
    echo
    echo "${msg_info} Charts deployed"
    echo
  fi
fi

################################################################################
# Uninstall charts
################################################################################

if [[ "${execution_mode}" == "uninstall" ]]; then

  # Check for charts
  count=${#helm_charts[@]}
  if ((count > 0)); then
    # Deploy charts
    echo
    echo "${msg_info} Uninstall charts"
    echo
    for chart in "${helm_charts[@]}"; do
      helm uninstall --namespace "${namespace}" "${chart}"
    done
    echo
    echo "${msg_info} Charts uninstalled"
    echo
  fi

fi

################################################################################
# Remove namespace and PV's
################################################################################

if [[ "${execution_mode}" == "remove" ]] ||
  [[ "${execution_mode}" == "uninstall" ]]; then

  # Remove namespace
  echo
  echo "${msg_info} Remove ${namespace}"
  echo
  kubectl delete namespace "${namespace}"

  echo
  echo "${msg_info} Namespace ${namespace} removed from cluster"
  echo

fi

################################################################################
# Display status information
################################################################################

if [[ "${execution_mode}" == "list-status" ]] ||
  [[ "${execution_mode}" == "install" ]] ||
  [[ "${execution_mode}" == "update" ]]; then

  # Display namespace status
  echo
  echo "${msg_info} Namespace ${namespace} status information"
  echo
  kubectl -n "${namespace}" get all

  # Chart array history information
  echo
  echo "${msg_info} Chart release history information"
  echo
  # Check for charts
  count=${#helm_charts[@]}
  if ((count > 0)); then
    for charts in "${helm_charts[@]}"; do
      helm --namespace "${namespace}" history "${charts}"
      echo
    done
  fi
fi

#### END OF EXECUTION (EOE) ####################################################
echo
echo "${msg_info} END OF EXECUTION (EOE)"
echo
exit 0
