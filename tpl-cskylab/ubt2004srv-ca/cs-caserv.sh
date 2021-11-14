#!/bin/bash

#
#   cs-caserv.sh
#
#       Certificate Authority Services.
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
  Certificate Authority Services.
  Use this script to operate a private Certificate Authority.

Usage:
  sudo cs-caserv.sh [-l] [-c <certificate_file>] [-m <execution_mode>]
                    [-n <cert_common_name>] [-h] [-q]

Execution modes:
  -l  [list-status]       - Show CA certificate and database index file.
  -c  [cert-info]         - Show certificate info.
      <certificate_file>  - Certificate file name

  -m  <execution_mode>    - Valid modes are:

      [ca-create]         - Create new private CA.
      [ca-tar]            - Create .tar file from /etc/ssl
      [ca-untar]          - Restore /etc/ssl from .tar file
      [cert-req]          - Certificate request & issuance

Options and arguments:  
  -n <cert_common_name>   - Certificate Common Name
                            (SAN provided in openssl-cert.cnf)
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Create new private CA
  # Change ca_name and base_subject variables as needed.
    sudo cs-caserv.sh -m ca-create

  # Request and issue certificate for hostname "opn-cskylab"
  # Review openssl-cert.cnf file for certificate SAN
    sudo cs-caserv.sh -m cert-req -n opn-cskylab
  
  # Backup directory /etc/ssl with CA keys and certificates
  # File "ca-name".tar will be created at HOME directory
    sudo cs-caserv.sh -m ca-tar
  
  # Restore directory /etc/ssl with CA keys and certificates
  # File "ca-name".tar must exist at setup_dir directory
    sudo cs-caserv.sh -m ca-untar
  
  # Show CA certificate and database index file:
    sudo cs-caserv.sh -l

  # Display information for certificate /etc/ssl/certs/Amazon_Root_CA_1.pem:
    sudo cs-caserv.sh -c /etc/ssl/certs/Amazon_Root_CA_1.pem

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

# CA Common Name (Should be in the form "ca-something")
ca_name="{{ .ca.caname }}"

# Certificate base subject (to be completed with common name)
base_subject="{{ .ca.basesubject }}"

# Color code for messages
# https://robotmoon.com/256-colors/
msg_info="$(tput setaf 2 -T xterm-256color)[$(hostname)] [$(basename "$0")] $(date -R)
Info:$(tput sgr0 -T xterm-256color)" # Green
msg_error="$(tput setaf 1 -T xterm-256color)[$(hostname)] [$(basename "$0")] $(date -R)
Error:$(tput sgr0 -T xterm-256color)" # Red

################################################################################
# Options and arguments
################################################################################

# Certificate file name
certificate_file=
# Certificate Common name
cert_common_name=
# Certificate Subject
cert_subject=

