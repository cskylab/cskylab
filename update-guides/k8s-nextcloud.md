<!-- markdownlint-disable MD024 -->

# k8s-nextcloud <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v24-12-11](#v24-12-11)
  - [Background](#background)
  - [Prerequisites](#prerequisites)
  - [How-to guides](#how-to-guides)
    - [1.- Check configuration files in ingress-nginx namespace](#1--check-configuration-files-in-ingress-nginx-namespace)
    - [2.- Update mariadb chart to version 20.1.1 app version 11.4.4](#2--update-mariadb-chart-to-version-2011-app-version-1144)
    - [3.- Update to chart 5.5.6 app version 29.0.6](#3--update-to-chart-556-app-version-2906)
    - [4.- Update to chart 6.2.4 app version 30.0.2](#4--update-to-chart-624-app-version-3002)
  - [Reference](#reference)
- [v24-04-20](#v24-04-20)
  - [Background](#background-1)
  - [Prerequisites](#prerequisites-1)
  - [How-to guides](#how-to-guides-1)
    - [1.- Update configuration files in ingress-nginx namespace](#1--update-configuration-files-in-ingress-nginx-namespace)
    - [2.- Update configuration files in nextcloud namespace](#2--update-configuration-files-in-nextcloud-namespace)
    - [2.- Pull charts \& update](#2--pull-charts--update)
  - [Reference](#reference-1)
- [v23-11-24](#v23-11-24)
  - [Background](#background-2)
  - [Prerequisites](#prerequisites-2)
  - [How-to guides](#how-to-guides-2)
    - [1.- Update configuration files](#1--update-configuration-files)
    - [2.- Pull charts \& update](#2--pull-charts--update-1)
  - [Reference](#reference-2)
- [v23-04-27](#v23-04-27)
  - [Background](#background-3)
  - [Prerequisites](#prerequisites-3)
  - [How-to guides](#how-to-guides-3)
    - [1.- Update configuration files](#1--update-configuration-files-1)
    - [2.- Pull charts \& update](#2--pull-charts--update-2)
  - [Reference](#reference-3)
- [v22-12-19](#v22-12-19)
  - [Background](#background-4)
  - [Prerequisites](#prerequisites-4)
  - [How-to guides](#how-to-guides-4)
    - [1.- Update configuration files](#1--update-configuration-files-2)
    - [2.- Pull charts \& update](#2--pull-charts--update-3)
  - [Reference](#reference-4)
- [v22-08-21](#v22-08-21)
  - [Background](#background-5)
  - [Prerequisites](#prerequisites-5)
  - [How-to guides](#how-to-guides-5)
    - [1.- Uninstall nextcloud namespace](#1--uninstall-nextcloud-namespace)
    - [2.- Rename old configuration directory](#2--rename-old-configuration-directory)
    - [3.- Create new configuration from new template](#3--create-new-configuration-from-new-template)
    - [4.- Prepare configuration files in the new directory](#4--prepare-configuration-files-in-the-new-directory)
    - [5.- Install nextcloud namespace and update mariadb](#5--install-nextcloud-namespace-and-update-mariadb)
    - [6.- Upgrade nextcloud to intermediate v23.0.3](#6--upgrade-nextcloud-to-intermediate-v2303)
    - [6.- Perform final nextcloud chart upgrade](#6--perform-final-nextcloud-chart-upgrade)
    - [8.- Update new restic backup and rsync procedures](#8--update-new-restic-backup-and-rsync-procedures)
  - [Reference](#reference-5)
- [v22-03-23](#v22-03-23)
  - [Background](#background-6)
  - [Prerequisites](#prerequisites-6)
  - [How-to guides](#how-to-guides-6)
    - [1.- Update configuration files](#1--update-configuration-files-3)
    - [2.- Pull charts \& update](#2--pull-charts--update-4)
  - [Reference](#reference-6)
- [v22-01-05](#v22-01-05)
  - [Background](#background-7)
  - [How-to guides](#how-to-guides-7)
    - [1.- Change redis to standalone mode](#1--change-redis-to-standalone-mode)
    - [2.- Update configuration files](#2--update-configuration-files)
    - [3.- Pull charts \& re-install application](#3--pull-charts--re-install-application)
  - [Reference](#reference-7)
- [v21-12-06](#v21-12-06)
  - [Background](#background-8)
  - [How-to guides](#how-to-guides-8)
    - [1.- Update configuration files](#1--update-configuration-files-4)
    - [2.- Pull charts \& upgrade](#2--pull-charts--upgrade)
  - [Reference](#reference-8)

---
## v24-12-11

### Background

Nextcloud chart 6.2.4 updates chart parameters in Nextcloud appVersion 30.0.2.

This procedure updates Nextcloud installation in k8s-mod cluster.

### Prerequisites

Previous v24-04-20 deployment of the namespace is needed.

### How-to guides

#### 1.- Check configuration files in ingress-nginx namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/ingress-nginx` folder repository.

- Edit `values-ingress-nginx.yaml` file and add the following lines under **controller:** section:

```yaml
controller:
  # -- This configuration defines if Ingress Controller should allow users to set
  # their own *-snippet annotations, otherwise this is forbidden / dropped
  # when users add those annotations.
  # Global snippets in ConfigMap are still respected
  allowSnippetAnnotations: true
```

Execute the following commands to pull charts and update ingress-nginx namespace:

```bash
# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```
#### 2.- Update mariadb chart to version 20.1.1 app version 11.4.4

>**Note**: To upgrade mariadb chart you must uninstall and reinstall the namespace.

Uninstall namespace

```bash
# Uninstall namespace
./csdeploy.sh -m uninstall
```

Prepare deploy script:

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull nextcloud/nextcloud --version 4.6.5 --untar
helm pull bitnami/mariadb --version 20.1.1 --untar

EOF
)"
```
- Save file

Pull charts & reinstall:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Install
./csdeploy.sh -m install

# Check status
./csdeploy.sh -l
```


#### 3.- Update to chart 5.5.6 app version 29.0.6

Prepare deploy script:

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull nextcloud/nextcloud --version 5.5.6 --untar
helm pull bitnami/mariadb --version 20.1.1 --untar

EOF
)"
```
- Save file

Pull charts & update:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```

>**NOTE**: In case the update fails or nexcloud starts in maintenance mode, refer to the section **Nextcloud occ commands** in documentation file `README.md`.

#### 4.- Update to chart 6.2.4 app version 30.0.2

Prepare deploy script:

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull nextcloud/nextcloud --version 6.2.4 --untar
helm pull bitnami/mariadb --version 20.1.1 --untar

EOF
)"
```
- Save file

Pull charts & update;

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```
>**NOTE**: In case the update fails or nexcloud starts in maintenance mode, refer to the section **Nextcloud occ commands** in documentation file `README.md`.

**Update README.md**

- Edit `README.md` documentation file, and change header as follows:

``` bash
## v24-12-11 <!-- omit in toc -->

## Helm charts: nextcloud/nextcloud v6.2.4 bitnami/mariadb v20.1.1 <!-- omit in toc -->
```
- Save file


### Reference

- <https://github.com/nextcloud/helm/tree/master/charts/nextcloud>

---

## v24-04-20

### Background

Nextcloud chart 4.6.5 updates chart parameters in Nextcloud appVersion 28.0.4.

This procedure updates Nextcloud installation in k8s-mod cluster.

### Prerequisites

Previous v23-11-24 deployment of the namespace is needed.

### How-to guides

#### 1.- Update configuration files in ingress-nginx namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/ingress-nginx` folder repository.

- Edit `values-ingress-nginx.yaml` file and add the following lines under **controller:** section:

```yaml
controller:
  # -- This configuration defines if Ingress Controller should allow users to set
  # their own *-snippet annotations, otherwise this is forbidden / dropped
  # when users add those annotations.
  # Global snippets in ConfigMap are still respected
  allowSnippetAnnotations: true
```

Execute the following commands to pull charts and update ingress-nginx namespace:

```bash
# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```


#### 2.- Update configuration files in nextcloud namespace

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull nextcloud/nextcloud --version 4.6.5 --untar
helm pull bitnami/mariadb --version 18.0.1 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v24-04-20 <!-- omit in toc -->

## Helm charts: nextcloud/nextcloud v4.6.5 bitnami/mariadb v18.0.1 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/nextcloud` repository directory.

Execute the following commands to pull charts and update:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```

### Reference

- <https://github.com/nextcloud/helm/tree/master/charts/nextcloud>

---

## v23-11-24

### Background

Nextcloud chart 4.5.2 updates chart parameters in Nextcloud appVersion 27.1.4.

This procedure updates Nextcloud installation in k8s-mod cluster.

### Prerequisites

Previous v23-04-27 deployment of the namespace is needed.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/nextcloud` folder repository.

- Edit `values-ingress-nginx.yaml` file and add the following lines under **controller:** section:

```yaml
controller:
  # -- This configuration defines if Ingress Controller should allow users to set
  # their own *-snippet annotations, otherwise this is forbidden / dropped
  # when users add those annotations.
  # Global snippets in ConfigMap are still respected
  allowSnippetAnnotations: true
```

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull nextcloud/nextcloud --version 4.5.2 --untar
helm pull bitnami/mariadb --version 14.1.4 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v23-11-24 <!-- omit in toc -->

## Helm charts: nextcloud/nextcloud v4.5.2 bitnami/mariadb v14.1.3 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/nextcloud` repository directory.

Execute the following commands to pull charts and update:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```

### Reference

- <https://github.com/nextcloud/helm/tree/master/charts/nextcloud>

---

## v23-04-27

### Background

Nextcloud chart 3.5.10 updates chart parameters in Nextcloud appVersion 26.0.1.

This procedure updates Nextcloud installation in k8s-mod cluster.

### Prerequisites

Previous v22-12-19 deployment of the namespace is needed.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/nextcloud` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull nextcloud/nextcloud --version 3.5.10 --untar
helm pull bitnami/mariadb --version 12.0.0 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v23-04-27 <!-- omit in toc -->

## Helm charts: nextcloud/nextcloud v3.5.10 bitnami/mariadb v12.0.0 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/nextcloud` repository directory.

Execute the following commands to pull charts and update:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```

### Reference

- <https://github.com/nextcloud/helm/tree/master/charts/nextcloud>

---

## v22-12-19

### Background

Nextcloud chart 3.3.4 updates chart parameters in Nextcloud appVersion 25.0.2.

This procedure updates Nextcloud installation in k8s-mod cluster.

### Prerequisites

Previous v22-08-21 deployment of the namespace is needed.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/nextcloud` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull nextcloud/nextcloud --version 3.3.4 --untar
helm pull bitnami/mariadb --version 11.4.1 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v22-12-19 <!-- omit in toc -->

## Helm charts: nextcloud/nextcloud v3.3.4 bitnami/mariadb v11.4.1 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/nextcloud` repository directory.

Execute the following commands to pull charts and update:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```

### Reference

- <https://github.com/nextcloud/helm/tree/master/charts/nextcloud>

---

## v22-08-21

### Background

This update applies charts nextcloud/nextcloud v3.0.4 with Nextloud v24.0.2 and bitnami/mariadb v11.1.8. with MariaDB v10.6.9.

Before applying the final update it is necessary to perform an intermediate update to nextcloud chart v2.14.6 with appVersion 23.0.3.

This upgrade include new backup and rsync procedures and requires to uninstall and re-install the namespace. The Nextcloud LVM data service will preserve existing data.

This procedure updates Nextcloud installation in k8s-mod cluster.

### Prerequisites

Before aplying this update it is mandatory to have the namespace updated to cSkyLab v22-03-23:

- Nextcloud chart 2.12.2
  
### How-to guides

#### 1.- Uninstall nextcloud namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/nextcloud` repository directory.

- Remove gitlab namespace by running:

```bash
# Uninstall chart and namespace.  
./csdeploy.sh -m uninstall
```

#### 2.- Rename old configuration directory

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/` repository directory.

- Rename `cs-mod/k8s-mod/nextcloud` directory to `cs-mod/k8s-mod/nextcloud-dep`

#### 3.- Create new configuration from new template

From VS Code Remote connected to `mcc`, open  terminal at `_cfg-fabric` repository directory.

- Update configuration runbook models following instructions in `README.md` file.
- Generate new configuration directory following instructions in runbook `_rb-k8s-mod-nextcloud.md` file.

>**Note**: Configuration data must match with the used in the old deployment.

#### 4.- Prepare configuration files in the new directory

- Copy the file `values-mariadb.yaml` from the old configuration directory to the new one (This file must retain the previously exisisting mariadb configuration).
- Copy the file `values-nextcloud.yaml` from the old configuration directory to the new one (This file must retain the previously exisisting nextcloud configuration).

- Edit `csdeploy.sh` file on the new directory and change the `source_charts` variable to the following values:

```bash
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull nextcloud/nextcloud --version 2.12.2 --untar
helm pull bitnami/mariadb --version 11.1.8 --untar

EOF
)"
```

>**Note**: With this configuration, you will be ready to update mariadb chart without changing your actual nextcloud version.

#### 5.- Install nextcloud namespace and update mariadb

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/nextcloud` repository directory.

Install nextcloud namespace by running:

```bash
# Pull new chart versions
./csdeploy.sh -m pull-charts

# Install chart and namespace.  
./csdeploy.sh -m install
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```

#### 6.- Upgrade nextcloud to intermediate v23.0.3

- Edit file `values-nextcloud.yaml` and change the initial image section, commenting the `tag` and `pullPolicy` values in the following way:

```bash
## Official nextcloud image version
## ref: https://hub.docker.com/r/library/nextcloud/tags/
##
image:
  repository: harbor.cskylab.net/dockerhub/library/nextcloud
  # tag: 22-apache
  # pullPolicy: IfNotPresent
  # pullSecrets:
  #   - myRegistrKeySecretName
```

>**Note**: Value image.tag must be commented to allow the chart to update nextcloud versions.


- Edit `csdeploy.sh` file on the new directory and change the `source_charts` variable to the following values:

```bash
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull nextcloud/nextcloud --version 2.14.6 --untar
helm pull bitnami/mariadb --version 11.1.8 --untar

EOF
)"
```

>**Note**: This configuration will update nextcloud to intermediate version v23.0.3.


- Update nextcloud namespace by running:

```bash
# Pull new chart versions
./csdeploy.sh -m pull-charts

# Redeploy upgraded chart.  
./csdeploy.sh -m update
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```

#### 6.- Perform final nextcloud chart upgrade

- Edit `csdeploy.sh` file on the new directory and change the `source_charts` variable to the following values:

```bash
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull nextcloud/nextcloud --version 3.0.4 --untar
helm pull bitnami/mariadb --version 11.1.8 --untar

EOF
)"
```

>**Note**: This configuration will update nextcloud to final version v24.0.2.

- Update nextcloud namespace by running:

```bash
# Pull new chart versions
./csdeploy.sh -m pull-charts

# Redeploy upgraded chart.  
./csdeploy.sh -m update
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```

- After migration, remove old configuration directory `cs-mod/k8s-mod/nextcloud-dep`

#### 8.- Update new restic backup and rsync procedures

- Review the new restic backup and rsync procedures in file `README.md`
- Update the cronjobs in kubernetes node and check the jobs are running properly.

### Reference

- <https://github.com/nextcloud/helm/tree/master/charts/nextcloud>

---

## v22-03-23

### Background

Nextcloud chart 2.12.2 updates chart parameters in Nextcloud appVersion 22.2.3.

Before applying this chart, you must change redis configuration in `values-nextcloud.yaml` from replicated to standalone mode.

This procedure updates Nextcloud installation in k8s-mod cluster.

### Prerequisites

Before aplying this update it is mandatory to have the namespace updated to cSkyLab v22-01-05:

- Nextcloud chart 2.11.3
- Redis in standalone mode
  
### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/nextcloud` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull nextcloud/nextcloud --version 2.12.1 --untar
helm pull bitnami/mariadb --version 10.4.0 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v22-03-23 <!-- omit in toc -->

## Helm charts: nextcloud/nextcloud v2.12.1 bitnami/mariadb v10.4.0 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/nextcloud` repository directory.

Execute the following commands to pull charts and update:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```

### Reference

- <https://github.com/nextcloud/helm/tree/master/charts/nextcloud>

---

## v22-01-05

### Background

Nextcloud chart 2.11.3 updates chart parameters in Nextcloud appVersion 22.2.3.

Before applying this chart, you must change redis configuration in `values-nextcloud.yaml` from replicated to standalone mode.

This procedure updates Nextcloud installation in k8s-mod cluster.

### How-to guides

#### 1.- Change redis to standalone mode

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/nextcloud` folder repository.

- Check installation status:

```bash
# Check status
./csdeploy.sh -l
```

>**Note**: You should have now replicated redis mode with two redis pods: `pod/nextcloud-redis-master-0` and `pod/nextcloud-redis-slave-0`

- Uninstall application

```bash
# Uninstall application
./csdeploy.sh -m uninstall
```

- Edit `values-nextcloud.yaml` file
- Delete all section under **redis:** label from file and replace it with the following one:
  
>**Note**: You must use your previously defined password

```yaml
##
## Redis chart configuration
## for more options see https://github.com/bitnami/charts/tree/master/bitnami/redis
##

redis:
  enabled: true
  ## @param architecture Redis&trade; architecture. Allowed values: `standalone` or `replication`
  ##
  architecture: standalone
  auth:
    enabled: true
    password: 'YourPassword'

  global:
    imageRegistry: harbor.cskylab.net/dockerhub

  ## Cluster settings
  cluster:
    enabled: false

  ##
  ## Redis Master parameters
  ##
  master:
    ## Enable persistence using Persistent Volume Claims
    ## ref: http://kubernetes.io/docs/user-guide/persistent-volumes/
    ##
    persistence:
      enabled: true
      ## The path the volume will be mounted at, useful when using different
      ## Redis images.
      path: /data
      ## The subdirectory of the volume to mount to, useful in dev environments
      ## and one PV for multiple services.
      subPath: ""
      ## redis data Persistent Volume Storage Class
      ## If defined, storageClassName: <storageClass>
      ## If set to "-", storageClassName: "", which disables dynamic provisioning
      ## If undefined (the default) or set to null, no storageClassName spec is
      ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
      ##   GKE, AWS & OpenStack)
      ##
      storageClass: nextcloud-redis-master
      accessModes:
      - ReadWriteOnce
      size: 8Gi
```

- Remove from configuration the file `pv-redis-slave.yaml` (This will prevent to declare an unneeded PV when re-installing the application)

#### 2.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/nextcloud` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull nextcloud/nextcloud --version 2.11.3 --untar
helm pull bitnami/mariadb --version 10.2.0 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: nextcloud/nextcloud v2.11.3 bitnami/mariadb v10.2.0 <!-- omit in toc -->
```

- Save file

#### 3.- Pull charts & re-install application

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/nextcloud` folder repository.

Execute the following commands to pull charts and upgrade:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Re-install
./csdeploy.sh -m install

# Check status
./csdeploy.sh -l
```

>**Note**: After applying the new values, you should have now standalone redis mode with one redis pod: `pod/nextcloud-redis-master-0`

### Reference

- <https://github.com/nextcloud/helm/tree/master/charts/nextcloud>

---

## v21-12-06

### Background

Nextcloud chart 2.10.2 updates chart parameters in Nextcloud appVersion 22.2.3.

This procedure updates Nextcloud installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/nextcloud` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull nextcloud/nextcloud --version 2.10.2 --untar
helm pull bitnami/mariadb --version 10.1.0 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: nextcloud/nextcloud v2.10.2 bitnami/mariadb v10.1.0 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & upgrade

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/nextcloud` folder repository.

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

- <https://github.com/nextcloud/helm/tree/master/charts/nextcloud>
