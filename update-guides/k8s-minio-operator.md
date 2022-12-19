<!-- markdownlint-disable MD024 -->

# k8s-minio-operator <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v22-12-19](#v22-12-19)
  - [Background](#background)
  - [How-to guides](#how-to-guides)
    - [1.- Update minio-tenant manifest](#1--update-minio-tenant-manifest)
    - [2.- Update minio-operator chart](#2--update-minio-operator-chart)
    - [3.- Update minio-operator namespace](#3--update-minio-operator-namespace)
    - [4.- Update minio-tenant namespace](#4--update-minio-tenant-namespace)
  - [Reference](#reference)
- [v22-08-21](#v22-08-21)
  - [Background](#background-1)
  - [How-to guides](#how-to-guides-1)
    - [1.- Uninstall minio-tenant  namespace](#1--uninstall-minio-tenant--namespace)
    - [2.- Uninstall minio-operator  namespace](#2--uninstall-minio-operator--namespace)
    - [3.- Update minio-tenant manifest](#3--update-minio-tenant-manifest)
    - [4.- Update minio-operator chart](#4--update-minio-operator-chart)
    - [5.- Remove old tenant CRD's](#5--remove-old-tenant-crds)
    - [5.- Install minio-operator namespace](#5--install-minio-operator-namespace)
    - [6.- Install minio-tenant namespace](#6--install-minio-tenant-namespace)
  - [Reference](#reference-1)

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


