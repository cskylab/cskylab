# Nextcloud chart 2.10.2 Upgrade <!-- omit in toc -->

- [Background](#background)
- [How-to guides](#how-to-guides)
  - [Update configuration files](#update-configuration-files)
  - [Pull charts & upgrade](#pull-charts--upgrade)
- [Reference](#reference)

---

## Background

Nextcloud chart 2.10.2 updates chart parameters in Nextcloud appVersion 22.2.3.

This procedure updates Nextcloud installation in k8s-mod cluster.

## How-to guides

### Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/nextcloud` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull nextcloud/nextcloud --version 2.10.2 --untar
helm pull bitnami/mariadb --version 10.0.1 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: bitnami/minio v9.2.3<!-- omit in toc -->
```

- Save file

### Pull charts & upgrade

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/nextcloud` folder repository.

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

- <https://github.com/nextcloud/helm/tree/master/charts/nextcloud>
