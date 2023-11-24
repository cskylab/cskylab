<!-- markdownlint-disable MD024 -->

# k8s-cert-manager <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v23-11-24](#v23-11-24)
  - [Background](#background)
  - [How-to guides](#how-to-guides)
    - [1.- Update configuration files](#1--update-configuration-files)
    - [2.- Pull charts \& update namespace](#2--pull-charts--update-namespace)
  - [Reference](#reference)
- [v23-04-27](#v23-04-27)
  - [Background](#background-1)
  - [How-to guides](#how-to-guides-1)
    - [1.- Update configuration files](#1--update-configuration-files-1)
    - [2.- Pull charts \& update namespace](#2--pull-charts--update-namespace-1)
  - [Reference](#reference-1)
- [v22-12-19](#v22-12-19)
  - [Background](#background-2)
  - [How-to guides](#how-to-guides-2)
    - [1.- Update configuration files](#1--update-configuration-files-2)
    - [2.- Pull charts \& update namespace](#2--pull-charts--update-namespace-2)
  - [Reference](#reference-2)
- [v22-08-21](#v22-08-21)
  - [Background](#background-3)
  - [How-to guides](#how-to-guides-3)
    - [1.- Update configuration files](#1--update-configuration-files-3)
    - [2.- Pull charts \& update namespace](#2--pull-charts--update-namespace-3)
  - [Reference](#reference-3)
- [v22-03-23](#v22-03-23)
  - [Background](#background-4)
  - [How-to guides](#how-to-guides-4)
    - [1.- Update configuration files](#1--update-configuration-files-4)
    - [2.- Pull charts \& update namespace](#2--pull-charts--update-namespace-4)
  - [Reference](#reference-4)

---

## v23-11-24

### Background

Jetstack chart cert-manager 1.13.2 updates components for appVersion 1.13.2.

There are some considerations concerning migrations that you can review at <https://cert-manager.io/docs/installation/upgrading/>


This procedure updates cert-manager installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/cert-manager` repository directory.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Charts
helm pull jetstack/cert-manager --version 1.13.2 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v23-11-24 <!-- omit in toc -->

## Helm charts: `jetstack/cert-manager v1.13.2` <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/cert-manager` repository directory.

Execute the following commands to pull charts and update namespace:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```

### Reference

- <https://cert-manager.io/docs/>


---

## v23-04-27

### Background

Jetstack chart cert-manager 1.11.1 updates components for appVersion 1.11.1.

There are some considerations concerning migrations that you can review at <https://cert-manager.io/docs/installation/upgrading/>


This procedure updates cert-manager installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/cert-manager` repository directory.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Charts
helm pull jetstack/cert-manager --version 1.11.1 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v23-04-27 <!-- omit in toc -->

## Helm charts: `jetstack/cert-manager v1.11.1` <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/cert-manager` repository directory.

Execute the following commands to pull charts and update namespace:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```

### Reference

- <https://cert-manager.io/docs/>


---



## v22-12-19

### Background

Jetstack chart cert-manager 1.10.1 updates components for appVersion 1.10.1.

There are some considerations concerning migrations that you can review at <https://cert-manager.io/docs/installation/upgrading/>


This procedure updates cert-manager installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/cert-manager` repository directory.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Charts
helm pull jetstack/cert-manager --version 1.10.1 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v22-12-19 <!-- omit in toc -->

## Helm charts: `jetstack/cert-manager v1.10.1` <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/cert-manager` repository directory.

Execute the following commands to pull charts and update namespace:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```

### Reference

- <https://cert-manager.io/docs/>


---

## v22-08-21

### Background

Jetstack chart cert-manager 1.9.1 updates components for appVersion 1.9.1.

There are some considerations concerning migrations that you can review at <https://cert-manager.io/docs/installation/upgrading/>


This procedure updates cert-manager installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/cert-manager` repository directory.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Charts
helm pull jetstack/cert-manager --version 1.9.1 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v22-08-21 <!-- omit in toc -->

## Helm charts: `jetstack/cert-manager v1.9.1` <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/cert-manager` repository directory.

Execute the following commands to pull charts and update namespace:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```

### Reference

- <https://cert-manager.io/docs/>


---

## v22-03-23

### Background

Jetstack chart cert-manager 1.7.1 updates components for appVersion 1.7.1.

This procedure updates cert-manager installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/cert-manager` repository directory.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Charts
helm pull jetstack/cert-manager --version 1.7.1 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v22-03-23 <!-- omit in toc -->

## Helm charts: `jetstack/cert-manager v1.7.1` <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/cert-manager` repository directory.

Execute the following commands to pull charts and update namespace:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```

### Reference

- <https://cert-manager.io/docs/>
