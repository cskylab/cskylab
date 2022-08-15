<!-- markdownlint-disable MD024 -->

# k8s-metallb-system <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v99-99-99](#v99-99-99)
  - [Background](#background)
  - [How-to guides](#how-to-guides)
    - [1.- Uninstall metallb-system namespace](#1--uninstall-metallb-system-namespace)
    - [2.- Rename old configuration directory](#2--rename-old-configuration-directory)
    - [3.- Create new configuration from new template](#3--create-new-configuration-from-new-template)
    - [4.- Install new metallb-namespace](#4--install-new-metallb-namespace)
    - [5.- Configure IP address pools](#5--configure-ip-address-pools)
  - [Reference](#reference)
- [v22-03-23](#v22-03-23)
  - [Background](#background-1)
  - [How-to guides](#how-to-guides-1)
    - [1.- Uninstall metallb-system namespace](#1--uninstall-metallb-system-namespace-1)
    - [2.- Rename old configuration directory](#2--rename-old-configuration-directory-1)
    - [3.- Create new configuration from new template](#3--create-new-configuration-from-new-template-1)
    - [4.- Deploy new metallb-namespace](#4--deploy-new-metallb-namespace)
  - [Reference](#reference-1)
- [v22-01-05](#v22-01-05)
  - [Background](#background-2)
  - [How-to guides](#how-to-guides-2)
    - [1.- Update configuration files](#1--update-configuration-files)
    - [2.- Pull charts & upgrade](#2--pull-charts--upgrade)
  - [Reference](#reference-2)
- [v21-12-06](#v21-12-06)
  - [Background](#background-3)
  - [How-to guides](#how-to-guides-3)
    - [1.- Update configuration files](#1--update-configuration-files-1)
    - [2.- Pull charts & upgrade](#2--pull-charts--upgrade-1)
  - [Reference](#reference-3)

---

## v99-99-99

### Background

In this release, MetalLB configuration template has been changed from MetalLB manifest 0.12.1 to version 0.13.4.

Previous versions of MetalLB are configurable via a configmap. However, starting from the version v0.13.0, it will be possible to configure it only via CRs. A tool to convert old configmaps to CRs is provided as a container image under quay.io/metallb/configmaptocrs.

In order to use the tool the container must be ran mapping the path with the source file config.yaml to /var/input, and it will generate a resources.yaml file containing the resources mapped to the yaml.

To migrate old config.yaml files run:

```bash
docker run -d -v $(pwd):/var/input quay.io/metallb/configmaptocrs -source config.yaml
```

This procedure migrates from old MetalLB template to the new one in k8s-mod cluster.

### How-to guides

#### 1.- Uninstall metallb-system namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/metallb-system` repository directory.

- Remove metallb-system namespace by running:

```bash
# Uninstall chart and namespace.  
./csdeploy.sh -m uninstall
```

#### 2.- Rename old configuration directory

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/` repository directory.

- Rename `cs-mod/k8s-mod/metallb-system` directory to `cs-mod/k8s-mod/metallb-system-dep`

>**Note**: This configuration directory can be reused to reinstall the namespace in case the migration procedure fails.

#### 3.- Create new configuration from new template

From VS Code Remote connected to `mcc`, open  terminal at `_cfg-fabric` repository directory.

- Update configuration runbook models following instructions in `README.md` file.
- Generate new configuration directory following instructions in runbook `_rb-k8s-metallb-system.md` file.

>**Note**: Check MetalLB static and dynamic ip addresses pools in overrides. They must match with the used in the old deployment.

#### 4.- Install new metallb-namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/metallb-system` repository directory.

Install metallb-system namespace by running:

```bash
# Install chart and namespace.  
./csdeploy.sh -m install
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```

>**Note**: Be sure all metallb pods are running before configuring IP address pools.

#### 5.- Configure IP address pools

- Review address-pools values in `resources.yaml` file.

Configure IP address pools by running:

```bash
# Configure IP address pools
./csdeploy.sh -m config
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```


- After migration, remove old configuration directory `cs-mod/k8s-mod/metallb-system-dep`

### Reference

- <https://metallb.universe.tf>

---


## v22-03-23

### Background

In this release, MetalLB configuration template has been changed from using bitnami chart 2.5.16 to original MetalLB manifest 0.12.1. The use of original MetalLB docker images allows to deploy MetalLB in linux/amrv7 and linux/arm64 platforms in addition to linux/amd64.

This procedure migrates from old MetalLB template to the new one in k8s-mod cluster.

### How-to guides

#### 1.- Uninstall metallb-system namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/metallb-system` repository directory.

- Remove metallb-system namespace by running:

```bash
# Uninstall chart and namespace.  
./csdeploy.sh -m uninstall
```

#### 2.- Rename old configuration directory

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/` repository directory.

- Rename `cs-mod/k8s-mod/metallb-system` directory to `cs-mod/k8s-mod/metallb-system-dep`

>**Note**: This configuration directory can be reused to reinstall the namespace in case the migration procedure fails.

#### 3.- Create new configuration from new template

From VS Code Remote connected to `mcc`, open  terminal at `_cfg-fabric` repository directory.

- Update configuration runbook models following instructions in `README.md` file.
- Generate new configuration directory following instructions in runbook `_rb-k8s-metallb-system.md` file.

>**Note**: Check MetalLB static and dynamic ip addresses pools in overrides. They must match with the used in the old deployment.

#### 4.- Deploy new metallb-namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/metallb-system` repository directory.

- Review address-pools values in configmap `config.yaml` file.
- Install metallb-system namespace by running:

```bash
# Install chart and namespace.  
./csdeploy.sh -m install
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```

- After migration, remove old configuration directory `cs-mod/k8s-mod/metallb-system-dep`

### Reference

- <https://metallb.universe.tf>

---

## v22-01-05

### Background

MetalLB chart 2.5.16 updates chart components versions in metallb appVersion 0.11.0.

This procedure updates MetalLB installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/metallb` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull bitnami/metallb --version 2.5.16 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: bitnami/metallb v2.5.16 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & upgrade

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/metallb` folder repository.

Execute the following commands to pull charts and upgrade:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```

### Reference

- <https://github.com/bitnami/charts/tree/master/bitnami/metallb/>
- <https://metallb.universe.tf>

---

## v21-12-06

### Background

MetalLB chart 2.5.13 updates chart components versions in metallb appVersion 0.11.0.

This procedure updates MetalLB installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/metallb` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull bitnami/metallb --version 2.5.13 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: bitnami/metallb v2.5.13 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & upgrade

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/metallb` folder repository.

Execute the following commands to pull charts and upgrade:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```

### Reference

- <https://github.com/bitnami/charts/tree/master/bitnami/metallb/>
- <https://metallb.universe.tf>
