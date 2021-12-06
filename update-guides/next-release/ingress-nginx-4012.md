# ingress-nginx chart 4.0.12 Upgrade <!-- omit in toc -->

- [Background](#background)
- [How-to guides](#how-to-guides)
  - [Update configuration files](#update-configuration-files)
  - [Pull charts & upgrade](#pull-charts--upgrade)
- [Reference](#reference)

---

## Background

ingress-nginx chart 4.0.12 updates chart parameters in appVersion 1.1.0.

This procedure updates ingress-nginx installation in k8s-mod cluster.

## How-to guides

### Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/ingress-nginx` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Charts
helm pull ingress-nginx/ingress-nginx --version 4.0.12 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: ingress-nginx/ingress-nginx v4.0.12 <!-- omit in toc -->
```

- Save file

### Pull charts & upgrade

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/ingress-nginx` folder repository.

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

- <https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx>
- <https://github.com/kubernetes/ingress-nginx>
