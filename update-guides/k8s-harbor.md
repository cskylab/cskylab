<!-- markdownlint-disable MD024 -->

# k8s-harbor <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v99-99-99](#v99-99-99)
  - [Background](#background)
  - [How-to guides](#how-to-guides)
    - [1.- Create new data service directory on k8s-mod-n1](#1--create-new-data-service-directory-on-k8s-mod-n1)
    - [2.- Create new PV manifest](#2--create-new-pv-manifest)
    - [3.- Update harbor chart values file](#3--update-harbor-chart-values-file)
    - [4.- Update configuration files](#4--update-configuration-files)
    - [5.- Pull charts \& update](#5--pull-charts--update)
  - [Reference](#reference)
- [v22-12-19](#v22-12-19)
  - [Background](#background-1)
  - [How-to guides](#how-to-guides-1)
    - [1.- Update configuration files](#1--update-configuration-files)
    - [2.- Pull charts \& update](#2--pull-charts--update)
  - [Reference](#reference-1)
- [v22-08-21](#v22-08-21)
  - [Background](#background-2)
  - [How-to guides](#how-to-guides-2)
    - [1.- Uninstall harbor namespace](#1--uninstall-harbor-namespace)
    - [2.- Rename old configuration directory](#2--rename-old-configuration-directory)
    - [3.- Create new configuration from new template](#3--create-new-configuration-from-new-template)
    - [4.- Install new harbor namespace](#4--install-new-harbor-namespace)
  - [Reference](#reference-2)
- [v22-03-23](#v22-03-23)
  - [Background](#background-3)
  - [How-to guides](#how-to-guides-3)
    - [1.- Update configuration files](#1--update-configuration-files-1)
    - [2.- Pull charts \& update](#2--pull-charts--update-1)
  - [Reference](#reference-3)
- [v22-01-05](#v22-01-05)
  - [Background](#background-4)
  - [How-to guides](#how-to-guides-4)
    - [1.- Update configuration files](#1--update-configuration-files-2)
    - [2.- Pull charts \& upgrade](#2--pull-charts--upgrade)
  - [Reference](#reference-4)
- [v21-12-06](#v21-12-06)
  - [Background](#background-5)
  - [How-to guides](#how-to-guides-5)
    - [1.- Update configuration files](#1--update-configuration-files-3)
    - [2.- Pull charts \& upgrade](#2--pull-charts--upgrade-1)
  - [Reference](#reference-5)

---

## v99-99-99

### Background

Harbor chart 16.4.10 updates components versions in Harbor appVersion 2.7.0. This version requires the addition of a new data service and persistent volume for `harbor-scandata`.

This procedure updates Harbor installation in k8s-mod cluster.

### How-to guides

#### 1.- Create new data service directory on k8s-mod-n1

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

#### 2.- Create new PV manifest

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/harbor` folder repository.

Create a new PV manifest file called `pv-scandata.yaml` with the following content:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: 'harbor-scandata'
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer

---

apiVersion: v1
kind: PersistentVolume
metadata:
  name: 'harbor-scandata'
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: 'harbor-scandata'
  local:
    path: '/srv/harbor/data/scandata'
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - k8s-mod-n1
```

#### 3.- Update harbor chart values file

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/harbor` folder repository.

Edit file `values-harbor.yaml` and find the property tree called `persistentVolumeClaim:`

Replace the entire tree with the following values (keeping the appropriate identation of the whole tree):

```yaml
  persistentVolumeClaim:
    ## @param persistence.persistentVolumeClaim.registry.existingClaim Name of an existing PVC to use
    ## @param persistence.persistentVolumeClaim.registry.storageClass PVC Storage Class for Harbor Registry data volume
    ## Note: The default StorageClass will be used if not defined. Set it to `-` to disable dynamic provisioning
    ## @param persistence.persistentVolumeClaim.registry.subPath The sub path used in the volume
    ## @param persistence.persistentVolumeClaim.registry.accessModes The access mode of the volume
    ## @param persistence.persistentVolumeClaim.registry.size The size of the volume
    ## @param persistence.persistentVolumeClaim.registry.annotations Annotations for the PVC
    ## @param persistence.persistentVolumeClaim.registry.selector Selector to match an existing Persistent Volume
    ##
    registry:
      existingClaim: ""
      storageClass: "harbor-registry"
      subPath: ""
      accessModes:
        - ReadWriteOnce
      size: 5Gi
      annotations: {}
      selector: {}
    ## @param persistence.persistentVolumeClaim.jobservice.existingClaim Name of an existing PVC to use
    ## @param persistence.persistentVolumeClaim.jobservice.storageClass PVC Storage Class for Harbor Jobservice data volume
    ## Note: The default StorageClass will be used if not defined. Set it to `-` to disable dynamic provisioning
    ## @param persistence.persistentVolumeClaim.jobservice.subPath The sub path used in the volume
    ## @param persistence.persistentVolumeClaim.jobservice.accessModes The access mode of the volume
    ## @param persistence.persistentVolumeClaim.jobservice.size The size of the volume
    ## @param persistence.persistentVolumeClaim.jobservice.annotations Annotations for the PVC
    ## @param persistence.persistentVolumeClaim.jobservice.selector Selector to match an existing Persistent Volume
    ##
    jobservice:
      existingClaim: ""
      storageClass: "harbor-jobservice"
      subPath: ""
      accessModes:
        - ReadWriteOnce
      size: 1Gi
      annotations: {}
      selector: {}
      ## @param persistence.persistentVolumeClaim.jobservice.scanData.existingClaim Name of an existing PVC to use
      ## @param persistence.persistentVolumeClaim.jobservice.scanData.storageClass PVC Storage Class for Harbor Jobservice scan data volume
      ## Note: The default StorageClass will be used if not defined. Set it to `-` to disable dynamic provisioning
      ## @param persistence.persistentVolumeClaim.jobservice.scanData.subPath The sub path used in the volume
      ## @param persistence.persistentVolumeClaim.jobservice.scanData.accessModes The access mode of the volume
      ## @param persistence.persistentVolumeClaim.jobservice.scanData.size The size of the volume
      ## @param persistence.persistentVolumeClaim.jobservice.scanData.annotations Annotations for the PVC
      ## @param persistence.persistentVolumeClaim.jobservice.scanData.selector Selector to match an existing Persistent Volume
      ##
      scanData:
        existingClaim: ""
        storageClass: "harbor-scandata"
        subPath: ""
        accessModes:
          - ReadWriteOnce
        size: 1Gi
        annotations: {}
        selector: {}
    ## @param persistence.persistentVolumeClaim.chartmuseum.existingClaim Name of an existing PVC to use
    ## @param persistence.persistentVolumeClaim.chartmuseum.storageClass PVC Storage Class for Chartmuseum data volume
    ## Note: The default StorageClass will be used if not defined. Set it to `-` to disable dynamic provisioning
    ## @param persistence.persistentVolumeClaim.chartmuseum.subPath The sub path used in the volume
    ## @param persistence.persistentVolumeClaim.chartmuseum.accessModes The access mode of the volume
    ## @param persistence.persistentVolumeClaim.chartmuseum.size The size of the volume
    ## @param persistence.persistentVolumeClaim.chartmuseum.annotations Annotations for the PVC
    ## @param persistence.persistentVolumeClaim.chartmuseum.selector Selector to match an existing Persistent Volume
    ##
    chartmuseum:
      existingClaim: ""
      storageClass: "harbor-chartmuseum"
      subPath: ""
      accessModes:
        - ReadWriteOnce
      size: 5Gi
      annotations: {}
      selector: {}
    ## @param persistence.persistentVolumeClaim.trivy.storageClass PVC Storage Class for Trivy data volume
    ## Note: The default StorageClass will be used if not defined. Set it to `-` to disable dynamic provisioning
    ## @param persistence.persistentVolumeClaim.trivy.accessModes The access mode of the volume
    ## @param persistence.persistentVolumeClaim.trivy.size The size of the volume
    ## @param persistence.persistentVolumeClaim.trivy.annotations Annotations for the PVC
    ## @param persistence.persistentVolumeClaim.trivy.selector Selector to match an existing Persistent Volume
    ##
    trivy:
      storageClass: "harbor-trivy"
      accessModes:
        - ReadWriteOnce
      size: 5Gi
      annotations: {}
      selector: {}
```

Save the modified file `values-harbor.yaml`.

#### 4.- Update configuration files

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
helm pull bitnami/harbor --version 16.4.10 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## v99-99-99 <!-- omit in toc -->

## Helm charts: bitnami/harbor v16.4.10 <!-- omit in toc -->
```

- Save file

#### 5.- Pull charts & update

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
