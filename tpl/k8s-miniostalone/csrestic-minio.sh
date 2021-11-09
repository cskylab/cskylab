#!/bin/bash

#
#   csrestic-minio.sh
#
#       k8s restic backup jobs for MinIO buckets.
#
#   Copyright © 2021 cSky.cloud authors
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
  k8s restic backup jobs for MinIO buckets.

Usage:
  csrestic-minio.sh [-l] [-m <execution_mode>] [-f <source-env.sh] [-h] [-q]

Execution modes:
  -l  [list-status]         - List current namespace status.
  
  -m  <execution_mode>      - Valid modes are:
      [apply]               - Apply and reconfigure all restic cronjobs from 'source-*.sh' environment files.
      [remove]              - Delete all restic cronjobs.
  
  -f  <source-env.sh>       - Launch a restic forge environment 
                              for interactive restore operations.

Options and arguments:
  -h  Help
  -q  Quiet (Nonstop) execution

Examples:
  # Apply and reconfigure all restic cronjobs from 'source-*.sh' environment files.
    csrestic-minio.sh -m apply

  # Delete all restic cronjobs.
    csrestic-minio.sh -m remove

  # Launch a restic forge environment for bucket "beatles"
    csrestic-minio.sh -f source-beatles.sh

  # Display job status
    csrestic-minio.sh -l

EOF
)"

################################################################################
# Variable initialization
################################################################################

# Kubernetes namespace (name of current directory)
# namespace="${PWD##*/}"
namespace="{{ .namespace.name }}"

# Restic-MinIO image
restic_minio_image="harbor.cskylab.com/cskylab/csrestic:stable"

# Time Zone for restic forge (cronjobs run in UTC)
time_zone="Europe/Madrid"

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
while getopts ":lm:f:hq" opt; do
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
  # Get restic forge environment
  f)
    # Set execution mode if empty (not previously set)
    if [[ -z "${execution_mode}" ]]; then
      execution_mode="forge"
      source_env_file="$OPTARG"
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

# Get namespace or trigger an error if not found
echo
echo "${msg_info} Namespace status:"
echo
kubectl get namespace "${namespace}"

# Validate execution modes
case "${execution_mode}" in
"apply") ;;
"remove") ;;
"forge") ;;
"list-status") ;;
*)
  echo
  echo "${msg_error} Execution mode not valid ${command_line}" >&2
  echo
  exit 1
  ;;
esac

