<!-- markdownlint-disable MD024 -->

# k8s-keycloakx <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v22-12-19](#v22-12-19)
  - [Background](#background)
  - [How-to guides](#how-to-guides)
    - [1.- Change image section in values-postgresql.yaml](#1--change-image-section-in-values-postgresqlyaml)
    - [2.- Update script cs-deploy.sh](#2--update-script-cs-deploysh)
    - [3.- Pull charts \& update](#3--pull-charts--update)
  - [Reference](#reference)

---

## v22-12-19

### Background

This update covers the following charts upgrades:

- **codecentric/keycloakx** (Note that this chart is the logical successor of the Wildfly based codecentric/keycloak chart.):
  - From v1.6.0 with appVersion 18.0.0
  - To v2.1.0 with appVersion 20.0.1
  
- **bitnami/postgresql**:
  - From 11.7.1 appVersion 14.5.0
  - To 12.1.5 appVersion 14.x (PostgreSQL versions > 14 should not be used without database migration)

Regarding the version changes in keycloack application see:

- <https://www.keycloak.org/2022/03/releases.html>

PostgreSQL image repository must be maintained in version 14. It is required to modify this parameter in file `values-postgresql.yaml`.

This procedure updates Keycloakx installation in k8s-mod cluster.

### How-to guides

#### 1.- Change image section in values-postgresql.yaml

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/keycloakx` application folder repository.

- Edit `values-postgresql.yaml` file
- Look for the following section, and change values as follows:

```yaml
## Bitnami PostgreSQL image version
## ref: https://hub.docker.com/r/bitnami/postgresql/tags/
## @param image.tag PostgreSQL image tag (immutable tags are recommended)
##
image:
#   tag: 14.5.0-debian-11-r0
  tag: 14
```

- Save the file

#### 2.- Update script cs-deploy.sh

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
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull codecentric/keycloakx --version 2.1.0 --untar
helm pull bitnami/postgresql --version 12.1.5 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v22-12-19 <!-- omit in toc -->

## Helm charts: <!-- omit in toc -->

- codecentric/keycloakx v2.1.0 appVersion 20.0.1 (Note that this chart is the logical successor of the Wildfly based codecentric/keycloak chart.)
- bitnami/postgresql 12.1.5 appVersion 14.x      
```

- Save file

#### 3.- Pull charts & update

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/keycloakx` repository directory.

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
