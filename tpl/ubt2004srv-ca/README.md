# {{ .machine.hostname }} <!-- omit in toc -->

[comment]: <> (**Machine functional description goes here**)

Machine `{{ .machine.hostname }}` is deployed from template {{ ._tpldescription }} version {{ ._tplversion }}.

- [Prerequisites](#prerequisites)
- [How-to guides](#how-to-guides)
  - [Inject & Deploy configuration](#inject--deploy-configuration)
    - [1. SSH Authentication and sudoers file](#1-ssh-authentication-and-sudoers-file)
    - [2. Network configuration](#2-network-configuration)
    - [3. Install packages, updates and configuration tasks](#3-install-packages-updates-and-configuration-tasks)
    - [4. Configuration tasks](#4-configuration-tasks)
    - [5. Connect and operate](#5-connect-and-operate)
  - [Create CA](#create-ca)
  - [Certificate request and issuance](#certificate-request-and-issuance)
  - [Display certificate information](#display-certificate-information)
  - [Display CA status](#display-ca-status)
  - [Backup and restore CA files](#backup-and-restore-ca-files)
  - [Utilities](#utilities)
    - [Passwords and secrets](#passwords-and-secrets)
- [Reference](#reference)
  - [Scripts](#scripts)
    - [cs-caserv](#cs-caserv)
    - [cs-deploy](#cs-deploy)
    - [cs-inject](#cs-inject)
    - [cs-connect](#cs-connect)
    - [cs-helloworld](#cs-helloworld)
  - [Template values](#template-values)
- [License](#license)

---

## Prerequisites

- Physical or virtual machine up and running, with a clean or cloud-init installation of Ubuntu server 20.04.

- Package `openssh-server` must be installed to allow remote ssh connections.

## How-to guides

### Inject & Deploy configuration

To install and configure the machine, open a terminal from the machine configuration directory in the management repository, and perform the following configuration steps:

#### 1. SSH Authentication and sudoers file

```bash
# Run csinject.sh in [ssh-sudoers] execution mode
./csinject.sh -k
```

> **NOTE:** If IP address has not been previously set in cloud-init or net-config, use `-r IPaddress`
until network configuration files are deployed.

This step injects ssh key and sudoers file into the machine.

Required before other configuration options. Its purpose is to allow automated and passwordless logins by using ssh protocol.

If ssh key has not been injected before, you must provide the password for username `{{ .machine.localadminusername }}@{{ .machine.hostname }}` twice:

- First one to install ssh key (ssh-copy-id).
- Second one to deploy the sudoers file.

#### 2. Network configuration

```bash
# Run csinject.sh to inject & deploy configuration in [net-config] deploy mode
./csinject.sh -d -m net-config
```

> **NOTE:** If IP address has not been previously set in cloud-init or net-config, use `-r IPaddress`
until network configuration files are deployed.

This step deploys network configuration files that allow the machine to operate with specific IP address and hostname. Cloud-init configuration will be disabled from the next start.

Reboot is recommended when finished.

#### 3. Install packages, updates and configuration tasks

```bash
# Run csinject.sh to inject & deploy configuration in [install] deploy mode
./csinject.sh -d -m install
```

This step performs:

- Package installation
- Updates
- Configuration files deployment
- Configuration tasks

Required to run at least once in order to complete proper configuration. Reboot is recommended when finished.

#### 4. Configuration tasks

```bash
# Run csinject.sh to inject & deploy configuration in [config] deploy mode (default)
./csinject.sh -d
```

When configuration needs to be changed, this mode redeploys all configuration files into the machine, executing again all configuration tasks.

#### 5. Connect and operate

```bash
# Run csconnect.sh to establish a ssh session with sudoer (admin) user
./csconnect.sh
```

To run scripts and operate from inside the machine, establish an ssh connection with administrator (sudoer) user name `{{ .machine.localadminusername }}@{{ .machine.hostname }}`.

### Create CA

You can configure `ca_name` and `ca_subject` before creating the configuration files from the template, providing the appropiate template values in .yaml file.

Example:

```yaml
ca:
  caname: ca-cskylab.net
  basesubject: /C=ES/ST=Spain/L=Madrid/O=Trantor/OU=cSkyLab/CN=cSkylabTest
```

These values can also be updated in variable intialization section of `cs-caserv.sh` script.

File `openssl-ca.conf` provides configuration default values for the CA that can be customized.

Only one CA can be configured in a single machine. To create a new CA, execute:

```bash
# Create new private CA
sudo cs-caserv.sh -m ca-create
```

### Certificate request and issuance

File `openssl-cert.conf` provides configuration default values for certificate creation that can be customized. In particular, you should check the following section to verify that the appropriate Certificate Subject Alternate Names (SAN) are given:

```properties
[alt_names]
DNS.1 = ${CNAME}
DNS.2 = ${CNAME}.{{ .machine.domainname }}
# DNS.3 = *.example.com
# DNS.4 = example.com
```

To create and issue a certificate for a hostname called "opn-cskylab" execute:

```bash
  # Request and issue certificate for hostname "opn-cskylab"
  # Review openssl-cert.cnf file for certificate SAN
    sudo cs-caserv.sh -m cert-req -n opn-cskylab
```

Certificates are generated in different formats. To copy all certificate formats generated, including the private key, you should execute a SCP command from other machine, in the form:

- `scp {{ .machine.localadminusername }}@hostname_fqdn:cert_common_name* ./`.

### Display certificate information

To show certificate information for a given certificate file, execute:

```bash
  # Display information for certificate /etc/ssl/certs/Amazon_Root_CA_1.pem:
    sudo cs-caserv.sh -c /etc/ssl/certs/Amazon_Root_CA_1.pem
```

### Display CA status

To show CA certificate and database index file, execute:

```bash
  # Show CA certificate and database index file:
    sudo cs-caserv.sh -l
```

### Backup and restore CA files

Backup or restore CA files can be done via `ca_name.tar` file.

This file includes all contents in `/etc/ssl/` directory.

To backup `/etc/ssl/` directory into `ca_name.tar` file, execute

```bash
  # Backup directory /etc/ssl with CA keys and certificates
  # File "ca-name".tar will be created at HOME directory
    sudo cs-caserv.sh -m ca-tar
```

File `ca_name.tar` is created at HOME directory of `{{ .machine.localadminusername }}` user. You should copy this file to configuration management via SCP. A command template is given in the form:

- `scp {{ .machine.localadminusername }}@hostname_fqdn:ca_name.tar ./`

To restore `/etc/ssl/` directory from `ca_name.tar` file, execute:

```bash
  # Restore directory /etc/ssl with CA keys and certificates
  # File "ca-name".tar must exist at setup_dir directory
    sudo cs-caserv.sh -m ca-untar
```

> Note: All contents of `/etc/ssl/` directory will be replaced.

### Utilities

#### Passwords and secrets

Generate passwords and secrets with:

```bash
# Screen
echo $(head -c 512 /dev/urandom | LC_ALL=C tr -cd 'a-zA-Z0-9' | head -c 16)

# File (without newline)
printf $(head -c 512 /dev/urandom | LC_ALL=C tr -cd 'a-zA-Z0-9' | head -c 16) > RESTIC-PASS.txt
```

Change the parameter `head -c 16` according with the desired length of the secret.

## Reference

### Scripts

#### cs-caserv

```console
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
```

**Tasks performed:**

| ${execution_mode}           | Tasks                                   | Block / Description                                                                                      |
| --------------------------- | --------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| [ca-create]                 |                                         | **Create new private CA**                                                                                |
|                             | Export environment variables            | Export ca_name as environment variable for `openssl-ca.cnf`.                                             |
|                             | Create CA directories                   | Create directories and index file for CA operation.                                                      |
|                             | Create CA key pair:                     | Create CA private and public keys and copy to CA directories. Files can be exported via SCP.             |
|                             | Public key                              | `/etc/ssl/certs/ca_name.pem`                                                                             |
|                             | Private key                             | `/etc/ssl/private/ca_name-key.pem`                                                                       |
|                             | Create base64 encoded formats:          | Create base64 encoded line format for kubernetes tls secrets. Files can be exported via SCP.             |
|                             | Public key                              | `$HOME/ca_name.pem.b64`                                                                                  |
|                             | Private key                             | `$HOME/ca_name.key.b64`                                                                                  |
| [ca-tar]                    |                                         | **Create .tar file from /etc/ssl**                                                                       |
|                             | Create .tar file                        | Create `$HOME/ca_name.tar` file from /etc/ssl directory. File can be exported via SCP.                   |
| [ca-untar]                  |                                         | **Restore /etc/ssl from .tar file**                                                                      |
|                             | Restore .tar file                       | Restore `/etc/ssl/` directory contents from `ca_name.tar` file in setup directory.                       |
| [cert-req]                  |                                         | **Certificate request and issuance**                                                                     |
|                             | Export environment variables            | Export ca_name and cert_common_name as environment variables for `openssl-cert.cnf`.                     |
|                             | Generate CSR file                       | Generate `cert_common_name.csr` and private key `cert_common_name.key`.                                  |
|                             | Sign CSR and generate certificate       | Sign CSR and generate certificate file  `cert_common_name.pem`.                                          |
|                             | Convert certificate to other formats    | Generate certificate formats `*.pfx *.chain.pem *.chain.crt *.chain.pfx`. Files can be exported via SCP. |
|                             | Display certificate and files generated | List `cert_common_name.*` files                                                                          |
| [cert-info]                 |                                         | **Show certificate information**                                                                         |
|                             | Show certificate information            | Show certificate information for a given certificate `-c certificate_file`.                              |
| [cert-create] [list-status] |                                         | **Show CA certificate and database index file**                                                          |
|                             | Show CA certificate status              | Show CA certificate info and index of issued certificates.                                               |
|                             |                                         |                                                                                                          |

#### cs-deploy

```console
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
```

**Tasks performed:**

| ${execution_mode}  | Tasks                              | Block / Description                                                                                    |
| ------------------ | ---------------------------------- | ------------------------------------------------------------------------------------------------------ |
| [net-config]       |                                    | **Network configuration**                                                                              |
|                    | Deploy /etc/hostname               | Configuration file `hostname` must exist in setup directory.                                           |
|                    | Deploy /etc/hosts                  | Configuration file `hosts` must exist in setup directory.                                              |
|                    | Deploy /etc/netplan/01-netcfg.yaml | Configuration file `01-netcfg.yaml` must exist in setup directory.                                     |
|                    | Disable cloud-init                 | Flag that signals that cloud-init should not run.                                                      |
|                    | Change systemd-resolved            | Change configuration of file `/etc/resolv.conf`.                                                       |
|                    | Try Netplan configuration          | Execute `netplan try` to test new network configuration.                                               |
|                    | Reboot                             | Reboot with confirmation message.                                                                      |
| [install]          |                                    | **Install and update packages**                                                                        |
|                    | Update installed packages          | Update package repositories, perform `dist-upgrade` and `autoremove`                                   |
|                    | Generate locales                   | Deploy file `locale.gen` if present in setup directory and execute `locale-gen`.                       |
|                    | Install chrony time sync           | Chrony time synchronization (https://chrony.tuxfamily.org)                                             |
|                    | Install rng-tools                  | Increase entropy for certificate creation. (<https://wiki.archlinux.org/index.php/Rng-tools>)          |
| [install] [config] |                                    | **Deploy config files and execute configuration tasks**                                                |
|                    | Set timezone                       | Set time zone from `time_zone` variable.                                                               |
|                    | Set locale                         | Set locale from `system_locale` variable.                                                              |
|                    | Set keyboard                       | Set keyboard layout from `system_keyboard` variable.                                                   |
|                    | Deploy sudoers file                | Deploy sudoers configuration file `domadminsudo` (Must be present in setup directory).                 |
|                    | UFW firewall configuration         | UFW enabled with ssh allowed.                                                                          |
|                    | Change local passwords             | If file `kos-pass`is present in setup directory. (Template `tpl-kos-pass` provided).                   |
|                    | Deploy ssh authorized_keys         | If file `authorized_keys`is present in setup directory. (Template `tpl-authorized_keys` provided).     |
|                    | Deploy ssh id_rsa keys             | If files `id_rsa` and `id_rsa.pub` are present in setup directory. (Templates `tpl-id_rsa*` provided). |
|                    | Generate id_rsa                    | If doesn't exist for root and sudoer user.                                                             |
|                    | Deploy ca-certificates             | If files with name pattern `ca-*.crt` are present.                                                     |
|                    | Deploy machine certificate         | If files with name pattern `hostname.crt` and `hostname.key`are present.                               |
|                    | Deploy crontab files               | If files with name pattern `cron-cs-*` are present in setup directory.                                 |
| [install]          |                                    | **Reboot after install**                                                                               |
|                    | Reboot                             | Reboot with confirmation message.                                                                      |

#### cs-inject

> **Note:** This script runs from the "DevOps Computer", opening a terminal from the machine configuration directory in the management repository,.

```console
Purpose:
  Inject & Deploy configuration files into remote machine.
  This script runs from the management (DevOps) computer, copying all configuration
  files to the remote machine, and calling the script 'cs-deploy.sh' to run from
  inside the remote machine if 'deploy' mode [-d] is selected.

Usage:
  ./csinject.sh [-k] [-i] [-d] [-m <deploy_mode>] [-u <sudo_username>] [-r <remote_machine>] [-h] [-q]

Execution modes:
  -k  [ssh-sudoers] - install ssh key and sudoers file into the machine. Required before other actions.
  -i  [inject]      - Inject only. Inject configuration files into the machine for manual deployment.
  -d  [deploy]      - Inject & Deploy configuration. Calls 'cs-deploy.sh' to run from inside the machine.

Options and arguments:  
  -m  <deploy_mode>       - Deploy mode passed to 'cs-deploy.sh'. Valid modes are:

      [net-config]        - Network configuration. (Reboot when finished).
      [install]           - Package installation, updates and configuration tasks (Reboot when finished).
      [config]            - Redeploy config files and perform configuration tasks (Default mode).
  
  -u  <sudo_username>     - Remote administrator (sudoer) user name (Default value).
  -r  <remote_machine>    - Machine hostname or IPAddress (Default value).
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Copy ssh key and sudoers file into the machine:
    ./csinject.sh -k

  # Inject & Deploy configuration in [net-config] mode:
    ./csinject.sh -dm net-config

  # Inject & Deploy configuration in [install] mode:
    ./csinject.sh -dm install

  # Inject & Deploy configuration in [config] mode (default):
    ./csinject.sh -d
```

**Tasks performed:**

| ${execution_mode} | Tasks                                     | Block / Description                                                                           |
| ----------------- | ----------------------------------------- | --------------------------------------------------------------------------------------------- |
| [ssh-sudoers]     |                                           | **Inject ssh key and sudoers file**                                                           |
|                   | Perform ssh-copy-id                       | Insert your public key to be authorized in ssh authentication.                                |
|                   | Deploy sudoers file                       | Deploy sudoers configuration file `domadminsudo` (Must be present in setup directory).        |
|                   |                                           |                                                                                               |
| [inject] [deploy] |                                           | **Copy config files and deploy scripts**                                                      |
|                   | Prepare setup directory in remote machine | Remove setup directory if exist and create empty new one with permissions.                    |
|                   | Inject configuration files                | SCP configuration files from configuration management into machine setup directory.           |
|                   | Deploy scripts to `/usr/local/sbin`       | Delete old `cs-*.sh` scripts inside `/usr/local/sbin` and copy new ones from setup directory. |
|                   |                                           |                                                                                               |
| [deploy]          |                                           | **Run cs-deploy from inside the machine**                                                     |
|                   | Execute `cs-deploy.sh` inside the machine | Run `cs-deploy.sh` script inside the machine in mode specified by `deploy-mode` variable`.    |
|                   |                                           |                                                                                               |

#### cs-connect

> **Note:** This script runs from the "DevOps Computer", opening a terminal from the machine configuration directory in the management repository,.

```console
Purpose:
  SSH remote connection.
  Use this script to remote login into the machine and establish a ssh session.

Usage:
  csconnect.sh [-u <sudo_username>] [-r <remote_machine>] [-h]

Options and arguments:  
  -u  <sudo_username>   - Remote user name (Default value).
  -r  <remote_machine>  - Machine hostname or IPAddress (Default value).
  -h  Help

Examples:
  # Connect to the machine with default values
    ./csconnect.sh

  # Connect to IPAddress with specific user
    ./csconnect.sh -u sudo_username -r 192.168.2.99
```

**Tasks performed:**

| Tasks                  | Description                               |
| ---------------------- | ----------------------------------------- |
| Perform ssh connection | Passwordless ssh connection with timeout. |

#### cs-helloworld

```console
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
```

**Tasks performed:**

| ${execution_mode}                         | Tasks                          | Block / Description                                      |
| ----------------------------------------- | ------------------------------ | -------------------------------------------------------- |
| [install]                                 |                                | **Install apps and services**                            |
|                                           | Task 1                         | Task 1 description as commented in code.                 |
|                                           | Task 2                         | Task 2 description as commented in code.                 |
|                                           | Task n                         | Task n description as commented in code.                 |
| [remove]                                  |                                | **Remove apps and services**                             |
|                                           | Task 1                         | Task 1 description as commented in code.                 |
|                                           | Task 2                         | Task 2 description as commented in code.                 |
|                                           | Task n                         | Task n description as commented in code.                 |
| [update] [install]                        |                                | **Update and reconfigure apps and services**             |
|                                           | Task 1                         | Task 1 description as commented in code.                 |
|                                           | Task 2                         | Task 2 description as commented in code.                 |
|                                           | Task n                         | Task n description as commented in code.                 |
| [list-status] [install] [update] [remove] |                                | **Display status information**                           |
|                                           | Display hostname and variables | Show hostame and content of variables used in the script |
|                                           | Display report message         | Display report message with "some surprise"              |

### Template values

The following table lists template configuration parameters and their specified values, when machine configuration files were created from the template:

| Parameter                    | Description                                 | Values                                                     |
| ---------------------------- | ------------------------------------------- | ---------------------------------------------------------- |
| `_tplname`                   | template name                               | `{{ ._tplname }}`                                          |
| `_tpldescription`            | template description                        | `{{ ._tpldescription }}`                                   |
| `_tplversion`                | template version                            | `{{ ._tplversion }}`                                       |
| `machine.hostname`           | hostname                                    | `{{ .machine.hostname }}`                                  |
| `machine.domainname`         | domain name                                 | `{{ .machine.domainname }}`                                |
| `machine.localadminusername` | local admin username                        | `{{ .machine.localadminusername }}`                        |
| `machine.localadminpassword` | local admin password                        | `{{ .machine.localadminpassword }}`                        |
| `machine.timezone`           | timezone                                    | `{{ .machine.timezone }}`                                  |
| `machine.networkinterface`   | main network interface name                 | `{{ .machine.networkinterface }}`                          |
| `machine.ipaddress`          | main IP address                             | `{{ .machine.ipaddress }}`                                 |
| `machine.netmask`            | netmask                                     | `{{ .machine.netmask }}`                                   |
| `machine.gateway4`           | default gateway                             | `{{ .machine.gateway4 }}`                                  |
| `machine.searchdomainnames`  | search domain names                         | `{{ range .machine.searchdomainnames }}{{ . }}, {{ end }}` |
| `machine.nameservers`        | name servers IP addresses                   | `{{ range .machine.nameservers }}{{ . }}, {{ end }}`       |
| `machine.setupdir`           | inject directory for setup and config files | `{{ .machine.setupdir }}`                                  |
| `machine.systemlocale`       | language configuration                      | `{{ .machine.systemlocale }}`                              |
| `machine.systemkeyboard`     | keyboard layout configuration               | `{{ .machine.systemkeyboard }}`                            |

## License

Copyright © 2021 cSkyLab.com ™

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
