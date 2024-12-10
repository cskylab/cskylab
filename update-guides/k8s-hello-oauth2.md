<!-- markdownlint-disable MD024 -->

# k8s-hello-oauth2 <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v24-12-11](#v24-12-11)
  - [Background](#background)
  - [How-to guides](#how-to-guides)
    - [1.- Update configuration files](#1--update-configuration-files)
    - [2.- Pull charts \& update namespace](#2--pull-charts--update-namespace)
  - [Reference](#reference)
- [v24-04-20](#v24-04-20)
  - [Background](#background-1)
  - [How-to guides](#how-to-guides-1)
    - [1.- Update configuration files](#1--update-configuration-files-1)
    - [2.- Pull charts \& update namespace](#2--pull-charts--update-namespace-1)
  - [Reference](#reference-1)
- [v23-11-24](#v23-11-24)
  - [Background](#background-2)
  - [How-to guides](#how-to-guides-2)
    - [1.- Update configuration files](#1--update-configuration-files-2)
    - [2.- Pull charts \& update namespace](#2--pull-charts--update-namespace-2)
  - [Reference](#reference-2)

---

## v24-12-11

### Background

Chart oauth2-proxy/oauth2-proxy version 7.8.1 updates chart parameters in appVersion 7.7.1

This procedure updates oauth2-proxy installation in k8s-mod cluster.

>**Note**: This namespace, requires to configure a k8s-keycloakx backend authentication client.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/hello-oauth2` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

## Repositories
helm repo add oauth2-proxy https://oauth2-proxy.github.io/manifests
helm repo update

## Charts
helm pull oauth2-proxy/oauth2-proxy --version 7.8.1 --untar

EOF
)"
```

- Save file
- Edit `README.md` configuration file, and change header as follows:

``` bash
## v24-12-11 <!-- omit in toc -->

## Helm charts: oauth2-proxy/oauth2-proxy v7.8.1 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/hello-oauth2` folder repository.

Execute the following commands to pull charts and update the namespace:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```

### Reference

- <https://github.com/oauth2-proxy/manifests/tree/main/helm/oauth2-proxy>
- <https://oauth2-proxy.github.io/oauth2-proxy/>
- <https://github.com/oauth2-proxy/oauth2-proxy>



## v24-04-20

### Background

Chart oauth2-proxy/oauth2-proxy version 7.4.1 updates chart parameters in appVersion 7.6.0

This procedure updates oauth2-proxy installation in k8s-mod cluster.

>**Note**: This namespace, requires to configure a k8s-keycloakx backend authentication client.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/hello-oauth2` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

## Repositories
helm repo add oauth2-proxy https://oauth2-proxy.github.io/manifests
helm repo update

## Charts
helm pull oauth2-proxy/oauth2-proxy --version 7.4.1 --untar

EOF
)"
```

- Save file
- Edit `README.md` configuration file, and change header as follows:

``` bash
## v24-04-20 <!-- omit in toc -->

## Helm charts: oauth2-proxy/oauth2-proxy v7.4.1 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/hello-oauth2` folder repository.

Execute the following commands to pull charts and update the namespace:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```

### Reference

- <https://github.com/oauth2-proxy/manifests/tree/main/helm/oauth2-proxy>
- <https://oauth2-proxy.github.io/oauth2-proxy/>
- <https://github.com/oauth2-proxy/oauth2-proxy>


## v23-11-24

### Background

Chart oauth2-proxy/oauth2-proxy version 6.19.1 updates chart parameters in appVersion 7.5.1

This procedure updates oauth2-proxy installation in k8s-mod cluster.

>**Note**: This namespace, requires to configure a k8s-keycloakx backend authentication client.

### How-to guides

#### 1.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/hello-oauth2` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

## Repositories
helm repo add oauth2-proxy https://oauth2-proxy.github.io/manifests
helm repo update

## Charts
helm pull oauth2-proxy/oauth2-proxy --version 6.19.1 --untar

EOF
)"
```

- Save file
- Edit `README.md` configuration file, and change header as follows:

``` bash
## v23-11-24 <!-- omit in toc -->

## Helm charts: oauth2-proxy/oauth2-proxy v6.19.1 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/hello-oauth2` folder repository.

Execute the following commands to pull charts and update the namespace:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l
```

### Reference

- <https://github.com/oauth2-proxy/manifests/tree/main/helm/oauth2-proxy>
- <https://oauth2-proxy.github.io/oauth2-proxy/>
- <https://github.com/oauth2-proxy/oauth2-proxy>


