<!-- markdownlint-disable MD024 -->

# k8s-keycloakx <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v99-99-99](#v99-99-99)
  - [Background](#background)
  - [How-to guides](#how-to-guides)
    - [PostgreSQL migration](#postgresql-migration)
    - [Keycloak migration](#keycloak-migration)
  - [Reference](#reference)
- [v23-04-27](#v23-04-27)
  - [Background](#background-1)
  - [How-to guides](#how-to-guides-1)
    - [1.- Uninstall keycloakx namespace](#1--uninstall-keycloakx-namespace)
    - [2.- Rename old configuration directory](#2--rename-old-configuration-directory)
    - [3.- Create new configuration from new template](#3--create-new-configuration-from-new-template)
    - [4.- Install new keycloakx namespace](#4--install-new-keycloakx-namespace)
  - [Reference](#reference-1)
- [v22-12-19](#v22-12-19)
  - [Background](#background-2)
  - [How-to guides](#how-to-guides-2)
    - [1.- Change image section in values-postgresql.yaml](#1--change-image-section-in-values-postgresqlyaml)
    - [2.- Update script cs-deploy.sh](#2--update-script-cs-deploysh)
    - [3.- Pull charts \& update](#3--pull-charts--update)
  - [Reference](#reference-2)

---
## v99-99-99

### Background

Chart codecentric/keycloakx 2.3.0 updates chart components in keycloak appVersion 22.0.4
Chart bitnami/postgresql 13.1.5 updates chart components in postgresql appVersion 15.x (image selected in values-posgresql.yaml)   

### How-to guides

#### PostgreSQL migration

- This upgrade requires to update from postgresql 14 to 15 version following the new procedure covered in `README.md`. 

#### Keycloak migration

- Change the following sections in helm chart values file `values-keycloakx.yaml`:

```yaml
image:
  # The Keycloak image repository
  repository: quay.io/keycloak/keycloak
  # Overrides the Keycloak image tag whose default is the chart appVersion
  tag: "22.0.4"
  # Overrides the Keycloak image tag with a specific digest
  digest: ""
  # The Keycloak image pull policy
  pullPolicy: IfNotPresent

```

```yaml
# Additional environment variables for Keycloak
extraEnv: |
  - name: KEYCLOAK_ADMIN
    value: keycloak
  - name: KEYCLOAK_ADMIN_PASSWORD
    value: "{{ .publishing.password }}"
  - name: JAVA_OPTS_APPEND
    value: >-
      -Djgroups.dns.query={{ include "keycloak.fullname" . }}-headless
      -XX:+UseContainerSupport
      -XX:MaxRAMPercentage=50.0
      -Djava.net.preferIPv4Stack=true
      -Djava.awt.headless=true
```

```yaml
## Overrides the default entrypoint of the Keycloak container
command:
  - "/opt/keycloak/bin/kc.sh"
  - "start"
  - "--http-enabled=true"
  - "--http-port=8080"
  - "--hostname-strict=false"
  - "--hostname-strict-https=false"

```

- Change `csdeploy.sh` to migrate keycloak to intermediate codecentric/keycloakx 2.2.2 (appVersion 21.1.1)
- Change `csdeploy.sh` to migrate keycloak to verskon codecentric/keycloakx 2.3.0 (appVersion 22.0.4)

### Reference

- <https://github.com/codecentric/helm-charts/tree/master/charts/keycloakx>
- <https://www.keycloak.org/>

---


## v23-04-27

### Background

Chart codecentric/keycloakx 2.1.1 updates chart components in keycloak appVersion 20.0.3
Chart bitnami/postgresql 12.3.1 updates chart components in postgresql appVersion 14.x (image selected in values-posgresql.yaml)   

This upgrade covers changes in customizing theme providers and requires to uninstall and re-install the namespace. The keycloakx postresql LVM data service will preserve existing data.

This procedure updates Harbor installation in k8s-mod cluster.

### How-to guides

#### 1.- Uninstall keycloakx namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/keycloakx` repository directory.

- Remove keycloakx namespace by running:

```bash
# Uninstall chart and namespace.  
./csdeploy.sh -m uninstall
```

#### 2.- Rename old configuration directory

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/` repository directory.

- Rename `cs-mod/k8s-mod/keycloakx` directory to `cs-mod/k8s-mod/keycloakx-dep`

>**Note**: This configuration directory can be reused to reinstall the namespace in case the migration procedure fails.

#### 3.- Create new configuration from new template

From VS Code Remote connected to `mcc`, open  terminal at `_cfg-fabric` repository directory.

- Update configuration runbook models following instructions in `README.md` file.
- Generate new configuration directory following instructions in runbook `_rb-k8s-mod-keycloakx.md` file.

>**Note**: Configuration data must match with the used in the old deployment.

#### 4.- Install new keycloakx namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/keycloakx` repository directory.

Install keycloakx namespace by running:

```bash
# Install chart and namespace.  
./csdeploy.sh -m install
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```

- After migration, remove old configuration directory `cs-mod/k8s-mod/keycloakx-dep`

### Reference

- <https://github.com/codecentric/helm-charts/tree/master/charts/keycloak>
- <https://www.keycloak.org/>

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
