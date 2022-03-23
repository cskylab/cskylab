<!-- markdownlint-disable MD024 -->

# k8s-miniostalone <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v909-909-909](#v909-909-909)
  - [Background](#background)
  - [How-to guides](#how-to-guides)
    - [1.- Update chart values file](#1--update-chart-values-file)
    - [2.- Update configuration files](#2--update-configuration-files)
    - [3.- Pull charts & update](#3--pull-charts--update)
  - [Reference](#reference)
- [v22-01-05](#v22-01-05)
  - [Background](#background-1)
  - [How-to guides](#how-to-guides-1)
    - [1.- Update configuration files](#1--update-configuration-files)
    - [2.- Pull charts & upgrade](#2--pull-charts--upgrade)
  - [Reference](#reference-1)
- [v21-12-06](#v21-12-06)
  - [Background](#background-2)
  - [How-to guides](#how-to-guides-2)
    - [1.- Update configuration files](#1--update-configuration-files-1)
    - [2.- Pull charts & upgrade](#2--pull-charts--upgrade-1)
  - [Reference](#reference-2)

---

## v909-909-909

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
## v909-909-909 <!-- omit in toc -->

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
