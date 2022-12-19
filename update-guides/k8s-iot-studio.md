<!-- markdownlint-disable MD024 -->

# k8s-iot-studio <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v99-99-99](#v99-99-99)
  - [Background](#background)
  - [How-to guides](#how-to-guides)
    - [1.- Change image section in values-node-red.yaml](#1--change-image-section-in-values-node-redyaml)
    - [2.- Change image section in values-influxdb2.yaml](#2--change-image-section-in-values-influxdb2yaml)
    - [3.- Update script cs-deploy.sh](#3--update-script-cs-deploysh)
    - [3.- Pull charts \& update](#3--pull-charts--update)

---

## v99-99-99

### Background

This update covers the following charts upgrades:

- **k8s-at-home/mosquitto v4.8.2**
- **k8s-at-home/node-red v10.3.2**: appVersion v3.0.2
- **influxdata/influxdb2 v2.1.1**: appVersion v2.5.1
- **bitnami/grafana v8.2.21**: appVersion v9.3.2

This procedure updates iot-studio installation in k8s-mod cluster.

### How-to guides

#### 1.- Change image section in values-node-red.yaml

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/iot-studio` application folder repository.

- Edit `values-node-red.yaml` file
- Look for the following section, and change values as follows:

```yaml
image:
  tag: 3.0.2
```

- Save the file

#### 2.- Change image section in values-influxdb2.yaml

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/iot-studio` application folder repository.

- Edit `values-influxdb.yaml` file
- Look for the following section, and change values as follows:

```yaml
image:
  tag: 2.5.1
```

- Save the file

#### 3.- Update script cs-deploy.sh

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/iot-studio` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

## Repositories
helm repo add k8s-at-home https://k8s-at-home.com/charts/
helm repo add influxdata https://helm.influxdata.com/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

## Charts
helm pull k8s-at-home/mosquitto --version 4.8.2 --untar
helm pull k8s-at-home/node-red --version 10.3.2 --untar
helm pull influxdata/influxdb2 --version 2.1.1 --untar
helm pull bitnami/grafana --version 8.2.21 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## k8s-iot-studio v99-99-99 <!-- omit in toc -->
```

- Save file

#### 3.- Pull charts & update

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/iot-studio` repository directory.

Execute the following commands to pull charts and upgrade:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```

---
