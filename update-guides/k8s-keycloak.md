<!-- markdownlint-disable MD024 -->

# k8s-keycloak <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v99-99-99](#v99-99-99)
  - [Background](#background)
  - [How-to guides](#how-to-guides)
    - [1.- Update configuration files](#1--update-configuration-files)
    - [2.- Pull charts & update](#2--pull-charts--update)
  - [Reference](#reference)
- [v22-01-05](#v22-01-05)
  - [Background](#background-1)
  - [How-to guides](#how-to-guides-1)
    - [1.- Update configuration files](#1--update-configuration-files-1)
    - [2.- Pull charts & upgrade](#2--pull-charts--upgrade)
  - [Reference](#reference-1)

---

## v99-99-99

### Background

Keycloak chart 18.1.1 updates chart components in keycloak appVersion 17.0.1-legacy.

This procedure updates Keycloak installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/keycloak` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add codecentric https://codecentric.github.io/helm-charts
helm repo update

# Charts
helm pull codecentric/keycloak --version 18.1.1 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v99-99-99 <!-- omit in toc -->

## Helm charts: `codecentric/keycloak` v18.1.1 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/keycloak` repository directory.

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

- <https://github.com/codecentric/helm-charts/tree/master/charts/keycloak>
- <https://www.keycloak.org/>

---

## v22-01-05

### Background

Keycloak chart 16.0.5 updates chart components in keycloak appVersion 15.0.2.

This procedure updates Keycloak installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/keycloak` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add codecentric https://codecentric.github.io/helm-charts
helm repo update

# Charts
helm pull codecentric/keycloak --version 16.0.5 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: `codecentric/keycloak` v16.0.5 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & upgrade

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/keycloak` folder repository.

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

- <https://github.com/codecentric/helm-charts/tree/master/charts/keycloak>
- <https://www.keycloak.org/>
