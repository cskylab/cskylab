# [Harbor](https://goharbor.io/) registry <!-- omit in toc -->

## Helm charts: bitnami/harbor v11.1.0<!-- omit in toc -->

[Harbor](https://goharbor.io/) is an open source registry that secures artifacts with policies and role-based access control, ensures images are scanned and free from vulnerabilities, and signs images as trusted. Harbor, a CNCF Graduated project, delivers compliance, performance, and interoperability to help you consistently and securely manage artifacts across cloud native compute platforms like Kubernetes and Docker.

Configuration files are deployed from template {{ ._tpldescription }} version {{ ._tplversion }}.

  ![ ](./images/harbor-sample-2021-11-07_19-32-56.png)

- [TL;DR](#tldr)
- [Prerequisites](#prerequisites)
  - [Persistent Volumes](#persistent-volumes)
  - [LVM Data Services](#lvm-data-services)
    - [Backup & data protection](#backup--data-protection)
- [How-to guides](#how-to-guides)
  - [Pull Charts](#pull-charts)
  - [Install](#install)
  - [Update](#update)
  - [Uninstall](#uninstall)
  - [Remove](#remove)
  - [Display status](#display-status)
  - [Create private registry](#create-private-registry)
  - [Create dockerhub proxy](#create-dockerhub-proxy)
  - [Utilities](#utilities)
    - [Passwords and secrets](#passwords-and-secrets)
- [Reference](#reference)
  - [Helm charts and values](#helm-charts-and-values)
  - [Scripts](#scripts)
    - [cs-deploy](#cs-deploy)
  - [Template values](#template-values)
- [License](#license)

---

## TL;DR

Prepare LVM Data services for PV's:

- [LVM Data Services](#lvm-data-services)

Install namespace and charts:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts
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

### Persistent Volumes

Review values in all Persistent volume manifests with the name format `./pv-*.yaml`.

The following PersistentVolume & StorageClass manifests are applied:

```bash
# PV manifests
pv-chartmuseum.yaml
pv-jobservice.yaml
pv-postgresql.yaml
pv-redis.yaml
pv-registry.yaml
pv-trivy.yaml
```

The node assigned in `nodeAffinity` section of the PV manifest, will be used when scheduling the pod that holds the service.

### LVM Data Services

Data services are supported by the following nodes:

| Data service                 | Kubernetes PV node           | Kubernetes RSync node           |
| ---------------------------- | ---------------------------- | ------------------------------- |
| `/srv/{{ .namespace.name }}` | `{{ .localpvnodes.all_pv }}` | `{{ .localrsyncnodes.all_pv }}` |

To **create** the corresponding LVM data services, execute inside the appropriate node in your cluster the following commands:

```bash
# Create LVM data service (Execute inside the node(s) that holds the local storage)
sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}" \
&& mkdir "/srv/{{ .namespace.name }}/data/chartmuseum" \
&& mkdir "/srv/{{ .namespace.name }}/data/jobservice" \
&& mkdir "/srv/{{ .namespace.name }}/data/postgresql" \
&& mkdir "/srv/{{ .namespace.name }}/data/redis" \
&& mkdir "/srv/{{ .namespace.name }}/data/registry" \
&& mkdir "/srv/{{ .namespace.name }}/data/trivy"
```

To **delete** the corresponding LVM data services, execute inside the appropriate node in your cluster the following commands:

```bash
# Delete LVM data service (Execute inside the node(s) that holds the local storage)
sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}"
```

#### Backup & data protection

Backup & data protection must be configured in file `cs-cron_scripts` of the node that holds the local storage.

**RSync:**

When more than one kubernetes node is present in the cluster, rsync cronjobs are used to achieve service HA for LVM data services that supports the persistent volumes.

To perform RSync manual copies on demand, connecto to the node that holds the local storage and execute:

```bash
## RSync path:  /srv/{{ .namespace.name }}
## To Node:     {{ .localrsyncnodes.all_pv }}
sudo cs-rsync.sh -q -m rsync-to -d /srv/{{ .namespace.name }}  -t {{ .localrsyncnodes.all_pv }}.{{ .namespace.domain }}
```

**RSync cronjobs:**

The following cron jobs should be added to file `cs-cron-scripts` of the appropriate node (Change time schedule as needed):

```bash
################################################################################
# {{ .namespace.name }} - RSync LVM data services
################################################################################
##
## RSync path:  /srv/{{ .namespace.name }}
## To Node:     {{ .localrsyncnodes.all_pv }}
## At minute 0 past every hour from 8 through 23.
# 0 8-23 * * *     root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/{{ .namespace.name }} >> /var/log/cs-rsync.log 2>&1 ; run-one cs-rsync.sh -q -m rsync-to -d /srv/{{ .namespace.name }}  -t {{ .localrsyncnodes.all_pv }}.{{ .namespace.domain }}  >> /var/log/cs-rsync.log 2>&1
```

**Restic:**

Restic is configured to perform data backups to local USB disks, remote disk via sftp or remote S3 storage.

To perform on-demand restic backups:

```bash
## Data service:  /srv/{{ .namespace.name }}
## Restic repo:   {{ .restic.repo }}
sudo cs-restic.sh -q -m restic-bck -d  /srv/{{ .namespace.name }} -r {{ .restic.repo }}  -t {{ .namespace.name }}
```

To view available backups:

```bash
## Specific tag
## Data service: /srv/{{ .namespace.name }}
## Restic repo:   {{ .restic.repo }}
sudo cs-restic.sh -q -m restic-list -r {{ .restic.repo }}  -t {{ .namespace.name }}

## All snapshots
## Remote restic repo
sudo cs-restic.sh -q -m restic-list -r {{ .restic.repo }} 
```

**Restic cronjobs:**

The following cron jobs should be added to file `cs-cron-scripts` of the appropriate node (Change time schedule as needed):

```bash
################################################################################
# {{ .namespace.name }} - Restic backups
################################################################################
##
## Data service:  /srv/{{ .namespace.name }}
## At minute 30 past every hour from 8 through 23.
## Restic repo:   {{ .restic.repo }}
# 30 8-23 * * *   root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/{{ .namespace.name }} >> /var/log/cs-restic.log 2>&1 ; run-one cs-restic.sh -q -m restic-bck -d  /srv/{{ .namespace.name }} -r {{ .restic.repo }}  -t {{ .namespace.name }}  >> /var/log/cs-restic.log 2>&1 && run-one cs-restic.sh -q -m restic-forget -r {{ .restic.repo }}  -t {{ .namespace.name }}  -f "--keep-hourly 6 --keep-daily 31 --keep-weekly 5 --keep-monthly 13 --keep-yearly 10" >> /var/log/cs-restic.log 2>&1
```

## How-to guides

### Pull Charts

To pull charts, change the repositories and charts needed in variable `source_charts` inside the script `csdeploy.sh`  and run:

```bash
# Pull charts to './charts/' directory
  ./csdeploy.sh -m pull-charts
```

When pulling new charts, all the content of `./charts` directory will be removed, and replaced by the new pulled charts.

After pulling new charts redeploy the new versions with: `./csdeploy -m update`.

### Install

To create namespace, persistent volume and install the chart:

```bash
  # Create namespace, PV and install chart
    ./csdeploy.sh -m install
```

Notice that PV's are not namespaced. They are deployed at cluster scope.

### Update

To update chart settings, change values in the file `values-harbor.yaml`.

Redeploy or upgrade the chart by running:

```bash
  # Redeploy or upgrade chart
    ./csdeploy.sh -m update
```

### Uninstall

To uninstall the chart, remove namespace and PV run:

```bash
  # Uninstall chart, remove PV and namespace
    ./csdeploy.sh -m uninstall
```

### Remove

This option is intended to be used only to remove the namespace when chart deployment is failed. Otherwise, you must run `./csdeploy.sh -m uninstall`.

To remove PV, namespace and all its contents run:

```bash
  # Remove PV namespace and all its contents
    ./csdeploy.sh -m remove
```

### Display status

To display namespace, persistence and chart status run:

```bash
  # Display namespace, persistence and chart status:
    ./csdeploy.sh -l
```

### Create private registry

To create a private registry repository (Ex. cskylab) follow these steps:

- Login to Harbor with admin account:

  ![ ](./images/2021-06-22_12-47-08.png)

- Go to **Projects** and select **+ NEW PROJECT**
- Enter your private registry information:

  ![ ](./images/2021-06-22_12-54-38.png)

Your private registry repository is now accesible via '{{ .publishing.url }}/cskylab'

### Create dockerhub proxy

To create the dockerhub registry proxy follow these steps:

- Login to Harbor with admin account:

  ![ ](./images/2021-06-22_12-47-08.png)

- Before creating a proxy cache project, create a Harbor registry endpoint for the proxy cache project to use.
- Go to **Registries** and select **+ NEW ENDPOINT**

  ![ ](./images/2021-06-22_13-08-59.png)

- Test connection and create endpoint
  
  After registry endpoint is created you can reference it in the new dockerhub proxy cache repository .

- To create dockerkub proxy cache repository, go to **Projects**, select **+ NEW PROJECT** and enter the following information:

  ![ ](./images/2021-06-22_13-12-46.png)

Your dockerhub proxy repository is now accesible via '{{ .publishing.url }}/dockerhub'

To start using the proxy cache, configure your docker pull commands or pod manifests to reference the proxy cache project by adding `{{ .publishing.url }}/dockerhub/` as a prefix to the image tag. For example:

```bash
docker pull {{ .publishing.url }}/dockerhub/goharbor/harbor-core:dev
```

To pull official images or from single level repositories, make sure to include the `library` namespace. For example:

```bash
docker pull {{ .publishing.url }}/dockerhub/library/nginx:latest
```

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

- <https://github.com/bitnami/charts/tree/master/bitnami/harbor>

### Helm charts and values

| Chart          | Values               |
| -------------- | -------------------- |
| bitnami/harbor | `values-harbor.yaml` |

### Scripts

#### cs-deploy

```console
Purpose:
  Harbor registry.

Usage:
  sudo csdeploy.sh [-l] [-m <execution_mode>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List current status.
  -m  <execution_mode>  - Valid modes are:

      [pull-charts]     - Pull charts to './charts/' directory.
      [install]         - Create namespace, PV's and install charts.
      [update]          - Redeploy or upgrade charts.
      [uninstall]       - Uninstall charts, remove PV's and namespace.
      [remove]          - Remove PV's namespace and all its contents.

Options and arguments:  
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Pull charts to './charts/' directory
    ./csdeploy.sh -m pull-charts

  # Create namespace, PV's and install charts
    ./csdeploy.sh -m install

  # Redeploy or upgrade charts
    ./csdeploy.sh -m update

  # Uninstall charts, remove PV's and namespace
    ./csdeploy.sh -m uninstall

  # Remove PV's namespace and all its contents
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
| [install]                        |                            | **Create namespace, certificate and PV's**                                  |
|                                  | Create namespace           | Namespace must be unique in cluster.                                        |
|                                  | Create harbor-certificate  | Apply certificate from file `harbor-certificate.yaml`.                      |
|                                  | Create PV's                | Apply all persistent volume manifests in the form `pv-*.yaml`.              |
| [update] [install]               |                            | **Deploy charts**                                                           |
|                                  | Deploy charts              | Deploy all charts in `./charts` directory with `upgrade --install` options. |
| [uninstall]                      |                            | **Uninstall charts**                                                        |
|                                  | Uninstall charts           | Uninstall all charts in `./charts` directory.                               |
| [uninstall] [remove]             |                            | **Remove namespace and PV's**                                               |
|                                  | Remove namespace           | Remove namespace and all its objects.                                       |
|                                  | Delete PV's                | Delete all persistent volume manifests in the form `pv-*.yaml`.             |
| [install] [update] [list-status] |                            | **Display status information**                                              |
|                                  | Display namespace          | Namespace and object status.                                                |
|                                  | Display certificates       | Certificate status information.                                             |
|                                  | Display persistence        | Persistence status information.                                             |
|                                  | Display charts             | Charts releases history information.                                        |
|                                  |                            |                                                                             |

### Template values

The following table lists template configuration parameters and their specified values, when machine configuration files were created from the template:

| Parameter                   | Description                | Values                             |
| --------------------------- | -------------------------- | ---------------------------------- |
| `_tplname`                  | template name              | `{{ ._tplname }}`                  |
| `_tpldescription`           | template description       | `{{ ._tpldescription }}`           |
| `_tplversion`               | template version           | `{{ ._tplversion }}`               |
| `kubeconfig`                | kubeconfig file            | `{{ .kubeconfig }}`                |
| `namespace.name`            | namespace name             | `{{ .namespace.name }}`            |
| `namespace.domain`          | domain name                | `{{ .namespace.domain }}`          |
| `publishing.url`            | external URL               | `{{ .publishing.url }}`            |
| `publishing.password`       | password                   | `{{ .publishing.password }}`       |
| `certificate.clusterissuer` | cert-manager clusterissuer | `{{ .certificate.clusterissuer }}` |
| `registry.proxy`            | docker private proxy URL                         | `{{ .registry.proxy }}`            |
| `restic.password`           | password to access restic repository (mandatory) | `{{ .restic.password }}`           |
| `restic.repo`               | restic repository (mandatory)                    | `{{ .restic.repo }}`               |
| `restic.aws_access`         | S3 bucket access key (if used)                   | `{{ .restic.aws_access }}`         |
| `restic.aws_secret`         | S3 bucket secret key (if used)                   | `{{ .restic.aws_secret }}`         |
| `localpvnodes.all_pv`       | dataservice node                                 | `{{ .localpvnodes.all_pv }}`       |
| `localrsyncnodes.all_pv`    | rsync node                                       | `{{ .localrsyncnodes.all_pv }}`    |

## License

Copyright © 2021 cSkyLab.com ™

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
