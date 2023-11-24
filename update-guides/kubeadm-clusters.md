<!-- markdownlint-disable MD024 -->

# kubeadm-clusters <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v99-99-99 (k8s v1.28.x-00)](#v99-99-99-k8s-v128x-00)
  - [Prerequisites](#prerequisites)
    - [Containerd configuration (Not neccesary in Ubuntu 22.04)](#containerd-configuration-not-neccesary-in-ubuntu-2204)
    - [Change kubernetes package repository](#change-kubernetes-package-repository)
  - [k8s version 1.28.x-\*](#k8s-version-128x-)
  - [List available kubeadm versions](#list-available-kubeadm-versions)
  - [Upgrading k8s master node](#upgrading-k8s-master-node)
  - [Upgrading k8s worker nodes](#upgrading-k8s-worker-nodes)
    - [Drain the node](#drain-the-node)
    - [Upgrade the node](#upgrade-the-node)
    - [Uncordon the node](#uncordon-the-node)
  - [Upgrade mcc management station](#upgrade-mcc-management-station)
    - [Update mcc configuration](#update-mcc-configuration)
    - [Connect with mcc](#connect-with-mcc)
    - [Inject \& Deploy configuration to mcc](#inject--deploy-configuration-to-mcc)
- [v23-04-27b (k8s v1.27.1-00)](#v23-04-27b-k8s-v1271-00)
  - [Prerequisites (Not neccesary in Ubuntu 22.04)](#prerequisites-not-neccesary-in-ubuntu-2204)
  - [k8s version 1.27.1-00](#k8s-version-1271-00)
  - [List available kubeadm versions](#list-available-kubeadm-versions-1)
  - [Upgrading k8s master node](#upgrading-k8s-master-node-1)
  - [Upgrading k8s worker nodes](#upgrading-k8s-worker-nodes-1)
    - [Drain the node](#drain-the-node-1)
    - [Upgrade the node](#upgrade-the-node-1)
    - [Uncordon the node](#uncordon-the-node-1)
  - [Upgrade mcc management station](#upgrade-mcc-management-station-1)
    - [Update mcc configuration](#update-mcc-configuration-1)
    - [Connect with mcc](#connect-with-mcc-1)
    - [Inject \& Deploy configuration to mcc](#inject--deploy-configuration-to-mcc-1)
- [v23-04-27a (k8s v1.26.3-00)](#v23-04-27a-k8s-v1263-00)
  - [Prerequisites (Not neccesary in Ubuntu 22.04)](#prerequisites-not-neccesary-in-ubuntu-2204-1)
  - [k8s version 1.26.3-00](#k8s-version-1263-00)
  - [List available kubeadm versions](#list-available-kubeadm-versions-2)
  - [Upgrading k8s master node](#upgrading-k8s-master-node-2)
  - [Upgrading k8s worker nodes](#upgrading-k8s-worker-nodes-2)
    - [Drain the node](#drain-the-node-2)
    - [Upgrade the node](#upgrade-the-node-2)
    - [Uncordon the node](#uncordon-the-node-2)
  - [Upgrade mcc management station](#upgrade-mcc-management-station-2)
    - [Update mcc configuration](#update-mcc-configuration-2)
    - [Connect with mcc](#connect-with-mcc-2)
    - [Inject \& Deploy configuration to mcc](#inject--deploy-configuration-to-mcc-2)
- [v22-12-19](#v22-12-19)
  - [k8s version 1.25.5-00](#k8s-version-1255-00)
  - [List available kubeadm versions](#list-available-kubeadm-versions-3)
  - [Upgrading k8s master node](#upgrading-k8s-master-node-3)
  - [Upgrading k8s worker nodes](#upgrading-k8s-worker-nodes-3)
    - [Drain the node](#drain-the-node-3)
    - [Upgrade the node](#upgrade-the-node-3)
    - [Uncordon the node](#uncordon-the-node-3)
  - [Upgrade mcc management station](#upgrade-mcc-management-station-3)
    - [Update mcc configuration](#update-mcc-configuration-3)
    - [Connect with mcc](#connect-with-mcc-3)
    - [Inject \& Deploy configuration to mcc](#inject--deploy-configuration-to-mcc-3)
- [v22-08-21](#v22-08-21)
  - [k8s version 1.24.4-00](#k8s-version-1244-00)
  - [List available kubeadm versions](#list-available-kubeadm-versions-4)
  - [Upgrading k8s master node](#upgrading-k8s-master-node-4)
  - [Upgrading k8s worker nodes](#upgrading-k8s-worker-nodes-4)
    - [Drain the node](#drain-the-node-4)
    - [Upgrade the node](#upgrade-the-node-4)
    - [Uncordon the node](#uncordon-the-node-4)
  - [Upgrade mcc management station](#upgrade-mcc-management-station-4)
    - [Update mcc configuration](#update-mcc-configuration-4)
    - [Connect with mcc](#connect-with-mcc-4)
    - [Inject \& Deploy configuration to mcc](#inject--deploy-configuration-to-mcc-4)
- [v22-03-23](#v22-03-23)
  - [k8s version 1.23.5-00](#k8s-version-1235-00)
  - [List available kubeadm versions](#list-available-kubeadm-versions-5)
  - [Upgrading k8s master node](#upgrading-k8s-master-node-5)
  - [Upgrading k8s worker nodes](#upgrading-k8s-worker-nodes-5)
    - [Drain the node](#drain-the-node-5)
    - [Upgrade the node](#upgrade-the-node-5)
    - [Uncordon the node](#uncordon-the-node-5)
  - [Upgrade mcc management station](#upgrade-mcc-management-station-5)
    - [Update mcc configuration](#update-mcc-configuration-5)
    - [Connect with mcc](#connect-with-mcc-5)
    - [Inject \& Deploy configuration to mcc](#inject--deploy-configuration-to-mcc-5)
- [v22-01-05](#v22-01-05)
  - [k8s version 1.23.1-00](#k8s-version-1231-00)
  - [List available kubeadm versions](#list-available-kubeadm-versions-6)
  - [Upgrading k8s master node](#upgrading-k8s-master-node-6)
  - [Upgrading k8s worker nodes](#upgrading-k8s-worker-nodes-6)
    - [Drain the node](#drain-the-node-6)
    - [Upgrade the node](#upgrade-the-node-6)
    - [Uncordon the node](#uncordon-the-node-6)
  - [Upgrade mcc management station](#upgrade-mcc-management-station-6)
    - [Update mcc configuration](#update-mcc-configuration-6)
    - [Connect with mcc](#connect-with-mcc-6)
    - [Inject \& Deploy configuration to mcc](#inject--deploy-configuration-to-mcc-6)

---

## v99-99-99 (k8s v1.28.x-00)

### Prerequisites 

#### Containerd configuration (Not neccesary in Ubuntu 22.04)

- Check file `kubeadm-config.yaml` and deploy it with this api configuration:

```yaml
# kubeadm-config.yaml
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
kubernetesVersion: stable
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd
```

- Remove from configuration files `config.toml` and deploy a new one inside the node running the following commands:

```bash
  # Generate containterd default configuration
  sudo containerd config default >/etc/containerd/config.toml

  # Update /etc/containerd/config.toml
  sudo sed -i "s/SystemdCgroup = false/SystemdCgroup = true/g" /etc/containerd/config.toml

  # Restart containerd
  sudo systemctl restart containerd
```

#### Change kubernetes package repository

>**Important from September 13, 2023!**: The new kubernetes package repository must be introduced in all nodes (master & workers):

```bash
sudo echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

### k8s version 1.28.x-*

This page explains how to upgrade a Kubernetes cluster created with kubeadm from version 1.27.x to version 1.28.x, and from version 1.28.x to 1.28.y (where y > x). Skipping MINOR versions when upgrading is unsupported.

The complete procedures to upgrade kubeadm kubernetes clusters are covered in: <https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade>

### List available kubeadm versions

To view all available kubeadm versions:

```bash
# Find the latest 1.28 version in the list.
# It should look like 1.28.x-*, where x is the latest patch.
sudo apt update && sudo apt-cache madison kubeadm
```

### Upgrading k8s master node

Connect to k8s master machine and follow the next steps:

- Upgrade kubeadm:

```bash
# Kubeadm upgrade
sudo apt-mark unhold kubeadm \
  && sudo apt-get update \
  && sudo apt-get install -y kubeadm=1.28.x-* \
  && sudo apt-mark hold kubeadm \
  && sudo apt-mark showhold
```

- Verify kubeadm version:

```bash
# Verify kubeadm version
sudo kubeadm version
```

- Verify upgrade plan:

```bash
# Verify upgrade plan
sudo kubeadm upgrade plan
```

>**Note**: kubeadm upgrade also automatically renews the certificates that it manages on this node.

- To apply k8s master upgrade:

```bash
# replace x with the patch version you picked for this upgrade
sudo kubeadm upgrade apply v1.28.x
```

- Once the command finishes you should see:

```bash
[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.28.x". Enjoy!
```

Upgrade Weave Net CNI provider:

```bash
# Update Weave Net
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```

- Upgrade kubelet and kubectl:

```bash
# Upgrade kubelet and kubectl
# replace x in 1.28.x-* with the latest patch version
sudo apt-mark unhold kubelet kubectl \
  && sudo apt-get update \
  && sudo apt-get install -y kubelet=1.28.x-* kubectl=1.28.x-* \
  && sudo apt-mark hold kubelet kubectl \
  && sudo apt-mark showhold
```

- Restart the kubelet:

```bash
# Restart the kubelet
sudo systemctl daemon-reload && sudo systemctl restart kubelet
```

- If needed, upgrade other packages and reboot:

```bash
# Distribution upgrade
sudo apt-get update \
  && sudo apt-get dist-upgrade -y \
  && sudo apt-get autoremove -y
```

- Reboot the master node:

```bash
# Reboot master node
sudo reboot
```

### Upgrading k8s worker nodes

#### Drain the node

If necessary, prepare the node for maintenance by marking it unschedulable and evicting the workloads. From computer management machine run:

```bash
# replace <node-to-drain> with the name of your node you are draining
kubectl drain <node-to-drain> --ignore-daemonsets --delete-emptydir-data --disable-eviction --force
```

#### Upgrade the node

Connect to k8s worker node machine and follow the next steps:

- Install kubeadm upgrade:

```bash
# Kubeadm upgrade
sudo apt-mark unhold kubeadm \
  && sudo apt-get update \
  && sudo apt-get install -y kubeadm=1.28.x-* \
  && sudo apt-mark hold kubeadm \
  && sudo apt-mark showhold
```

- Verify kubeadm version:

```bash
# Verify kubeadm version
sudo kubeadm version
```

- To apply k8s worker node upgrade:

```bash
# Apply upgrade
sudo kubeadm upgrade node
```

- Once the command finishes you should see:

```bash
[upgrade] The configuration for this node was successfully updated!
```

- Upgrade kubelet and kubectl:

```bash
# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl \
  && sudo apt-get update \
  && sudo apt-get install -y kubelet=1.28.x-* kubectl=1.28.x-* \
  && sudo apt-mark hold kubelet kubectl \
  && sudo apt-mark showhold
```

- Restart the kubelet:

```bash
# Restart the kubelet
sudo systemctl daemon-reload && sudo systemctl restart kubelet
```

- If needed, upgrade other packages and reboot:

```bash
# Distribution upgrade
sudo apt-get update \
  && sudo apt-get dist-upgrade -y \
  && sudo apt-get autoremove -y
```

- Reboot the node:

```bash
# Reboot node
sudo reboot
```

#### Uncordon the node

Bring the node back online by marking it schedulable. From computer management machine run:

```bash
# replace <node-to-uncordon> with the name of the node
kubectl uncordon <node-to-uncordon>
```

Verify the cluster status:

```bash
# Verify node status and version number
kubectl get nodes
```

### Upgrade mcc management station

#### Update mcc configuration

>**Note:** You must have pre-deployed in your computer your ssh keys.

- Open your **cSkLab installation locally cloned repository** and sychronize changes with remote
- Open console in **cs-sys -> mcc** folder
- Edit `cs-deploy.sh` script deployment file, and change values for variables **k8s_version** and **go_version** in the following way:

```bash
# Kubernetes version for kubectl
k8s_version="1.28.x-*"

# Go version
go_version="go1.21.3.linux-amd64.tar.gz"
```

- Save the file, commit changes and synchronize repository with remote

#### Connect with mcc

- Connect to your cSkyLab installation in one of the following ways:
  - **VPN**: Establish vpn session with `vpn_mgt` profile
  - **Local**: Connect to physical `sys` network in your `kvm-main/aux` machines

- Check conectivity with `mcc`:
  
```bash
# mcc connectivity
dig mcc.cskylab.net
ping mcc.cskylab.net
```

- Edit your `.ssh/config` and add the check for the following configuration lines to disable HostKeyChecking for `mcc` (if not previously done):

```bash
# Disable HostKeyChecking for mcc
Host mcc.cskylab.net
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
```

>**Note:** Delete records for mcc.cskylab.net & 192.168.80.5 in your `$HOME/.ssh/known_hosts` file if needed.

#### Inject & Deploy configuration to mcc

- Perform installation procedure:

```bash
# Run csinject.sh in [ssh-sudoers] execution mode (if not previously executed)
./csinject.sh -k


# Run csinject.sh to inject & deploy configuration in [install] deploy mode
./csinject.sh -qdm install
```

---

## v23-04-27b (k8s v1.27.1-00)

### Prerequisites (Not neccesary in Ubuntu 22.04)

- Check file `kubeadm-config.yaml` and deploy it with this api configuration:

```yaml
# kubeadm-config.yaml
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
kubernetesVersion: stable
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd
```

- Remove from configuration files `config.toml` and deploy a new one inside the node running the following commands:

```bash
  # Generate containterd default configuration
  sudo containerd config default >/etc/containerd/config.toml

  # Update /etc/containerd/config.toml
  sudo sed -i "s/SystemdCgroup = false/SystemdCgroup = true/g" /etc/containerd/config.toml

  # Restart containerd
  sudo systemctl restart containerd
```

### k8s version 1.27.1-00

This page explains how to upgrade a Kubernetes cluster created with kubeadm from version 1.26.x to version 1.27.x, and from version 1.27.x to 1.27.y (where y > x). Skipping MINOR versions when upgrading is unsupported.

The complete procedures to upgrade kubeadm kubernetes clusters are covered in: <https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade>

### List available kubeadm versions

To view all available kubeadm versions:

```bash
# List available kubeadm versions
sudo apt update && sudo apt-cache madison kubeadm
```

### Upgrading k8s master node

Connect to k8s master machine and follow the next steps:

- Upgrade kubeadm:

```bash
# Kubeadm upgrade
sudo apt-mark unhold kubeadm \
  && sudo apt-get update \
  && sudo apt-get install -y kubeadm=1.27.1-00 \
  && sudo apt-mark hold kubeadm \
  && sudo apt-mark showhold
```

- Verify kubeadm version:

```bash
# Verify kubeadm version
sudo kubeadm version
```

- Verify upgrade plan:

```bash
# Verify upgrade plan
sudo kubeadm upgrade plan
```

- To apply k8s master upgrade:

```bash
# Apply upgrade
sudo kubeadm upgrade apply v1.27.1
```

- Once the command finishes you should see:

```bash
[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.27.1". Enjoy!
```

Upgrade Weave Net CNI provider:

```bash
# Update Weave Net
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```

- Upgrade kubelet and kubectl:

```bash
# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl \
  && sudo apt-get update \
  && sudo apt-get install -y kubelet=1.27.1-00 kubectl=1.27.1-00 \
  && sudo apt-mark hold kubelet kubectl \
  && sudo apt-mark showhold
```

- Restart the kubelet:

```bash
# Restart the kubelet
sudo systemctl daemon-reload && sudo systemctl restart kubelet
```

- If needed, upgrade other packages and reboot:

```bash
# Distribution upgrade
sudo apt-get update \
  && sudo apt-get dist-upgrade -y \
  && sudo apt-get autoremove -y
```

- Update containerd configuration

```bash
sudo -i
# Generate containterd default configuration
containerd config default >/etc/containerd/config.toml

# Update /etc/containerd/config.toml
sed -i "s/SystemdCgroup = false/SystemdCgroup = true/g" /etc/containerd/config.toml

# Restart containerd
systemctl restart containerd
```

- Reboot the master node:

```bash
# Reboot master node
sudo reboot
```

### Upgrading k8s worker nodes

#### Drain the node

Prepare the node for maintenance by marking it unschedulable and evicting the workloads. From computer management machine run:

```bash
# replace <node-to-drain> with the name of your node you are draining
kubectl drain <node-to-drain> --ignore-daemonsets --delete-emptydir-data --disable-eviction --force
```

#### Upgrade the node

Connect to k8s worker node machine and follow the next steps:

- Install kubeadm upgrade:

```bash
# Kubeadm upgrade
sudo apt-mark unhold kubeadm \
  && sudo apt-get update \
  && sudo apt-get install -y kubeadm=1.27.1-00 \
  && sudo apt-mark hold kubeadm \
  && sudo apt-mark showhold
```

- Verify kubeadm version:

```bash
# Verify kubeadm version
sudo kubeadm version
```

- To apply k8s worker node upgrade:

```bash
# Apply upgrade
sudo kubeadm upgrade node
```

- Once the command finishes you should see:

```bash
[upgrade] The configuration for this node was successfully updated!
```

- Upgrade kubelet and kubectl:

```bash
# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl \
  && sudo apt-get update \
  && sudo apt-get install -y kubelet=1.27.1-00 kubectl=1.27.1-00 \
  && sudo apt-mark hold kubelet kubectl \
  && sudo apt-mark showhold
```

- Restart the kubelet:

```bash
# Restart the kubelet
sudo systemctl daemon-reload && sudo systemctl restart kubelet
```

- If needed, upgrade other packages and reboot:

```bash
# Distribution upgrade
sudo apt-get update \
  && sudo apt-get dist-upgrade -y \
  && sudo apt-get autoremove -y
```

- Update containerd configuration

```bash
sudo -i

# Generate & update containterd default configuration
containerd config default >/etc/containerd/config.toml \
  && sed -i "s/SystemdCgroup = false/SystemdCgroup = true/g" /etc/containerd/config.toml \
  && systemctl restart containerd
```

- Reboot the node:

```bash
# Reboot node
sudo reboot
```

#### Uncordon the node

Bring the node back online by marking it schedulable. From computer management machine run:

```bash
# replace <node-to-uncordon> with the name of the node
kubectl uncordon <node-to-uncordon>
```

Verify the cluster status:

```bash
# Verify node status and version number
kubectl get nodes
```

### Upgrade mcc management station

#### Update mcc configuration

>**Note:** You must have pre-deployed in your computer your ssh keys.

- Open your **cSkLab installation locally cloned repository** and sychronize changes with remote
- Open console in **cs-sys -> mcc** folder
- Edit `cs-deploy.sh` script deployment file, and change values for variables **k8s_version** and **go_version** in the following way:

```bash
# Kubernetes version for kubectl
k8s_version="1.27.1-00"

# Go version
go_version="go1.20.3.linux-amd64.tar.gz"
```

- Save the file, commit changes and synchronize repository with remote

#### Connect with mcc

- Connect to your cSkyLab installation in one of the following ways:
  - **VPN**: Establish vpn session with `vpn_mgt` profile
  - **Local**: Connect to physical `sys` network in your `kvm-main/aux` machines

- Check conectivity with `mcc`:
  
```bash
# mcc connectivity
dig mcc.cskylab.net
ping mcc.cskylab.net
```

- Edit your `.ssh/config` and add the check for the following configuration lines to disable HostKeyChecking for `mcc` (if not previously done):

```bash
# Disable HostKeyChecking for mcc
Host mcc.cskylab.net
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
```

>**Note:** Delete records for mcc.cskylab.net & 192.168.80.5 in your `$HOME/.ssh/known_hosts` file if needed.

#### Inject & Deploy configuration to mcc

- Perform installation procedure:

```bash
# Run csinject.sh in [ssh-sudoers] execution mode (if not previously executed)
./csinject.sh -k


# Run csinject.sh to inject & deploy configuration in [install] deploy mode
./csinject.sh -qdm install
```

---

## v23-04-27a (k8s v1.26.3-00)

### Prerequisites (Not neccesary in Ubuntu 22.04)

- Check file `kubeadm-config.yaml` and deploy it with this api configuration:

```yaml
# kubeadm-config.yaml
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
kubernetesVersion: stable
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd
```

- Remove from configuration files `config.toml` and deploy a new one inside the node running the following commands:

```bash
  # Generate containterd default configuration
  sudo containerd config default >/etc/containerd/config.toml

  # Update /etc/containerd/config.toml
  sudo sed -i "s/SystemdCgroup = false/SystemdCgroup = true/g" /etc/containerd/config.toml

  # Restart containerd
  sudo systemctl restart containerd
```

### k8s version 1.26.3-00

This page explains how to upgrade a Kubernetes cluster created with kubeadm from version 1.25.x to version 1.26.x, and from version 1.26.x to 1.26.y (where y > x). Skipping MINOR versions when upgrading is unsupported.

The complete procedures to upgrade kubeadm kubernetes clusters are covered in: <https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade>

### List available kubeadm versions

To view all available kubeadm versions:

```bash
# List available kubeadm versions
sudo apt update && sudo apt-cache madison kubeadm
```

### Upgrading k8s master node

Connect to k8s master machine and follow the next steps:

- Upgrade kubeadm:

```bash
# Kubeadm upgrade
sudo apt-mark unhold kubeadm \
  && sudo apt-get update \
  && sudo apt-get install -y kubeadm=1.26.3-00 \
  && sudo apt-mark hold kubeadm \
  && sudo apt-mark showhold
```

- Verify kubeadm version:

```bash
# Verify kubeadm version
sudo kubeadm version
```

- Verify upgrade plan:

```bash
# Verify upgrade plan
sudo kubeadm upgrade plan
```

- To apply k8s master upgrade:

```bash
# Apply upgrade
sudo kubeadm upgrade apply v1.26.3
```

- Once the command finishes you should see:

```bash
[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.26.3". Enjoy!
```

Upgrade Weave Net CNI provider:

```bash
# Update Weave Net
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```

- Upgrade kubelet and kubectl:

```bash
# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl \
  && sudo apt-get update \
  && sudo apt-get install -y kubelet=1.26.3-00 kubectl=1.26.3-00 \
  && sudo apt-mark hold kubelet kubectl \
  && sudo apt-mark showhold
```

- Restart the kubelet:

```bash
# Restart the kubelet
sudo systemctl daemon-reload && sudo systemctl restart kubelet
```

- If needed, upgrade other packages and reboot:

```bash
# Distribution upgrade
sudo apt-get update \
  && sudo apt-get dist-upgrade -y \
  && sudo apt-get autoremove -y
```

- To reboot the master node:

```bash
# Reboot master node
sudo reboot
```

### Upgrading k8s worker nodes

#### Drain the node

Prepare the node for maintenance by marking it unschedulable and evicting the workloads. From computer management machine run:

```bash
# replace <node-to-drain> with the name of your node you are draining
kubectl drain <node-to-drain> --ignore-daemonsets --delete-emptydir-data --disable-eviction --force
```

#### Upgrade the node

Connect to k8s worker node machine and follow the next steps:

- Install kubeadm upgrade:

```bash
# Kubeadm upgrade
sudo apt-mark unhold kubeadm \
  && sudo apt-get update \
  && sudo apt-get install -y kubeadm=1.26.3-00 \
  && sudo apt-mark hold kubeadm \
  && sudo apt-mark showhold
```

- Verify kubeadm version:

```bash
# Verify kubeadm version
sudo kubeadm version
```

- To apply k8s worker node upgrade:

```bash
# Apply upgrade
sudo kubeadm upgrade node
```

- Once the command finishes you should see:

```bash
[upgrade] The configuration for this node was successfully updated!
```

- Upgrade kubelet and kubectl:

```bash
# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl \
  && sudo apt-get update \
  && sudo apt-get install -y kubelet=1.26.3-00 kubectl=1.26.3-00 \
  && sudo apt-mark hold kubelet kubectl \
  && sudo apt-mark showhold
```

- Restart the kubelet:

```bash
# Restart the kubelet
sudo systemctl daemon-reload && sudo systemctl restart kubelet
```

- If needed, upgrade other packages and reboot:

```bash
# Distribution upgrade
sudo apt-get update \
  && sudo apt-get dist-upgrade -y \
  && sudo apt-get autoremove -y
```

- To reboot the node:

```bash
# Reboot node
sudo reboot
```

#### Uncordon the node

Bring the node back online by marking it schedulable. From computer management machine run:

```bash
# replace <node-to-uncordon> with the name of the node
kubectl uncordon <node-to-uncordon>
```

Verify the cluster status:

```bash
# Verify node status and version number
kubectl get nodes
```

### Upgrade mcc management station

#### Update mcc configuration

>**Note:** You must have pre-deployed in your computer your ssh keys.

- Open your **cSkLab installation locally cloned repository** and sychronize changes with remote
- Open console in **cs-sys -> mcc** folder
- Edit `cs-deploy.sh` script deployment file, and change values for variables **k8s_version** and **go_version** in the following way:

```bash
# Kubernetes version for kubectl
k8s_version="1.26.3-00"

# Go version
go_version="go1.19.4.linux-amd64.tar.gz"
```

- Save the file, commit changes and synchronize repository with remote

#### Connect with mcc

- Connect to your cSkyLab installation in one of the following ways:
  - **VPN**: Establish vpn session with `vpn_mgt` profile
  - **Local**: Connect to physical `sys` network in your `kvm-main/aux` machines

- Check conectivity with `mcc`:
  
```bash
# mcc connectivity
dig mcc.cskylab.net
ping mcc.cskylab.net
```

- Edit your `.ssh/config` and add the check for the following configuration lines to disable HostKeyChecking for `mcc` (if not previously done):

```bash
# Disable HostKeyChecking for mcc
Host mcc.cskylab.net
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
```

>**Note:** Delete records for mcc.cskylab.net & 192.168.80.5 in your `$HOME/.ssh/known_hosts` file if needed.

#### Inject & Deploy configuration to mcc

- Perform installation procedure:

```bash
# Run csinject.sh in [ssh-sudoers] execution mode (if not previously executed)
./csinject.sh -k


# Run csinject.sh to inject & deploy configuration in [install] deploy mode
./csinject.sh -qdm install
```

---



## v22-12-19

### k8s version 1.25.5-00

This page explains how to upgrade a Kubernetes cluster created with kubeadm from version 1.24.x to version 1.25.x, and from version 1.25.x to 1.25.y (where y > x). Skipping MINOR versions when upgrading is unsupported.

The complete procedures to upgrade kubeadm kubernetes clusters are covered in: <https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade>

### List available kubeadm versions

To view all available kubeadm versions:

```bash
# List available kubeadm versions
sudo apt update && sudo apt-cache madison kubeadm
```

### Upgrading k8s master node

Connect to k8s master machine and follow the next steps:

- Upgrade kubeadm:

```bash
# Kubeadm upgrade
sudo apt-mark unhold kubeadm \
  && sudo apt-get update \
  && sudo apt-get install -y kubeadm=1.25.5-00 \
  && sudo apt-mark hold kubeadm \
  && sudo apt-mark showhold
```

- Verify kubeadm version:

```bash
# Verify kubeadm version
sudo kubeadm version
```

- Verify upgrade plan:

```bash
# Verify upgrade plan
sudo kubeadm upgrade plan
```

- To apply k8s master upgrade:

```bash
# Apply upgrade
sudo kubeadm upgrade apply v1.25.5
```

- Once the command finishes you should see:

```bash
[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.25.5". Enjoy!
```

Upgrade Weave Net CNI provider:

```bash
# Update Weave Net
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```

- Upgrade kubelet and kubectl:

```bash
# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl \
  && sudo apt-get update \
  && sudo apt-get install -y kubelet=1.25.5-00 kubectl=1.25.5-00 \
  && sudo apt-mark hold kubelet kubectl \
  && sudo apt-mark showhold
```

- Restart the kubelet:

```bash
# Restart the kubelet
sudo systemctl daemon-reload && sudo systemctl restart kubelet
```

- If needed, upgrade other packages and reboot:

```bash
# Distribution upgrade
sudo apt-get update \
  && sudo apt-get dist-upgrade -y \
  && sudo apt-get autoremove -y
```

- To reboot the master node:

```bash
# Reboot master node
sudo reboot
```

### Upgrading k8s worker nodes

#### Drain the node

Prepare the node for maintenance by marking it unschedulable and evicting the workloads. From computer management machine run:

```bash
# replace <node-to-drain> with the name of your node you are draining
kubectl drain <node-to-drain> --ignore-daemonsets --delete-emptydir-data --disable-eviction --force
```

#### Upgrade the node

Connect to k8s worker node machine and follow the next steps:

- Install kubeadm upgrade:

```bash
# Kubeadm upgrade
sudo apt-mark unhold kubeadm \
  && sudo apt-get update \
  && sudo apt-get install -y kubeadm=1.25.5-00 \
  && sudo apt-mark hold kubeadm \
  && sudo apt-mark showhold
```

- Verify kubeadm version:

```bash
# Verify kubeadm version
sudo kubeadm version
```

- To apply k8s worker node upgrade:

```bash
# Apply upgrade
sudo kubeadm upgrade node
```

- Once the command finishes you should see:

```bash
[upgrade] The configuration for this node was successfully updated!
```

- Upgrade kubelet and kubectl:

```bash
# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl \
  && sudo apt-get update \
  && sudo apt-get install -y kubelet=1.25.5-00 kubectl=1.25.5-00 \
  && sudo apt-mark hold kubelet kubectl \
  && sudo apt-mark showhold
```

- Restart the kubelet:

```bash
# Restart the kubelet
sudo systemctl daemon-reload && sudo systemctl restart kubelet
```

- If needed, upgrade other packages and reboot:

```bash
# Distribution upgrade
sudo apt-get update \
  && sudo apt-get dist-upgrade -y \
  && sudo apt-get autoremove -y
```

- To reboot the node:

```bash
# Reboot node
sudo reboot
```

#### Uncordon the node

Bring the node back online by marking it schedulable. From computer management machine run:

```bash
# replace <node-to-uncordon> with the name of the node
kubectl uncordon <node-to-uncordon>
```

Verify the cluster status:

```bash
# Verify node status and version number
kubectl get nodes
```

### Upgrade mcc management station

#### Update mcc configuration

>**Note:** You must have pre-deployed in your computer your ssh keys.

- Open your **cSkLab installation locally cloned repository** and sychronize changes with remote
- Open console in **cs-sys -> mcc** folder
- Edit `cs-deploy.sh` script deployment file, and change values for variables **k8s_version** and **go_version** in the following way:

```bash
# Kubernetes version for kubectl
k8s_version="1.25.5-00"

# Go version
go_version="go1.19.4.linux-amd64.tar.gz"
```

- Save the file, commit changes and synchronize repository with remote

#### Connect with mcc

- Connect to your cSkyLab installation in one of the following ways:
  - **VPN**: Establish vpn session with `vpn_mgt` profile
  - **Local**: Connect to physical `sys` network in your `kvm-main/aux` machines

- Check conectivity with `mcc`:
  
```bash
# mcc connectivity
dig mcc.cskylab.net
ping mcc.cskylab.net
```

- Edit your `.ssh/config` and add the check for the following configuration lines to disable HostKeyChecking for `mcc` (if not previously done):

```bash
# Disable HostKeyChecking for mcc
Host mcc.cskylab.net
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
```

>**Note:** Delete records for mcc.cskylab.net & 192.168.80.5 in your `$HOME/.ssh/known_hosts` file if needed.

#### Inject & Deploy configuration to mcc

- Perform installation procedure:

```bash
# Run csinject.sh in [ssh-sudoers] execution mode (if not previously executed)
./csinject.sh -k


# Run csinject.sh to inject & deploy configuration in [install] deploy mode
./csinject.sh -qdm install
```

---

## v22-08-21

### k8s version 1.24.4-00

This page explains how to upgrade a Kubernetes cluster created with kubeadm from version 1.22.x to version 1.23.x, and from version 1.23.x to 1.23.y (where y > x). Skipping MINOR versions when upgrading is unsupported.

The complete procedures to upgrade kubeadm kubernetes clusters are covered in: <https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade>

### List available kubeadm versions

To view all available kubeadm versions:

```bash
# List available kubeadm versions
sudo apt update && sudo apt-cache madison kubeadm
```

### Upgrading k8s master node

Connect to k8s master machine and follow the next steps:

- Upgrade kubeadm:

```bash
# Kubeadm upgrade
sudo apt-mark unhold kubeadm \
  && sudo apt-get update \
  && sudo apt-get install -y kubeadm=1.24.4-00 \
  && sudo apt-mark hold kubeadm \
  && sudo apt-mark showhold
```

- Verify kubeadm version:

```bash
# Verify kubeadm version
sudo kubeadm version
```

- Verify upgrade plan:

```bash
# Verify upgrade plan
sudo kubeadm upgrade plan
```

- To apply k8s master upgrade:

```bash
# Apply upgrade
sudo kubeadm upgrade apply v1.24.4
```

- Once the command finishes you should see:

```bash
[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.24.4". Enjoy!
```

Upgrade Weave Net CNI provider:

```bash
# Update Weave Net
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.NO_MASQ_LOCAL=1"
```

>**Note**: Environment variable **NO_MASQ_LOCAL=1** explanations can be found at: <https://metallb.universe.tf/configuration/weave/> and <https://www.weave.works/docs/net/latest/kubernetes/kube-addon/#configuration-options>

- Upgrade kubelet and kubectl:

```bash
# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl \
  && sudo apt-get update \
  && sudo apt-get install -y kubelet=1.24.4-00 kubectl=1.24.4-00 \
  && sudo apt-mark hold kubelet kubectl \
  && sudo apt-mark showhold
```

- Restart the kubelet:

```bash
# Restart the kubelet
sudo systemctl daemon-reload && sudo systemctl restart kubelet
```

- If needed, upgrade other packages and reboot:

```bash
# Distribution upgrade
sudo apt-get update \
  && sudo apt-get dist-upgrade -y \
  && sudo apt-get autoremove -y
```

- To reboot the master node:

```bash
# Reboot master node
sudo reboot
```

### Upgrading k8s worker nodes

#### Drain the node

Prepare the node for maintenance by marking it unschedulable and evicting the workloads. From computer management machine run:

```bash
# replace <node-to-drain> with the name of your node you are draining
kubectl drain <node-to-drain> --ignore-daemonsets --delete-emptydir-data --disable-eviction --force
```

#### Upgrade the node

Connect to k8s worker node machine and follow the next steps:

- Install kubeadm upgrade:

```bash
# Kubeadm upgrade
sudo apt-mark unhold kubeadm \
  && sudo apt-get update \
  && sudo apt-get install -y kubeadm=1.24.4-00 \
  && sudo apt-mark hold kubeadm \
  && sudo apt-mark showhold
```

- Verify kubeadm version:

```bash
# Verify kubeadm version
sudo kubeadm version
```

- To apply k8s worker node upgrade:

```bash
# Apply upgrade
sudo kubeadm upgrade node
```

- Once the command finishes you should see:

```bash
[upgrade] The configuration for this node was successfully updated!
```

- Upgrade kubelet and kubectl:

```bash
# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl \
  && sudo apt-get update \
  && sudo apt-get install -y kubelet=1.24.4-00 kubectl=1.24.4-00 \
  && sudo apt-mark hold kubelet kubectl \
  && sudo apt-mark showhold
```

- Restart the kubelet:

```bash
# Restart the kubelet
sudo systemctl daemon-reload && sudo systemctl restart kubelet
```

- If needed, upgrade other packages and reboot:

```bash
# Distribution upgrade
sudo apt-get update \
  && sudo apt-get dist-upgrade -y \
  && sudo apt-get autoremove -y
```

- To reboot the node:

```bash
# Reboot node
sudo reboot
```

#### Uncordon the node

Bring the node back online by marking it schedulable. From computer management machine run:

```bash
# replace <node-to-uncordon> with the name of the node
kubectl uncordon <node-to-uncordon>
```

Verify the cluster status:

```bash
# Verify node status and version number
kubectl get nodes
```

### Upgrade mcc management station

#### Update mcc configuration

>**Note:** You must have pre-deployed in your computer your ssh keys.

- Open your **cSkLab installation locally cloned repository** and sychronize changes with remote
- Open console in **cs-sys -> mcc** folder
- Edit `cs-deploy.sh` script deployment file, and change values for variables **k8s_version** and **go_version** in the following way:

```bash
# Kubernetes version for kubectl
k8s_version="1.24.4-00"

# Go version
go_version="go1.19.linux-amd64.tar.gz"
```

- Save the file, commit changes and synchronize repository with remote

#### Connect with mcc

- Connect to your cSkyLab installation in one of the following ways:
  - **VPN**: Establish vpn session with `vpn_mgt` profile
  - **Local**: Connect to physical `sys` network in your `kvm-main/aux` machines

- Check conectivity with `mcc`:
  
```bash
# mcc connectivity
dig mcc.cskylab.net
ping mcc.cskylab.net
```

- Edit your `.ssh/config` and add the check for the following configuration lines to disable HostKeyChecking for `mcc` (if not previously done):

```bash
# Disable HostKeyChecking for mcc
Host mcc.cskylab.net
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
```

>**Note:** Delete records for mcc.cskylab.net & 192.168.80.5 in your `$HOME/.ssh/known_hosts` file if needed.

#### Inject & Deploy configuration to mcc

- Perform installation procedure:

```bash
# Run csinject.sh in [ssh-sudoers] execution mode (if not previously executed)
./csinject.sh -k


# Run csinject.sh to inject & deploy configuration in [install] deploy mode
./csinject.sh -qdm install
```

---

## v22-03-23

### k8s version 1.23.5-00

This page explains how to upgrade a Kubernetes cluster created with kubeadm from version 1.22.x to version 1.23.x, and from version 1.23.x to 1.23.y (where y > x). Skipping MINOR versions when upgrading is unsupported.

The complete procedures to upgrade kubeadm kubernetes clusters are covered in: <https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade>

### List available kubeadm versions

To view all available kubeadm versions:

```bash
# List available kubeadm versions
sudo apt update && sudo apt-cache madison kubeadm
```

### Upgrading k8s master node

Connect to k8s master machine and follow the next steps:

- Upgrade kubeadm:

```bash
# Kubeadm upgrade
sudo apt-mark unhold kubeadm \
  && sudo apt-get update \
  && sudo apt-get install -y kubeadm=1.23.5-00 \
  && sudo apt-mark hold kubeadm \
  && sudo apt-mark showhold
```

- Verify kubeadm version:

```bash
# Verify kubeadm version
sudo kubeadm version
```

- Verify upgrade plan:

```bash
# Verify upgrade plan
sudo kubeadm upgrade plan
```

- To apply k8s master upgrade:

```bash
# Apply upgrade
sudo kubeadm upgrade apply v1.23.5
```

- Once the command finishes you should see:

```bash
[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.23.5". Enjoy!
```

Upgrade Weave Net CNI provider:

```bash
# Update Weave Net
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.NO_MASQ_LOCAL=1"
```

>**Note**: Environment variable **NO_MASQ_LOCAL=1** explanations can be found at: <https://metallb.universe.tf/configuration/weave/> and <https://www.weave.works/docs/net/latest/kubernetes/kube-addon/#configuration-options>

- Upgrade kubelet and kubectl:

```bash
# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl \
  && sudo apt-get update \
  && sudo apt-get install -y kubelet=1.23.5-00 kubectl=1.23.5-00 \
  && sudo apt-mark hold kubelet kubectl \
  && sudo apt-mark showhold
```

- Restart the kubelet:

```bash
# Restart the kubelet
sudo systemctl daemon-reload && sudo systemctl restart kubelet
```

- If needed, upgrade other packages and reboot:

```bash
# Distribution upgrade
sudo apt-get update \
  && sudo apt-get dist-upgrade -y \
  && sudo apt-get autoremove -y
```

- To reboot the master node:

```bash
# Reboot master node
sudo reboot
```

### Upgrading k8s worker nodes

#### Drain the node

Prepare the node for maintenance by marking it unschedulable and evicting the workloads. From computer management machine run:

```bash
# replace <node-to-drain> with the name of your node you are draining
kubectl drain <node-to-drain> --ignore-daemonsets --delete-emptydir-data --disable-eviction --force
```

#### Upgrade the node

Connect to k8s worker node machine and follow the next steps:

- Install kubeadm upgrade:

```bash
# Kubeadm upgrade
sudo apt-mark unhold kubeadm \
  && sudo apt-get update \
  && sudo apt-get install -y kubeadm=1.23.5-00 \
  && sudo apt-mark hold kubeadm \
  && sudo apt-mark showhold
```

- Verify kubeadm version:

```bash
# Verify kubeadm version
sudo kubeadm version
```

- To apply k8s worker node upgrade:

```bash
# Apply upgrade
sudo kubeadm upgrade node
```

- Once the command finishes you should see:

```bash
[upgrade] The configuration for this node was successfully updated!
```

- Upgrade kubelet and kubectl:

```bash
# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl \
  && sudo apt-get update \
  && sudo apt-get install -y kubelet=1.23.5-00 kubectl=1.23.5-00 \
  && sudo apt-mark hold kubelet kubectl \
  && sudo apt-mark showhold
```

- Restart the kubelet:

```bash
# Restart the kubelet
sudo systemctl daemon-reload && sudo systemctl restart kubelet
```

- If needed, upgrade other packages and reboot:

```bash
# Distribution upgrade
sudo apt-get update \
  && sudo apt-get dist-upgrade -y \
  && sudo apt-get autoremove -y
```

- To reboot the master node:

```bash
# Reboot master node
sudo reboot
```

#### Uncordon the node

Bring the node back online by marking it schedulable. From computer management machine run:

```bash
# replace <node-to-uncordon> with the name of the node
kubectl uncordon <node-to-uncordon>
```

Verify the cluster status:

```bash
# Verify node status and version number
kubectl get nodes
```

### Upgrade mcc management station

#### Update mcc configuration

>**Note:** You must have pre-deployed in your computer your ssh keys.

- Open your **cSkLab installation locally cloned repository** and sychronize changes with remote
- Open console in **cs-sys -> mcc** folder
- Edit `cs-deploy.sh` script deployment file, and change values for variables **k8s_version** and **go_version** in the following way:

```bash
# Kubernetes version for kubectl
k8s_version="1.23.5-00"

# Go version
go_version="go1.17.8.linux-amd64.tar.gz"
```

- Save the file, commit changes and synchronize repository with remote

#### Connect with mcc

- Connect to your cSkyLab installation in one of the following ways:
  - **VPN**: Establish vpn session with `vpn_mgt` profile
  - **Local**: Connect to physical `sys` network in your `kvm-main/aux` machines

- Check conectivity with `mcc`:
  
```bash
# mcc connectivity
dig mcc.cskylab.net
ping mcc.cskylab.net
```

- Edit your `.ssh/config` and add the check for the following configuration lines to disable HostKeyChecking for `mcc` (if not previously done):

```bash
# Disable HostKeyChecking for mcc
Host mcc.cskylab.net
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
```

>**Note:** Delete records for mcc.cskylab.net & 192.168.80.5 in your `$HOME/.ssh/known_hosts` file if needed.

#### Inject & Deploy configuration to mcc

- Perform installation procedure:

```bash
# Run csinject.sh in [ssh-sudoers] execution mode (if not previously executed)
./csinject.sh -k


# Run csinject.sh to inject & deploy configuration in [install] deploy mode
./csinject.sh -qdm install
```

---

## v22-01-05

### k8s version 1.23.1-00

This page explains how to upgrade a Kubernetes cluster created with kubeadm from version 1.22.x to version 1.23.x, and from version 1.23.x to 1.23.y (where y > x). Skipping MINOR versions when upgrading is unsupported.

The complete procedures to upgrade kubeadm kubernetes clusters are covered in: <https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade>

### List available kubeadm versions

To view all available kubeadm versions:

```bash
# List available kubeadm versions
sudo apt update && sudo apt-cache madison kubeadm
```

### Upgrading k8s master node

Connect to k8s master machine and follow the next steps:

- Upgrade kubeadm:

```bash
# Kubeadm upgrade
sudo apt-mark unhold kubeadm \
  && sudo apt-get update \
  && sudo apt-get install -y kubeadm=1.23.1-00 \
  && sudo apt-mark hold kubeadm \
  && sudo apt-mark showhold
```

- Verify kubeadm version:

```bash
# Verify kubeadm version
sudo kubeadm version
```

- Verify upgrade plan:

```bash
# Verify upgrade plan
sudo kubeadm upgrade plan
```

- To apply k8s master upgrade:

```bash
# Apply upgrade
sudo kubeadm upgrade apply v1.23.1
```

- Once the command finishes you should see:

```bash
[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.23.1". Enjoy!
```

Upgrade Weave Net CNI provider:

```bash
# Update Weave Net
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.NO_MASQ_LOCAL=1"
```

>**Note**: Environment variable **NO_MASQ_LOCAL=1** explanations can be found at: <https://metallb.universe.tf/configuration/weave/> and <https://www.weave.works/docs/net/latest/kubernetes/kube-addon/#configuration-options>

- Upgrade kubelet and kubectl:

```bash
# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl \
  && sudo apt-get update \
  && sudo apt-get install -y kubelet=1.23.1-00 kubectl=1.23.1-00 \
  && sudo apt-mark hold kubelet kubectl \
  && sudo apt-mark showhold
```

- Restart the kubelet:

```bash
# Restart the kubelet
sudo systemctl daemon-reload && sudo systemctl restart kubelet
```

- If needed, upgrade other packages and reboot:

```bash
# Distribution upgrade
sudo apt-get update \
  && sudo apt-get dist-upgrade -y \
  && sudo apt-get autoremove -y
```

- To reboot the master node:

```bash
# Reboot master node
sudo reboot
```

### Upgrading k8s worker nodes

#### Drain the node

Prepare the node for maintenance by marking it unschedulable and evicting the workloads. From computer management machine run:

```bash
# replace <node-to-drain> with the name of your node you are draining
kubectl drain <node-to-drain> --ignore-daemonsets --delete-emptydir-data --disable-eviction --force
```

#### Upgrade the node

Connect to k8s worker node machine and follow the next steps:

- Install kubeadm upgrade:

```bash
# Kubeadm upgrade
sudo apt-mark unhold kubeadm \
  && sudo apt-get update \
  && sudo apt-get install -y kubeadm=1.23.1-00 \
  && sudo apt-mark hold kubeadm \
  && sudo apt-mark showhold
```

- Verify kubeadm version:

```bash
# Verify kubeadm version
sudo kubeadm version
```

- To apply k8s worker node upgrade:

```bash
# Apply upgrade
sudo kubeadm upgrade node
```

- Once the command finishes you should see:

```bash
[upgrade] The configuration for this node was successfully updated!
```

- Upgrade kubelet and kubectl:

```bash
# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl \
  && sudo apt-get update \
  && sudo apt-get install -y kubelet=1.23.1-00 kubectl=1.23.1-00 \
  && sudo apt-mark hold kubelet kubectl \
  && sudo apt-mark showhold
```

- Restart the kubelet:

```bash
# Restart the kubelet
sudo systemctl daemon-reload && sudo systemctl restart kubelet
```

- If needed, upgrade other packages and reboot:

```bash
# Distribution upgrade
sudo apt-get update \
  && sudo apt-get dist-upgrade -y \
  && sudo apt-get autoremove -y
```

- To reboot the master node:

```bash
# Reboot master node
sudo reboot
```

#### Uncordon the node

Bring the node back online by marking it schedulable. From computer management machine run:

```bash
# replace <node-to-uncordon> with the name of the node
kubectl uncordon <node-to-uncordon>
```

Verify the cluster status:

```bash
# Verify node status and version number
kubectl get nodes
```

### Upgrade mcc management station

#### Update mcc configuration

>**Note:** You must have pre-deployed in your computer your ssh keys.

- Open your **cSkLab installation locally cloned repository** and sychronize changes with remote
- Open console in **cs-sys -> mcc** folder
- Edit `cs-deploy.sh` script deployment file, and change value for variable **k8s_version** in the following way:

```bash
# Kubernetes version for kubectl
k8s_version="1.23.1-00"
```

- Save the file, commit changes and synchronize repository with remote

#### Connect with mcc

- Connect to your cSkyLab installation in one of the following ways:
  - **VPN**: Establish vpn session with `vpn_mgt` profile
  - **Local**: Connect to physical `sys` network in your `kvm-main/aux` machines

- Check conectivity with `mcc`:
  
```bash
# mcc connectivity
dig mcc.cskylab.net
ping mcc.cskylab.net
```

- Edit your `.ssh/config` and add the check for the following configuration lines to disable HostKeyChecking for `mcc` (if not previously done):

```bash
# Disable HostKeyChecking for mcc
Host mcc.cskylab.net
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
```

>**Note:** Delete records for mcc.cskylab.net & 192.168.80.5 in your `$HOME/.ssh/known_hosts` file if needed.

#### Inject & Deploy configuration to mcc

- Perform installation procedure:

```bash
# Run csinject.sh in [ssh-sudoers] execution mode (if not previously executed)
./csinject.sh -k


# Run csinject.sh to inject & deploy configuration in [install] deploy mode
./csinject.sh -qdm install
```
