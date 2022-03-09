<!-- markdownlint-disable MD024 -->

# kubeadm-clusters <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v22-01-05](#v22-01-05)
  - [k8s version 1.23.1-00](#k8s-version-1231-00)
  - [List available kubeadm versions](#list-available-kubeadm-versions)
  - [Upgrading k8s master node](#upgrading-k8s-master-node)
  - [Upgrading k8s worker nodes](#upgrading-k8s-worker-nodes)
    - [Drain the node](#drain-the-node)
    - [Upgrade the node](#upgrade-the-node)
    - [Uncordon the node](#uncordon-the-node)
  - [Upgrade mcc management station](#upgrade-mcc-management-station)
    - [Update mcc configuration](#update-mcc-configuration)
    - [Connect with mcc](#connect-with-mcc)
    - [Inject & Deploy configuration to mcc](#inject--deploy-configuration-to-mcc)

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