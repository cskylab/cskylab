# {{ .machine.hostname }} <!-- omit in toc -->

This machine runs a Kubernetes node on Ubuntu Server 22.04 LTS.

Persistent Volumes on local storage are supported by LVM services.

[comment]: <> (**Machine functional description goes here**)

Machine `{{ .machine.hostname }}` is deployed from template {{ ._tpldescription }} version {{ ._tplversion }}.

- [Prerequisites](#prerequisites)
  - [Check kubernetes version](#check-kubernetes-version)
- [How-to guides](#how-to-guides)
  - [Inject \& Deploy configuration](#inject--deploy-configuration)
    - [1. SSH Authentication and sudoers file](#1-ssh-authentication-and-sudoers-file)
    - [2. Network configuration](#2-network-configuration)
    - [3. Install packages, updates and configuration tasks](#3-install-packages-updates-and-configuration-tasks)
    - [4. Configuration tasks](#4-configuration-tasks)
    - [5. Connect and operate](#5-connect-and-operate)
  - [Storage services](#storage-services)
    - [Manage disk volume groups](#manage-disk-volume-groups)
    - [Manage Thin Provisioning LVM data services](#manage-thin-provisioning-lvm-data-services)
    - [Repair LVM thin-pool](#repair-lvm-thin-pool)
    - [Rsync data replication](#rsync-data-replication)
    - [Restic data backup and restore](#restic-data-backup-and-restore)
  - [Initialize a new kubernetes cluster](#initialize-a-new-kubernetes-cluster)
    - [Prepare your internal CA files](#prepare-your-internal-ca-files)
    - [Single control-plane K8s cluster](#single-control-plane-k8s-cluster)
    - [Standalone K8s cluster](#standalone-k8s-cluster)
    - [Credentials for k8s clusters administration](#credentials-for-k8s-clusters-administration)
  - [Add node to k8s cluster](#add-node-to-k8s-cluster)
    - [Create a new token](#create-a-new-token)
    - [Join the new node to the cluster](#join-the-new-node-to-the-cluster)
    - [Inject ssh keys between k8s nodes](#inject-ssh-keys-between-k8s-nodes)
  - [Remove node from k8s cluster](#remove-node-from-k8s-cluster)
    - [Drain the node](#drain-the-node)
    - [Delete the node](#delete-the-node)
  - [k8s certificate management](#k8s-certificate-management)
    - [Check certificate expiration](#check-certificate-expiration)
    - [Manual certificate renewal](#manual-certificate-renewal)
  - [k8s Raspberry Pi](#k8s-raspberry-pi)
    - [Enable cgroups limit support](#enable-cgroups-limit-support)
  - [Force delete namespace](#force-delete-namespace)
  - [Utilities](#utilities)
    - [Passwords and secrets](#passwords-and-secrets)
    - [Abridged ‘find’ command examples](#abridged-find-command-examples)
    - [USB disk operations](#usb-disk-operations)
- [Reference](#reference)
  - [Scripts](#scripts)
    - [cs-k8init](#cs-k8init)
    - [cs-volgroup](#cs-volgroup)
    - [cs-lvmserv](#cs-lvmserv)
    - [cs-rsync](#cs-rsync)
    - [cs-restic](#cs-restic)
    - [cs-deploy](#cs-deploy)
    - [cs-inject](#cs-inject)
    - [cs-connect](#cs-connect)
    - [cs-helloworld](#cs-helloworld)
- [License](#license)

---

## Prerequisites

- Physical or virtual machine with two or more disks:
  - Disk 1: Ubuntu server 22.04 installed up and running.
  - Additional disks: Free and ready to be managed by LVM.
- Package `openssh-server` must be installed to allow remote ssh connections.

To run kubernetes node, (master or worker) the minimum recommended system requirements are:

- 2 CPU
- 4 GB RAM

### Check kubernetes version

Before installation, you can choose the k8s version to install by changing in `cs-deploy.sh` script the variable `k8s_version`

To see available versions, connect to the machine and run:

```bash
# List available kubeadm versions
sudo apt update && sudo apt-cache madison kubeadm
```

>**NOTE**: You must choose the kubernetes version, before running package installation with `./csinject.sh -d -m install` script.

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

### Storage services

#### Manage disk volume groups

Usage:

```bash
  sudo cs-volgroup.sh -h
```

List status:

```bash
  sudo cs-volgroup.sh -l
```

Create volume group + LVM thin pool:

```bash
# Create volume group with default variable values
  sudo cs-volgroup.sh -m create
```

If only one volume group is going to be created, you can edit the script and update in section `Variable initialization` the values for volume group name `vg_name` and block device names `block_dev_names`.

Otherwise, you can specify these values in the following way:

```bash
  # Create volume group with name "ssd"
  # from disk devices "/dev/sdb /dev/sdc /dev/sdd"
    sudo cs-volgroup.sh -m create -d "/dev/sdb /dev/sdc /dev/sdd" -v ssd
```

Delete volume group + LVM thin pool:

```bash
# Delete volume group with default variable values
  sudo cs-volgroup.sh -m delete

  # Delete volume group with name "ssd"
  # from disk devices "/dev/sdb /dev/sdc /dev/sdd"
    sudo cs-volgroup.sh -m delete -d "/dev/sdb /dev/sdc /dev/sdd" -v ssd
```

Before deleting volume groups, you must delete the LV's inside.

#### Manage Thin Provisioning LVM data services

Usage:

```bash
  sudo cs-lvmserv.sh -h
```

List status:

```bash
  sudo cs-lvmserv.sh -l
```

Create LV data service (Thin logical volume + directory mount):

```bash
  # Create thin logical volume data service "/srv/mydir"
  # in default volume group.
    sudo cs-lvmserv.sh -m create -d /srv/mydir
```

Create snapshot:

```bash
# Create snapshot of data service "/srv/mydir"
# in default volume group.
# Snapshot will be mounted read-only in /tmp/mydir_snap
  sudo cs-lvmserv.sh -m snap-create -d /srv/mydir
```

Remove snapshot:

```bash
# Remove snapshot of data service "/srv/mydir"
# in default volume group
  sudo cs-lvmserv.sh -m snap-remove -d /srv/mydir
```

Merge snapshot (Rollback to snapshot status):

```bash
# Merge snapshot of data service "/srv/mydir"
# in default volume group
  sudo cs-lvmserv.sh -m snap-merge -d /srv/mydir
```

Delete LV data service:

```bash
# Delete thin logical volume data service "/srv/mydir"
# in default volume group.
  sudo cs-lvmserv.sh -m delete -d /srv/mydir
```

Free space of unused blocks inside thin-pools:

```bash
# Free space inside thin-pools
  sudo cs-lvmserv.sh -m trim-space

```

#### Repair LVM thin-pool

1. Unmount all LVM in the volume group

2. List LVM to see vg and lv names

```bash
sudo lvscan
```

3. Deactivate volume group

```bash
sudo lvchange -an vg
```

4. Repair thin-pool

```bash
sudo lvconvert --repair  vg/tpool
```

5. Activate volume group

```bash
sudo lvchange -ay vg
```

6. Mount LVM and check data

To learn more see the following procedure: https://smileusd.github.io/2018/10/12/repair-thinpool/

#### Rsync data replication

> **Note:** Prior to operate rsync with a remote host, you must insert the root public key for ssh authentication and passwordless login as sudoer user in the remote host. From a console inside the machine you must run `sudo ssh-copy-id {{ .machine.localadminusername }}@hostname.domain.com`

Usage:

```bash
  sudo cs-rsync.sh -h
```

RSync data from local directory TO remote directory (snapshot automatically created and removed):

```bash
# RSync data service "/srv/mydir"
# TO same remote directory at host "hostname.cskylab.net"
  sudo cs-rsync.sh -m rsync-to -d /srv/mydir \
  -t hostname.cskylab.net
```

RSync data FROM remote directory to local directory:

```bash
# RSync data service "/srv/mydir"
# FROM remote directory "/srv/mydir" at host "hostname.cskylab.net"
  sudo cs-rsync.sh -m rsync-from -d /srv/mydir \
  -t hostname.cskylab.net
```

#### Restic data backup and restore

The script `cs-restic.sh` is designed as a wrapper to execute restic in LVM data services with snapshot operations.

Usage:

```bash
  sudo cs-restic.sh -h
```

Credentials for default Restic environment and S3 bucket if used, are stored in the following variables:

```bash
# restic-environment
export RESTIC_REPOSITORY="{{ .restic.repo }}"
export RESTIC_PASSWORD="{{ .restic.password }}"
export AWS_ACCESS_KEY_ID="{{ .restic.aws_access }}"
export AWS_SECRET_ACCESS_KEY="{{ .restic.aws_secret }}"
```

> **Note:** Prior to operate restic with a remote host in sftp mode, you must insert the root public key for ssh authentication and passwordless login as sudoer user in the remote host. From a console inside the machine you must run `sudo ssh-copy-id {{ .machine.localadminusername }}@hostname.domain.com`

**Create repository**:

To create Restic repository (Directory must exist):

```bash
  # Create repository
    sudo cs-restic.sh -m repo-init -r "{{ .restic.repo }}"
```

**Backup LVM data service**:

Data services must have been previously created with `cs-lvmserv.sh`. When making backup of a data service, the script automatically creates a snapshot and removes it when finished.

To backup a data service directory:

```bash
  # Backup data service /srv/mydir
    sudo cs-restic.sh -m restic-bck -d /srv/mydir \
      -r "{{ .restic.repo }}"
```

**List snapshots in repository**:

To list snapshots in a repository:

```bash
  # List snapshots in repository
    sudo cs-restic.sh -m restic-list -r "{{ .restic.repo }}"
```

**Restore snapshot**:

Data service directory must be empty. Otherwise you should use restic-mount and rsync data from mount point.

Restic restore does not show progress information in console. To see progress, open another terminal and run `sudo du -sh /srv/mydir`

To restore from specific snapshot E.G.:(2a3dff53):

```bash
  # Restore from specific snapshot
    sudo cs-restic.sh -m restic-res 2a3dff53 -d /srv/mydir \
      -r "{{ .restic.repo }}"
```

**Mount restic repository snapshot**:

Restic repository can be locally mounted, by default in `/tmp/restic` directory, in order to manually explore and copy files or to use the script `cs-rsync.sh -m rsync-from` to synchronize data from any snapshot in the repository to local data service directory.

To mount restic repository:

```bash
  # Mount repository in local directory /tmp/restic
    sudo cs-restic.sh -m restic-mount -r "{{ .restic.repo }}"
```

After a restic-mount operation, console will be freezed while repository is mounted. To access the contents of the repository, open another terminal and refer to the locally mounted directory `/tmp/restic`

**Use of cs-rsync from mount point**:

You can use the script `cs-rsync.sh` to restore a complete snapshot from mount point. 

Examples:

```bash
  # RSync data service "/srv/mydir"
  # FROM Restic snapshot /tmp/restic/snapshots/latest
    sudo cs-rsync.sh -m rsync-from -r "/tmp/restic/snapshots/latest" \
      -d /srv/mydir
  # RSync data service "/srv/mydir"
  # FROM Restic snapshot /tmp/restic/snapshots/2021-04-03T21\:39\:08+02\:00
    sudo cs-rsync.sh -m rsync-from -r "/tmp/restic/snapshots/2021-04-03T21\:39\:08+02\:00" \
      -d /srv/mydir
```

**Maintain Restic repository with forget option**:

The default forget option provided in the script is `--keep-hourly 6 --keep-daily 31 --keep-weekly 5 --keep-monthly 13 --keep-yearly 10`. You can provide a specific forget option (-f) with an specific tag (-t).

It's not recommended to run restic prune with regular backups, since it can be a time-consuming process and it should be planned in a way that it doesn’t interfere with regular backups.

```bash
  # Forget snapshots in repository with default forget option and tag mydir
    sudo cs-restic.sh -m restic-forget -t "mydir" -r "{{ .restic.repo }}"
```

### Initialize a new kubernetes cluster

To learn more about kubernetes cluster installation with `kubeadm` see <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/>

#### Prepare your internal CA files

To use your internal CA, you must copy your certificate and key files to the configuration directory. The following files must exist in your configuration directory:

- `ca.crt`: CA certificate file
- `ca.key`: CA key file

>**NOTE**: You must have the files into the k8s-master machine at install time, before initializing the kube with `cs-k8init.sh` script.

If files have been changed since machine installation, inject & deploy configuration by running:

```bash
# Inject & Deploy configuration
./csinject.sh -qd

```

#### Single control-plane K8s cluster

Follow these steps to install a single control-plane Kubernetes cluster with `kubeadm`.

To initialize a new cluster run:

```bash
# Initialize a new master node and kubernetes cluster":
sudo cs-k8init.sh -m init-master
```

#### Standalone K8s cluster

In standalone mode, master node can hold worloads for application deployment, and it is possible to deploy a single node cluster.

```bash
# Initialize a new kubestalone single node kubernetes cluster":
sudo cs-k8init.sh -m init-kubestalone
```

To display kubernetes cluster status execute:

```bash
# Display current cluster status:
sudo cs-k8init.sh -l
```

#### Credentials for k8s clusters administration

- **Prepare your kubernetes credentials directory**:
  
  If not previously created, you must have in your computer a special directory to hold kubernetes credentials files (kubeconfig files). Go to your home directory, and create it:

```bash
  # Create kubernetes credential directory for kubeconfig files
  mkdir ${HOME}/.kube
```

  This directory will contain kubeconfig credential files for each k8s cluster you need to operate with.

- **Copy kubeconfig file**: You must copy from every k8s master node its credentials file `.kube/config` to your computer. Use an SCP command and name the config file according to the k8s cluster name, in the following form:

```bash
  # Example: Download from host k8s-mod-master.cskylab.com, the kubeconfig file for cluster k8s-mod
  scp kos@k8s-mod-master.cskylab.net:~/.kube/config ${HOME}/.kube/config-k8s-mod
```

- **Edit kubeconfig file and customize names**: 
  
  Edit the kubeconfig file `${HOME}/.kube/config-<your_k8s_cluster_name>` and change all the entries named `kubernetes` to `your_k8s_cluster_name` in the following way:
  
  | Entry:       | Change to:                | Example                            |
  | ------------ | ------------------------- | ---------------------------------- |
  | `kubernetes` | `<your_k8s_cluster_name>` | Change `kubernetes` to `k8s-model` |
  
- **Change cluster administration context**: To set the administration context to a specific cluster, you must export the `$KUBECONFIG` environment variable in the followinng way:
  
```bash
  ## $KUBECONFIG environment variable
  export KUBECONFIG=$HOME/.kube/config-k8s-mod
```

- **Merging kubeconfig files**:
  
  In addition to these single cluster kubeconfig files, you need to merge them into a global default kubeconfig file `${HOME}/.kube/config`.
  
  Since kubeconfig files are structured YAML files, you can’t just append them to get one file. You must use `kubectl` to merge these files.

  To do so, take the following steps:

```bash
  # Backup your current default kubeconfig file
  cp -av ${HOME}/.kube/config ${HOME}/.kube/config.bak

  # Merge kubeconfig files format
  KUBECONFIG=file1:file2:file3 kubectl config view --merge --flatten > ${HOME}/.kube/config
  
  # Merging example for files config-k8s-mod and config-k8s-pro
  KUBECONFIG=${HOME}/.kube/config-k8s-mod:${HOME}/.kube/config-k8s-pro kubectl config view --merge --flatten > ${HOME}/.kube/config
```  

### Add node to k8s cluster

This procedure covers how to add a node to an existing cskylab kubernetes cluster.

Additional procedures can be found at:

- <https://www.serverlab.ca/tutorials/containers/kubernetes/how-to-add-workers-to-kubernetes-clusters/>
- <https://kubernetes.io/docs/concepts/architecture/nodes/>

#### Create a new token

Tokens only have a lifespan of 24-hours, preventing you from adding additional nodes after that time limit.

Create a new token using kubeadm. By using the –print-join-command argument, kubeadm will output the token and SHA hash required to securely communicate with the master.

```bash
# Create token and print join command
sudo kubeadm token create --print-join-command

# Verify created token
sudo kubeadm token list
```

Copy the join command to be used in next step.

#### Join the new node to the cluster

Use the kubeadm join command obtained with our new token to join the new node to the cluster.

Connect to the new node and execute the join command:

```bash
# Join the cluster (example)
sudo kubeadm join 192.168.1.130:6443 \
    --token qt57zu.wuvqh64un13trr7x \
    --discovery-token-ca-cert-hash sha256:5ad014cad868fdfe9388d5b33796cf40fc1e8c2b3dccaebff0b066a0532e8723
```

From the k8s master node or any other kubectl console, list your cluster’s nodes to verify the new node has successfully joined the cluster.

```bash
# List existing nodes
kubectl get nodes
```

#### Inject ssh keys between k8s nodes

In order to schedule cron-tab copies of local data services to other nodes, you must inject ssh keys from each node, to the other nodes in the cluster.

>**Note:** You will be asked for the password of local admin user (See file `secrets/admin-password`).

**Example: k8s-mod nodes**

- Open terminals at each k8s node and connect inside the machine with `./csconnect.sh`:
  - k8s-mod-n1
  - k8s-mod-n2
  - k8s-mod-n3
  - k8s-mod-n4

```bash
# Inject ssh keys from k8s-mod-n1
sudo ssh-copy-id kos@k8s-mod-n2.cskylab.net
sudo ssh-copy-id kos@k8s-mod-n3.cskylab.net
sudo ssh-copy-id kos@k8s-mod-n4.cskylab.net

# Inject ssh keys from k8s-mod-n2
sudo ssh-copy-id kos@k8s-mod-n1.cskylab.net
sudo ssh-copy-id kos@k8s-mod-n3.cskylab.net
sudo ssh-copy-id kos@k8s-mod-n4.cskylab.net

# Inject ssh keys from k8s-mod-n3
sudo ssh-copy-id kos@k8s-mod-n1.cskylab.net
sudo ssh-copy-id kos@k8s-mod-n2.cskylab.net
sudo ssh-copy-id kos@k8s-mod-n4.cskylab.net

# Inject ssh keys from k8s-mod-n4
sudo ssh-copy-id kos@k8s-mod-n1.cskylab.net
sudo ssh-copy-id kos@k8s-mod-n2.cskylab.net
sudo ssh-copy-id kos@k8s-mod-n3.cskylab.net
```

### Remove node from k8s cluster

>**NOTE**: Before running this procedure, you must check that the node to be removed is not running any persistent volume service in its local storage.

#### Drain the node

Remove all workloads in the node by running:

```bash
# Drain node <node-name>
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```

#### Delete the node

>**NOTE**: `kubectl delete`command deletes the node from cluster without confirmation prompt.

To delete the node from cluster:

```bash
# Delete node <node-name>
kubectl delete node <node-name>
```

After node removal, you can reset the machine to a state which was there before running kubeadm join. Connect to the removed node and execute:

```bash
# Reset the node
sudo kubeadm reset
```

### k8s certificate management

#### Check certificate expiration

- To see certificate expiration, connect to k8s master node and run:

```bash
# Check k8s certificate expiration
sudo kubeadm certs check-expiration
```

#### Manual certificate renewal

kubeadm renews all the certificates during k8s master node upgrade.

You can renew your certificates manually using the existing CA.

- To renew certificates manually, connect to k8s master node and run:

```bash
kubeadm certs renew all
```

- Restart k8s master node after running the command.

### k8s Raspberry Pi

Before create or joining a cluster in a Raspberry Pi, you must follow these steps:

#### Enable cgroups limit support

For the Raspberry Pi 4, make the following changes to the /boot/firmware/cmdline.txt file:

```bash
# Append the cgroups and swap options to the kernel command line
# Note the space before "cgroup_enable=cpuset", to add a space after the last existing item on the line

# Display file before change
cat /boot/firmware/cmdline.txt

# Execute the change
sudo sed -i '$ s/$/ cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 swapaccount=1/' /boot/firmware/cmdline.txt

# Display file after change
cat /boot/firmware/cmdline.txt

# Reboot the Raspberry Pi
sudo reboot
```

- Reboot the Raspberry Pi

### Force delete namespace

```bash
NAMESPACE={YOUR_NAMESPACE_TO_DELETE}
kubectl proxy &
kubectl get namespace $NAMESPACE -o json |jq '.spec = {"finalizers":[]}' >temp.json
curl -k -H "Content-Type: application/json" -X PUT --data-binary @temp.json 127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize
```

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

#### Abridged ‘find’ command examples

When looking for files or directories, you can use the `find` command like in the following examples:

```bash
# Basic case-insensitive commands
# -------------------------------
find /tmp/restic/snapshots/latest/ -type f -iname "*foo*"   # find files under latest snapshot
find /tmp/restic/snapshots/latest/ -type d -iname "*foo*"   # find directories under latest snapshot
find /tmp/restic/snapshots/ -type f -name "foo.txt"         # find a specific file in all snapshots

# find files with different extensions
# ------------------------------------
find . -type f \( -name "*.c" -o -name "*.sh" \)                       # *.c and *.sh files
find . -type f \( -name "*cache" -o -name "*xml" -o -name "*html" \)   # three patterns

# find files that don't match a pattern (-not)
# --------------------------------------------
find . -type f -not -name "*.html"    # find all files not ending in ".html"

# Execute ls -lah with files found
# --------------------------------
find $PWD -type f -iname "*foo*" -exec ls -lah {} \;

# find files bigger than a size
# -----------------------------
find $PWD -type f -size +4G -exec ls -lah {} \;  # find all files bigger than 4GB
```

#### USB disk operations

**Disk formatting and partitioning**:

- Plug USB disk and find the block device:

```bash
  # List all disk devices and partitions
  sudo fdisk -l
```

- Execute fdisk in interactive mode:

```bash
  # fdisk interactive mode (Example for device /dev/sdc)
  sudo fdisk /dev/sdc
  
  Welcome to fdisk (util-linux 2.34).
  Changes will remain in memory only, until you decide to write them.
  Be careful before using the write command.


  Command (m for help): 
```

- **Enter `m`** to get a list of all available commands:

```console
  Command (m for help): m

  Help:

    GPT
    M   enter protective/hybrid MBR

    Generic
    d   delete a partition
    F   list free unpartitioned space
    l   list known partition types
    n   add a new partition
    p   print the partition table
    t   change a partition type
    v   verify the partition table
    i   print information about a partition

    Misc
    m   print this menu
    x   extra functionality (experts only)

    Script
    I   load disk layout from sfdisk script file
    O   dump disk layout to sfdisk script file

    Save & Exit
    w   write table to disk and exit
    q   quit without saving changes

    Create a new label
    g   create a new empty GPT partition table
    G   create a new empty SGI (IRIX) partition table
    o   create a new empty DOS partition table
    s   create a new empty Sun partition table


  Command (m for help): 
```

- **Enter `g`** to create a new empty GPT partition table:

```console
  Command (m for help): g
  Created a new GPT disklabel (GUID: FB0E06DB-479A-C842-A775-657D4D52BA41).

  Command (m for help): 
```

- **Enter `n`** to create a new partition and accept default values:

```console
  Command (m for help): n
  Partition number (1-128, default 1): 
  First sector (2048-62545886, default 2048): 
  Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-62545886, default 62545886): 

  Created a new partition 1 of type 'Linux filesystem' and of size 29.8 GiB.

  Command (m for help): 
```
  
  > **Note**: You can change the partition type if needed, using option `t change a partition type`. (Example: `11 Microsoft basic data` to support `exfat` file system.)

- **Enter `p`** to display the new partition table:

```console
  Command (m for help): p
  Disk /dev/sdc: 29.84 GiB, 32023511040 bytes, 62545920 sectors
  Disk model: USB Flash Drive 
  Units: sectors of 1 * 512 = 512 bytes
  Sector size (logical/physical): 512 bytes / 512 bytes
  I/O size (minimum/optimal): 512 bytes / 512 bytes
  Disklabel type: gpt
  Disk identifier: FB0E06DB-479A-C842-A775-657D4D52BA41

  Device     Start      End  Sectors  Size Type
  /dev/sdc1   2048 62545886 62543839 29.8G Linux filesystem

  Command (m for help):   
```

- **Enter `w`** to save the changes:

```console
  Command (m for help): w
  The partition table has been altered.
  Calling ioctl() to re-read partition table.
  Syncing disks.
```

**Format partition & create file system:**

- To format partition and create the file system, run:

```bash
  # Format partition & create file system (Example for partition /dev/sdc1)
  sudo mkfs.ext4 -L USBDisk /dev/sdc1
```

  > **Note**: You can use analog commands (i.e., mkfs.exfat or mkfs.ntfs) to create other types of file systems.

**Repair file system:**

You can use the `fsck` command to repair corrupted file systems.

- To check and repair the filesystem, unmount the partition and run:

```bash
  # Check and repair the file system (Example for partition /dev/sdc1)
  sudo fsck.ext4 /dev/sdc1
```
  
  > **Note**: You can use analog commands (i.e., fsck.exfat or fsck.ntfs) to check or repair other types of file systems.

**USB Disk mount**:

Disk must be previously partitioned and file system created.

To mount a USB disk in `/media` directory:

- Find the disk and its UUID
  
```bash
  # List all disk devices and partitions
  sudo fdisk -l
  
  # Find disk UUID
  sudo blkid
```

  Output example for /dev/sdc1:

```console
  Output
  /dev/XXX: xxxxxxxxxxxxxxxxxxxxxxxxx
  /dev/sdc1: UUID="74530e5a-836c-4cf1-963a-2743b296349b" TYPE="ext4" PARTUUID="e7d880eb-f6a6-8648-bb80-21d8dc72b6e0"
```

- To mount interactively for the current session use the mount command (Example for /dev/sdc1):
  
```bash
  # Mount disk interactively
  sudo mount /dev/sdc1 /media
```

- To mount at system startup if present, you must update /etc/fstab in the following way (Example for UUID=...):

```bash
  # Update fstab to mount disk at startup
  sudo echo "UUID=74530e5a-836c-4cf1-963a-2743b296349b  /media  auto nosuid,nodev,nofail 0 0" | sudo tee -a /etc/fstab
  
  # Mount interactively if not mounted at startup
  sudo mount -a
```

**Create data directory**:

>**Note**: As a best practice, you should create a data directory with sudoer user ownership for remote access, in the mounted file system to be referenced in scripts instead of the mounting point. (i.e. You should reference `/media/data` instead of `/media`).

- To create data directory and set ownership:

```bash
  # Create data directory
  sudo mkdir /media/data
  sudo chown -R {{ .machine.localadminusername }}:{{ .machine.localadminusername }} /media/data
```

**USB Disk unmount**:

- To unmount from `/media`and get the disk ready to unplug:

```bash
  # Unmount disk interactively
  sudo umount /media
```

## Reference

### Scripts

#### cs-k8init

```console
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

```

**Tasks performed:**

| ${execution_mode}                | Tasks                                       | Block / Description                               |
| -------------------------------- | ------------------------------------------- | ------------------------------------------------- |
| [init-master] [init-kubestalone] |                                             | **Initialize kubernetes cluster**                 |
|                                  | Deploy internal CA to be used in kubernetes | If files `ca.crt` and `ca.key`are present.        |
|                                  | Download kube-system images                 | Download kube-system needed images.               |
|                                  | Initialize cluster with kubeadm             | Execute `kubeadm init`                            |
|                                  | Copy .kube/config key store                 | Copy key store needed for cluster administration. |
|                                  | Initialize pod weave network                | Initialize weave network for pods.                |
| [init-kubestalone]               |                                             | **Initialize kubestalone mode**                   |
|                                  | Set kubestalone mode                        | Set cluster to run pods at master node            |
| [list-status]                    |                                             | **Display cluster status**                        |
|                                  | Display status                              | Display status for nodes and pods.                |

#### cs-volgroup

```console
Purpose:
  Disk volume group management.
  Use this script to create and delete volume groups
  from one or several disk devices.
  Each volume group will have a thin-pool associated to hold
  data services that will be created with the script "cs-lvmserv.sh".

Usage:
  sudo cs-volgroup.sh [-l] [-m <execution_mode>] [-d  <block_dev_names>]
                      [-v <vg_name>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List volume group and disk status.
  -m  <execution_mode>  - Valid modes are:
  
      [create]          - Create volume group and thin pool.
      [delete]          - Delete volume group and erase disks.

Options and arguments:  
  -d  <block_dev_names> - Disk device names to be added into volume group.
                          (Array quoted list and space separated values)
                          (Optional. Default value)
  -v  <vg_name>         - Volume group name. (Optional. Default value)
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # List current status
    sudo cs-volgroup.sh -l

  # Create volume group with default variable values 
    sudo cs-volgroup.sh -m create

  # create volume group with name "ssd"
  # from disk devices "/dev/sdb /dev/sdc /dev/sdd"
    sudo cs-volgroup.sh -m create -d "/dev/sdb /dev/sdc /dev/sdd" -v ssd
```

**Tasks performed:**

| ${execution_mode} | Tasks                   | Block / Description                                                   |
| ----------------- | ----------------------- | --------------------------------------------------------------------- |
| [create]          |                         | **Create volume group**                                               |
|                   | Prepare devices         | Wipe signatures and erase partition tables for all specified devices. |
|                   | Create physical volumes | Create physical volumes for all specified devices.                    |
|                   | Create volume group     | Create volume group with all specified devices.                       |
|                   | Create thin-pool        | Create a unique thin-pool in volume group to hold thin volumes.       |
| [delete]          |                         | **Delete volume group**                                               |
|                   | Delete Volume Group     | Delete volume group and all logical volumes inside.                   |
|                   | Wipe devices            | Wipe signatures and erase partition tables for all specified devices. |
|                   | Update `/etc/fstab`     | Remove mounts for all logical volumes in volume group.                |
| [list-status]     |                         | **Display disk and volume group status**                              |
|                   | Display status          | Disks, physical volumes (PV's) and volume groups (VG's) status.       |

#### cs-lvmserv

```console
Purpose:
  LVM data services.
  Use this script to create or delete directory data services with independent 
  thin logical volumes suitable for snapshot operations.
  A volume group and thin-pool must have been created before using the 
  script "cs-volgroup.sh".

Usage:
  sudo cs-lvmserv.sh  [-l] [-m <execution_mode>]
                      [-d <data_path>] [-v <vg_name>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List status of existing logical volumes.
  -m  <execution_mode>  - Valid modes are:
  
      [create]          - Create data service.
                          (Thin logical volume + directory mount)
      [delete]          - Delete data service.
                          (Thin logical volume + directory mount)
      [snap-create]     - Create snapshot and mount to read-only directory.
      [snap-remove]     - Remove snapshot and unmount from read-only directory.
      [snap-merge]      - Roll back logical volume to snapshot status
                           and discard all changes.
      [trim-space]      - Free space inside thin-pools
                          discarding unused blocks on all mounted filesystems.

Options and arguments:  
  -d  <data_path>       - Data service directory path.
                          (Thin LV will be mounted on it)
  -v  <vg_name>         - Volume group name. (Default value)
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # List logical volume status
    sudo cs-lvmserv.sh -l

  # Create thin logical volume data service "/srv/gitlab-postgresql"
  # in default volume group.
    sudo cs-lvmserv.sh -m create -d /srv/gitlab-postgresql

  # Create snapshot of data service "/srv/gitlab-postgresql"
  # in default volume group.
  # Snapshot will be mounted read-only in /tmp/gitlab-postgresql_snap
    sudo cs-lvmserv.sh -m snap-create -d /srv/gitlab-postgresql

  # Remove snapshot of data service "/srv/gitlab-postgresql"
  # in default volume group
    sudo cs-lvmserv.sh -m snap-remove -d /srv/gitlab-postgresql

  # Merge snapshot of data service "/srv/gitlab-postgresql"
  # in default volume group
    sudo cs-lvmserv.sh -m snap-merge -d /srv/gitlab-postgresql

  # Delete thin logical volume data service "/srv/gitlab-postgresql"
  # in default volume group
    sudo cs-lvmserv.sh -m delete -d /srv/gitlab-postgresql

  # Free space inside thin-pools
    sudo cs-lvmserv.sh -m trim-space
```

**Tasks performed:**

| ${execution_mode} | Tasks                                  | Block / Description                                                                               |
| ----------------- | -------------------------------------- | ------------------------------------------------------------------------------------------------- |
| [create]          |                                        | **Create LVM data service**                                                                       |
|                   | Preserve original `/etc/fstab`         | File `/etc/fstab` is copied to `/etc/fstab.naked` if not exist.                                   |
|                   | Create thin logical volume             | Create thin logical volume in volume group exclusive for the data service.                        |
|                   |                                        | The whole thin pool volume size will be assigned for every thin LV data service.                  |
|                   | Create filesystem                      | Format the filesystem as specified in `command_to_format`data_path` option.                       |
|                   | Mount logical volume                   | Create directory and mount data service as specified in `data_path` option. (Typically /srv/xxx). |
|                   |                                        | If directory exists previously, the content will be copied to LVM before mount operation.         |
|                   | Update `/etc/fstab`                    | Add mount line to file `/etc/fstab` and mount all.                                                |
|                   | Set directory ownership                | Change ownership as specified by `user_owner` and `group_owner` variables.                        |
|                   |                                        | If directory exists previously, ownership will be preserved.                                      |
| [delete]          |                                        | **Delete LVM data service**                                                                       |
|                   | Unmount logical volume                 | If mounted, unmount logical volume from directory specified in `data_path` option.                |
|                   | Delete thin logical volume             | Delete thin logical volume from volume group.                                                     |
|                   | Update `/etc/fstab`                    | Remove mount line in file `/etc/fstab` .                                                          |
|                   | Delete service directory               | If empty, remove directory specified in `data_path` option.                                       |
| [snap-create]     |                                        | **Create snapshot**                                                                               |
|                   | Create snapshot                        | Create and activate thin snapshot.                                                                |
|                   | Mount snapshot                         | Mount snapshot read-only mode in directory `/mnt/<dataservice>_snap`.                             |
| [snap-remove]     |                                        | **Remove snapshot**                                                                               |
|                   | Unmount snapshot                       | If mounted, unmount snapshot from `/mnt/<dataservice>_snap`.                                      |
|                   | Remove snapshot                        | Delete thin snapshot from volume group.                                                           |
|                   | Delete snapshot directory              | If empty, remove `/mnt/<dataservice>_snap` directory                                              |
| [snap-merge]      |                                        | **Merge snapshot**                                                                                |
|                   | Merge Snapshot                         | Roll back logical volume to snapshot status.                                                      |
|                   |                                        | Merge will be delayed until next volume activation.                                               |
|                   | Unmount snapshot                       | If mounted, unmount snapshot from `/mnt/<dataservice>_snap`.                                      |
|                   | Unmount logical volume                 | If mounted, unmount logical volume from `data_path` (Typically /srv/xxx).                         |
|                   | Deactivate and activate logical volume | Reactivate logical volume to complete merge and remove snapshot.                                  |
|                   | Mount `/etc/fstab` volumes             | Mount all `/etc/fstab` volumes.                                                                   |
|                   | Delete snapshot directory              | If empty, remove `/mnt/<dataservice>_snap` .                                                      |
| [trim-space]      |                                        | **Trim filesystem**                                                                               |
|                   | Trim all filesystems                   | Discard unused blocks on all mounted filesystems (fstrim -a).                                     |
| [list-status]     |                                        | **Display LVM and filesystem status**                                                             |
| [ListStatus]      | List Status                            | List logical volumes and filesystems status.                                                      |

#### cs-rsync

> **Note:** Prior to operate rsync with a remote host, you must insert the root public key for ssh authentication and passwordless login as sudoer user in the remote host. From a console inside the machine you must run `sudo ssh-copy-id {{ .machine.localadminusername }}@hostname.domain.com`

```console
Purpose:
  RSync copies for LVM data services.
  Use this script to perform RSync operations with data services supported by
  thin-logical volumes created with the script "cs-lvmserv.sh".
  Snapshots will be created automatically for rsync-to copies 
  and removed when finished.

Usage:
  sudo cs-rsync.sh  [-m <execution_mode>] [-d <data_path>] [-v <vg_name>] 
                    [-r <remote_data_path>] [-t <hostname.domain.com>] [-h] [-q]

Execution modes:
  -m  <execution_mode>  - Valid modes are:

      [rsync-to]        - RSync data from local directory TO remote directory.
      [rsync-from]      - RSync data FROM remote directory to local directory.

Options and arguments:  
  -d  <data_path>           - Local data service directory path.
  -v  <vg_name>             - Volume group name. (Default value)
  -r  <remote_data_path>    - Remote directory path. (Default is same as local)
  -t  <hostname.domain.com> - Backup host (Default value)
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # RSync data service "/srv/gitlab-postgresql"
  # TO same remote directory at host "bckpoint.cskylab.com"
    sudo cs-rsync.sh -m rsync-to -d /srv/gitlab-postgresql \
    -t bckpoint.cskylab.com

  # RSync data service "/srv/gitlab-postgresql"
  # FROM remote directory "/srv/gitlab-postgresql" at host "bckpoint.cskylab.com"
    sudo cs-rsync.sh -m rsync-from -d /srv/gitlab-postgresql \
    -t bckpoint.cskylab.com
```

**Tasks performed:**

| ${execution_mode} | Tasks              | Block / Description                                                            |
| ----------------- | ------------------ | ------------------------------------------------------------------------------ |
| [rsync-to]        |                    | **RSync data TO remote directory**                                             |
|                   | Create Snapshot    | Create snapshot from data service LV and mount it in `/mnt/<dataservice>_snap` |
|                   | Execute rsync TO   | RSync data from snapshot TO directory specified in `remote_data_path` option.  |
|                   | Remove Snapshot    | Remove snapshot and mount directory when rsync has finished.                   |
| [rsync-from]      |                    | **RSync data FROM remote directory**                                           |
|                   | Execute rsync FROM | RSync data FROM directory specified in `remote_data_path` option.              |

#### cs-restic

```console
Purpose:
  Restic backup for LVM data services.
  Use this script to perform Restic operations with data services supported by
  thin-logical volumes created with the script "cs-lvmserv.sh".
  Snapshots will be created automatically for backups and removed when finished.

Usage:
  sudo cs-restic.sh [-m <execution_mode>] [-d <data_path>] [-v <vg_name>] [-t <tag_name>] 
                    [-r <RESTIC_REPOSITORY>] [-i <restic_snap_id>]
                    [-p <RESTIC_PASSWORD>] [-a <AWS_ACCESS_KEY_ID>]
                    [-k <AWS_SECRET_ACCESS_KEY>] [-f <forget_options>] [-h] [-q]

Execution modes:
  -m  <execution_mode>   - Valid modes are:
  
      [restic-bck]       - Backup to local or remote repository.
      [restic-list]      - List snapshots in repository.
      [restic-mount]     - Mount repository to /mnt directory.
      [restic-res]       - Restore from repository to directory data service.
                           (Directory must be empty).
      [repo-init]        - Initialize repository (Directory or bucket must exist).
      [restic-forget]    - Maintain repository and remove snapshots with forget option.

Options and arguments:  
  -d  <data_path>             - Local data service directory path. (Mandatory)
  -v  <vg_name>               - Volume group name. (Default value)
  -t  <tag_name>              - Tag name for the snapshot. (Default value)
  -r  <RESTIC_REPOSITORY>     - Restic repository (Default value)
  -i  <restic_snap_id>        - Snapshot ID to restore (Default latest)
  -p  <RESTIC_PASSWORD>       - Restic password (Default value)
  -a  <AWS_ACCESS_KEY_ID>     - S3 access key (Default value)
  -k  <AWS_SECRET_ACCESS_KEY> - S3 secret key (Default value)
  -f  <forget_options>        - Options to execute (Default value)
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Backup data service "/srv/gitlab-postgresql"
  # TO local repository "/srv/restic/gitlab-postgresql/" 
    sudo cs-restic.sh -m restic-bck -d /srv/gitlab-postgresql \
                                  -r "/srv/restic/gitlab-postgresql/"

  # Backup data service "/srv/gitlab-postgresql"
  # TO remote sftp repository "sftp:kos@backup.cskylab.com:/srv/restic/gitlab-postgresql/" 
    sudo cs-restic.sh -m restic-bck -d /srv/gitlab-postgresql \
                                  -r "sftp:kos@backup.cskylab.com:/srv/restic/gitlab-postgresql/"

  # Backup data service "/srv/gitlab-postgresql" tagged "gitlab-postgresql"
  # TO shared repository in MinIO bucket "s3:https://minio-standalone.cskylab.com/restic-test/" 
    sudo cs-restic.sh -m restic-bck -d /srv/gitlab-postgresql \
                                  -t gitlab-postgresql -r "s3:https://minio-standalone.cskylab.com/restic-test/"

  # List snapshots in repository "s3:https://minio-standalone.cskylab.com/restic-test/" 
    sudo cs-restic.sh -m restic-list -r "s3:https://minio-standalone.cskylab.com/restic-test/"

  # Restore data service "/srv/gitlab-postgresql"
  # FROM latest snapshot in repository "/srv/restic/gitlab-postgresql" 
    sudo cs-restic.sh -m restic-res -d /srv/gitlab-postgresql \
                                  -r "/srv/restic/gitlab-postgresql"

  # Create repository in directory "/srv/restic/gitlab-postgresql"
    sudo cs-restic.sh -m repo-init -r "/srv/restic/gitlab-postgresql"

  # Maintain repository "/srv/restic/gitlab-postgresql" applying host, tag and forget options
    sudo cs-restic.sh -m restic-forget -r "/srv/bck/gitlab-postgresql" \
              -t "gitlab-postgresql" -f "--keep-hourly 6 --keep-daily 31 --keep-weekly 5 --keep-monthly 13 --keep-yearly 10"

  # Mount repository "/srv/bck/gitlab-postgresql"   
  # in /mnt directory
    sudo cs-restic.sh -m restic-mount -r "s3:https://minio-standalone.cskylab.com/restic-test/"
```

**Tasks performed:**

| ${execution_mode}                          | Tasks                         | Block / Description                                                                                      |
| ------------------------------------------ | ----------------------------- | -------------------------------------------------------------------------------------------------------- |
| [restic-bck] [restic-res]                  |                               | **Set restic ssh config parameters**                                                                     |
|                                            | Prepare ssh config parameters | Generate file /root/.ssh/config with appropriate parameters for restic sftp connections.                 |
| [restic-bck]                               |                               | **Restic backup**                                                                                        |
|                                            | Create Snapshot               | Create snapshot from data service LV and mount it to `/mnt/<dataservice>_snap`                           |
|                                            | Execute Restic backup         | Backup data from snapshot to restic repository specified in `RESTIC_REPOSITORY` variable.                |
|                                            | Remove Snapshot               | Unmount and remove snapshot when Restic backup is finished.                                              |
| [restic-forget]                            |                               | **Restic repository maintenance**                                                                        |
|                                            | Maintain Restic repository    | Maintain Restic repository with policy defined in `forget_options` variable.                             |
| [restic-list] [restic-bck] [restic-forget] |                               | **Display snapshots in Restic repository**                                                               |
|                                            | List snapshots in repository  | List snapshots and display statistics for the repository.                                                |
| [restic-res]                               |                               | **Restic restore**                                                                                       |
|                                            | Execute Restic restore        | Restore data from snapshot to data service directory (must be empty) specified in `data_path` option.    |
| [repo-init]                                |                               | **Create Restic repository**                                                                             |
|                                            | Initialize Restic repository  | Initialize Restic repository in directory (Must be empty) specified in `RESTIC_REPOSITORY` variable.     |
| [restic-bck] [restic-forget] [repo-init]   |                               | **Change ownership of local restic repository**                                                          |
|                                            | Change repository ownership   | If `RESTIC_REPOSITORY` is a local directory, change ownership to local sudoer.                           |
| [restic-mount]                             |                               | **Restic repository maintenance**                                                                        |
|                                            | Mount Restic repository       | Mount Restic repository via FUSE in directory specified in `restic_mount_point` (Default `/tmp/restic`). |

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

| ${execution_mode}  | Tasks                                | Block / Description                                                                                    |
| ------------------ | ------------------------------------ | ------------------------------------------------------------------------------------------------------ |
| [net-config]       |                                      | **Network configuration**                                                                              |
|                    | Deploy /etc/hostname                 | Configuration file `hostname` must exist in setup directory.                                           |
|                    | Deploy /etc/hosts                    | Configuration file `hosts` must exist in setup directory.                                              |
|                    | Deploy /etc/netplan/01-netcfg.yaml   | Configuration file `01-netcfg.yaml` must exist in setup directory.                                     |
|                    | Disable cloud-init                   | Flag that signals that cloud-init should not run.                                                      |
|                    | Change systemd-resolved              | Change configuration of file `/etc/resolv.conf`.                                                       |
|                    | Try Netplan configuration            | Execute `netplan try` to test new network configuration.                                               |
|                    | Reboot                               | Reboot with confirmation message.                                                                      |
| [install]          |                                      | **Install and update packages**                                                                        |
|                    | Update installed packages            | Update package repositories, perform `dist-upgrade` and `autoremove`                                   |
|                    | Generate locales                     | Deploy file `locale.gen` if present in setup directory and execute `locale-gen`.                       |
|                    | Install chrony time sync             | Chrony time synchronization (https://chrony.tuxfamily.org)                                             |
|                    | Disable swap                         | Disable swap and update /etc/fstab                                                                     |
|                    | Install Docker CE                    | Install Docker CE according to kubernetes specs                                                        |
|                    |                                      | <https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker>                   |
|                    | Install kubeadm, kubelet and kubectl | Install needed tools for bootstraping the cluster with kubeadm                                         |
| [install] [config] |                                      | **Deploy config files and execute configuration tasks**                                                |
|                    | Set timezone                         | Set time zone from `time_zone` variable.                                                               |
|                    | Set locale                           | Set locale from `system_locale` variable.                                                              |
|                    | Set keyboard                         | Set keyboard layout from `system_keyboard` variable.                                                   |
|                    | Deploy sudoers file                  | Deploy sudoers configuration file `domadminsudo` (Must be present in setup directory).                 |
|                    | UFW firewall configuration           | UFW enabled with ssh allowed.                                                                          |
|                    | Change local passwords               | If file `kos-pass`is present in setup directory. (Template `tpl-kos-pass` provided).                   |
|                    | Deploy ssh authorized_keys           | If file `authorized_keys`is present in setup directory. (Template `tpl-authorized_keys` provided).     |
|                    | Deploy ssh id_rsa keys               | If files `id_rsa` and `id_rsa.pub` are present in setup directory. (Templates `tpl-id_rsa*` provided). |
|                    | Generate id_rsa                      | If doesn't exist for root and sudoer user.                                                             |
|                    | Deploy ca-certificates               | If files with name pattern `ca-*.crt` are present.                                                     |
|                    | Deploy machine certificate           | If files with name pattern `hostname.crt` and `hostname.key`are present.                               |
|                    | Deploy crontab files                 | If files with name pattern `cron-cs-*` are present in setup directory.                                 |
| [install]          |                                      | **Reboot after install**                                                                               |
|                    | Reboot                               | Reboot with confirmation message.                                                                      |

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
