# MetalLB chart 2.5.13 Upgrade <!-- omit in toc -->

- [Background](#background)
- [How-to guides](#how-to-guides)
  - [Update configuration files](#update-configuration-files)
  - [Pull charts & upgrade](#pull-charts--upgrade)
- [Reference](#reference)

---

## Background

MetalLB chart 2.5.13 updates chart components versions in metallb appVersion 0.11.0.

This procedure updates MetalLB installation in k8s-mod cluster.

## How-to guides

### Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/metallb` folder repository.

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
helm pull bitnami/metallb --version 2.5.13 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: bitnami/metallb v2.5.13 <!-- omit in toc -->
```

- Save file

### Pull charts & upgrade

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/metallb` folder repository.

Execute the following commands to pull charts and upgrade:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```

## Reference

- <https://github.com/bitnami/charts/tree/master/bitnami/metallb/>
- <https://metallb.universe.tf>