# CA Subject
ca_subject="${base_subject}${ca_name}"

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
while getopts ":lc:m:n:hq" opt; do
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
  # Certificate info option
  c)
    # Set execution mode if empty (not previously set)
    if [[ -z "${execution_mode}" ]]; then
      execution_mode="cert-info"
      quiet_mode=true
    else
      echo
      echo "${msg_error} Execution mode not valid ${command_line}" >&2
      echo
      exit 1
    fi
    # Remove trailing slashes in certificate_file
    # sed used intentionally
    # shellcheck disable=SC2001
    certificate_file="$(echo "$OPTARG" | sed 's:/*$::')"
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
  # Certificate Name option
  n)
    cert_common_name="$OPTARG"
    cert_subject="${base_subject}${cert_common_name}"
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
"ca-create")
  # Validate CA directories and key does not exist
  if [[ -d /etc/ssl/CA ]]; then
    echo
    echo "${msg_error} CA directory /etc/ssl/CA already exists" >&2
    exit 1
  fi
  if [[ -d /etc/ssl/newcerts ]]; then
    echo
    echo "${msg_error} CA directory /etc/ssl/newcerts already exists" >&2
    exit 1
  fi
  # Check for previous private key files in /etc/ssl/private/ directory
  shopt -s nullglob
  declare -a ca_keys=(/etc/ssl/private/*)
  shopt -u nullglob
  count=${#ca_keys[@]}
  if ((count > 0)); then
    echo
    echo "${msg_error} CA directory /etc/ssl/private not empty" >&2
    exit 1
  fi
  # Validate openssl-ca.cnf exist in setup directory
  if ! [[ -f "${setup_dir}"/openssl-ca.cnf ]]; then
    echo
    echo "${msg_error} Configuration file 'openssl-ca.cnf' must exist in setup directory" >&2
    exit 1
  fi
  ;;
"ca-tar") ;;

"ca-untar")
  # Validate .tar file exist
  if ! [[ -f "${setup_dir}/${ca_name}".tar ]]; then
    echo
    echo "${msg_error} ${ca_name}.tar does not exist" >&2
    exit 1
  fi
  ;;
"cert-req")
  # Validate openssl-cert.cnf exist in setup directory
  if ! [[ -f "${setup_dir}"/openssl-cert.cnf ]]; then
    echo
    echo "${msg_error} Configuration file 'openssl-cert.cnf' must exist in setup directory" >&2
    exit 1
  fi
  # Validate cert_common_name exist
  if [[ -z "${cert_common_name}" ]]; then
    echo
    echo "${msg_error} Option -n <certificate-common-name> must be provided" >&2
    echo
    exit 1
  fi
  ;;
"cert-info")
  # Validate certificate_file exist
  if ! [[ -f "${certificate_file}" ]]; then
    echo
    echo "${msg_error} Certificate file ${certificate_file} does not exist" >&2
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

# Validadte CA is created
if [[ "${execution_mode}" == "ca-tar" ]] ||
  [[ "${execution_mode}" == "cert-req" ]] ||
  [[ "${execution_mode}" == "list-status" ]]; then

  # Validate CA directories and key does exist
  if ! [[ -d /etc/ssl/CA ]]; then
    echo
    echo "${msg_error} CA directory /etc/ssl/CA does not exists" >&2
    exit 1
  fi
  if ! [[ -d /etc/ssl/newcerts ]]; then
    echo
    echo "${msg_error} CA directory /etc/ssl/newcerts does not exists" >&2
    exit 1
  fi
  # Check for private key files in /etc/ssl/private/ directory
  shopt -s nullglob
  declare -a ca_keys=(/etc/ssl/private/*)
  shopt -u nullglob
  count=${#ca_keys[@]}
  if ((count == 0)); then
    echo
    echo "${msg_error} CA directory /etc/ssl/private is empty" >&2
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
  if [[ "${execution_mode}" = "ca-create" ]]; then
    echo "      CA Name:            ${ca_name}"
    echo "      CA Subject:         ${ca_subject}"
  fi
  if [[ "${execution_mode}" = "ca-tar" ]] ||
    [[ "${execution_mode}" = "ca-tar" ]]; then
    echo "      TAR file name:      ${ca_name}.tar"
  fi
  if [[ "${execution_mode}" = "cert-req" ]]; then
    echo "      Certificate CN:     ${cert_common_name}"
    echo
    echo "      Check fike 'openssl-cert.cnf' for certificate SAN"
  fi
  echo
  echo "*********************************************************************"
  echo

  read -r -s -p $'Press Enter to continue or Ctrl+C to abort...'
  echo
  if [[ "${execution_mode}" = "ca-untar" ]]; then
    echo
    echo "******** WARNING: Existing CA Key and certificate history"
    echo "                  will be PERMANENTLY DELETED."
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
# Create new private CA
################################################################################

if [[ "${execution_mode}" == "ca-create" ]]; then

  echo
  echo "${msg_info} Create new private CA keys and directories"
  echo

  # Export ca_name as environment variable for openssl-ca.cnf
  export CSKY_CANAME="${ca_name}"

  # Create CA directories
  mkdir -pv /etc/ssl/CA
  sh -c "echo '01' > /etc/ssl/CA/serial"
  touch /etc/ssl/CA/index.txt

  mkdir -pv /etc/ssl/newcerts

  # Create CA key pair in ${sudo_username} ${HOME} directory
  openssl req -config "${setup_dir}"/openssl-ca.cnf \
    -new -x509 -extensions v3_ca \
    -nodes \
    -keyout "${ca_name}"-key.pem \
    -subj "${ca_subject}" \
    -out "${ca_name}".pem -days 7300

  # Base64 encoded line format for kubernetes tls secrets
  base64 -i ./"${ca_name}".pem -w 0 >./"${ca_name}".crt.b64
  base64 -i ./"${ca_name}"-key.pem -w 0 >./"${ca_name}".key.b64

  # Copy certificate and key files
  cp -v "${ca_name}"-key.pem ./"${ca_name}".key
  mv -v "${ca_name}"-key.pem /etc/ssl/private/
  cp -v "${ca_name}".pem /etc/ssl/certs/
  cp -v "${ca_name}".pem ./"${ca_name}".crt

  # Change ownership of CA files in ${sudo_username} ${HOME} directory
  # (This will allow to SCP CA files)
  chown "${sudo_username}":"${sudo_username}" ./"${ca_name}".*

  echo
  echo "${msg_info} CA files generated:"
  echo "To copy, execute from config directory:"
  echo "    < scp ${sudo_username}@$(hostname -f):${ca_name}.* ./ >"
  echo
  ls -lah ./"${ca_name}".*

fi

################################################################################
# Create .tar file from /etc/ssl
################################################################################

if [[ "${execution_mode}" == "ca-tar" ]]; then

  echo
  echo "${msg_info} Creating ${ca_name}.tar file from /etc/ssl"
  echo

  # Create .tar file from /etc/ssl in ${sudo_username} ${HOME} directory
  tar -cvf "${ca_name}".tar -C /etc/ssl .

  # Change ownership of .tar file in ${sudo_username} ${HOME} directory
  # (This will allow to SCP .tar file)
  chown "${sudo_username}":"${sudo_username}" "${ca_name}".tar

  echo
  echo "${msg_info} ${ca_name}.tar created from the content of /etc/ssl directory."
  echo "To copy, execute from config directory:"
  echo "    < scp ${sudo_username}@$(hostname -f):${ca_name}.tar ./ >"
  echo
fi

################################################################################
# Restore /etc/ssl from .tar file
################################################################################

if [[ "${execution_mode}" == "ca-untar" ]]; then

  echo
  echo "${msg_info} Restoring /etc/ssl from ${ca_name}.tar file"
  echo

  # Restore /etc/ssl from .tar file in setup directory
  tar -xvf "${setup_dir}/${ca_name}".tar -C /etc/ssl

  echo
  echo "${msg_info} Directory /etc/ssl restored from ${ca_name}.tar file."
  echo
fi

################################################################################
# Certificate request and issuance
################################################################################

if [[ "${execution_mode}" == "cert-req" ]]; then

  # Export cert_common_name and CAName as environment variable for openssl-cert.cnf
  export CSKY_CANAME="${ca_name}"
  export CSKY_CNAME="${cert_common_name}"

  # Generate CSR file
  # Create CSR file in ${sudo_username} ${HOME} directory
  echo
  echo "${msg_info} Generating ${cert_common_name}.key and ${cert_common_name}.csr files"
  echo
  openssl req -config "${setup_dir}"/openssl-cert.cnf \
    -subj "${cert_subject}" \
    -out "${cert_common_name}".csr \
    -new -newkey rsa:2048 -nodes \
    -keyout "${cert_common_name}".key

  # Sign CSR and generate certificate
  echo
  echo "${msg_info} Signing ${cert_common_name}.csr"
  echo
  openssl ca -batch -config "${setup_dir}"/openssl-cert.cnf \
    -in "${cert_common_name}".csr \
    -out "${cert_common_name}".pem

  # Convert certificate to other formats
  echo
  echo "${msg_info} Converting certificate file formats"
  echo

  # Public certificate in .der format
  openssl x509 -in ./"${cert_common_name}".pem -outform der -out ./"${cert_common_name}".der

  # Public certificate .crt format
  openssl x509 -in ./"${cert_common_name}".der -inform der -out ./"${cert_common_name}".crt

  # Base64 encoded line format for kubernetes tls secrets
  base64 -i ./"${cert_common_name}".crt -w 0 >./"${cert_common_name}".crt.b64
  base64 -i ./"${cert_common_name}".key -w 0 >./"${cert_common_name}".key.b64

  # Private + public certificate .pfx format
  openssl pkcs12 -export -nodes -passout pass: -inkey "${cert_common_name}".key \
    -in "${cert_common_name}".pem -out "${cert_common_name}".pfx
  # Public certificate with CARoot public embeded .pem format
  cat /etc/ssl/certs/"${ca_name}".pem ./"${cert_common_name}".crt >"${cert_common_name}".chain.pem
  # Public certificate with CARoot public embeded .crt format
  cat /etc/ssl/certs/"${ca_name}".pem ./"${cert_common_name}".crt >"${cert_common_name}".chain.crt
  # Private + public certificate with CARoot public embeded .pfx format
  openssl pkcs12 -export -nodes -passout pass: -inkey "${cert_common_name}".key \
    -in "${cert_common_name}".chain.pem -out "${cert_common_name}".chain.pfx

  # Change ownership of certificate files
  # (This will allow to SCP certificate ${cert_common_name}".* files)
  chown "${sudo_username}":"${sudo_username}" ./"${cert_common_name}".*

  # Display certificate and files generated
  echo
  echo "${msg_info} Certificate ${cert_common_name} issued:"
  echo
  openssl x509 -in "${cert_common_name}".pem -text -noout

  echo
  echo "${msg_info} Certificate files generated:"
  echo "To copy, execute from config directory:"
  echo "    < scp ${sudo_username}@$(hostname -f):${cert_common_name}.* ./ >"
  echo

  echo
  ls -lah ./"${cert_common_name}".*

fi

################################################################################
# Show certificate information
################################################################################

if [[ "${execution_mode}" == "cert-info" ]]; then

  echo
  echo "${msg_info} Certificate info for file ${certificate_file}"
  echo
  # Show certificate information
  openssl x509 -in "${certificate_file}" -text -noout
  echo
fi

################################################################################
# Show CA certificate and database index file
################################################################################

if [[ "${execution_mode}" == "ca-create" ]] ||
  [[ "${execution_mode}" == "list-status" ]]; then

  # Show certificate
  echo
  echo "${msg_info} CA key and self-signed certificate files:"
  echo
  ls -lah /etc/ssl/certs/"${ca_name}".*
  echo
  openssl x509 -in /etc/ssl/certs/"${ca_name}".pem -noout -text
  echo

  # Show CA index database
  echo
  echo "${msg_info} CA Database index:"
  echo
  cat /etc/ssl/CA/index.txt
  echo
  echo "${msg_info} Signed <serial number>.pem certificates can be found at /etc/ssl/newcerts."
  echo

fi

#### END OF EXECUTION (EOE) ####################################################
echo
echo "${msg_info} END OF EXECUTION (EOE)"
echo
exit 0
