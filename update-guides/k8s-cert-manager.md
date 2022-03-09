<!-- markdownlint-disable MD024 -->

# k8s-cert-manager <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v909-909-909](#v909-909-909)
  - [Background](#background)
  - [How-to guides](#how-to-guides)
    - [1.- Update configuration files](#1--update-configuration-files)
    - [2.- Pull charts & update namespace](#2--pull-charts--update-namespace)
  - [Reference](#reference)

---

## v909-909-909

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
## v909-909-909 <!-- omit in toc -->

## Helm charts: `jetstack/cert-manager v1.7.1` <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/harbor` repository directory.

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
