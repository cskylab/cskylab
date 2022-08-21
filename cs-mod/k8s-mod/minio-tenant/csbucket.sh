#!/bin/bash

#
#   csbucket.sh
#
#     Minio Bucket & User & Policy maintanance.
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
  Minio Bucket & User & Policy maintenance.
  Use this script to create or delete together a bucket
  with readwrite, readonly and writeonly users and access policies.
  
Usage:
  sudo csdeploy.sh [-l] [-c <bucket_name>] [-d <bucket_name>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List Buckets & Users & Policies.
  -c  <bucket_name>     - Create Bucket & Users & Policies
  -d  <bucket_name>     - Remove Bucket & Users & Policies

Options and arguments:  
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Create Bucket & Users & Policies
    ./csbucket.sh -c mybucket

  # Delete Bucket & Users & Policies
    ./csbucket.sh -d mybucket

EOF
)"

################################################################################
# Variable initialization
################################################################################

## MinIO Root Credentials
minio_host="minio-tenant.mod.cskylab.net"
minio_accesskey="admin"
minio_secretkey="NoFear21"

# Color code for messages
# https://robotmoon.com/256-colors/
msg_info="$(tput setaf 2)[$(hostname)] [$(basename "$0")] $(date -R)
Info:$(tput sgr0)" # Green
msg_error="$(tput setaf 1)[$(hostname)] [$(basename "$0")] $(date -R)
Error:$(tput sgr0)" # Red

################################################################################
# Options and arguments
################################################################################

# MinIO context
export MC_HOST_minio="https://${minio_accesskey}:${minio_secretkey}@${minio_host}"

# Bucket Name (Must be initialized empty)
bucket_name=

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
while getopts ":lc:d:hq" opt; do
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
  # Create option
  c)
    # Set execution mode if empty (not previously set)
    if [[ -z "${execution_mode}" ]]; then
      execution_mode="create-bucket"
      bucket_name="$OPTARG"
    else
      echo
      echo "${msg_error} Execution mode not valid ${command_line}" >&2
      echo
      exit 1
    fi
    ;;
  # Delete option
  d)
    # Set execution mode if empty (not previously set)
    if [[ -z "${execution_mode}" ]]; then
      execution_mode="delete-bucket"
      bucket_name="$OPTARG"
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

# Readwrite user key secret and policy
# Ref.: https://sourcegraph.com/github.com/gautamrege/minio-go/-/blob/bucket-policy.go
bucket_rw_user="${bucket_name}_rw"
bucket_rw_secret="$(head -c 512 /dev/urandom | LC_ALL=C tr -cd 'a-zA-Z0-9' | head -c 32)"
bucket_rw_policy="${bucket_name}_readwrite"
bucket_rw_policy_content="$(
  cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
		            "s3:ListBucket",
		            "s3:ListBucketMultipartUploads",
                "s3:AbortMultipartUpload",
		            "s3:DeleteObject",
		            "s3:GetObject",
		            "s3:ListMultipartUploadParts",
		            "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::${bucket_name}/*"
            ]
        }
    ]
}
EOF
)"

# Readonly user key secret and policy
# Ref.: https://sourcegraph.com/github.com/gautamrege/minio-go/-/blob/bucket-policy.go
bucket_ro_user="${bucket_name}_ro"
bucket_ro_secret="$(head -c 512 /dev/urandom | LC_ALL=C tr -cd 'a-zA-Z0-9' | head -c 32)"
bucket_ro_policy="${bucket_name}_readonly"
bucket_ro_policy_content="$(
  cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetBucketLocation",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${bucket_name}/*"
            ]
        }
    ]
}
EOF
)"

# Writeonly user key secret and policy
# Ref.: https://sourcegraph.com/github.com/gautamrege/minio-go/-/blob/bucket-policy.go
bucket_wo_user="${bucket_name}_wo"
bucket_wo_secret="$(head -c 512 /dev/urandom | LC_ALL=C tr -cd 'a-zA-Z0-9' | head -c 32)"
bucket_wo_policy="${bucket_name}_writeonly"
bucket_wo_policy_content="$(
  cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetBucketLocation",
		            "s3:ListBucketMultipartUploads",
                "s3:AbortMultipartUpload",
		            "s3:DeleteObject",
		            "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${bucket_name}/*"
            ]
        }
    ]
}
EOF
)"

################################################################################
# Validations before execution
################################################################################

# Validate execution modes
case "${execution_mode}" in
"create-bucket")
  # Validate bucket doesn't exist in config records
  if [[ -f "./buckets/${bucket_name}.config" ]]; then
    echo
    echo "${msg_error} Bucket configuration file ./buckets/${bucket_name}.config already exists" >&2
    echo
    exit 1
  fi
  ;;
"delete-bucket")
  # Validate bucket exist in config records
  if ! [[ -f "./buckets/${bucket_name}.config" ]]; then
    echo
    echo "${msg_error} Bucket configuration file ./buckets/${bucket_name}.config not found" >&2
    echo
    exit 1
  fi
  ;;
