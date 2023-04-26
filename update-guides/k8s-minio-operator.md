<!-- markdownlint-disable MD024 -->

# k8s-minio-operator <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v99-99-99](#v99-99-99)
  - [Background](#background)
  - [How-to guides](#how-to-guides)
    - [1.- Update minio-tenant manifest and documentation](#1--update-minio-tenant-manifest-and-documentation)
    - [2.- Update minio-operator chart](#2--update-minio-operator-chart)
    - [3.- Update minio-operator namespace](#3--update-minio-operator-namespace)
    - [4.- Update minio-tenant namespace](#4--update-minio-tenant-namespace)
  - [Reference](#reference)
- [v22-12-19](#v22-12-19)
  - [Background](#background-1)
  - [How-to guides](#how-to-guides-1)
    - [1.- Update minio-tenant manifest](#1--update-minio-tenant-manifest)
    - [2.- Update minio-operator chart](#2--update-minio-operator-chart-1)
    - [3.- Update minio-operator namespace](#3--update-minio-operator-namespace-1)
    - [4.- Update minio-tenant namespace](#4--update-minio-tenant-namespace-1)
  - [Reference](#reference-1)
- [v22-08-21](#v22-08-21)
  - [Background](#background-2)
  - [How-to guides](#how-to-guides-2)
    - [1.- Uninstall minio-tenant  namespace](#1--uninstall-minio-tenant--namespace)
    - [2.- Uninstall minio-operator  namespace](#2--uninstall-minio-operator--namespace)
    - [3.- Update minio-tenant manifest](#3--update-minio-tenant-manifest)
    - [4.- Update minio-operator chart](#4--update-minio-operator-chart)
    - [5.- Remove old tenant CRD's](#5--remove-old-tenant-crds)
    - [5.- Install minio-operator namespace](#5--install-minio-operator-namespace)
    - [6.- Install minio-tenant namespace](#6--install-minio-tenant-namespace)
  - [Reference](#reference-2)

---

## v99-99-99

### Background

This procedure upgrades minio-operator to version `5.0.4` and minio-tenant to version `RELEASE.2023-04-20T17-56-55Z`.

This procedure updates the installation in k8s-mod cluster.

### How-to guides

#### 1.- Update minio-tenant manifest and documentation

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/minio-t1` repository directory.

- Edit file  `mod-tenant.yaml` and update the minio server line as follows:

```bash
## Registry location and Tag to download MinIO Server image
image: quay.io/minio/minio:RELEASE.2023-04-20T17-56-55Z
```

- Edit `README.md` documentation file and change in section **Install** the yaml section as follows:

```yaml
  ## Registry location and Tag to download MinIO Server image
  image: quay.io/minio/minio:RELEASE.2023-04-20T17-56-55Z
```

#### 2.- Update minio-operator chart

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/minio-op` repository directory.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

## Repositories
helm repo add minio https://operator.min.io/
helm repo update

## Charts
helm pull minio/operator --version 5.0.4 --untar

EOF
)"
```

- Edit `README.md` documentation file, and change header as follows:

``` bash
## v99-99-99 <!-- omit in toc -->

## Helm charts: minio/operator v5.0.4 <!-- omit in toc -->
```

#### 3.- Update minio-operator namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/minio-op` repository directory.

Update namespace by running:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Install chart and namespace.  
./csdeploy.sh -m update
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```
#### 4.- Update minio-tenant namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/minio-t1` repository directory.

Open script `csbucket.sh` and change the code section **"Create Bucket & User & Policy"** with the following code:

```bash
################################################################################
# Create Bucket & User & Policy
################################################################################

if [[ "${execution_mode}" == "create-bucket" ]]; then

  # Create bucket configuration file
  echo
  echo "${msg_info} Create bucket configuration file ./buckets/${bucket_name}.config"
  echo
  touch ./buckets/"${bucket_name}".config
  {
    echo "minio_host=${minio_host}"
    echo "bucket_name=${bucket_name}"
    echo "---"
    echo "bucket_rw_user=${bucket_rw_user}"
    echo "bucket_rw_secret=${bucket_rw_secret}"
    echo "bucket_rw_policy=${bucket_rw_policy}"
    echo "bucket_rw_policy_content=${bucket_rw_policy_content}"
    echo "---"
    echo "bucket_ro_user=${bucket_ro_user}"
    echo "bucket_ro_secret=${bucket_ro_secret}"
    echo "bucket_ro_policy=${bucket_ro_policy}"
    echo "bucket_ro_policy_content=${bucket_ro_policy_content}"
    echo "---"
    echo "bucket_wo_user=${bucket_wo_user}"
    echo "bucket_wo_secret=${bucket_wo_secret}"
    echo "bucket_wo_policy=${bucket_wo_policy}"
    echo "bucket_wo_policy_content=${bucket_wo_policy_content}"

  } >>./buckets/"${bucket_name}".config

  # Create bucket environment source file
  echo
  echo "${msg_info} Create bucket environment source file ./buckets/source-${bucket_name}.sh"
  echo
  touch ./buckets/source-"${bucket_name}".sh

  cat >>./buckets/source-"${bucket_name}".sh <<EOF
#
#   Source environment file for MinIO bucket "${bucket_name}"
#

# This script is designed to be sourced
# No shebang intentionally
# shellcheck disable=SC2148

## minio bucket environment
export MINIO_ACCESS_KEY="${bucket_rw_user}"
export MINIO_SECRET_KEY="${bucket_rw_secret}"
export MINIO_URL="${minio_host}"
export MINIO_BUCKET="${bucket_name}"
export MC_HOST_minio="https://${bucket_rw_user}:${bucket_rw_secret}@${minio_host}"

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

EOF

  # Create bucket
  echo
  echo "${msg_info} Create bucket minio/${bucket_name}"
  echo
  mc mb minio/"${bucket_name}"

  # ReadWrite
  echo
  echo "${msg_info} Create ReadWrite user ${bucket_rw_user} access secret and policy"
  echo
  # user
  mc admin user add minio/ "${bucket_rw_user}" "${bucket_rw_secret}"
  # policy
  echo "${bucket_rw_policy_content}" >"/tmp/${bucket_rw_policy}.json"
  mc admin policy create minio/ "${bucket_rw_policy}" "/tmp/${bucket_rw_policy}.json"
  # Set policy to user
  mc admin policy attach minio/ "${bucket_rw_policy}" --user "${bucket_rw_user}"

  # ReadOnly
  echo
  echo "${msg_info} Create ReadOnly user ${bucket_ro_user} access secret and policy"
  echo
  # user
  mc admin user add minio/ "${bucket_ro_user}" "${bucket_ro_secret}"
  # policy
  echo "${bucket_ro_policy_content}" >"/tmp/${bucket_ro_policy}.json"
  mc admin policy create minio/ "${bucket_ro_policy}" "/tmp/${bucket_ro_policy}.json"
  # Set policy to user
  mc admin policy attach minio/ "${bucket_ro_policy}" --user "${bucket_ro_user}"

  # WriteOnly
  echo
  echo "${msg_info} Create WriteOnly user ${bucket_wo_user} access secret and policy"
  echo
  # user
  mc admin user add minio/ "${bucket_wo_user}" "${bucket_wo_secret}"
  # policy
  echo "${bucket_wo_policy_content}" >"/tmp/${bucket_wo_policy}.json"
  mc admin policy create minio/ "${bucket_wo_policy}" "/tmp/${bucket_wo_policy}.json"
  # Set policy to user
  mc admin policy attach minio/ "${bucket_wo_policy}" --user "${bucket_wo_user}"

fi
```

Update namespace by running:

```bash

# Update namespace.  
./csdeploy.sh -m update
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```

- Connect to minio-tenant console and check the application is running.

### Reference

- <https://github.com/bitnami/charts/tree/master/bitnami/minio>

---

## v22-12-19

### Background

This procedure upgrades minio-operator to version `4.5.5` and minio-tenant to version `RELEASE.2022-12-12T19-27-27Z`.

This procedure updates the installation in k8s-mod cluster.

### How-to guides

#### 1.- Update minio-tenant manifest

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/minio-t1` repository directory.

- Edit file  `mod-tenant.yaml` and update the minio server line as follows:

```bash
## Registry location and Tag to download MinIO Server image
image: quay.io/minio/minio:RELEASE.2022-12-12T19-27-27Z
```

#### 2.- Update minio-operator chart

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/minio-op` repository directory.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

## Repositories
helm repo add minio https://operator.min.io/
helm repo update

## Charts
helm pull minio/operator --version 4.5.5 --untar

EOF
)"
```

- Edit `README.md` documentation file, and change header as follows:

``` bash
## v22-12-19 <!-- omit in toc -->

## Helm charts: minio/operator v4.5.5 <!-- omit in toc -->
```

#### 3.- Update minio-operator namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/minio-op` repository directory.

Update namespace by running:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Install chart and namespace.  
./csdeploy.sh -m update
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```
#### 4.- Update minio-tenant namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/minio-t1` repository directory.

Update namespace by running:

```bash

# Update namespace.  
./csdeploy.sh -m update
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```

- Connect to minio-tenant console and check the application is running.

### Reference

- <https://github.com/bitnami/charts/tree/master/bitnami/minio>

---

## v22-08-21

### Background

This procedure upgrades minio-operator to version `4.4.28` and minio-tenant to version `RELEASE.2022-08-13T21-54-44Z`.

When migrating from version 4.8.8 it is neccesary to uninstall the namespaces and remove manually CRD's `tenants.minio.min.io`.

This procedure updates the installation in k8s-mod cluster.

### How-to guides
#### 1.- Uninstall minio-tenant  namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/minio-t1` repository directory.

- Remove gitlab namespace by running:

```bash
# Uninstall chart and namespace.  
./csdeploy.sh -m uninstall
```

#### 2.- Uninstall minio-operator  namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/minio-op` repository directory.

- Remove gitlab namespace by running:

```bash
# Uninstall chart and namespace.  
./csdeploy.sh -m uninstall
```

#### 3.- Update minio-tenant manifest

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/minio-t1` repository directory.

- Edit file  `mod-tenant.yaml` and update the minio server line as follows:

```bash
## Registry location and Tag to download MinIO Server image
image: quay.io/minio/minio:RELEASE.2022-08-13T21-54-44Z
```

#### 4.- Update minio-operator chart

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/minio-op` repository directory.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

## Repositories
helm repo add minio https://operator.min.io/
helm repo update

## Charts
helm pull minio/operator --version 4.4.28 --untar

EOF
)"
```

- Edit `README.md` documentation file, and change header as follows:

``` bash
## v22-08-21 <!-- omit in toc -->

## Helm charts: minio/operator v4.4.28 <!-- omit in toc -->
```

#### 5.- Remove old tenant CRD's

- Check existings CRD's by running:

```bash
# Get CRD's
kubectl get customresourcedefinitions.apiextensions.k8s.io
```

- Remove tenant CRD's by running:

```bash
# Remove tenant CRD's
kubectl delete customresourcedefinitions.apiextensions.k8s.io tenants.minio.min.io
```

#### 5.- Install minio-operator namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/minio-op` repository directory.

Install namespace by running:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Install chart and namespace.  
./csdeploy.sh -m install
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```
#### 6.- Install minio-tenant namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/minio-t1` repository directory.

Install namespace by running:

```bash

# Install chart and namespace.  
./csdeploy.sh -m install
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```

- Connect to minio-tenant console and check the application is running.

### Reference

- <https://github.com/bitnami/charts/tree/master/bitnami/minio>

---


