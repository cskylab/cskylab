<!-- markdownlint-disable MD024 -->

# k8s-gitlab<!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v99-99-99](#v99-99-99)
  - [Background](#background)
    - [Prerequisites](#prerequisites)
  - [How-to guides](#how-to-guides)
    - [1.- Update PostgreSQL chart and appVersion to latest v14](#1--update-postgresql-chart-and-appversion-to-latest-v14)
    - [2.- Perform all intermediate gitlab charts upgrades with PostgreSQL v14](#2--perform-all-intermediate-gitlab-charts-upgrades-with-postgresql-v14)
    - [3.- Perform final configuration steps after upgrade](#3--perform-final-configuration-steps-after-upgrade)
  - [Reference](#reference)
- [v23-11-24](#v23-11-24)
  - [Background](#background-1)
    - [Prerequisites](#prerequisites-1)
  - [How-to guides](#how-to-guides-1)
    - [1.- Upgrade postgresql from v12 to v13 database](#1--upgrade-postgresql-from-v12-to-v13-database)
    - [2.- Perform all intermediate gitlab charts upgrades with PostgreSQL v13](#2--perform-all-intermediate-gitlab-charts-upgrades-with-postgresql-v13)
    - [3.- Upgrade postgresql from v13 to v14 database](#3--upgrade-postgresql-from-v13-to-v14-database)
    - [4.- Perform all intermediate gitlab charts upgrades with PostgreSQL v14](#4--perform-all-intermediate-gitlab-charts-upgrades-with-postgresql-v14)
    - [5.- Perform final configuration steps after upgrade](#5--perform-final-configuration-steps-after-upgrade)
  - [Reference](#reference-1)
- [v23-04-27](#v23-04-27)
  - [Background](#background-2)
    - [Prerequisites](#prerequisites-2)
  - [How-to guides](#how-to-guides-2)
    - [1.- Upgrade postgresql chart](#1--upgrade-postgresql-chart)
    - [2.- Perform all intermediate gitlab charts upgrades](#2--perform-all-intermediate-gitlab-charts-upgrades)
    - [3.- Perform final configuration steps after upgrade](#3--perform-final-configuration-steps-after-upgrade-1)
  - [Reference](#reference-2)
- [v22-12-19](#v22-12-19)
  - [Background](#background-3)
    - [Prerequisites](#prerequisites-3)
  - [How-to guides](#how-to-guides-3)
    - [1.- Change image section in values-postgresql.yaml](#1--change-image-section-in-values-postgresqlyaml)
    - [2.- Perform all intermediate gitlab charts upgrades](#2--perform-all-intermediate-gitlab-charts-upgrades-1)
    - [3.- Perform final configuration steps after upgrade](#3--perform-final-configuration-steps-after-upgrade-2)
  - [Reference](#reference-3)
- [v22-08-21](#v22-08-21)
  - [Background](#background-4)
    - [Prerequisites](#prerequisites-4)
  - [How-to guides](#how-to-guides-4)
    - [1.- Uninstall gitlab namespace](#1--uninstall-gitlab-namespace)
    - [2.- Rename old configuration directory](#2--rename-old-configuration-directory)
    - [3.- Create new configuration from new template](#3--create-new-configuration-from-new-template)
    - [4.- Prepare configuration files in the new directory](#4--prepare-configuration-files-in-the-new-directory)
    - [5.- Install new gitlab namespace](#5--install-new-gitlab-namespace)
    - [6.- Restore the rail secrets](#6--restore-the-rail-secrets)
    - [7.- Perform all intermediate gitlab charts upgrades](#7--perform-all-intermediate-gitlab-charts-upgrades)
    - [8.- Perform final configuration steps after upgrade](#8--perform-final-configuration-steps-after-upgrade)
    - [9.- Update new restic backup and rsync procedures](#9--update-new-restic-backup-and-rsync-procedures)
  - [Reference](#reference-4)
- [v22-03-23](#v22-03-23)
  - [Background](#background-5)
    - [Prerequisites](#prerequisites-5)
  - [How-to guides](#how-to-guides-5)
    - [1.- Intermediate update to gitlab chart 5.6.6](#1--intermediate-update-to-gitlab-chart-566)
      - [1a.- Update configuration files](#1a--update-configuration-files)
      - [1b.- Pull charts \& update](#1b--pull-charts--update)
    - [2.- Intermediate update to gitlab chart 5.7.5](#2--intermediate-update-to-gitlab-chart-575)
      - [2a.- Update configuration files](#2a--update-configuration-files)
      - [2b.- Pull charts \& update](#2b--pull-charts--update)
    - [3.- Final update to gitlab chart 5.8.4](#3--final-update-to-gitlab-chart-584)
      - [3a.- Update configuration files](#3a--update-configuration-files)
      - [3b.- Pull charts \& update](#3b--pull-charts--update)
  - [Reference](#reference-5)
- [v22-01-05](#v22-01-05)
  - [Background](#background-6)
    - [Prerequisites](#prerequisites-6)
  - [How-to guides](#how-to-guides-6)
    - [1.- Intermediate update to gitlab chart 5.5.2](#1--intermediate-update-to-gitlab-chart-552)
      - [1a.- Update configuration files](#1a--update-configuration-files-1)
      - [1b.- Pull charts \& upgrade](#1b--pull-charts--upgrade)
    - [2.- Update to gitlab chart 5.6.0](#2--update-to-gitlab-chart-560)
      - [2a.- Update configuration files](#2a--update-configuration-files-1)
      - [2b.- Pull charts \& upgrade](#2b--pull-charts--upgrade)
  - [Reference](#reference-6)
- [v21-12-06](#v21-12-06)
  - [Background](#background-7)
  - [How-to guides](#how-to-guides-7)
    - [1.- Rename section in values-gitlab.yaml](#1--rename-section-in-values-gitlabyaml)
    - [2.- Update configuration files](#2--update-configuration-files)
    - [3.- Pull charts \& upgrade](#3--pull-charts--upgrade)
  - [Reference](#reference-7)

---

## v99-99-99

### Background

This procedure updates to the following versions:
- GitLab chart to version v7.10.1 with appVersion 16.10.1. Following Gitlab recommendations, updates to a new release must be made from the latest minor version of the previous release.

- Postgresql chart v15.2.5, with application version 14.11.0

This procedure updates gitlab installation in k8s-mod cluster.

#### Prerequisites

You must be running at least:
- GitLab chart v7.6.0 with appVersion 16.6.0. (Updated or deployed from cSkyLab v23-11-24)
- Postgresql chart v13.2.16, with application version 14.x

### How-to guides

#### 1.- Update PostgreSQL chart and appVersion to latest v14

- Edit `csdeploy.sh` file and change the gitlab chart version on `source_charts` variable with the appropriate values:

```bash
# Command to paste
...
...
helm pull bitnami/postgresql --version 15.2.2 --untar
...
...
```

- Edit `values-postgresql.yaml` file to download the appropriate image of postgresql:
```yaml
## Bitnami PostgreSQL image version
## ref: https://hub.docker.com/r/bitnami/postgresql/tags/
## @param image.tag PostgreSQL image tag (immutable tags are recommended)
##
image:
  # tag: 12.12.0-debian-11-r1
  tag: 14.11.0
```

- Pull new chart by running:

```bash
# Pull new chart versions
./csdeploy.sh -m pull-charts
```

- Update gitlab namespace by running:

```bash
# Redeploy upgraded chart.  
./csdeploy.sh -m update
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```


#### 2.- Perform all intermediate gitlab charts upgrades with PostgreSQL v14

Gitlab charts updates must be made one at a time from the latest minor version of the previous.

To do so, repeat the following steps for every intermediate chart version:

- Edit `csdeploy.sh` file and change the gitlab chart version on `source_charts` variable with the appropriate values:

```bash
# Command to paste
...
...
helm pull gitlab/gitlab --version x.x.x --untar
...
...
```

- Pull new chart by running:

```bash
# Pull new chart versions
./csdeploy.sh -m pull-charts
```

- Update gitlab namespace by running:

```bash
# Redeploy upgraded chart.  
./csdeploy.sh -m update
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```

>**Note**: In every upgrade, you must wait at least 10 minutes until pod `gitlab-migrations-X-xxxxx` status is **COMPLETED**. Before to perform the next one, check the application is running properly with its data.

You must perform all intermediate gitlab chart upgrades for every of these chart versions:

| Version                          | Command to paste                                 |
| -------------------------------- | ------------------------------------------------ |
| From chart 7.6.0 to chart 7.6.7  | helm pull gitlab/gitlab --version 7.6.7 --untar  |
| From chart 7.6.7 to chart 7.7.7  | helm pull gitlab/gitlab --version 7.7.7 --untar  |
| From chart 7.7.7 to chart 7.8.5  | helm pull gitlab/gitlab --version 7.8.5 --untar  |
| From chart 7.8.5 to chart 7.9.3  | helm pull gitlab/gitlab --version 7.9.3 --untar  |
| From chart 7.9.3 to chart 7.10.1 | helm pull gitlab/gitlab --version 7.10.1 --untar |


#### 3.- Perform final configuration steps after upgrade

- After migration, you must save rail secrets to rail-secrets.yaml

```bash
# Save rail secrets to rail-secrets.yaml
kubectl -n=gitlab get secret gitlab-rails-secret -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > rail-secrets.yaml
```

- Edit `README.md` documentation file, and change header as follows:

``` md
## v99-99-99 <!-- omit in toc -->

## Helm charts<!-- omit in toc -->

- **GitLab** chart v7.10.1 with appVersion 16.10.1. Following Gitlab recommendations, updates to a new release must be made from the latest minor version of the previous release.

- **Postgresql** chart v15.2.5, with application version 14.11.0
```


### Reference

- <https://docs.gitlab.com/charts/>

---


## v23-11-24

### Background

This procedure updates to the following versions:
- GitLab chart to version v7.6.0 with appVersion 16.6.0. Following Gitlab recommendations, updates to a new release must be made from the latest minor version of the previous release.

- Postgresql chart v13.2.16, with application version 14.x

This procedure updates gitlab installation in k8s-mod cluster.

#### Prerequisites

You must be running at least:
- GitLab chart v6.11.0 with appVersion v15.11.0 (Updated or deployed from cSkyLab v23-04-27)
- Postgresql chart v12.3.1, with appVersion 12.x

### How-to guides

#### 1.- Upgrade postgresql from v12 to v13 database

1. **Backup Running Container**

The `pg_dumpall` utility is used for writing out (dumping) all of your PostgreSQL databases of a cluster. It accomplishes this by calling the pg_dump command for each database in a cluster, while also dumping global objects that are common to all databases, such as database roles and tablespaces.

The official PostgreSQL Docker image come bundled with all of the standard utilities, such as pg_dumpall, and it is what we will use in this tutorial to perform a complete backup of our database server.

If your Postgres server is running as a Kubernetes Pod, you will execute the following command:

```bash
kubectl -n gitlab exec -i postgresql-0 -- /bin/bash -c "PGPASSWORD='NoFear21' pg_dumpall -U postgres" > postgresql-v12.dump
```

2. **Deploy New Postgres Image in a limited namespace**

The second step is to deploy a new Postgress container using the updated image version. This container MUST NOT mount the same volume from the older Postgress container. It will need to mount a new volume for the database.

>**Note**: If you mount to a previous volume used by the older Postgres server, the new Postgres server will fail. Postgres requires the data to be migrated before it can load it.

To deploy the new version on an empty volume:

- Uninstall the namespace containing the PostgreSQL service (GitLab)
- Perform a manual backup and delete the PostgreSQL data service
- Re-Create an empty PostgreSQL data service
- Change `csdeploy.sh` file with the appropriate values:
```bash
...
...
helm pull bitnami/postgresql --version 13.2.16 --untar
...
...
```
Change `csdeploy.sh` file commenting all helm pull deploying charts lines except `helm pull bitnami/postgresql`

- Remove all charts and pull only `bitnami/postgresql` chart by running `csdeploy.sh - m pull-charts`
- Edit `values-postgresql.yaml` file to download the appropriate image of postgresql:
```yaml
## Bitnami PostgreSQL image version
## ref: https://hub.docker.com/r/bitnami/postgresql/tags/
## @param image.tag PostgreSQL image tag (immutable tags are recommended)
##
image:
  tag: 13
```
- Deploy the namespace by running `csdeploy.sh -m install`

3. **Import PostgreSQL Dump into New Pod**
With the new Postgres container running with a new volume mount for the data directory, you will use the psql command to import the database dump file. During the import process Postgres will migrate the databases to the latest system schema.

```bash
kubectl -n gitlab exec -i postgresql-0 -- /bin/bash -c "PGPASSWORD='NoFear21' psql -U postgres" < postgresql-v12.dump
```

4. **Deploy the namespace with all charts**

Once the PosgreSQL container is running with the new version and dumped data successfully restored, the namespace can be re-started with all its charts:

- Uninstall the namespace
- Change `csdeploy.sh` file un-commenting all helm pull deploying charts lines
- Re-Import all charts by running `csdeploy.sh - m pull-charts`
- Deploy the namespace by running `csdeploy.sh -m install`

#### 2.- Perform all intermediate gitlab charts upgrades with PostgreSQL v13

Gitlab charts updates must be made one at a time from the latest minor version of the previous.

To do so, repeat the following steps for every intermediate chart version:

- Edit `csdeploy.sh` file and change the gitlab chart version on `source_charts` variable with the appropriate values:

```bash
# Command to paste
...
...
helm pull gitlab/gitlab --version x.x.x --untar
...
...
```

- Update gitlab namespace by running:

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

>**Note**: In every upgrade, you must wait at least 10 minutes until pod `gitlab-migrations-X-xxxxx` status is **COMPLETED**. Before to perform the next one, check the application is running properly with its data.

You must perform all intermediate gitlab chart upgrades for every of these chart versions:

| Version                            | Command to paste                                  |
| ---------------------------------- | ------------------------------------------------- |
| From chart 6.11.x to chart 6.11.13 | helm pull gitlab/gitlab --version 6.11.13 --untar |
| From chart 6.11.13 to chart 7.0.8  | helm pull gitlab/gitlab --version 7.0.8 --untar   |
| From chart 7.0.8 to chart 7.1.5    | helm pull gitlab/gitlab --version 7.1.5 --untar   |
| From chart 7.1.5 to chart 7.2.8    | helm pull gitlab/gitlab --version 7.2.8 --untar   |


#### 3.- Upgrade postgresql from v13 to v14 database

1. **Backup Running Container**

The `pg_dumpall` utility is used for writing out (dumping) all of your PostgreSQL databases of a cluster. It accomplishes this by calling the pg_dump command for each database in a cluster, while also dumping global objects that are common to all databases, such as database roles and tablespaces.

The official PostgreSQL Docker image come bundled with all of the standard utilities, such as pg_dumpall, and it is what we will use in this tutorial to perform a complete backup of our database server.

If your Postgres server is running as a Kubernetes Pod, you will execute the following command:

```bash
kubectl -n gitlab exec -i postgresql-0 -- /bin/bash -c "PGPASSWORD='NoFear21' pg_dumpall -U postgres" > postgresql-v13.dump
```

2. **Deploy New Postgres Image in a limited namespace**

The second step is to deploy a new Postgress container using the updated image version. This container MUST NOT mount the same volume from the older Postgress container. It will need to mount a new volume for the database.

>**Note**: If you mount to a previous volume used by the older Postgres server, the new Postgres server will fail. Postgres requires the data to be migrated before it can load it.

To deploy the new version on an empty volume:

- Uninstall the namespace containing the PostgreSQL service (GitLab)
- Perform a manual backup and delete the PostgreSQL data service
- Re-Create an empty PostgreSQL data service
- Change `csdeploy.sh` file with the appropriate values:
```bash
...
...
helm pull bitnami/postgresql --version 13.2.16 --untar
...
...
```
Change `csdeploy.sh` file commenting all helm pull deploying charts lines except `helm pull bitnami/postgresql`

- Remove all charts and pull only `bitnami/postgresql` chart by running `csdeploy.sh - m pull-charts`
- Edit `values-postgresql.yaml` file to download the appropriate image of postgresql:
```yaml
## Bitnami PostgreSQL image version
## ref: https://hub.docker.com/r/bitnami/postgresql/tags/
## @param image.tag PostgreSQL image tag (immutable tags are recommended)
##
image:
  tag: 14
```
- Deploy the namespace by running `csdeploy.sh -m install`

3. **Import PostgreSQL Dump into New Pod**
With the new Postgres container running with a new volume mount for the data directory, you will use the psql command to import the database dump file. During the import process Postgres will migrate the databases to the latest system schema.

```bash
kubectl -n gitlab exec -i postgresql-0 -- /bin/bash -c "PGPASSWORD='NoFear21' psql -U postgres" < postgresql-v13.dump
```

4. **Deploy the namespace with all charts**

Once the PosgreSQL container is running with the new version and dumped data successfully restored, the namespace can be re-started with all its charts:

- Uninstall the namespace
- Change `csdeploy.sh` file un-commenting all helm pull deploying charts lines
- Re-Import all charts by running `csdeploy.sh - m pull-charts`
- Deploy the namespace by running `csdeploy.sh -m install`

#### 4.- Perform all intermediate gitlab charts upgrades with PostgreSQL v14

Gitlab charts updates must be made one at a time from the latest minor version of the previous.

To do so, repeat the following steps for every intermediate chart version:

- Edit `csdeploy.sh` file and change the gitlab chart version on `source_charts` variable with the appropriate values:

```bash
# Command to paste
...
...
helm pull gitlab/gitlab --version x.x.x --untar
...
...
```

- Update gitlab namespace by running:

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

>**Note**: In every upgrade, you must wait at least 10 minutes until pod `gitlab-migrations-X-xxxxx` status is **COMPLETED**. Before to perform the next one, check the application is running properly with its data.

You must perform all intermediate gitlab chart upgrades for every of these chart versions:

| Version                         | Command to paste                                |
| ------------------------------- | ----------------------------------------------- |
| From chart 7.2.8 to chart 7.3.6 | helm pull gitlab/gitlab --version 7.3.6 --untar |
| From chart 7.3.6 to chart 7.4.2 | helm pull gitlab/gitlab --version 7.4.2 --untar |
| From chart 7.4.2 to chart 7.5.2 | helm pull gitlab/gitlab --version 7.5.2 --untar |
| From chart 7.5.2 to chart 7.6.0 | helm pull gitlab/gitlab --version 7.6.0 --untar |

#### 5.- Perform final configuration steps after upgrade

- After migration, you must save rail secrets to rail-secrets.yaml

```bash
# Save rail secrets to rail-secrets.yaml
kubectl -n=gitlab get secret gitlab-rails-secret -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > rail-secrets.yaml
```

### Reference

- <https://docs.gitlab.com/charts/>

---

## v23-04-27

### Background

This procedure updates GitLab chart to version 6.11.0 with appVersion 15.11.0. Following Gitlab recommendations, updates to a new release must be made from the latest minor version of the previous.

Postgresql chart is also updated to version 12.3.1, but application must be maintained in version 12.x.

This procedure updates gitlab installation in k8s-mod cluster.

#### Prerequisites

You must be running at least chart 6.6.2 (Updated or deployed from cSkyLab v22-12-19)

### How-to guides

#### 1.- Upgrade postgresql chart

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` application folder repository.

- Edit `csdeploy.sh` file and change the gitlab chart version on `source_charts` variable with the appropriate values:

```bash
# Command to paste
...
...
helm pull bitnami/postgresql --version 12.3.1 --untar
...
...
```

- Update gitlab namespace by running:

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

#### 2.- Perform all intermediate gitlab charts upgrades

Gitlab charts updates must be made one at a time from the latest minor version of the previous.

To do so, repeat the following steps for every intermediate chart version:

- Edit `csdeploy.sh` file and change the gitlab chart version on `source_charts` variable with the appropriate values:

```bash
# Command to paste
...
...
helm pull gitlab/gitlab --version x.x.x --untar
...
...
```

- Update gitlab namespace by running:

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

>**Note**: In every upgrade, you must wait at least 10 minutes until pod `gitlab-migrations-X-xxxxx` status is **COMPLETED**. Before to perform the next one, check the application is running properly with its data.

You must perform all intermediate gitlab chart upgrades for every of these chart versions:

| Version                           | Command to paste                                 |
| --------------------------------- | ------------------------------------------------ |
| From chart 6.6.x to chart 6.6.8   | helm pull gitlab/gitlab --version 6.6.8 --untar  |
| From chart 6.6.8 to chart 6.7.9   | helm pull gitlab/gitlab --version 6.7.9 --untar  |
| From chart 6.7.9 to chart 6.8.6   | helm pull gitlab/gitlab --version 6.8.6 --untar  |
| From chart 6.8.6 to chart 6.9.5   | helm pull gitlab/gitlab --version 6.9.5 --untar  |
| From chart 6.9.5 to chart 6.10.4  | helm pull gitlab/gitlab --version 6.10.4 --untar |
| From chart 6.10.4 to chart 6.11.0 | helm pull gitlab/gitlab --version 6.11.0 --untar |

#### 3.- Perform final configuration steps after upgrade

- After migration, you must save rail secrets to rail-secrets.yaml

```bash
# Save rail secrets to rail-secrets.yaml
kubectl -n=gitlab get secret gitlab-rails-secret -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > rail-secrets.yaml
```

### Reference

- <https://docs.gitlab.com/charts/>

---

## v22-12-19

### Background

This procedure updates GitLab chart to version 6.6.2 with appVersion 15.6.2. Following Gitlab recommendations, updates to a new release must be made from the latest minor version of the previous.

Postgresql chart is also updated to version 12.1.3, but application must be maintained in version 12.x.

This procedure updates gitlab installation in k8s-mod cluster.

#### Prerequisites

You must be running at least chart 6.2.2 (Updated or deployed from cSkyLab v22-08-21)

### How-to guides

#### 1.- Change image section in values-postgresql.yaml

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` application folder repository.

- Edit `values-postgresql.yaml` file
- Look for the following section, and change values as follows:

```yaml
## Bitnami PostgreSQL image version
## ref: https://hub.docker.com/r/bitnami/postgresql/tags/
## @param image.tag PostgreSQL image tag (immutable tags are recommended)
##
image:
  # tag: 12.12.0-debian-11-r1
  tag: 12
```

- Save the file

- Edit `csdeploy.sh` file and change the gitlab chart version on `source_charts` variable with the appropriate values:

```bash
# Command to paste
...
...
helm pull bitnami/postgresql --version 12.1.3 --untar
...
...
```

- Update gitlab namespace by running:

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

#### 2.- Perform all intermediate gitlab charts upgrades

Gitlab charts updates must be made one at a time from the latest minor version of the previous.

To do so, repeat the following steps for every intermediate chart version:


- Edit `csdeploy.sh` file and change the gitlab chart version on `source_charts` variable with the appropriate values:

```bash
# Command to paste
...
...
helm pull gitlab/gitlab --version x.x.x --untar
...
...
```

- Update gitlab namespace by running:

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

>**Note**: In every upgrade, you must wait at least 10 minutes until pod `gitlab-migrations-X-xxxxx` status is **COMPLETED**. Before to perform the next one, check the application is running properly with its data.

You must perform all intermediate gitlab chart upgrades for every of these chart versions:

| Version                         | Command to paste                                |
| ------------------------------- | ----------------------------------------------- |
| From chart 6.2.x to chart 6.2.5 | helm pull gitlab/gitlab --version 6.2.5 --untar |
| From chart 6.2.5 to chart 6.3.5 | helm pull gitlab/gitlab --version 6.3.5 --untar |
| From chart 6.3.5 to chart 6.4.6 | helm pull gitlab/gitlab --version 6.4.6 --untar |
| From chart 6.4.6 to chart 6.5.7 | helm pull gitlab/gitlab --version 6.5.7 --untar |
| From chart 6.5.7 to chart 6.6.2 | helm pull gitlab/gitlab --version 6.6.2 --untar |

#### 3.- Perform final configuration steps after upgrade

- After migration, you must save rail secrets to rail-secrets.yaml

```bash
# Save rail secrets to rail-secrets.yaml
kubectl -n=gitlab get secret gitlab-rails-secret -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > rail-secrets.yaml
```

### Reference

- <https://docs.gitlab.com/charts/>

---

## v22-08-21

### Background

This upgrade requires to uninstall and re-install the namespace. The Gitlab LVM data service will preserve existing data.

There are two separated steps on this update:

- **Postgresql**: Bitnami chart version 11.7.1 with postgresql image `12.12.0-debian-11-r1`. This chart version cannot be deployed with values from 10.x.x charts.
- **Gitlab**: GitLab chart update to version 6.2.2 with appVersion 15.2.2. Following Gitlab recommendations, updates to a new release must be made from the latest minor version of the previous.

This procedure updates gitlab installation in k8s-mod cluster.

#### Prerequisites

- You must be running at least chart 5.8.4 (Updated or deployed from cSkyLab v22-03-23)
- Restic backups and Rsync directories checked and availables.
- It is **VERY IMPORTANT** to have a fresh copy of the rail secrets backup file `rail-secrets.yaml` on the configuration directory. To do so, execute the following command:

```bash
# Save rail secrets to rail-secrets.yaml
kubectl -n=gitlab get secret gitlab-rails-secret -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > rail-secrets.yaml
```

### How-to guides

#### 1.- Uninstall gitlab namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` repository directory.

- Remove gitlab namespace by running:

```bash
# Uninstall chart and namespace.  
./csdeploy.sh -m uninstall
```

#### 2.- Rename old configuration directory

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/` repository directory.

- Rename `cs-mod/k8s-mod/gitlab` directory to `cs-mod/k8s-mod/gitlab-dep`

>**Note**: This configuration directory can be reused to reinstall the namespace in case the migration procedure fails.

#### 3.- Create new configuration from new template

From VS Code Remote connected to `mcc`, open  terminal at `_cfg-fabric` repository directory.

- Update configuration runbook models following instructions in `README.md` file.
- Generate new configuration directory following instructions in runbook `_rb-k8s-mod-gitlab.md` file.

>**Note**: Configuration data must match with the used in the old deployment.

#### 4.- Prepare configuration files in the new directory

- Copy the rail secrets backup file `rail-secrets.yaml` from the old configuration directory to the new one.
- Copy the file `values-gitlab.yaml` from the old configuration directory to the new one (This file must retain the previously exisisting gitlab configuration).
- Edit `csdeploy.sh` file on the new directory and change the `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add gitlab https://charts.gitlab.io/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull gitlab/gitlab --version 5.8.4 --untar
helm pull bitnami/postgresql --version 11.7.1 --untar

EOF
)"
```

>**Note**: With this configuration, you must be ready to reinstall the gitlab namespace with the same previous gitlab version and the new postgresql chart


#### 5.- Install new gitlab namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/gitlab` repository directory.

Install gitlab namespace by running:

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

#### 6.- Restore the rail secrets

To restore rail secrets from a backup file `rail-secrets.yaml`:

```bash
# Find the object name for the rails secrets (gitlab-rails-secret)
kubectl -n=gitlab get secrets | grep rails-secret

# Delete the existing secret
kubectl -n=gitlab delete secret gitlab-rails-secret

# Create the new secret with the same name from backup file
kubectl -n=gitlab create secret generic gitlab-rails-secret --from-file=secrets.yml=rail-secrets.yaml

# Restart the pods
kubectl -n=gitlab delete pods -lapp=sidekiq \
&& kubectl -n=gitlab delete pods -lapp=webservice \
&& kubectl -n=gitlab delete pods -lapp=toolbox \
&& kubectl -n=gitlab delete pods -lapp=migrations
```

Wait until all pods are running, and check the application is running properly with its data.


#### 7.- Perform all intermediate gitlab charts upgrades

Gitlab charts updates must be made one at a time from the latest minor version of the previous.

To do so, repeat the following steps for every intermediate chart version:


- Edit `csdeploy.sh` file and change the gitlab chart version on `source_charts` variable with the appropriate values:

```bash
# Command to paste
...
...
helm pull gitlab/gitlab --version x.x.x --untar
...
...
```

- Update gitlab namespace by running:

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

>**Note**: In every upgrade, you must wait at least 10 minutes until pod `gitlab-migrations-X-xxxxx` status is **COMPLETED**. Before to perform the next one, check the application is running properly with its data.

You must perform all intermediate gitlab chart upgrades for every of these chart versions:

| Version                          | Command to paste                                 |
| -------------------------------- | ------------------------------------------------ |
| From chart 5.8.x to chart 5.8.6  | helm pull gitlab/gitlab --version 5.8.6 --untar  |
| From chart 5.8.6 to chart 5.9.5  | helm pull gitlab/gitlab --version 5.9.5 --untar  |
| From chart 5.9.5 to chart 5.10.5 | helm pull gitlab/gitlab --version 5.10.5 --untar |
| From chart 5.10.5 to chart 6.0.5 | helm pull gitlab/gitlab --version 6.0.5 --untar  |
| From chart 6.0.5 to chart 6.1.4  | helm pull gitlab/gitlab --version 6.1.4 --untar  |
| From chart 6.1.4 to chart 6.2.2  | helm pull gitlab/gitlab --version 6.2.2 --untar  |

#### 8.- Perform final configuration steps after upgrade

- After migration, yoy must remove the old configuration directory `cs-mod/k8s-mod/gitlab-dep`
- Save rail secrets to rail-secrets.yaml

```bash
# Save rail secrets to rail-secrets.yaml
kubectl -n=namespace get secret gitlab-rails-secret -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > rail-secrets.yaml
```

#### 9.- Update new restic backup and rsync procedures

- Review the new restic backup and rsync procedures in file `README.md`
- Update the cronjobs in kubernetes node and check the jobs are running properly.

### Reference

- <https://docs.gitlab.com/charts/>

---

## v22-03-23

### Background

This procedure updates GitLab chart to version 5.8.4 with appVersion 14.8.4. Following Gitlab recommendations, updates to a new release must be made from the latest minor version of the previous.

In this case, the update process require to perform intermediate updates:

- From chart 5.6.x to chart 5.6.6
- From chart 5.6.6 to chart 5.7.5
- From chart 5.7.5 to chart 5.8.4

This procedure updates gitlab installation in k8s-mod cluster.

#### Prerequisites

You must be running at least chart 5.6.0 (Updated or deployed from cSkyLab v22-01-05)

### How-to guides

#### 1.- Intermediate update to gitlab chart 5.6.6

This step also updates bitnami/postgresql chart to v10.16.2

##### 1a.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add gitlab https://charts.gitlab.io/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull gitlab/gitlab --version 5.6.6 --untar
helm pull bitnami/postgresql --version 10.16.2 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

- Save file

##### 1b.- Pull charts & update

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` repository directory.

Execute the following commands to pull charts and upgrade gitlab:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l

# Save rail secrets to rail-secrets.yaml
kubectl -n=gitlab get secret gitlab-rails-secret -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > rail-secrets.yaml
```

#### 2.- Intermediate update to gitlab chart 5.7.5

##### 2a.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add gitlab https://charts.gitlab.io/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull gitlab/gitlab --version 5.7.5 --untar
helm pull bitnami/postgresql --version 10.16.2 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

- Save file

##### 2b.- Pull charts & update

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` repository directory.

Execute the following commands to pull charts and upgrade gitlab:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l

# Save rail secrets to rail-secrets.yaml
kubectl -n=gitlab get secret gitlab-rails-secret -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > rail-secrets.yaml
```

#### 3.- Final update to gitlab chart 5.8.4

##### 3a.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` repository directory.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add gitlab https://charts.gitlab.io/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull gitlab/gitlab --version 5.8.4 --untar
helm pull bitnami/postgresql --version 10.16.2 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v22-03-23 <!-- omit in toc -->

## Helm charts: gitlab/gitlab v5.8.4 bitnami/postgresql v10.16.2<!-- omit in toc -->
```

- Save file

##### 3b.- Pull charts & update

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` folder repository.

Execute the following commands to pull charts and upgrade gitlab:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l

# Save rail secrets to rail-secrets.yaml
kubectl -n=namespace get secret gitlab-rails-secret -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > rail-secrets.yaml
```

### Reference

- <https://docs.gitlab.com/charts/>

---

## v22-01-05

### Background

This procedure updates GitLab chart to version 5.6.0 with appVersion 14.6.0. Before applying chart 5.6.0 it is mandatory to perform an intermediate update to chart 5.5.2.

This procedure updates gitlab installation in k8s-mod cluster.

#### Prerequisites

You must be running chart 5.5.1 (Updated or deployed from cSkyLab v21-12-06)

### How-to guides

#### 1.- Intermediate update to gitlab chart 5.5.2

##### 1a.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add gitlab https://charts.gitlab.io/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull gitlab/gitlab --version 5.5.2 --untar
helm pull bitnami/postgresql --version 10.13.11 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: gitlab/gitlab v5.5.2 bitnami/postgresql v10.13.11<!-- omit in toc -->
```

- Save file

##### 1b.- Pull charts & upgrade

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` folder repository.

Execute the following commands to pull charts and upgrade gitlab:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l

# Save rail secrets to rail-secrets.yaml
kubectl -n=gitlab get secret gitlab-rails-secret -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > rail-secrets.yaml
```

#### 2.- Update to gitlab chart 5.6.0

##### 2a.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add gitlab https://charts.gitlab.io/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull gitlab/gitlab --version 5.6.0 --untar
helm pull bitnami/postgresql --version 10.14.0 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: gitlab/gitlab v5.6.0 bitnami/postgresql v10.14.0<!-- omit in toc -->
```

- Save file

##### 2b.- Pull charts & upgrade

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` folder repository.

Execute the following commands to pull charts and upgrade gitlab:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l

# Save rail secrets to rail-secrets.yaml
kubectl -n=gitlab get secret gitlab-rails-secret -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > rail-secrets.yaml
```

### Reference

- <https://docs.gitlab.com/charts/>

---

## v21-12-06

### Background

GitLab chart 5.5.1 implements appVersion 14.5.1. In this version `gitlab-task-runner` pod must be renamed to `gitlab-toolbox`.

This procedure updates gitlab installation in k8s-mod cluster.

### How-to guides

#### 1.- Rename section in values-gitlab.yaml

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` folder repository.

- Edit `values-gitlab.yaml` file
- Look for the following section:

```yaml
gitlab:
  ## doc/charts/gitlab/task-runner
  task-runner:
```

- Change values as follow:

```yaml
gitlab:
  ## doc/charts/gitlab/toolbox
  toolbox:
```

- Save the file

#### 2.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add gitlab https://charts.gitlab.io/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull gitlab/gitlab --version 5.5.1 --untar
helm pull bitnami/postgresql --version 10.13.11 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: gitlab/gitlab v5.5.1 bitnami/postgresql v10.13.11<!-- omit in toc -->
```

- Save file

#### 3.- Pull charts & upgrade

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` folder repository.

Execute the following commands to pull charts and upgrade gitlab:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l

# Save rail secrets to rail-secrets.yaml
kubectl -n=gitlab get secret gitlab-rails-secret -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > rail-secrets.yaml
```

### Reference

- <https://docs.gitlab.com/ee/update/deprecations.html#rename-task-runner-pod-to-toolbox>
