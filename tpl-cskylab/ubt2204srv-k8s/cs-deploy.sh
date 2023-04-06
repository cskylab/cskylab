#!/bin/bash

#
#   cs-deploy.sh
#
#       Machine installation and configuration deployment
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
  Machine installation and configuration deployment.
  This script is usually called by csinject.sh when executing Inject & Deploy
  operations. Exceptionally, it can also be run manually from inside the machine.

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
sudo_username="{{ .machine.localadminusername }}"

# Setup directory
# Must be declared in all scripts because it could be referenced in templates
# WARNING: Content will be deleted and replaced with every new configuration.
# Must be accesible by sudo_username. Use the same in all scripts.
# shellcheck disable=SC2034
setup_dir="{{ .machine.setupdir }}"

# Time Zone
time_zone="{{ .machine.timezone }}"

# System Locale (https://wiki.archlinux.org/index.php/Locale)
system_locale="{{ .machine.systemlocale }}"

# System Keyboard (https://wiki.archlinux.org/index.php/Linux_console/Keyboard_configuration)
# system_keyboard="LAYOUT [MODEL [VARIANT [OPTIONS]]]"
system_keyboard="{{ .machine.systemkeyboard }}"

# Netplan Try timeout in seconds
netplan_timeout="30"

# Kubernetes version to install
k8s_version="{{ .k8s_version }}"

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

  # Install Restic Backup
  echo
  echo "${msg_info} Install Restic backup"
  echo
  apt -y install restic && restic self-update

  #
  # Kubernetes section
  #

  echo
  echo "${msg_info} Install ContainerD and Kubernetes"
  echo

  # Disable swap
  swapoff -a
  sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

  # Install ContainerD
  # Ref.: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd

  # Install and configure prerequisites

  cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

  modprobe overlay
  modprobe br_netfilter

  # Setup required sysctl params, these persist across reboots.
  cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

  # Apply sysctl params without reboot
  sysctl --system

  # (Install containerd)
  apt-get update && sudo apt-get install -y containerd

  # Configure containerd
  if ! [[ -d /etc/containerd/ ]]; then
    mkdir -p /etc/containerd
  fi

  containerd config default >/etc/containerd/config.toml

  # Update /etc/containerd/config.toml (space needed behind variable ${lv_dev_name})
  sed -i "s/SystemdCgroup = false/SystemdCgroup = true/g" /etc/containerd/config.toml

  # Restart containerd
  systemctl restart containerd

  # Install kubeadm, kubelet and kubectl
  # Ref.: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
  apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl
  curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

  apt-get update
  apt-get install -y kubelet="${k8s_version}" kubeadm="${k8s_version}" kubectl="${k8s_version}"
  apt-mark hold kubelet kubeadm kubectl

  # Restarting the kubelet is required
  systemctl daemon-reload
  systemctl restart kubelet

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

  # UFW firewall configuration
  echo
  echo "${msg_info} UFW firewall configuration"
  echo
  ufw allow ssh

  ##
  ## Kubernetes ufw required ports
  ##
  
  ## Required ports on master node
  ufw allow 6443/tcp  # Kubernetes API server
  ufw allow 2379/tcp  # etcd server client API
  ufw allow 2380/tcp  # etcd server client API
  ufw allow 10250/tcp # Kubelet API
  ufw allow 10259/tcp # kube-scheduler
  ufw allow 10257/tcp # kube-controller-manager

  ## Required ports on worker nodes
  ufw allow 10250/tcp       # Kubelet API
  ufw allow 30000:32767/tcp # NodePort Services

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
