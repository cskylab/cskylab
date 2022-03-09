<!-- markdownlint-disable MD024 -->

# k8s-nextcloud <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v22-01-05](#v22-01-05)
  - [Background](#background)
  - [How-to guides](#how-to-guides)
    - [1.- Change redis to standalone mode](#1--change-redis-to-standalone-mode)
    - [2.- Update configuration files](#2--update-configuration-files)
    - [3.- Pull charts & re-install application](#3--pull-charts--re-install-application)
  - [Reference](#reference)
- [v21-12-06](#v21-12-06)
  - [Background](#background-1)
  - [How-to guides](#how-to-guides-1)
    - [1.- Update configuration files](#1--update-configuration-files)
    - [2.- Pull charts & upgrade](#2--pull-charts--upgrade)
  - [Reference](#reference-1)

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