# Check for source forge file
if [[ "${execution_mode}" == "forge" ]]; then
  if ! [[ -f ./"${source_env_file}" ]]; then
    echo
    echo "${msg_error} ${source_env_file} file does not exist." >&2
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
  echo "  Kubernetes cluster context: $(tput setaf 2)$(kubectl config current-context)$(tput sgr0)"
  echo "                Command line: [${command_line}]"
  echo
  echo "      Execution mode: [${execution_mode}]"
  echo
  if [[ "${execution_mode}" == "forge" ]]; then
    echo "   Source forge file: ${source_env_file}"
  fi
  if [[ "${execution_mode}" == "apply" ]]; then
    shopt -s nullglob
    declare -a source_files=(./source-*.sh)
    shopt -u nullglob
    count=${#source_files[@]}
    if ((count > 0)); then
      echo "        Source files:"
      echo
      for file in "${source_files[@]}"; do
        echo "                      ${file}"
      done
    fi
  fi
  if [[ "${execution_mode}" == "remove" ]]; then
    echo " Cronjobs:"
    echo
    kubectl -n "${namespace}" get cronjobs -lapp=resticjob
  fi
  echo
  echo "*********************************************************************"
  echo

  read -r -s -p $'Press Enter to continue or Ctrl+C to abort...'
  echo
  if [[ "${execution_mode}" == "remove" ]]; then
    echo
    echo "******** WARNING: Jobs will be REMOVED FROM CLUSTER."
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
# Launch restic forge environment
################################################################################

if [[ "${execution_mode}" == "forge" ]]; then

  echo
  echo "${msg_info} Launching interactive restic forge environment"
  echo

  # Initialize empty environment variables
  # restic-environment
  export AWS_ACCESS_KEY_ID=
  export AWS_SECRET_ACCESS_KEY=
  export RESTIC_REPOSITORY=
  export RESTIC_PASSWORD=
  export RESTIC_BACKUP_JOB_SCHEDULE=
  export RESTIC_FORGET_POLICY=
  export RESTIC_REPO_MAINTENANCE_JOB_SCHEDULE=
  export RESTIC_REPO_MAINTENANCE_CHECK_DATA_SUBSET=
  # minio bucket environment
  export MINIO_ACCESS_KEY=
  export MINIO_SECRET_KEY=
  export MINIO_URL=
  export MINIO_BUCKET=
  export MC_HOST_minio=

  # Define environment variables from source file
  # shellcheck disable=SC1090
  source "${source_env_file}"

# Generate unique restic forge pod name
restic_forge_pod_name="restic-forge-${MINIO_BUCKET}-$(head -c 512 /dev/urandom | LC_ALL=C tr -cd 'a-z0-9' | head -c 6)"

  # Deploy pod using environment variables
  cat <<EOF | kubectl apply -f -
  apiVersion: v1
  kind: Pod
  metadata:
    name: "${restic_forge_pod_name}"
    namespace: "${namespace}"
    labels:
      app: resticjob
  spec:
    containers:
    - name: csrestic
      image: "${restic_minio_image}"
      imagePullPolicy: IfNotPresent
      tty: true
      securityContext:
        privileged: true
      env:
      - name: AWS_ACCESS_KEY_ID
        value: "${AWS_ACCESS_KEY_ID}"
      - name: AWS_SECRET_ACCESS_KEY
        value: "${AWS_SECRET_ACCESS_KEY}"
      - name: RESTIC_REPOSITORY
        value: "${RESTIC_REPOSITORY}"
      - name: RESTIC_PASSWORD
        value: "${RESTIC_PASSWORD}"
      - name: MINIO_ACCESS_KEY
        value: "${MINIO_ACCESS_KEY}"
      - name: MINIO_SECRET_KEY
        value: "${MINIO_SECRET_KEY}"
      - name: MINIO_URL
        value: "${MINIO_URL}"
      - name: MINIO_BUCKET
        value: "${MINIO_BUCKET}"
      - name: MC_HOST_minio
        value: "${MC_HOST_minio}"
      command: ["/bin/bash", "-c"]
      args:
      - |
        ln -snf /usr/share/zoneinfo/${time_zone} /etc/localtime && echo ${time_zone} > /etc/timezone;
        mc --autocompletion;
        mkdir /tmp/restic && restic mount --no-lock /tmp/restic;
    restartPolicy: Never

EOF

  # Wait for restic-forge pod to get ready
  while [[ $(kubectl -n "${namespace}" get pods "${restic_forge_pod_name}" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
    echo "waiting for pod" && sleep 1
  done
  echo
  echo "*********************************************************************"
  echo
  echo "  Entering in console mode with ${restic_forge_pod_name}"
  echo
  echo "    - Restic repository is mounted in /tmp/restic."
  echo "    - To read/write bucket files use MinIO Client commands like:"
  echo "        <mc ls minio>         List bucket and objects"
  echo "        <mc tree minio>       List bucket and objects in tree format"
  echo "    - Use <mc --help> for help with MinIO Client"
  echo "    - Execute <exit> when finished."
  echo
  echo "*********************************************************************"
  echo
  # Connect to pod
  set +e # Disable exit on error
  kubectl -n "${namespace}" exec -it "${restic_forge_pod_name}" -- /bin/bash
  set -e # Enable exit on error

  echo
  echo "${msg_info} Removing restic forge environment"
  echo
  # Delete pod
  kubectl -n "${namespace}" delete pod "${restic_forge_pod_name}"

fi

################################################################################
# Deploy jobs
################################################################################

if [[ "${execution_mode}" == "apply" ]]; then

  # Check for source environment files in the form source-*.sh
  shopt -s nullglob
  declare -a source_files=(./source-*.sh)
  shopt -u nullglob
  count=${#source_files[@]}
  if ((count > 0)); then
    echo
    echo "${msg_info} Apply job manifests from source files"
    echo
    for file in "${source_files[@]}"; do

      # Initialize empty environment variables
      # restic-environment
      export AWS_ACCESS_KEY_ID=
      export AWS_SECRET_ACCESS_KEY=
      export RESTIC_REPOSITORY=
      export RESTIC_PASSWORD=
      export RESTIC_BACKUP_JOB_SCHEDULE=
      export RESTIC_FORGET_POLICY=
      export RESTIC_REPO_MAINTENANCE_JOB_SCHEDULE=
      export RESTIC_REPO_MAINTENANCE_CHECK_DATA_SUBSET=
      # minio bucket environment
      export MINIO_ACCESS_KEY=
      export MINIO_SECRET_KEY=
      export MINIO_URL=
      export MINIO_BUCKET=
      export MC_HOST_minio=

      # Define environment variables from source file
      # shellcheck disable=SC1090
      source "${file}"

      # Check backup schedule is not empty
      if [[ -n "${RESTIC_BACKUP_JOB_SCHEDULE}" ]]; then
        # Apply manifest for restic-backup cronjob
        cat <<EOF | kubectl apply -f -
  apiVersion: batch/v1
  kind: CronJob
  metadata:
    name: "restic-backup-${MINIO_BUCKET}"
    namespace: "${namespace}"
    labels:
      app: resticjob
  spec:
    schedule: "${RESTIC_BACKUP_JOB_SCHEDULE}"
    concurrencyPolicy: Forbid
    jobTemplate:
      spec:
        template:
          spec:
            containers:
            - name: csrestic
              image: "${restic_minio_image}"
              imagePullPolicy: IfNotPresent
              securityContext:
                privileged: true
              env:
              - name: AWS_ACCESS_KEY_ID
                value: "${AWS_ACCESS_KEY_ID}"
              - name: AWS_SECRET_ACCESS_KEY
                value: "${AWS_SECRET_ACCESS_KEY}"
              - name: RESTIC_REPOSITORY
                value: "${RESTIC_REPOSITORY}"
              - name: RESTIC_PASSWORD
                value: "${RESTIC_PASSWORD}"
              - name: MINIO_ACCESS_KEY
                value: "${MINIO_ACCESS_KEY}"
              - name: MINIO_SECRET_KEY
                value: "${MINIO_SECRET_KEY}"
              - name: MINIO_URL
                value: "${MINIO_URL}"
              - name: MINIO_BUCKET
                value: "${MINIO_BUCKET}"
              - name: MC_HOST_minio
                value: "${MC_HOST_minio}"
              command: ["/bin/bash", "-c"]
              args:
              - |
                echo ${MINIO_ACCESS_KEY}:${MINIO_SECRET_KEY} > .passwd-s3fs;
                chmod 600 .passwd-s3fs;
                s3fs ${MINIO_BUCKET} /mnt -o passwd_file=.passwd-s3fs -o url="https://${MINIO_URL}" -o use_path_request_style -o dbglevel=info;
                cd /mnt;
                restic backup . --no-cache --tag "${MINIO_BUCKET}" --host "resticjob";
                restic forget --tag "${MINIO_BUCKET}" ${RESTIC_FORGET_POLICY};
            restartPolicy: Never

EOF
      fi

      # Check repo maintenance schedule is not empty
      if [[ -n "${RESTIC_REPO_MAINTENANCE_JOB_SCHEDULE}" ]]; then
        # Apply manifest for restic-repo-maintenance cronjob
        cat <<EOF | kubectl apply -f -
  apiVersion: batch/v1
  kind: CronJob
  metadata:
    name: "restic-repo-maintenance-${MINIO_BUCKET}"
    namespace: "${namespace}"
    labels:
      app: resticjob
  spec:
    schedule: "${RESTIC_REPO_MAINTENANCE_JOB_SCHEDULE}"
    concurrencyPolicy: Forbid
    jobTemplate:
      spec:
        template:
          spec:
            containers:
            - name: csrestic
              image: "${restic_minio_image}"
              imagePullPolicy: IfNotPresent
              env:
              - name: AWS_ACCESS_KEY_ID
                value: "${AWS_ACCESS_KEY_ID}"
              - name: AWS_SECRET_ACCESS_KEY
                value: "${AWS_SECRET_ACCESS_KEY}"
              - name: RESTIC_REPOSITORY
                value: "${RESTIC_REPOSITORY}"
              - name: RESTIC_PASSWORD
                value: "${RESTIC_PASSWORD}"
              command: ["/bin/bash", "-c"]
              args:
              - |
                restic prune;
                restic check --read-data-subset=${RESTIC_REPO_MAINTENANCE_CHECK_DATA_SUBSET};
            restartPolicy: Never

EOF
      fi

    done

    echo
    echo "${msg_info} Job manifests applied"
    echo
  fi

fi

################################################################################
# Remove jobs
################################################################################

if [[ "${execution_mode}" == "remove" ]]; then

  kubectl -n "${namespace}" delete cronjobs -lapp=resticjob

fi

################################################################################
# Display status information
################################################################################

if [[ "${execution_mode}" == "list-status" ]] ||
  [[ "${execution_mode}" == "apply" ]] ||
  [[ "${execution_mode}" == "remove" ]]; then

  # Display cronjob status
  echo
  echo "${msg_info} Namespace status information"
  echo
  kubectl -n "${namespace}" get all

fi

#### END OF EXECUTION (EOE) ####################################################
echo
echo "${msg_info} END OF EXECUTION (EOE)"
echo
exit 0
