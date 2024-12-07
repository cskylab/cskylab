# Kubernetes Mailu<!-- omit in toc -->

## `k8s-mailu` v99-99-99 <!-- omit in toc -->

This namespace installs the Mailu mail system on kubernetes.

Configuration files are deployed from template {{ ._tpldescription }} version {{ ._tplversion }}.

- [TL;DR](#tldr)
- [Prerequisites](#prerequisites)
  - [LVM Data Services](#lvm-data-services)
    - [Persistent Volumes](#persistent-volumes)
- [How-to guides](#how-to-guides)
  - [Install](#install)
  - [Update](#update)
  - [Uninstall](#uninstall)
  - [Remove](#remove)
  - [Display status](#display-status)
  - [Backup \& data protection](#backup--data-protection)
    - [RSync HA copies](#rsync-ha-copies)
    - [Restic backup](#restic-backup)
  - [Upgrade PostgreSQL database version](#upgrade-postgresql-database-version)
  - [Utilities](#utilities)
    - [Passwords and secrets](#passwords-and-secrets)
- [Reference](#reference)
  - [Application modules](#application-modules)
  - [Scripts](#scripts)
    - [cs-deploy](#cs-deploy)
  - [Template values](#template-values)
- [License](#license)

---

## TL;DR

```bash
# Install  
./csdeploy.sh -m install
# Check status
./csdeploy.sh -l
```

Run:

- Published at: `{{ .publishing.url }}`
- Username: `admin`
- Password: `{{ .publishing.password }}`

## Prerequisites

- Administrative access to Kubernetes cluster.
- Helm v3.

### LVM Data Services

Data services are supported by the following nodes:

| Data service                 | Kubernetes PV node           | Kubernetes RSync node           |
| ---------------------------- | ---------------------------- | ------------------------------- |
| `/srv/{{ .namespace.name }}` | `{{ .localpvnodes.all_pv }}` | `{{ .localrsyncnodes.all_pv }}` |

`PV node` is the node that supports the data service in normal operation.

`RSync node` is the node that receives data service copies synchronized by cron-jobs for HA.


To **create** the corresponding LVM data services, execute from your **mcc** management machine the following commands:


```bash
#
# Create LVM data services in PV node
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }} \
  'sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}" \
&& mkdir "/srv/{{ .namespace.name }}/data/postgresql" \
&& mkdir "/srv/{{ .namespace.name }}/data/postfix" \
&& mkdir "/srv/{{ .namespace.name }}/data/dovecot" \
&& mkdir "/srv/{{ .namespace.name }}/data/rspamd" \
&& mkdir "/srv/{{ .namespace.name }}/data/clamav" \
&& mkdir "/srv/{{ .namespace.name }}/data/webmail" \
&& mkdir "/srv/{{ .namespace.name }}/data/redis"' \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

```bash
#
# Create LVM data services in RSync node
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localrsyncnodes.localadminusername }}@{{ .localrsyncnodes.all_pv }}.{{ .localrsyncnodes.domain }} \
  'sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}" \
&& mkdir "/srv/{{ .namespace.name }}/data/postgresql" \
&& mkdir "/srv/{{ .namespace.name }}/data/postfix" \
&& mkdir "/srv/{{ .namespace.name }}/data/dovecot" \
&& mkdir "/srv/{{ .namespace.name }}/data/rspamd" \
&& mkdir "/srv/{{ .namespace.name }}/data/clamav" \
&& mkdir "/srv/{{ .namespace.name }}/data/webmail" \
&& mkdir "/srv/{{ .namespace.name }}/data/redis"' \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```


To **delete** the corresponding LVM data services, execute from your **mcc** management machine the following commands:

```bash
#
# Delete LVM data services in PV node
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }} \
  'sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}"' \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

```bash
#
# Delete LVM data services in RSync node
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localrsyncnodes.localadminusername }}@{{ .localrsyncnodes.all_pv }}.{{ .localrsyncnodes.domain }} \
  'sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}"' \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

#### Persistent Volumes

Review values in all Persistent volume manifests with the name format `./pv-*.yaml`.

The following PersistentVolume & StorageClass manifests are applied:

```bash
# PV manifests
pv-postgresql.yaml
```

The node assigned in `nodeAffinity` section of the PV manifest, will be used when scheduling the pod that holds the service.

## How-to guides

### Install

To Create namespace:

```bash
  #  Create namespace, secrets, config-maps, PV's, apply manifests and install charts.
    ./csdeploy.sh -m install
```

### Update

Reapply module manifests by running:

```bash
  # Reapply manifests
    ./csdeploy.sh -m update
```

### Uninstall

To delete module manifests and namespace run:

```bash
  # Delete manifests, and namespace
    ./csdeploy.sh -m uninstall
```

### Remove

This option is intended to be used only to remove the namespace when uninstall is failed. Otherwise, you must run `./csdeploy.sh -m uninstall`.

To remove namespace and all its contents run:

```bash
  # Remove namespace and all its contents
    ./csdeploy.sh -m remove
```

### Display status

To display namespace status run:

```bash
  # Display namespace, status:
    ./csdeploy.sh -l
```

### Backup & data protection

Backup & data protection must be configured on file `cs-cron_scripts` of the node that supports the data services.

#### RSync HA copies

Rsync cronjobs are used to achieve service HA for LVM data services that supports the persistent volumes. The script `cs-rsync.sh` perform the following actions:

- Take a snapshot of LVM data service in the node that supports the service (PV node)
- Copy and syncrhonize the data to the mirrored data service in the kubernetes node designed for HA (RSync node)
- Remove snapshot in LVM data service

To perform RSync manual copies on demand, execute from your **mcc** management machine the following commands:

>**Warning:** You should not make two copies at the same time. You must check the scheduled jobs in `cs-cron-scripts` and disable them if necesary, in order to avoid conflicts.

```bash
#
# RSync data services
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }} \
  'sudo cs-rsync.sh -q -m rsync-to -d /srv/{{ .namespace.name }} \
  -t {{ .localrsyncnodes.all_pv }}.{{ .namespace.domain }}' \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

**RSync cronjobs:**

The following cron jobs should be added to file `cs-cron-scripts` on the node that supports the service (PV node). Change time schedule as needed:

```bash
################################################################################
# /srv/{{ .namespace.name }} - RSync LVM data services
################################################################################
##
## RSync path:  /srv/{{ .namespace.name }}
## To Node:     {{ .localrsyncnodes.all_pv }}
## At minute 0 past every hour from 8 through 23.
# 0 8-23 * * *     root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/{{ .namespace.name }} >> /var/log/cs-rsync.log 2>&1 ; run-one cs-rsync.sh -q -m rsync-to -d /srv/{{ .namespace.name }} -t {{ .localrsyncnodes.all_pv }}.{{ .namespace.domain }}  >> /var/log/cs-rsync.log 2>&1
```

#### Restic backup

Restic can be configured to perform data backups to local USB disks, remote disk via sftp or cloud S3 storage.

To perform on-demand restic backups execute from your **mcc** management machine the following commands:

>**Warning:** You should not launch two backups at the same time. You must check the scheduled jobs in `cs-cron-scripts` and disable them if necesary, in order to avoid conflicts.

```bash
#
# Restic backup data services
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }} \
  'sudo cs-restic.sh -q -m restic-bck -d  /srv/{{ .namespace.name }} -t {{ .namespace.name }}' \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

To view available backups:

```bash
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }} \
  'sudo cs-restic.sh -q -m restic-list  -t {{ .namespace.name }}' \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

**Restic cronjobs:**

The following cron jobs should be added to file `cs-cron-scripts` on the node that supports the service (PV node). Change time schedule as needed:

```bash
################################################################################
# /srv/{{ .namespace.name }}- Restic backups
################################################################################
##
## Data service:  /srv/{{ .namespace.name }}
## At minute 30 past every hour from 8 through 23.
# 30 8-23 * * *   root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/{{ .namespace.name }} >> /var/log/cs-restic.log 2>&1 ; run-one cs-restic.sh -q -m restic-bck -d  /srv/{{ .namespace.name }}  -t {{ .namespace.name }}  >> /var/log/cs-restic.log 2>&1 && run-one cs-restic.sh -q -m restic-forget   -t {{ .namespace.name }}  -f "--keep-hourly 6 --keep-daily 31 --keep-weekly 5 --keep-monthly 13 --keep-yearly 10" >> /var/log/cs-restic.log 2>&1
```

### Upgrade PostgreSQL database version

1. **Backup Running Container**

The `pg_dumpall` utility is used for writing out (dumping) all of your PostgreSQL databases of a cluster. It accomplishes this by calling the pg_dump command for each database in a cluster, while also dumping global objects that are common to all databases, such as database roles and tablespaces.

The official PostgreSQL Docker image come bundled with all of the standard utilities, such as pg_dumpall, and it is what we will use in this tutorial to perform a complete backup of our database server.

If your Postgres server is running as a Kubernetes Pod, you will execute the following command:

```bash
kubectl -n {{ .namespace.name }} exec -i postgresql-0 -- /bin/bash -c "PGPASSWORD='{{ .publishing.password }}' pg_dumpall -U postgres" > postgresql.dump
```

2. **Deploy New Postgres Image in a limited namespace**

The second step is to deploy a new Postgress container using the updated image version. This container MUST NOT mount the same volume from the older Postgress container. It will need to mount a new volume for the database.

>**Note**: If you mount to a previous volume used by the older Postgres server, the new Postgres server will fail. Postgres requires the data to be migrated before it can load it.

To deploy the new version on an empty volume:

- Uninstall the namespace containing the PostgreSQL service (Keycloakx)
- Delete the PostgreSQL data service
- Re-Create the PostgreSQL data service
- Change `csdeploy.sh` file commenting all helm pull deploying charts lines except `helm pull bitnami/postgresql`
- Remove all charts and pull only `bitnami/postgresql` chart by running `csdeploy.sh - m pull-charts`
- Deploy the namespace by running `csdeploy.sh -m install`

3. **Import PostgreSQL Dump into New Pod**
With the new Postgres container running with a new volume mount for the data directory, you will use the psql command to import the database dump file. During the import process Postgres will migrate the databases to the latest system schema.

```bash
kubectl -n {{ .namespace.name }} exec -i postgresql-0 -- /bin/bash -c "PGPASSWORD='{{ .publishing.password }}' psql -U postgres" < postgresql.dump
```

4. **Deploy the namespace with all charts**

Once the PosgreSQL container is running with the new version and dumped data successfully restored, the namespace can be re-started with all its charts:

- Uninstall the namespace
- Change `csdeploy.sh` file un-commenting all helm pull deploying charts lines
- Re-Import all charts by running `csdeploy.sh - m pull-charts`
- Deploy the namespace by running `csdeploy.sh -m install`

### Utilities

#### Passwords and secrets

Generate passwords and secrets with:

```bash
# Screen
echo $(head -c 512 /dev/urandom | LC_ALL=C tr -cd 'a-zA-Z0-9' | head -c 16)

# File (without newline)
printf $(head -c 512 /dev/urandom | LC_ALL=C tr -cd 'a-zA-Z0-9' | head -c 16) > RESTIC-PASS.txt
```

Change the parameter `head -c 16` according with the desired length of the secret.


## Reference

To learn more see:

- <https://github.com/Mailu/helm-charts/tree/master/mailu>

### Application modules

| Module                      | Description                |
| --------------------------- | -------------------------- |

### Scripts

#### cs-deploy

```console
Purpose:
   Kubernetes Mailu mail system.

Usage:
  sudo csdeploy.sh [-l] [-m <execution_mode>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List current status.
  -m  <execution_mode>  - Valid modes are:

      [pull-charts]     - Pull charts to './charts/' directory.
      [install]         - Create namespace, secrets, config-maps, PV's,
                          apply manifests and install charts.
      [update]          - Reapply manifests and update or upgrade charts.
      [uninstall]       - Uninstall charts, delete manifests, remove PV's and namespace.
      [remove]          - Remove PV's, namespace and all its contents.

Options and arguments:  
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Pull charts to './charts/' directory
    ./csdeploy.sh -m pull-charts

  # Create namespace, secrets, config-maps, PV's, apply manifests and install charts.
    ./csdeploy.sh -m install

  # Reapply manifests and update or upgrade charts.
    ./csdeploy.sh -m update

  # Uninstall charts, delete manifests, remove PV's and namespace.
    ./csdeploy.sh -m uninstall

  # Remove PV's, namespace and all its contents
    ./csdeploy.sh -m remove

  # Display namespace, persistence and charts status:
    ./csdeploy.sh -l
```

**Tasks performed:**

| ${execution_mode}                | Tasks                      | Block / Description                                                         |
| -------------------------------- | -------------------------- | --------------------------------------------------------------------------- |
| [pull-charts]                    |                            | **Pull helm charts from repositories**                                      |
|                                  | Clean `./charts` directory | Remove all contents in `./charts` directory.                                |
|                                  | Pull helm charts           | Pull new charts according to sourced script in variable `source_charts`.    |
|                                  | Show charts                | Show Helm charts pulled into `./charts` directory.                          |
| [install]                        |                            | **Create namespace, config-maps, secrets and PV's**                         |
|                                  | Create namespace           | Namespace must be unique in cluster.                                        |
|                                  | Create secrets             | Create secrets containing usernames, passwords... etc.                      |
|                                  | Create PV's                | Apply all persistent volume manifests in the form `pv-*.yaml`.              |
| [update] [install]               |                            | **Deploy app mod's and charts**                                             |
|                                  | Apply manifests            | Apply all app module manifests in the form `mod-*.yaml`.                    |
|                                  | Deploy charts              | Deploy all charts in `./charts` directory with `upgrade --install` options. |
| [uninstall]                      |                            | **Uninstall charts and app mod's**                                          |
|                                  | Delete manifests           | Delete all app module manifests in the form `mod-*.yaml`.                   |
|                                  | Uninstall charts           | Uninstall all charts in `./charts` directory.                               |
| [uninstall] [remove]             |                            | **Remove namespace and PV's**                                               |
|                                  | Remove namespace           | Remove namespace and all its objects.                                       |
|                                  | Delete PV's                | Delete all persistent volume manifests in the form `pv-*.yaml`.             |
| [install] [update] [list-status] |                            | **Display status information**                                              |
|                                  | Display namespace          | Namespace and object status.                                                |
|                                  | Display certificates       | Certificate status information.                                             |
|                                  | Display secrets            | Secret status information.                                                  |
|                                  | Display persistence        | Persistence status information.                                             |
|                                  | Display charts             | Charts releases history information.                                        |
|                                  |                            |                                                                             |

### Template values

The following table lists template configuration parameters and their specified values, when machine configuration files were created from the template:

| Parameter                   | Description                                      | Values                             |
| --------------------------- | ------------------------------------------------ | ---------------------------------- |
| `_tplname`                  | template name                                    | `{{ ._tplname }}`                  |
| `_tpldescription`           | template description                             | `{{ ._tpldescription }}`           |
| `_tplversion`               | template version                                 | `{{ ._tplversion }}`               |
| `kubeconfig`                | kubeconfig file                                  | `{{ .kubeconfig }}`                |
| `namespace.name`            | namespace name                                   | `{{ .namespace.name }}`            |
| `namespace.domain`          | domain name                                      | `{{ .namespace.domain }}`          |
| `publishing.url`            | external URL                                     | `{{ .publishing.url }}`            |
| `certificate.clusterissuer` | cert-manager clusterissuer                       | `{{ .certificate.clusterissuer }}` |
| `registry.proxy`            | docker private proxy URL                         | `{{ .registry.proxy }}`            |

## License

Copyright © 2024 cSkyLab.com ™

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
