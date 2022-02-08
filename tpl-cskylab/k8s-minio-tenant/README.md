# Kubernetes MinIO Tenant <!-- omit in toc -->

## Helm charts: minio/tenant v4.4.7 <!-- omit in toc -->

---

[MinIO](https://min.io/) is a Kubernetes-native high performance object store with an S3-compatible API. The MinIO Kubernetes Operator supports deploying MinIO Tenants onto private and public cloud infrastructures ("Hybrid" Cloud).

This service creates a X-node MinIO Tenant using MinIO for object storage.

Configuration files are deployed from template {{ ._tpldescription }} version {{ ._tplversion }}.

- [TL;DR](#tldr)
- [Prerequisites](#prerequisites)
  - [Persistence](#persistence)
    - [MinIO Erasure Code Parity (EC:N)](#minio-erasure-code-parity-ecn)
  - [Persistent Volumes](#persistent-volumes)
    - [LVM Data Services](#lvm-data-services)
- [How-to guides](#how-to-guides)
  - [Install](#install)
  - [Update](#update)
  - [Delete](#delete)
  - [Remove](#remove)
  - [Display status](#display-status)
  - [Bucket maintenance](#bucket-maintenance)
    - [Create bucket, users and policies](#create-bucket-users-and-policies)
    - [Delete bucket, users and policies](#delete-bucket-users-and-policies)
    - [Display bucket, users and policies](#display-bucket-users-and-policies)
    - [Restic backup jobs](#restic-backup-jobs)
      - [Prepare the bucket source environment file](#prepare-the-bucket-source-environment-file)
      - [Launch restic cronjobs](#launch-restic-cronjobs)
      - [Delete restic cronjobs](#delete-restic-cronjobs)
      - [Launch an interactive restic-forge environment in a pod](#launch-an-interactive-restic-forge-environment-in-a-pod)
  - [MinIO Client](#minio-client)
    - [Web utility](#web-utility)
    - [Console utility](#console-utility)
    - [Command line utility](#command-line-utility)
- [Reference](#reference)
  - [Scripts](#scripts)
    - [cs-deploy](#cs-deploy)
    - [csbucket](#csbucket)
  - [csrestic-minio](#csrestic-minio)
  - [Template values](#template-values)
- [License](#license)

---

## TL;DR

Prepare LVM Data services for PV's:

- [LVM Data Services](#lvm-data-services)

Install namespace and charts:

```bash
# Install  
./csdeploy.sh -m install
# Check status
./csdeploy.sh -l
```

Access:

- MinIO URL: `{{ .publishing.miniourl }}`
- AccessKey: `{{ .credentials.minio_accesskey }}`
- SecretKey: `{{ .credentials.minio_secretkey }}`

- Console URL: `{{ .publishing.consoleurl }}`
- AccessKey: `{{ .credentials.console_accesskey }}`
- SecretKey: `{{ .credentials.console_secretkey }}`

> Important: Console keys must be different from MinIO root keys

## Prerequisites

- MinIO Operator must be installed in K8s Cluster.
- Administrative access to Kubernetes cluster.

### Persistence

#### MinIO Erasure Code Parity (EC:N)

The minimum configuration for a standalone tenant must be 1 server with 4 drives. For a distributed tenant the minimum is 4 servers with 4 drives each one (Total 16 drives).

The reccomended Erasure code is EC:4

| TOTAL DRIVES | DATA DRIVES | PARITY DRIVES (EC:N) | STORAGE USAGE RATIO |
| ------------ | ----------- | -------------------- | ------------------- |
| 16           | 8           | 8                    | 2.00                |
| 16           | 9           | 7                    | 1.79                |
| 16           | 10          | 6                    | 1.60                |
| 16           | 11          | 5                    | 1.45                |
| 16           | 12          | 4 (Recommended)      | 1.33                |
| 16           | 13          | 3                    | 1.23                |
| 16           | 14          | 2                    | 1.14                |

### Persistent Volumes

Review values in all Persistent volume manifests with the name format `./pv-*.yaml`.

The following PersistentVolume & StorageClass manifests are applied:

```bash
# PV manifests
pv-minio.yaml
```

The node assigned in `nodeAffinity` section of the PV manifest, will be used when scheduling the pod that holds the service.

#### LVM Data Services

Data services are supported by the following nodes:

| Data service                         | Kubernetes PV node          |
| ------------------------------------ | --------------------------- |
| `/srv/{{ .namespace.name }}-s00-d00` | `{{ .localpvnodes.srv00 }}` |
| `/srv/{{ .namespace.name }}-s00-d01` | `{{ .localpvnodes.srv00 }}` |
| `/srv/{{ .namespace.name }}-s00-d02` | `{{ .localpvnodes.srv00 }}` |
| `/srv/{{ .namespace.name }}-s00-d03` | `{{ .localpvnodes.srv00 }}` |
| `/srv/{{ .namespace.name }}-s01-d00` | `{{ .localpvnodes.srv01 }}` |
| `/srv/{{ .namespace.name }}-s01-d01` | `{{ .localpvnodes.srv01 }}` |
| `/srv/{{ .namespace.name }}-s01-d02` | `{{ .localpvnodes.srv01 }}` |
| `/srv/{{ .namespace.name }}-s01-d03` | `{{ .localpvnodes.srv01 }}` |
| `/srv/{{ .namespace.name }}-s02-d00` | `{{ .localpvnodes.srv02 }}` |
| `/srv/{{ .namespace.name }}-s02-d01` | `{{ .localpvnodes.srv02 }}` |
| `/srv/{{ .namespace.name }}-s02-d02` | `{{ .localpvnodes.srv02 }}` |
| `/srv/{{ .namespace.name }}-s02-d03` | `{{ .localpvnodes.srv02 }}` |
| `/srv/{{ .namespace.name }}-s03-d00` | `{{ .localpvnodes.srv03 }}` |
| `/srv/{{ .namespace.name }}-s03-d01` | `{{ .localpvnodes.srv03 }}` |
| `/srv/{{ .namespace.name }}-s03-d02` | `{{ .localpvnodes.srv03 }}` |
| `/srv/{{ .namespace.name }}-s03-d03` | `{{ .localpvnodes.srv03 }}` |

To **create** the corresponding LVM data services, execute inside the appropriate node in your cluster the following commands:

```bash
# Server {{ .localpvnodes.srv00 }}
sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s00-d00" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s00-d01" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s00-d02" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s00-d03"

# Server {{ .localpvnodes.srv01 }}
sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s01-d00" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s01-d01" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s01-d02" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s01-d03"

# Server {{ .localpvnodes.srv02 }}
sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s02-d00" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s02-d01" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s02-d02" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s02-d03"

# Server {{ .localpvnodes.srv03 }}
sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s03-d00" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s03-d01" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s03-d02" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s03-d03"
```

```bash
#
# Create LVM data services
#
echo && echo "******** SOE - START of execution ********" && echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.srv00 }}.{{ .localpvnodes.domain }} \
  'sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s00-d00" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s00-d01" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s00-d02" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s00-d03"' \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.srv01 }}.{{ .localpvnodes.domain }} \
  'sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s01-d00" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s01-d01" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s01-d02" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s01-d03"' \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.srv02 }}.{{ .localpvnodes.domain }} \
  'sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s02-d00" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s02-d01" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s02-d02" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s02-d03"' \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.srv03 }}.{{ .localpvnodes.domain }} \
  'sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s03-d00" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s03-d01" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s03-d02" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-s03-d03"' \
&& echo && echo "******** EOE - END of execution ********" && echo
```

To **delete** the corresponding LVM data services, execute inside the appropriate node in your cluster the following commands:

```bash
# Server 1
sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s00-d00" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s00-d01" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s00-d02" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s00-d03"

# Server 2
sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s01-d00" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s01-d01" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s01-d02" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s01-d03"

# Server 3
sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s02-d00" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s02-d01" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s02-d02" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s02-d03"

# Server 4
sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s03-d00" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s03-d01" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s03-d02" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s03-d03"
```

```bash
#
# Delete LVM data services
#
echo && echo "******** SOE - START of execution ********" && echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.srv00 }}.{{ .localpvnodes.domain }} \
  'sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s00-d00" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s00-d01" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s00-d02" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s00-d03"' \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.srv01 }}.{{ .localpvnodes.domain }} \
  'sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s01-d00" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s01-d01" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s01-d02" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s01-d03"' \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.srv02 }}.{{ .localpvnodes.domain }} \
  'sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s02-d00" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s02-d01" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s02-d02" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s02-d03"' \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.srv03 }}.{{ .localpvnodes.domain }} \
  'sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s03-d00" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s03-d01" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s03-d02" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-s03-d03"' \
&& echo && echo "******** EOE - END of execution ********" && echo
```

## How-to guides

### Install

Check versions and update if necesary, for the following images in `mod-tenant.yaml` file:

- minio/minio
- minio/console

To check for the later docker images versions see:

- <https://hub.docker.com/r/minio/minio>
- <https://hub.docker.com/r/minio/console>

To create namespace and install MinIO tenant:

```bash
  # Install namespace and tenant
    ./csdeploy.sh -m install
```

### Update

Check image versions and update if necesary.

To reapply manifests and upgrade images:

```bash
  # Reapply manifests and update images
    ./csdeploy.sh -m update
```

### Delete

> **WARNING**: This action will delete MinIO tenant. All MinIO Storage Data in K8s Cluster will be erased.

To delete MinIO tenant, remove namespace and PV's run:

```bash
  # Delete tenant, PV's and namespace
    ./csdeploy.sh -m delete
```

### Remove

This option is intended to be used only to remove the namespace when tenant deployment is failed. Otherwise, you must run `./csdeploy.sh -m delete`.

To remove PV's, namespace and all its contents run:

```bash
  # Remove PV's namespace and all its contents
    ./csdeploy.sh -m remove
```

### Display status

To display namespace, persistence and tenant status run:

```bash
  # Display namespace, persistence and tenant status
    ./csdeploy.sh -l
```

### Bucket maintenance

Buckets can be created together with users and policies for ReadWrite, ReadOnly and WriteOnly access. 

A record file in configuration management `./buckets` folder will be created for each bucket in the form `bucket_name.config`.

Additionally, a source environment file for MinIO bucket access and restic operations will be created in the form `source-bucket_name.sh`. This file can be used for restic backups operations with the script `csrestic-minio.sh`. It can be sourced also from a management console to initialize the variables needed to access bucket through MinIO client `mc` and restic repository through restic commands.

#### Create bucket, users and policies

To create bucket, users and policies:

```bash
# Create Bucket & Users & Policies
  ./csbucket.sh -c mybucket
```

In this case a file named `./buckets/mybucket.config` will be created with the access and secret keys used for the following users:

- mybucket_rw (ReadWrite user)
- mybucket_ro (ReadOnly user)
- mybucket_wo (Write only user)

You can use these keys for specific access to the bucket from any application or user.

#### Delete bucket, users and policies

To delete bucket, users and policies:

```bash
# Delete Bucket & Users & Policies
  ./csbucket.sh -d mybucket
```

File `./buckets/mybucket.config` will also be deleted with access and secret keys.

#### Display bucket, users and policies

To list current bucket, users and policies:

```bash
# List Bucket & Users & Policies
  ./csbucket.sh -l
```

#### Restic backup jobs

You can make restic backups for MinIO buckets with cskylab/csrestic image scheduled through crontab jobs. 

##### Prepare the bucket source environment file

To schedule automatic restic backups for a bucket, you must prepare the bucket source environment file. This file will trigger a cronjob when applying manifests with `csrestic-minio.sh` script. You can copy from `./buckets/` directory and customize the restic environment with the appropriate options for repository, passwords, schedule... etc.

The following is an example of source environment file for a bucket called beatles:

```bash
#
#   Source environment file for MinIO bucket beatles
#

# This script is designed to be sourced
# No shebang intentionally
# shellcheck disable=SC2148

## minio bucket environment
export MINIO_ACCESS_KEY="beatles_rw"
export MINIO_SECRET_KEY="eeMlviN2Lp653PPgv5M9Bc691nqmbvoP"
export MINIO_URL="minio-standalone.cskylab.com"
export MINIO_BUCKET="beatles"
export MC_HOST_minio="https://beatles_rw:eeMlviN2Lp653PPgv5M9Bc691nqmbvoP@minio-standalone.cskylab.com"

## restic-environment
export AWS_ACCESS_KEY_ID="restic-test_rw"
export AWS_SECRET_ACCESS_KEY="iZ6Qpx1WlmXXoXKxBmiCMKWCsYOrgZKr"
export RESTIC_REPOSITORY="s3:https://minio-standalone.cskylab.com/restic-test/"
export RESTIC_PASSWORD="sGKvPNSRzQ1YlAxv"

## Restic backup job schedule (UTC)
## At every 15th minute.
export RESTIC_BACKUP_JOB_SCHEDULE="*/15 * * * *"
export RESTIC_FORGET_POLICY="--keep-last 6 --keep-hourly 12 --keep-daily 31 --keep-weekly 5 --keep-monthly 13 --keep-yearly 10"

## Restic repo maintenance job schedule (UTC)
## At 02:00.
export RESTIC_REPO_MAINTENANCE_JOB_SCHEDULE="0 2 * * *"
# Percentage of pack files to check in repo maintenance
export RESTIC_REPO_MAINTENANCE_CHECK_DATA_SUBSET="10%"
```

##### Launch restic cronjobs

To launch or reconfigure backup jobs for all `source-*.sh` environment files in the configuration directory, run:

```bash
  # Apply and reconfigure all restic cronjobs from 'source-*.sh' environment files.
    csrestic-jobs.sh -m apply
```

Restic backup jobs and restic repository maintenance jobs are scheduled acording to crontab policies specified in variables `RESTIC_BACKUP_JOB_SCHEDULE` and `RESTIC_REPO_MAINTENANCE_JOB_SCHEDULE`. If any of these variables are empty, the corresponding job will not be scheduled.

Restic repository maintenance jobs should not interfere with regular backup runs.

##### Delete restic cronjobs

To remove all restic cronjobs in the namespace:

```bash
  # Delete all restic cronjobs.
    csrestic-jobs.sh -m remove
```

##### Launch an interactive restic-forge environment in a pod

A restic forge environment is a pod with access to a MinIO bucket and a restic repository mounted with all the snapshots available for restore operations.

To launch a restic forge environment, use the specific MinIO bucket source environment file:

```bash
  # Launch a restic forge environment for bucket "beatles"
    csrestic-jobs.sh -f source-beatles.sh
```

### MinIO Client

#### Web utility

To access MinIO throug web utility:

- MinIO URL: `{{ .publishing.miniourl }}`
- AccessKey: `{{ .credentials.minio_accesskey }}`
- SecretKey: `{{ .credentials.minio_secretkey }}`

#### Console utility

To acces MinIO console throug web utility:

- Console URL: `{{ .publishing.consoleurl }}`
- AccessKey: `{{ .credentials.console_accesskey }}`
- SecretKey: `{{ .credentials.console_secretkey }}`

#### Command line utility

If you have minio client installed, you can access `mc` command line utiliy from the command line.

File `.envrc` export automatically through "direnv" the environment variable needed to operate `mc` with `minio` as hostname from its directory in git repository:

```bash
# minio-tenant environment variable
export MC_HOST_minio="https://$(kubectl -n={{ .namespace.name }} get secrets minio-creds-secret -o jsonpath={.data.accesskey} | base64 --decode):$(kubectl -n={{ .namespace.name }} get secrets minio-creds-secret -o jsonpath={.data.secretkey} | base64 --decode)@{{ .publishing.miniourl }}"

```

You can run `mc` commands to operate from console with buckets and files: Ex `mc tree minio`.

For more information: <https://docs.min.io/docs/minio-client-complete-guide.html>

## Reference

To learn more see:

- <https://github.com/kubernetes/ingress-nginx>

### Scripts

#### cs-deploy

```console
Purpose:
  Kubernetes MinIO Tenant.
  
Usage:
  sudo csdeploy.sh [-l] [-m <execution_mode>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List namespace, persistence and tenant status.
  -m  <execution_mode>  - Valid modes are:

      [install]         - Install namespace and MinIO tenant.
      [update]          - Reapply manifests and update images.
      [delete]          - Delete MinIO tenant, remove PV's and namespace.
      [remove]          - Remove PV's namespace and all its contents.

Options and arguments:  
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Install namespace and tenant
    ./csdeploy.sh -m install

  # Reapply manifests and update images
    ./csdeploy.sh -m update

  # Delete tenant, PV's and namespace
    ./csdeploy.sh -m delete

  # Remove PV's namespace and all its contents
    ./csdeploy.sh -m remove

  # Display namespace, persistence and tenant status
    ./csdeploy.sh -l
```

**Tasks performed:**

| ${execution_mode}       | Tasks                | Block / Description                                             |
| ----------------------- | -------------------- | --------------------------------------------------------------- |
| [install]               |                      | **Create namespace, secrets and PV's**                          |
|                         | Create namespace     | Namespace must be unique in cluster.                            |
|                         | Create secrets       | Create secrets containing usernames, passwords... etc.          |
|                         | Create PV's          | Apply all persistent volume manifests in the form `pv-*.yaml`.  |
| [install] [update]      |                      | **Deploy app mod's**                                            |
|                         | Apply manifests      | Apply all app module manifests in the form `mod-*.yaml`.        |
| [delete]                |                      | **Delete tenant**                                               |
|                         | Delete manifests     | Delete all app module manifests in the form `mod-*.yaml`.       |
| [delete] [remove]       |                      | **Remove namespace and PV's**                                   |
|                         | Remove namespace     | Remove namespace and all its objects.                           |
|                         | Delete PV's          | Delete all persistent volume manifests in the form `pv-*.yaml`. |
| [install] [list-status] |                      | **Display namespace status information**                        |
|                         | Display namespace    | Namespace and object status.                                    |
|                         | Display certificates | Certificate status information.                                 |
|                         | Display secrets      | Secret status information.                                      |
|                         | Display persistence  | Persistence status information.                                 |
|                         | Display persistence  | Persistence status information.                                 |
|                         | Display tenant       | Display tenant information.                                     |
|                         |                      |                                                                 |

#### csbucket

```console
Purpose:
  Minio Bucket & User & Policy maintenance.
  Use this script to create or delete together a bucket
  with readwrite, readonly and writeonly users and access policies.
  
Usage:
  sudo csdeploy.sh [-l] [-c <bucket_name>] [-d <bucket_name>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List Buckets & Users & Policies.
  -c  <bucket_name>     - Create Bucket & Users & Policies
  -d  <bucket_name>     - Remove Bucket & Users & Policies

Options and arguments:  
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Create Bucket & Users & Policies
    ./csbucket.sh -c mybucket

  # Delete Bucket & Users & Policies
    ./csbucket.sh -d mybucket
```

**Tasks performed:**

| ${execution_mode}                             | Tasks                                 | Block / Description                                                         |
| --------------------------------------------- | ------------------------------------- | --------------------------------------------------------------------------- |
| [create-bucket]                               |                                       | **Create Bucket & User & Policy**                                           |
|                                               | Create bucket configuration file      | Create bucket configuration file `./buckets/${bucket_name}.config`.         |
|                                               | Create bucket source environment file | Create bucket environment source file `./buckets/source-${bucket_name}.sh`. |
|                                               | Create bucket                         | Create bucket from MinIO client with root credentials.                      |
|                                               | Create and set users and policies     | Create users and policies for ReadWrite, ReadOnly and WriteOnly access.     |
| [delete-bucket]                               |                                       | **Delete Bucket & User & Policy**                                           |
|                                               | Delete bucket                         | Delete bucket from MinIO client with root credentials.                      |
|                                               | Delete and set users and policies     | Delete users and policies for ReadWrite, ReadOnly and WriteOnly access.     |
|                                               | Delete bucket configuration file      | Delete bucket configuration file `./buckets/${bucket_name}.config`.         |
|                                               | Delete bucket source environment file | Delete bucket environment source file `./buckets/source-${bucket_name}.sh`. |
| [list-status] [create-bucket] [delete-bucket] |                                       | **Display status information**                                              |
|                                               | MinIO status information              | Display MinIO host information from MinIO client.                           |
|                                               | Display buckets                       | List buckets from MinIO client.                                             |
|                                               | Display users                         | List users from MinIO client.                                               |
|                                               | Display policies                      | List policies from MinIO client.                                            |
|                                               |                                       |                                                                             |

### csrestic-minio

```console
Purpose:
  k8s restic backup jobs for MinIO buckets.

Usage:
  csrestic-minio.sh [-l] [-m <execution_mode>] [-f <source-env.sh] [-h] [-q]

Execution modes:
  -l  [list-status]         - List current namespace status.
  
  -m  <execution_mode>      - Valid modes are:
      [apply]               - Apply and reconfigure all restic cronjobs from 'source-*.sh' environment files.
      [remove]              - Delete all restic cronjobs.
  
  -f  <source-env.sh>       - Launch a restic forge environment 
                              for interactive restore operations.

Options and arguments:
  -h  Help
  -q  Quiet (Nonstop) execution

Examples:
  # Apply and reconfigure all restic cronjobs from 'source-*.sh' environment files.
    csrestic-minio.sh -m apply

  # Delete all restic cronjobs.
    csrestic-minio.sh -m remove

  # Launch a restic forge environment for bucket "beatles"
    csrestic-minio.sh -f source-beatles.sh

  # Display job status
    csrestic-minio.sh -l
```

**Tasks performed:**

| ${execution_mode}              | Tasks                                        | Block / Description                                                             |
| ------------------------------ | -------------------------------------------- | ------------------------------------------------------------------------------- |
| [forge]                        |                                              | **Launch restic forge environment**                                             |
|                                | Source env variables from `source-bucket.sh` | Define environment variables from source file.                                  |
|                                | Generate unique restic forge pod name        | Generate unique restic forge pod name from bucket name and random text.         |
|                                | Deploy pod                                   | Deploy pod using environment variables.                                         |
|                                | Conect to pod                                | Open console for interactive restore operations.                                |
|                                | Delete pod                                   | Delete pod after interactive console session.                                   |
| [apply]                        |                                              | **Deploy jobs**                                                                 |
|                                | Apply restic backup cronjobs                 | Apply backup cronjobs scheduled in source environment files `source-*.sh`.      |
|                                | Apply restic repo maintenance cronjobs       | Apply maintenance cronjobs scheduled in source environment files `source-*.sh`. |
| [remove]                       |                                              | **Deploy jobs**                                                                 |
|                                | Delete cronjobs                              | Delete all cronjobs in namespace with label `resticjob`.                        |
| [list-status] [apply] [remove] |                                              | **Display status information**                                                  |
|                                | Display namespace                            | Namespace and object status.                                                    |
|                                |                                              |                                                                                 |

### Template values

The following table lists template configuration parameters and their specified values, when machine configuration files were created from the template:

| Parameter                              | Description                  | Values                                        |
| -------------------------------------- | ---------------------------- | --------------------------------------------- |
| `_tplname`                             | template name                | `{{ ._tplname }}`                             |
| `_tpldescription`                      | template description         | `{{ ._tpldescription }}`                      |
| `_tplversion`                          | template version             | `{{ ._tplversion }}`                          |
| `kubeconfig`                           | kubeconfig file              | `{{ .kubeconfig }}`                           |
| `namespace.name`                       | namespace name               | `{{ .namespace.name }}`                       |
| `publishing.miniourl`                  | publishing url               | `{{ .publishing.miniourl }}`                  |
| `publishing.consoleurl`                | console url                  | `{{ .publishing.consoleurl }}`                |
| `credentials.minio_accesskey`          | access key                   | `{{ .credentials.minio_accesskey }}`          |
| `credentials.minio_secretkey`          | secret key                   | `{{ .credentials.minio_secretkey }}`          |
| `credentials.console_accesskey`        | console access key           | `{{ .credentials.console_accesskey }}`        |
| `credentials.console_secretkey`        | console secret key           | `{{ .credentials.console_secretkey }}`        |
| `credentials.console_pbkdf_passphrase` | console passphrase           | `{{ .credentials.console_pbkdf_passphrase }}` |
| `credentials.console_pbkdf_salt`       | console salt                 | `{{ .credentials.console_pbkdf_salt }}`       |
| `localpvnodes.srv00`                   | local persistent volume node | `{{ .localpvnodes.srv00 }}`                   |
| `localpvnodes.srv01`                   | local persistent volume node | `{{ .localpvnodes.srv01 }}`                   |
| `localpvnodes.srv02`                   | local persistent volume node | `{{ .localpvnodes.srv03 }}`                   |
| `localpvnodes.srv03`                   | local persistent volume node | `{{ .localpvnodes.srv03 }}`                   |

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
