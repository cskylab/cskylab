<!-- markdownlint-disable MD024 -->

# k8s-miniostalone <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v24-12-11](#v24-12-11)
  - [Background](#background)
  - [How-to guides](#how-to-guides)
    - [1.- Update configuration files](#1--update-configuration-files)
    - [3.- Pull charts \& update](#3--pull-charts--update)
  - [Reference](#reference)
- [v24-04-20](#v24-04-20)
  - [Background](#background-1)
  - [How-to guides](#how-to-guides-1)
    - [1.- Update configuration files](#1--update-configuration-files-1)
    - [3.- Pull charts \& update](#3--pull-charts--update-1)
  - [Reference](#reference-1)
- [v23-11-24](#v23-11-24)
  - [Background](#background-2)
  - [How-to guides](#how-to-guides-2)
    - [1.- Update configuration files](#1--update-configuration-files-2)
    - [3.- Pull charts \& update](#3--pull-charts--update-2)
  - [Reference](#reference-2)
- [v23-04-27](#v23-04-27)
  - [Background](#background-3)
  - [How-to guides](#how-to-guides-3)
    - [1.- Uninstall miniostalone namespace](#1--uninstall-miniostalone-namespace)
    - [2.- Rename old configuration directory](#2--rename-old-configuration-directory)
    - [3.- Create new configuration from new template](#3--create-new-configuration-from-new-template)
    - [4.- Copy buckets directory](#4--copy-buckets-directory)
    - [5.- Install miniostalone namespace](#5--install-miniostalone-namespace)
    - [6.- Update new restic backup and rsync procedures](#6--update-new-restic-backup-and-rsync-procedures)
  - [Reference](#reference-3)
- [v22-12-19](#v22-12-19)
  - [Background](#background-4)
  - [How-to guides](#how-to-guides-4)
    - [1.- Update configuration files](#1--update-configuration-files-3)
    - [3.- Pull charts \& update](#3--pull-charts--update-3)
  - [Reference](#reference-4)
- [v22-08-21](#v22-08-21)
  - [Background](#background-5)
  - [How-to guides](#how-to-guides-5)
    - [1.- Uninstall miniostalone namespace](#1--uninstall-miniostalone-namespace-1)
    - [2.- Rename old configuration directory](#2--rename-old-configuration-directory-1)
    - [3.- Create new configuration from new template](#3--create-new-configuration-from-new-template-1)
    - [4.- Prepare configuration files in the new directory](#4--prepare-configuration-files-in-the-new-directory)
    - [5.- Install miniostalone namespace](#5--install-miniostalone-namespace-1)
    - [6.- Update new restic backup and rsync procedures](#6--update-new-restic-backup-and-rsync-procedures-1)
  - [Reference](#reference-5)
- [v22-03-23](#v22-03-23)
  - [Background](#background-6)
  - [How-to guides](#how-to-guides-6)
    - [1.- Update chart values file](#1--update-chart-values-file)
    - [2.- Update configuration files](#2--update-configuration-files)
    - [3.- Pull charts \& update](#3--pull-charts--update-4)
  - [Reference](#reference-6)
- [v22-01-05](#v22-01-05)
  - [Background](#background-7)
  - [How-to guides](#how-to-guides-7)
    - [1.- Update configuration files](#1--update-configuration-files-4)
    - [2.- Pull charts \& upgrade](#2--pull-charts--upgrade)
  - [Reference](#reference-7)
- [v21-12-06](#v21-12-06)
  - [Background](#background-8)
  - [How-to guides](#how-to-guides-8)
    - [1.- Update configuration files](#1--update-configuration-files-5)
    - [2.- Pull charts \& upgrade](#2--pull-charts--upgrade-1)
  - [Reference](#reference-8)

---
## v24-12-11

### Background

MinIO chart 14.8.6 updates components versions in MinIO appVersion 2024.11.7

This procedure updates MinIO installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/miniostalone` folder repository.

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
helm pull bitnami/minio --version 14.8.6 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v24-12-11 <!-- omit in toc -->

## Helm charts: bitnami/minio v14.8.6<!-- omit in toc -->
```

- Check the following section in helm chart values file `values-minio.yaml`:
  
```yaml
## @param automountServiceAccountToken Mount Service Account token in pod
##
automountServiceAccountToken: true

## @section RBAC parameters

## Specifies whether a ServiceAccount should be created
##
serviceAccount:
  ## @param serviceAccount.create Enable the creation of a ServiceAccount for MinIO&reg; pods
  ##
  create: true
  ## @param serviceAccount.name Name of the created ServiceAccount
  ## If not set and create is true, a name is generated using the common.names.fullname template
  ##
  name: ""
  ## @param serviceAccount.automountServiceAccountToken Enable/disable auto mounting of the service account token
  ##
  automountServiceAccountToken: true
  ## @param serviceAccount.annotations Custom annotations for MinIO&reg; ServiceAccount
  ##
  annotations: {}
```

- Save file

#### 3.- Pull charts & update

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/miniostalone` repository directory.

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

- <https://github.com/bitnami/charts/tree/master/bitnami/minio>

---

## v24-04-20

### Background

MinIO chart 14.1.7 updates components versions in MinIO appVersion 2024.4.6

This procedure updates MinIO installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/miniostalone` folder repository.

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
helm pull bitnami/minio --version 14.1.7 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v24-04-20 <!-- omit in toc -->

## Helm charts: bitnami/minio v14.1.7<!-- omit in toc -->
```

- Add the following section in helm chart values file `values-minio.yaml`:
  
```yaml
## @param automountServiceAccountToken Mount Service Account token in pod
##
automountServiceAccountToken: true

## @section RBAC parameters

## Specifies whether a ServiceAccount should be created
##
serviceAccount:
  ## @param serviceAccount.create Enable the creation of a ServiceAccount for MinIO&reg; pods
  ##
  create: true
  ## @param serviceAccount.name Name of the created ServiceAccount
  ## If not set and create is true, a name is generated using the common.names.fullname template
  ##
  name: ""
  ## @param serviceAccount.automountServiceAccountToken Enable/disable auto mounting of the service account token
  ##
  automountServiceAccountToken: true
  ## @param serviceAccount.annotations Custom annotations for MinIO&reg; ServiceAccount
  ##
  annotations: {}
```

- Save file

#### 3.- Pull charts & update

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/miniostalone` repository directory.

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

- <https://github.com/bitnami/charts/tree/master/bitnami/minio>

---

## v23-11-24

### Background

MinIO chart 12.10.3 updates components versions in MinIO appVersion 2023.11.20

This procedure updates MinIO installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/miniostalone` folder repository.

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
helm pull bitnami/minio --version 12.10.3 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v23-11-24 <!-- omit in toc -->

## Helm charts: bitnami/minio v12.10.3<!-- omit in toc -->
```

- Save file

#### 3.- Pull charts & update

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/miniostalone` repository directory.

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

- <https://github.com/bitnami/charts/tree/master/bitnami/minio>

---

## v23-04-27

### Background

MinIO chart 12.4.1 updates components versions in MinIO appVersion 2023.4.20.

This procedure updates MinIO installation in k8s-mod cluster.

### How-to guides

#### 1.- Uninstall miniostalone namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/miniostalone` repository directory.

- Remove namespace by running:

```bash
# Uninstall chart and namespace.  
./csdeploy.sh -m uninstall
```

#### 2.- Rename old configuration directory

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/` repository directory.

- Rename `cs-mod/k8s-mod/miniostalone` directory to `cs-mod/k8s-mod/miniostalone-dep`

#### 3.- Create new configuration from new template

From VS Code Remote connected to `mcc`, open  terminal at `_cfg-fabric` repository directory.

- Update configuration runbook models following instructions in `README.md` file.
- Generate new configuration directory following instructions in runbook `_rb-k8s-mod-miniostalone.md` file.

>**Note**: Configuration data must match with the used in the old deployment.

#### 4.- Copy buckets directory

- Copy the content of the `buckets` directory from the old configuration to the new one. This will preserve existing buckets access keys.

#### 5.- Install miniostalone namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/miniostalone` repository directory.

Install namespace by running:

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

- After migration, remove old configuration directory `cs-mod/k8s-mod/miniostalone-dep`

#### 6.- Update new restic backup and rsync procedures

- Review the new restic backup and rsync procedures in file `README.md`
- Update the cronjobs in kubernetes node and check the jobs are running properly.

### Reference

- <https://github.com/bitnami/charts/tree/master/bitnami/minio>

---

## v22-12-19

### Background

MinIO chart 11.10.24 updates components versions in MinIO appVersion 2022.12.12.

This procedure updates MinIO installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/miniostalone` folder repository.

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
helm pull bitnami/minio --version 11.10.24 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v22-12-19 <!-- omit in toc -->

## Helm charts: bitnami/minio v11.10.24<!-- omit in toc -->
```

- Save file

#### 3.- Pull charts & update

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/miniostalone` repository directory.

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

- <https://github.com/bitnami/charts/tree/master/bitnami/minio>

---

## v22-08-21

### Background

MinIO chart 11.8.4 updates components versions in MinIO appVersion 2022.8.13.

This upgrade include new backup and rsync procedures and requires to uninstall and re-install the namespace. The LVM data service will preserve existing data.

This procedure updates the installation in k8s-mod cluster.

### How-to guides
#### 1.- Uninstall miniostalone namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/miniostalone` repository directory.

- Remove namespace by running:

```bash
# Uninstall chart and namespace.  
./csdeploy.sh -m uninstall
```

#### 2.- Rename old configuration directory

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/` repository directory.

- Rename `cs-mod/k8s-mod/miniostalone` directory to `cs-mod/k8s-mod/miniostalone-dep`

#### 3.- Create new configuration from new template

From VS Code Remote connected to `mcc`, open  terminal at `_cfg-fabric` repository directory.

- Update configuration runbook models following instructions in `README.md` file.
- Generate new configuration directory following instructions in runbook `_rb-k8s-mod-miniostalone.md` file.

>**Note**: Configuration data must match with the used in the old deployment.

#### 4.- Prepare configuration files in the new directory

- Copy the file `values-minio.yaml` from the old configuration directory to the new one (This file must retain the previously exisisting mariadb configuration).

- Edit `csdeploy.sh` file on the new directory and change the `source_charts` variable to the following values:

```bash
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull bitnami/minio --version 11.8.4 --untar

EOF
)"
```

#### 5.- Install miniostalone namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/miniostalone` repository directory.

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

- After migration, remove old configuration directory `cs-mod/k8s-mod/miniostalone-dep`

#### 6.- Update new restic backup and rsync procedures

- Review the new restic backup and rsync procedures in file `README.md`
- Update the cronjobs in kubernetes node and check the jobs are running properly.

### Reference

- <https://github.com/bitnami/charts/tree/master/bitnami/minio>

---


## v22-03-23

### Background

MinIO chart 11.1.5 updates components versions in MinIO appVersion 2022.3.22.

A change has to be made in chart configuration values `values-minio.yaml` in order to send the appropriate self-signed URL when sharing a file from the console.

This procedure updates MinIO installation in k8s-mod cluster.

### How-to guides

#### 1.- Update chart values file

Edit values file `values-minio.yaml` and add the following section after **defaultBukets:** section (Before **persistence:**):

```yaml
## @param extraEnvVars Extra environment variables to be set on MinIO&reg; container
## e.g:
## extraEnvVars:
##   - name: FOO
##     value: "bar"
##
extraEnvVars:
  - name: MINIO_SERVER_URL
    value: "https://miniostalone.cskylab.net:443"
```

>**Note**: The given value must be the URL corresponding with the API, not with the console.

#### 2.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/miniostalone` folder repository.

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
helm pull bitnami/minio --version 11.1.5 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v22-03-23 <!-- omit in toc -->

## Helm charts: bitnami/minio v11.1.5<!-- omit in toc -->
```

- Save file

#### 3.- Pull charts & update

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/miniostalone` repository directory.

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

- <https://github.com/bitnami/charts/tree/master/bitnami/minio>

---

## v22-01-05

### Background

MinIO chart 9.2.10 updates components versions in MinIO appVersion 2021.12.29.

This procedure updates MinIO installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/miniostalone` folder repository.

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
helm pull bitnami/minio --version 9.2.10 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: bitnami/minio v9.2.10<!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & upgrade

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/miniostalone` folder repository.

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

- <https://github.com/bitnami/charts/tree/master/bitnami/minio>

---

## v21-12-06

### Background

MinIO chart 9.2.3 updates components versions in MinIO appVersion 2021.11.24.

This procedure updates MinIO installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/miniostalone` folder repository.

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
helm pull bitnami/minio --version 9.2.3 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: bitnami/minio v9.2.3<!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & upgrade

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/miniostalone` folder repository.

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

- <https://github.com/bitnami/charts/tree/master/bitnami/minio>
