#!/bin/bash

#
#   cs-deploy.sh
#
#       Mission Control Center
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
  Mission Control Center.
  Datacenter Management Machine.

Usage:
  sudo cs-deploy.sh [-m <execution_mode>] [-h] [-q]

Execution modes:
  -m  <execution_mode>  - Valid modes are:
  
      [net-config]      - Network configuration. (Reboot when finished).
      [install]         - Package installation, updates and configuration tasks (Reboot when finished).
      [config]          - Redeploy config files and perform configuration tasks (Default mode).

Options and arguments:  
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Deploy configuration in [net-config] mode:
    sudo cs-deploy.sh -m net-config

  # Deploy configuration in [install] mode:
    sudo cs-deploy.sh -m install

  # Deploy configuration in [config] mode:
    sudo cs-deploy.sh -m config

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

# Time Zone
time_zone="UTC"

# System Locale (https://wiki.archlinux.org/index.php/Locale)
system_locale="C.UTF-8"

# System Keyboard (https://wiki.archlinux.org/index.php/Linux_console/Keyboard_configuration)
# system_keyboard="LAYOUT [MODEL [VARIANT [OPTIONS]]]"
system_keyboard="us"

# Netplan Try timeout in seconds
netplan_timeout="30"

# Kubernetes version for kubectl
k8s_version="1.23.1-00"

# Go version
go_version="go1.17.3.linux-amd64.tar.gz"

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
while getopts ":m:hq" opt; do
  case $opt in
  # Mode option
  m)
    # Set execution_mode
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

# Check if running as root (sudo)
if ! [[ "$(id -u)" == 0 ]]; then
  echo
  echo "${msg_error} The script $0 need to be run with sudo option" >&2
  echo
  exit 1
fi

# Validate execution modes
case "${execution_mode}" in
"net-config") ;;
"install") ;;
"config") ;;
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
  echo "  Machine installation and configuration deployment"
  echo
  echo "      Execution mode:     ${execution_mode}"
  if [[ "${execution_mode}" = "net-config" ]]; then
    echo
    echo "      The new netplan configuration is going to be tested."
    echo "      If IPAddress has been changed, you should open another console"
    echo "      and verify that connection is possible with the new settings."
    echo
    echo "  WARNING! You will have ${netplan_timeout} seconds to verify."
  fi
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
# Network configuration
################################################################################