"list-status") ;;
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
  echo "  Minio Bucket & User & Policy maintenance."
  echo
  echo "        Execution mode: [${execution_mode}]"
  echo
  echo "            MinIO Host: ${minio_host}"
  echo "           Bucket name: ${bucket_name}"
  echo
  echo "             ReadWrite:"
  echo "             AccessKey: ${bucket_rw_user}"
  if [[ "${execution_mode}" == "create-bucket" ]]; then

    echo "             SecretKey: ${bucket_rw_secret}"
  fi
  echo "                Policy: ${bucket_rw_policy}"
  echo
  echo "              ReadOnly:"
  echo "             AccessKey: ${bucket_ro_user}"
  if [[ "${execution_mode}" == "create-bucket" ]]; then

    echo "             SecretKey: ${bucket_ro_secret}"
  fi
  echo "                Policy: ${bucket_ro_policy}"
  echo
  echo "             WriteOnly:"
  echo "             AccessKey: ${bucket_wo_user}"
  if [[ "${execution_mode}" == "create-bucket" ]]; then

    echo "             SecretKey: ${bucket_wo_secret}"
  fi
  echo "                Policy: ${bucket_wo_policy}"
  echo
  echo "*********************************************************************"
  echo

  read -r -s -p $'Press Enter to continue or Ctrl+C to abort...'
  echo
  if [[ "${execution_mode}" == "delete-bucket" ]]; then
    echo
    echo "******** WARNING:"
    echo
    echo "         This action will DELETE MinIO bucket ${bucket_name}".
    echo
    echo "         ALL Data in bucket WILL BE ERASED."
    echo
    read -r -s -p $'Press Enter to continue or Ctrl+C to abort...'
    echo
    echo
    echo "******** LAST WARNING:"
    echo
    echo "         This action will DELETE MinIO bucket ${bucket_name}".
    echo
    echo "         ALL Data in bucket WILL BE ERASED."
    echo
    read -r -s -p $'Press Enter to continue or Ctrl+C to abort...'
  fi
fi

#### START OF EXECUTION (SOE) ##################################################
echo
echo "${msg_info} START OF EXECUTION (SOE)"
echo

################################################################################
# Create Bucket & User & Policy
################################################################################

if [[ "${execution_mode}" == "create-bucket" ]]; then

  # Create bucket configuration file
  echo
  echo "${msg_info} Create bucket configuration file ./buckets/${bucket_name}.config"
  echo
  touch ./buckets/"${bucket_name}".config
  {
    echo "minio_host=${minio_host}"
    echo "bucket_name=${bucket_name}"
    echo "---"
    echo "bucket_rw_user=${bucket_rw_user}"
    echo "bucket_rw_secret=${bucket_rw_secret}"
    echo "bucket_rw_policy=${bucket_rw_policy}"
    echo "bucket_rw_policy_content=${bucket_rw_policy_content}"
    echo "---"
    echo "bucket_ro_user=${bucket_ro_user}"
    echo "bucket_ro_secret=${bucket_ro_secret}"
    echo "bucket_ro_policy=${bucket_ro_policy}"
    echo "bucket_ro_policy_content=${bucket_ro_policy_content}"
    echo "---"
    echo "bucket_wo_user=${bucket_wo_user}"
    echo "bucket_wo_secret=${bucket_wo_secret}"
    echo "bucket_wo_policy=${bucket_wo_policy}"
    echo "bucket_wo_policy_content=${bucket_wo_policy_content}"

  } >>./buckets/"${bucket_name}".config

  # Create bucket environment source file
  echo
  echo "${msg_info} Create bucket environment source file ./buckets/source-${bucket_name}.sh"
  echo
  touch ./buckets/source-"${bucket_name}".sh

  cat >>./buckets/source-"${bucket_name}".sh <<EOF
#
#   Source environment file for MinIO bucket "${bucket_name}"
#

# This script is designed to be sourced
# No shebang intentionally
# shellcheck disable=SC2148

## minio bucket environment
export MINIO_ACCESS_KEY="${bucket_rw_user}"
export MINIO_SECRET_KEY="${bucket_rw_secret}"
export MINIO_URL="${minio_host}"
export MINIO_BUCKET="${bucket_name}"
export MC_HOST_minio="https://${bucket_rw_user}:${bucket_rw_secret}@${minio_host}"

## restic-environment
export AWS_ACCESS_KEY_ID="restic-test_rw"
export AWS_SECRET_ACCESS_KEY="iZ6Qpx1WlmXXoXKxBmiCMKWCsYOrgZKr"
export RESTIC_REPOSITORY="s3:https://minio-standalone.cskylab.com/restic-test/"
export RESTIC_PASSWORD="sGKvPNSRzQ1YlAxv"

