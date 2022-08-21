#!/bin/bash

#
#   csbuild.sh
#
#       cSkyLab docker image build script.
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
  cSkyLab docker image build script.

Usage:
  sudo csbuild.sh [-b] [-p] [-h] [-q]

Execution modes:
  -b  [build]           - Build & tag image only.
  -p  [push]            - Build & tag & push image to repository.

Options and arguments:  
  -h  Help
  -q  Quiet (Nonstop) execution.

EOF
)"

################################################################################
# Variable initialization
################################################################################

# Private registry
registry="harbor.cskylab.net/cskylab"
username="admin"
password="NoFear21"


# Repository/Image name
image_name="keycloak-theme-provider"
date_ver="$(date +'%Y.%m.%d')"
# Tag array (String array space separated)
declare -a tag_array=("${date_ver}" stable latest)

# Docker build context
build_context="." # current directory

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
while getopts ":bphq" opt; do
  case $opt in
  # build option
  b)
    # Set execution mode if empty (not previously set)
    if [[ -z "${execution_mode}" ]]; then
      execution_mode="build"
    else
      echo
      echo "${msg_error} Execution mode not valid ${command_line}" >&2
      echo
      exit 1
    fi
    ;;
  # push option
  p)
    # Set execution mode if empty (not previously set)
    if [[ -z "${execution_mode}" ]]; then
      execution_mode="push"
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
"build") ;;
"push") ;;
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
  echo "  cSkyLab docker image build script"
  echo "        Command line: [${command_line}]"
  echo
  echo "      Execution mode: [${execution_mode}]"
  echo
  echo "      Registry: ${registry}"
  echo "      Username: ${username}"
  echo "      Image:    ${image_name}"
  echo "      tags:     ${tag_array[*]}"
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
# build and tag image
################################################################################

if [[ "${execution_mode}" == "build" ]] ||
  [[ "${execution_mode}" == "push" ]]; then

  # Build image
  echo
  echo "${msg_info} Building image"
  echo
  echo "${registry}"/"${image_name}" "${build_context}"
  docker build -t "${registry}"/"${image_name}" "${build_context}"

  # Tag image
  count=${#tag_array[@]}
  if ((count > 0)); then
    # Apply tags
    echo
    echo "${msg_info} Tagging image"
    echo
    for tag in "${tag_array[@]}"; do
      echo "${tag}"
      docker tag "${registry}"/"${image_name}" \
        "${registry}"/"${image_name}":"${tag}"
    done
    echo
    echo "${msg_info} Image built and tagged"
    echo
    docker image list "${registry}"/"${image_name}"
  fi

fi

################################################################################
# Push image to registry
################################################################################

if [[ "${execution_mode}" == "push" ]]; then

  # Login to registry
  echo
  echo "${msg_info} Login to repository"
  echo
  docker login -u="${username}" -p="${password}" "${registry}"

  # Push to registry
  echo
  echo "${msg_info} Pushing image to repository"
  echo
  docker push --all-tags "${registry}"/"${image_name}"

fi

#### END OF EXECUTION (EOE) ####################################################
echo
echo "${msg_info} END OF EXECUTION (EOE)"
echo
exit 0