if [[ "${execution_mode}" == "net-config" ]]; then

  # Deploy network configuration files
  echo
  echo "${msg_info} Deploy network configuration files"
  echo

  # Deploy /etc/hostname
  cp -v "${setup_dir}"/hostname /etc/hostname
  chmod 644 /etc/hostname
  chown root:root /etc/hostname

  # Deploy /etc/hosts
  cp -v "${setup_dir}"/hosts /etc/hosts
  chmod 644 /etc/hosts
  chown root:root /etc/hosts

  # Netplan configuration
  # Backup existing netplan configuration files
  for filename in /etc/netplan/*.yaml; do
    mv -v "$filename" "$filename".bck
  done
  # Deploy /etc/netplan/01-netcfg.yaml
  cp -v "${setup_dir}"/01-netcfg.yaml /etc/netplan/01-netcfg.yaml
  chmod 644 /etc/netplan/01-netcfg.yaml
  chown root:root /etc/netplan/01-netcfg.yaml

  # Flag that signals that cloud-init should not run
  if [[ -d /etc/cloud/ ]]; then
    touch /etc/cloud/cloud-init.disabled
  fi

  # Change systemd-resolved
  rm -f /etc/resolv.conf
  ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

  # Try netplan network configuration and reboot
  if [[ ${quiet_mode} == false ]]; then
    echo
    echo "${msg_info} Try netplan configuration /etc/netplan/01-netcfg.yaml"
    echo
    netplan try --timeout "${netplan_timeout}"
    echo

    # Reboot confirmation message
    echo
    echo "*********************************************************************"
    echo
    echo "  $(hostname):"
    echo
    echo "      ${command_line}"
    echo
    echo "  Reboot is needed to complete network configuration."
    echo
    echo "  WARNING! Reboot only if netplan configuration is accepted."
    echo
    echo "*********************************************************************"
    echo
    read -r -s -p $'Press Enter to REBOOT or Ctrl+C to ABORT...'
    echo
  fi

  # Perform reboot
  echo
  echo "${msg_info} Reboot in progress."
  echo
  reboot
fi

################################################################################
# Install and update packages
################################################################################

if [[ "${execution_mode}" == "install" ]]; then

  # Update installed packages
  echo
  echo "${msg_info} Update installed packages"
  echo

  apt update
  apt -y dist-upgrade
  apt -y autoremove

  # Generate locales
  # https://wiki.archlinux.org/index.php/Locale

  if [[ -f "${setup_dir}"/locale.gen ]]; then
    echo
    echo "${msg_info} Deploy /etc/locale.gen"
    echo

    cp -v "${setup_dir}"/locale.gen /etc/locale.gen
    chown root:root /etc/locale.gen
    chmod 0644 /etc/locale.gen
    locale-gen
  fi

  # Install chrony time sync
  echo
  echo "${msg_info} Install Chrony time synchronization"
  echo

  apt -y install chrony

  # Install Docker-ce
  echo
  echo "${msg_info} Install Docker-ce"
  echo

  apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
  apt -y install docker-ce
  # Add user to docker administration group
  usermod -aG docker "${sudo_username}"

  # Install OpenJDK JRE
  # echo
  # echo "${msg_info} Install Java Runtime Environment"
  # echo
  # apt -y install default-jre

  # Install shfmt shell formatter
  echo
  echo "${msg_info} Install shfmt shell formatter"
  echo
  snap install shfmt

  # Install jq JSON processor
  echo
  echo "${msg_info} Install jq JSON processor"
  echo
  apt -y install jq

  # Install go
  echo
  echo "${msg_info} Install Go"
  echo

  wget https://golang.org/dl/"${go_version}"

  # Remove previous installation
  if [[ -d /usr/local/go ]]; then
    rm -rf /usr/local/go
  fi

  # Extract files in /usr/local
  tar -C /usr/local -xzf "${go_version}"

  # Remove downloaded file
  rm ./"${go_version}"

  # Update ./.bashrc to remove line (space needed behind /usr/local/go/bin )
  sed -i "\#/usr/local/go/bin #d" ./.bashrc
  # Update ./.bashrc
  # shellcheck disable=SC2016
  echo 'export PATH=$PATH:/usr/local/go/bin:${HOME}/go/bin' | sudo tee -a ./.bashrc

  # Install direnv shell extension
  echo
  echo "${msg_info} Install direnv shell extension"
  echo

  curl -sfL https://direnv.net/install.sh | bash

  # Update ./.bashrc to remove line (space needed behind /usr/local/go/bin )
  sed -i "\#direnv #d" ./.bashrc
  # Update ./.bashrc
  # shellcheck disable=SC2016
  echo 'eval "$(direnv hook bash)"' | sudo tee -a ./.bashrc


  # Install kubectl
  echo
  echo "${msg_info} Install kubectl"
  echo

  apt-get install -y apt-transport-https curl
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

  apt-get update

  set +e
  apt-mark unhold kubectl
  set -e
  apt-get install -y kubectl="${k8s_version}"
  kubectl completion bash |sudo tee /etc/bash_completion.d/kubectl
  apt-mark hold kubectl

  # Install helm
  echo
  echo "${msg_info} Install Helm"
  echo
  snap install helm --classic

  # Install tree directory
  echo
  echo "${msg_info} Install tree directory"
  echo
  apt -y install tree

  # Install restic
  echo
  echo "${msg_info} Install restic"
  echo
  snap install restic --classic

  # Install MinIO client
  echo
  echo "${msg_info} Install MinIO client"
  echo

  wget https://dl.min.io/client/mc/release/linux-amd64/mc
  cp -v ./mc /usr/local/sbin/
  rm ./mc
  chown root:root /usr/local/sbin/mc
  chmod 755 /usr/local/sbin/mc

  # Install shellcheck
  echo
  echo "${msg_info} Install shellcheck"
  echo
  snap install shellcheck

  # Install kustomize
  echo
  echo "${msg_info} Install kustomize"
  echo
  snap install kustomize

fi

################################################################################
# Deploy config files and execute configuration tasks
################################################################################

if [[ "${execution_mode}" == "install" ]] ||
  [[ "${execution_mode}" == "config" ]]; then

  # Set timezone
  echo
  echo "${msg_info} Set timezone to ${time_zone}"
  echo
  timedatectl set-timezone "${time_zone}"

  # Set locale
  echo
  echo "${msg_info} Locales available"
  echo
  localectl list-locales
  echo
  echo "${msg_info} Set locale to '${system_locale}'"
  echo
  localectl set-locale "${system_locale}"

  # Set keyboard
  # https://wiki.archlinux.org/index.php/Linux_console/Keyboard_configuration
  echo
  echo "${msg_info} Set keyboard to '${system_keyboard}'"
  echo
  localectl set-x11-keymap "${system_keyboard}"
  echo
  echo "${msg_info} Locale status:"
  echo
  localectl status
  echo

  # Deploy sudoers file
  if [[ -f "${setup_dir}"/domadminsudo ]]; then
    echo
    echo "${msg_info} Deploy /etc/sudoers.d/domadminsudo"
    echo
    cp -v "${setup_dir}"/domadminsudo /etc/sudoers.d/domadminsudo
    chown root:root /etc/sudoers.d/domadminsudo
    chmod 0440 /etc/sudoers.d/domadminsudo
    visudo -c
  fi

  # Git profile configuration
  if [[ -f "${setup_dir}"/gitconfig ]]; then
    echo
    echo "${msg_info} Git profile configuration"
    echo

    cp -v "${setup_dir}"/gitconfig /home/"${sudo_username}"/.gitconfig
    chown "${sudo_username}":"${sudo_username}" /home/"${sudo_username}"/.gitconfig
    chmod 0644 /home/"${sudo_username}"/.gitconfig

  fi

  # UFW firewall configuration
  echo
  echo "${msg_info} UFW firewall configuration"
  echo
  ufw allow ssh
  # ufw disable
  ufw --force enable
  ufw status

  # Change local passwords
  if [[ -f "${setup_dir}"/kos-pass ]]; then
    echo
    echo "${msg_info} Change local passwords as specified in 'kos-pass' file"
    echo
    kos_pass_list="$(cat "${setup_dir}"/kos-pass)"
    echo "${kos_pass_list}" | chpasswd
  fi

  # Deploy ssh authorized_keys
  if [[ -f "${setup_dir}"/authorized_keys ]]; then
    echo
    echo "${msg_info} Deploy ssh authorized_keys for ${sudo_username}@$(hostname -f)"
    echo
    cp -v "${setup_dir}"/authorized_keys /home/"${sudo_username}"/.ssh/
    chown "${sudo_username}":"${sudo_username}" /home/"${sudo_username}"/.ssh/authorized_keys
    chmod 0600 /home/"${sudo_username}"/.ssh/authorized_keys
  fi
  if [[ -f "${setup_dir}"/authorized_keys_root ]]; then
    echo
    echo "${msg_info} Deploy ssh authorized_keys for root@$(hostname -f)"
    echo
    cp -v "${setup_dir}"/authorized_keys_root /root/.ssh/authorized_keys
    chown root:root /root/.ssh/authorized_keys
    chmod 0600 /root/.ssh/authorized_keys
  fi

  # Deploy ssh id_rsa keys
  if [[ -f "${setup_dir}"/id_rsa ]] && [[ -f "${setup_dir}"/id_rsa.pub ]]; then
    echo
    echo "${msg_info} Deploy ssh id_rsa keys for ${sudo_username}@$(hostname -f)"
    echo
    cp -v "${setup_dir}"/id_rsa /home/"${sudo_username}"/.ssh/
    chown "${sudo_username}":"${sudo_username}" /home/"${sudo_username}"/.ssh/id_rsa
    chmod 0600 /home/"${sudo_username}"/.ssh/id_rsa

    cp -v "${setup_dir}"/id_rsa.pub /home/"${sudo_username}"/.ssh/
    chown "${sudo_username}":"${sudo_username}" /home/"${sudo_username}"/.ssh/id_rsa.pub
    chmod 0644 /home/"${sudo_username}"/.ssh/id_rsa.pub
  fi

  if [[ -f "${setup_dir}"/id_rsa_root ]] && [[ -f "${setup_dir}"/id_rsa_root.pub ]]; then
    echo
    echo "${msg_info} Deploy ssh id_rsa keys for root@$(hostname -f)"
    echo
    cp -v "${setup_dir}"/id_rsa_root /root/.ssh/id_rsa
    chown root:root /root/.ssh/id_rsa
    chmod 0600 /root/.ssh/id_rsa

    cp -v "${setup_dir}"/id_rsa_root.pub /root/.ssh/id_rsa.pub
    chown root:root /root/.ssh/id_rsa.pub
    chmod 0644 /root/.ssh/id_rsa
  fi

  # Generate id_rsa for sudo_username
  if ! [[ -f /home/"${sudo_username}"/.ssh/id_rsa ]]; then
    echo
    echo "${msg_info} Generate ssh id_rsa for ${sudo_username} "
    echo
    ssh-keygen -t rsa -N '' -f /home/"${sudo_username}"/.ssh/id_rsa -C "${sudo_username}@$(hostname -f)"
    chown -R "${sudo_username}":"${sudo_username}" /home/"${sudo_username}"/.ssh
  fi

  # Generate id_rsa for root
  if ! [[ -f /root/.ssh/id_rsa ]]; then
    echo
    echo "${msg_info} Generate id_rsa for root"
    echo
    ssh-keygen -t rsa -N '' -f /root/.ssh/id_rsa -C "root@$(hostname -f)"
  fi

  # Check for ca-*.crt files in setup directory
  shopt -s nullglob
  declare -a ca_files=("${setup_dir}"/ca-*.crt)
  shopt -u nullglob
  count=${#ca_files[@]}
  if ((count > 0)); then
    # Deploy ca-certificates
    echo
    echo "${msg_info} Deploy ca-certificates (ca-*.crt files)"
    echo
    cp -v "${setup_dir}"/ca-*.crt /usr/local/share/ca-certificates/
    chmod 644 /usr/local/share/ca-certificates/*
    chown root:root /usr/local/share/ca-certificates/*
    update-ca-certificates
  fi

  # Deploy machine certificate
  if [[ -f "${setup_dir}"/"$(hostname)".crt ]] && [[ -f "${setup_dir}"/"$(hostname)".key ]]; then
    echo
    echo "${msg_info} Deploy $(hostname).key and $(hostname).crt machine certificate files"
    echo

    # Deploy public certificate
    cp -v "${setup_dir}"/"$(hostname)".crt /usr/local/share/ca-certificates/
    chmod 644 /usr/local/share/ca-certificates/*
    chown root:root /usr/local/share/ca-certificates/*
    update-ca-certificates

    # Deploy private key
    cp -v "${setup_dir}"/"$(hostname)".key /etc/ssl/private/
    chmod 600 /etc/ssl/private/"$(hostname)".key
    chown root:root /etc/ssl/private/"$(hostname)".key
  fi

  # Deploy crontab files
  # Delete existing crontab cs-cron* files in /etc/cron.d and copy new ones
  echo
  echo "${msg_info} Delete existing crontab files (/etc/cron.d/cron-cs-*)"
  echo
  touch /etc/cron.d/cs-cron_somefilewithprefixcreatedjustfordelete.txt
  rm -vf /etc/cron.d/cs-cron*

  # Copy new crontab cs-cron-* files if present
  shopt -s nullglob
  declare -a crontab_files=("${setup_dir}"/cs-cron*)
  shopt -u nullglob
  count=${#crontab_files[@]}
  if ((count > 0)); then
    echo
    echo "${msg_info} Copy crontab files (/etc/cron.d/cs-cron*)"
    echo
    cp -v "${setup_dir}"/cs-cron* /etc/cron.d/
    chmod 644 /etc/cron.d/cs-cron*
    chown root:root /etc/cron.d/cs-cron*
  fi
  # Restart cron.server and diplay status
  systemctl restart cron.service
  systemctl status cron.service
fi

################################################################################
# Reboot after install
################################################################################

if [[ "${execution_mode}" == "install" ]]; then

  # Reboot with confirmation message
  if [[ ${quiet_mode} == false ]]; then
    echo
    echo "*********************************************************************"
    echo
    echo "  $(hostname):"
    echo
    echo "      ${command_line}"
    echo
    echo "  Installation and configuration completed."
    echo
    echo "  Reboot is recommended."
    echo
    echo "*********************************************************************"
    echo
    read -r -s -p $'Press Enter to REBOOT or Ctrl+C to ABORT...'
    echo
  fi

  # Perform reboot
  echo
  echo "${msg_info} Reboot in progress."
  echo
  reboot

fi

#### END OF EXECUTION (EOE) ####################################################
echo
echo "${msg_info} END OF EXECUTION (EOE)"
echo
exit 0