## Restic backup job schedule (UTC)
## At every 15th minute.
export RESTIC_BACKUP_JOB_SCHEDULE="*/15 * * * *"
export RESTIC_FORGET_POLICY="--keep-last 6 --keep-hourly 12 --keep-daily 31 --keep-weekly 5 --keep-monthly 13 --keep-yearly 10"

## Restic repo maintenance job schedule (UTC)
## At 02:00.
export RESTIC_REPO_MAINTENANCE_JOB_SCHEDULE="0 2 * * *"
# Percentage of pack files to check in repo maintenance
export RESTIC_REPO_MAINTENANCE_CHECK_DATA_SUBSET="10%"

EOF

  # Create bucket
  echo
  echo "${msg_info} Create bucket minio/${bucket_name}"
  echo
  mc mb minio/"${bucket_name}"

  # ReadWrite
  echo
  echo "${msg_info} Create ReadWrite user ${bucket_rw_user} access secret and policy"
  echo
  # user
  mc admin user add minio/ "${bucket_rw_user}" "${bucket_rw_secret}"
  # policy
  echo "${bucket_rw_policy_content}" >"/tmp/${bucket_rw_policy}.json"
  mc admin policy add minio/ "${bucket_rw_policy}" "/tmp/${bucket_rw_policy}.json"
  # Set policy to user
  mc admin policy set minio/ "${bucket_rw_policy}" user="${bucket_rw_user}"

  # ReadOnly
  echo
  echo "${msg_info} Create ReadOnly user ${bucket_ro_user} access secret and policy"
  echo
  # user
  mc admin user add minio/ "${bucket_ro_user}" "${bucket_ro_secret}"
  # policy
  echo "${bucket_ro_policy_content}" >"/tmp/${bucket_ro_policy}.json"
  mc admin policy add minio/ "${bucket_ro_policy}" "/tmp/${bucket_ro_policy}.json"
  # Set policy to user
  mc admin policy set minio/ "${bucket_ro_policy}" user="${bucket_ro_user}"

  # WriteOnly
  echo
  echo "${msg_info} Create WriteOnly user ${bucket_wo_user} access secret and policy"
  echo
  # user
  mc admin user add minio/ "${bucket_wo_user}" "${bucket_wo_secret}"
  # policy
  echo "${bucket_wo_policy_content}" >"/tmp/${bucket_wo_policy}.json"
  mc admin policy add minio/ "${bucket_wo_policy}" "/tmp/${bucket_wo_policy}.json"
  # Set policy to user
  mc admin policy set minio/ "${bucket_wo_policy}" user="${bucket_wo_user}"

fi

################################################################################
# Delete Bucket & User & Policy
################################################################################

if [[ "${execution_mode}" == "delete-bucket" ]]; then

  # Delete bucket
  echo
  echo "${msg_info} Delete bucket minio/${bucket_name}"
  echo
  mc rb --force minio/"${bucket_name}"

  # Delete users
  echo
  echo "${msg_info} Delete bucket Users"
  echo
  mc admin user remove minio/ "${bucket_rw_user}"
  mc admin user remove minio/ "${bucket_ro_user}"
  mc admin user remove minio/ "${bucket_wo_user}"

  # Delete policies
  echo
  echo "${msg_info} Delete bucket policies"
  echo
  mc admin policy remove minio/ "${bucket_rw_policy}"
  mc admin policy remove minio/ "${bucket_ro_policy}"
  mc admin policy remove minio/ "${bucket_wo_policy}"

  # Delete bucket configuration file
  if [[ -f ./buckets/${bucket_name}.config ]]; then
    echo
    echo "${msg_info} Delete bucket configuration file ./buckets/${bucket_name}.config"
    echo
    rm ./buckets/"${bucket_name}".config
  fi

  # Delete bucket environment source file
  if [[ -f ./buckets/source-${bucket_name}.sh ]]; then
    echo
    echo "${msg_info} Delete bucket environment source file ./buckets/source-${bucket_name}.sh"
    echo
    rm ./buckets/source-"${bucket_name}".sh
  fi

fi

################################################################################
# Display status information
################################################################################

if [[ "${execution_mode}" == "list-status" ]] ||
  [[ "${execution_mode}" == "create-bucket" ]] ||
  [[ "${execution_mode}" == "delete-bucket" ]]; then

  echo
  echo "${msg_info} MinIO status information"
  echo
  echo "MinIO host: https://${minio_host}"
  echo
  mc admin info minio/
  echo
  echo "${msg_info} MinIO healing information"
  echo
  echo "MinIO host: https://${minio_host}"
  echo
  mc admin heal --dry-run minio
  echo

  # Display buckets
  echo "Buckets:"
  echo
  mc ls minio/
  echo

  # Display users
  echo "Users (AccessKeys):"
  echo
  mc admin user list minio/
  echo

  # Display policies
  echo "IAM Policies:"
  echo
  mc admin policy list minio/
  echo

fi

#### END OF EXECUTION (EOE) ####################################################
echo
echo "${msg_info} END OF EXECUTION (EOE)"
echo
exit 0
