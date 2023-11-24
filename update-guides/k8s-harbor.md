<!-- markdownlint-disable MD024 -->

# k8s-harbor <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v23-11-24](#v23-11-24)
  - [Background](#background)
  - [How-to guides](#how-to-guides)
    - [1.- Backup PostgreSQL database version](#1--backup-postgresql-database-version)
    - [2.- Uninstall harbor namespace](#2--uninstall-harbor-namespace)
    - [3.- Deploy New Postgres Image in a limited namespace](#3--deploy-new-postgres-image-in-a-limited-namespace)
    - [4.- Import PostgreSQL Dump into the new pod](#4--import-postgresql-dump-into-the-new-pod)
    - [5.- Uninstall namespace \& remove pv-chartmuseum.yaml](#5--uninstall-namespace--remove-pv-chartmuseumyaml)
    - [6.- Update configuration files](#6--update-configuration-files)
    - [7.- Pull charts \& install](#7--pull-charts--install)
  - [Reference](#reference)
- [v23-04-27](#v23-04-27)
  - [Background](#background-1)
  - [How-to guides](#how-to-guides-1)
    - [1.- Uninstall harbor namespace](#1--uninstall-harbor-namespace)
    - [2.- Rename old configuration directory](#2--rename-old-configuration-directory)
    - [3.- Create new configuration from new template](#3--create-new-configuration-from-new-template)
    - [4.- Create new data service directory on k8s-mod-n1](#4--create-new-data-service-directory-on-k8s-mod-n1)
    - [5.- Install new harbor namespace](#5--install-new-harbor-namespace)
  - [Reference](#reference-1)
- [v22-12-19](#v22-12-19)
  - [Background](#background-2)
  - [How-to guides](#how-to-guides-2)
    - [1.- Update configuration files](#1--update-configuration-files)
    - [2.- Pull charts \& update](#2--pull-charts--update)
  - [Reference](#reference-2)
- [v22-08-21](#v22-08-21)
  - [Background](#background-3)
  - [How-to guides](#how-to-guides-3)
    - [1.- Uninstall harbor namespace](#1--uninstall-harbor-namespace-1)
    - [2.- Rename old configuration directory](#2--rename-old-configuration-directory-1)
    - [3.- Create new configuration from new template](#3--create-new-configuration-from-new-template-1)
    - [4.- Install new harbor namespace](#4--install-new-harbor-namespace)
  - [Reference](#reference-3)
- [v22-03-23](#v22-03-23)
  - [Background](#background-4)
  - [How-to guides](#how-to-guides-4)
    - [1.- Update configuration files](#1--update-configuration-files-1)
    - [2.- Pull charts \& update](#2--pull-charts--update-1)
  - [Reference](#reference-4)
- [v22-01-05](#v22-01-05)
  - [Background](#background-5)
  - [How-to guides](#how-to-guides-5)
    - [1.- Update configuration files](#1--update-configuration-files-2)
    - [2.- Pull charts \& upgrade](#2--pull-charts--upgrade)
  - [Reference](#reference-5)
- [v21-12-06](#v21-12-06)
  - [Background](#background-6)
  - [How-to guides](#how-to-guides-6)
    - [1.- Update configuration files](#1--update-configuration-files-3)
    - [2.- Pull charts \& upgrade](#2--pull-charts--upgrade-1)
  - [Reference](#reference-6)

---

## v23-11-24

### Background

Harbor chart 19.1.1 updates components versions in Harbor appVersion 2.9.1. This version deprecates the use of  `notary` and `chartmuseum`.

This procedure updates Harbor installation in k8s-mod cluster.

### How-to guides

#### 1.- Backup PostgreSQL database version

The `pg_dumpall` utility is used for writing out (dumping) all of your PostgreSQL databases of a cluster. It accomplishes this by calling the pg_dump command for each database in a cluster, while also dumping global objects that are common to all databases, such as database roles and tablespaces.

The official PostgreSQL Docker image come bundled with all of the standard utilities, such as pg_dumpall, and it is what we will use in this tutorial to perform a complete backup of our database server.

If your Postgres server is running as a Kubernetes Pod, you will execute the following command:

```bash
kubectl -n harbor exec -i harbor-postgresql-0 -- /bin/bash -c "PGPASSWORD='NoFear21' pg_dumpall -U postgres" > postgresql.dump
```

#### 2.- Uninstall harbor namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/harbor` repository directory.

- Remove harbor namespace by running:

```bash
# Uninstall chart and namespace.  
./csdeploy.sh -m uninstall
```

#### 3.- Deploy New Postgres Image in a limited namespace

The second step is to deploy a new Postgress container using the updated image version. This container MUST NOT mount the same volume from the older Postgress container. It will need to mount a new volume for the database.

>**Note**: If you mount to a previous volume used by the older Postgres server, the new Postgres server will fail. Postgres requires the data to be migrated before it can load it.

To deploy the new version on an empty volume:

- Delete the PostgreSQL data service (view snippets in README.md)
- Re-Create the PostgreSQL data service (view snippets in README.md)
- Change the following section of `values-harbor` to update PostgreSQL:

```yaml
postgresql:
  enabled: true
  image:
    registry: docker.io
    repository: bitnami/postgresql
    tag: 13.12.0-debian-11-r57
...
```

- Deploy the namespace by running `csdeploy.sh -m install`

#### 4.- Import PostgreSQL Dump into the new pod
With the new Postgres container running with a new volume mount for the data directory, you will use the psql command to import the database dump file. During the import process Postgres will migrate the databases to the latest system schema.

```bash
kubectl -n harbor exec -i harbor-postgresql-0 -- /bin/bash -c "PGPASSWORD='NoFear21' psql -U postgres" < postgresql.dump
```

#### 5.- Uninstall namespace & remove pv-chartmuseum.yaml
- Uninstall the namespace by running `csdeploy.sh -m uninstall`
- Rename deprecated chartmuseum PV to`deprecated-pv-chartmuseum.yaml`

#### 6.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/harbor` folder repository.

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
helm pull bitnami/harbor --version 19.2.1 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v23-11-24 <!-- omit in toc -->

## Helm charts: bitnami/harbor v19.1.1 <!-- omit in toc -->
```

- Save file

#### 7.- Pull charts & install

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/harbor` repository directory.

Execute the following commands to pull charts and install namespace:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m install

# Check status
./csdeploy.sh -l
```

### Reference

- <https://github.com/bitnami/charts/tree/master/bitnami/harbor>

---

## v23-04-27

### Background

Harbor chart 16.4.10 updates components versions in Harbor appVersion 2.7.0. This version requires the addition of a new data service and persistent volume for `harbor-scandata`.

This procedure updates Harbor installation in k8s-mod cluster.

### How-to guides

#### 1.- Uninstall harbor namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/harbor` repository directory.

- Remove harbor namespace by running:

```bash
# Uninstall chart and namespace.  
./csdeploy.sh -m uninstall
```

#### 2.- Rename old configuration directory

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/` repository directory.

- Rename `cs-mod/k8s-mod/harbor` directory to `cs-mod/k8s-mod/harbor-dep`

>**Note**: This configuration directory can be reused to reinstall the namespace in case the migration procedure fails.

#### 3.- Create new configuration from new template

From VS Code Remote connected to `mcc`, open  terminal at `_cfg-fabric` repository directory.

- Update configuration runbook models following instructions in `README.md` file.
- Generate new configuration directory following instructions in runbook `_rb-k8s-mod-harbor.md` file.

>**Note**: Configuration data must match with the used in the old deployment.


#### 4.- Create new data service directory on k8s-mod-n1

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/harbor` folder repository.

Asuming that your PV is supported by node k8s-mod-n1, execute the following command to create the new directory needed for `harbor-scandata`:

```bash
#
# Create directory for harbor-scandata
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh kos@k8s-mod-n1.cskylab.net \
  'sudo mkdir -v "/srv/harbor/data/scandata" \
  ; ls -lah /srv/harbor/data/' \
;  echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

>**Note:** Directory must be created only in k8s node that supports the service, also called "PV node". "RSync node" will get data by synchronizing with PV node.

#### 5.- Install new harbor namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/harbor` repository directory.

Install harbor namespace by running:

```bash
# Install chart and namespace.  
./csdeploy.sh -m install
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```

- After migration, remove old configuration directory `cs-mod/k8s-mod/harbor-dep`

### Reference

- <https://github.com/bitnami/charts/tree/master/bitnami/harbor>

---


## v22-12-19

### Background

Harbor chart 16.1.1 updates components versions in Harbor appVersion 2.7.0.

This procedure updates Harbor installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/harbor` folder repository.

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
helm pull bitnami/harbor --version 16.1.1 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v22-12-19 <!-- omit in toc -->

## Helm charts: bitnami/harbor v16.1.1 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/harbor` repository directory.

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

- <https://github.com/bitnami/charts/tree/master/bitnami/harbor>

---

## v22-08-21

### Background

Bitnami/Harbor chart 15.0.5 deploys Harbor appVersion 2.5.3.

This upgrade requires to uninstall and re-install the namespace. The Harbor LVM data service will preserve existing data.

This procedure updates Harbor installation in k8s-mod cluster.

### How-to guides

#### 1.- Uninstall harbor namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/harbor` repository directory.

- Remove harbor namespace by running:

```bash
# Uninstall chart and namespace.  
./csdeploy.sh -m uninstall
```

#### 2.- Rename old configuration directory

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/` repository directory.

- Rename `cs-mod/k8s-mod/harbor` directory to `cs-mod/k8s-mod/harbor-dep`

>**Note**: This configuration directory can be reused to reinstall the namespace in case the migration procedure fails.

#### 3.- Create new configuration from new template

From VS Code Remote connected to `mcc`, open  terminal at `_cfg-fabric` repository directory.

- Update configuration runbook models following instructions in `README.md` file.
- Generate new configuration directory following instructions in runbook `_rb-k8s-mod-harbor.md` file.

>**Note**: Configuration data must match with the used in the old deployment.

#### 4.- Install new harbor namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/harbor` repository directory.

Install harbor namespace by running:

```bash
# Install chart and namespace.  
./csdeploy.sh -m install
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```

- After migration, remove old configuration directory `cs-mod/k8s-mod/harbor-dep`

### Reference

- <https://github.com/bitnami/charts/tree/master/bitnami/harbor>

---


## v22-03-23

### Background

Harbor chart 11.2.4 updates components versions in Harbor appVersion 2.4.1.

This procedure updates Harbor installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/harbor` folder repository.

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
helm pull bitnami/harbor --version 11.2.4 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v22-03-23 <!-- omit in toc -->

## Helm charts: bitnami/harbor v11.2.4 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/harbor` repository directory.

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

- <https://github.com/bitnami/charts/tree/master/bitnami/harbor>

---

## v22-01-05

### Background

Harbor chart 11.1.6 updates components versions in Harbor appVersion 2.4.1.

This procedure updates Harbor installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/harbor` folder repository.

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
helm pull bitnami/harbor --version 11.1.6 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: bitnami/harbor v11.1.6 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & upgrade

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/harbor` folder repository.

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

- <https://github.com/bitnami/charts/tree/master/bitnami/harbor>

---

## v21-12-06

### Background

Harbor chart 11.1.5 updates components versions in Harbor appVersion 2.4.0.

This procedure updates Harbor installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/harbor` folder repository.

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
helm pull bitnami/harbor --version 11.1.5 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: bitnami/harbor v11.1.5 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & upgrade

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/harbor` folder repository.

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

- <https://github.com/bitnami/charts/tree/master/bitnami/harbor>
