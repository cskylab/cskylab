<!-- markdownlint-disable MD024 -->

# k8s-ingress-nginx <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v24-04-20](#v24-04-20)
  - [Background](#background)
  - [How-to guides](#how-to-guides)
    - [1.- Update configuration files](#1--update-configuration-files)
    - [2.- Pull charts \& update namespace](#2--pull-charts--update-namespace)
  - [Reference](#reference)
- [v23-11-24](#v23-11-24)
  - [Background](#background-1)
  - [How-to guides](#how-to-guides-1)
    - [1.- Update configuration files](#1--update-configuration-files-1)
    - [2.- Pull charts \& update namespace](#2--pull-charts--update-namespace-1)
  - [Reference](#reference-1)
- [v23-04-27](#v23-04-27)
  - [Background](#background-2)
  - [How-to guides](#how-to-guides-2)
    - [1.- Update configuration files](#1--update-configuration-files-2)
    - [2.- Pull charts \& update namespace](#2--pull-charts--update-namespace-2)
  - [Reference](#reference-2)
- [v22-12-19](#v22-12-19)
  - [Background](#background-3)
  - [How-to guides](#how-to-guides-3)
    - [1.- Update configuration files](#1--update-configuration-files-3)
    - [2.- Pull charts \& update namespace](#2--pull-charts--update-namespace-3)
  - [Reference](#reference-3)
- [v22-08-21](#v22-08-21)
  - [Background](#background-4)
  - [How-to guides](#how-to-guides-4)
    - [1.- Update configuration files](#1--update-configuration-files-4)
    - [2.- Pull charts \& update namespace](#2--pull-charts--update-namespace-4)
  - [Reference](#reference-4)
- [v22-03-23](#v22-03-23)
  - [Background](#background-5)
  - [How-to guides](#how-to-guides-5)
    - [1.- Update configuration files](#1--update-configuration-files-5)
    - [2.- Pull charts \& update namespace](#2--pull-charts--update-namespace-5)
  - [Reference](#reference-5)
- [v22-01-05](#v22-01-05)
  - [Background](#background-6)
  - [How-to guides](#how-to-guides-6)
    - [1.- Update configuration files](#1--update-configuration-files-6)
    - [2.- Pull charts \& upgrade](#2--pull-charts--upgrade)
  - [Reference](#reference-6)
- [v21-12-06](#v21-12-06)
  - [Background](#background-7)
  - [How-to guides](#how-to-guides-7)
    - [1.- Update configuration files](#1--update-configuration-files-7)
    - [2.- Pull charts \& upgrade](#2--pull-charts--upgrade-1)
  - [Reference](#reference-7)

---
## v24-04-20

### Background

ingress-nginx chart 4.10.0 updates chart parameters in appVersion 1.10.0

This procedure updates ingress-nginx installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

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
helm pull ingress-nginx/ingress-nginx --version 4.10.0 --untar

EOF
)"
```

- Save file
- Edit `README.md` configuration file, and change header as follows:

``` bash
## v24-04-20 <!-- omit in toc -->

## Helm charts: ingress-nginx/ingress-nginx v4.10.0 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/ingress-nginx` repository directory.

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

- <https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx>
- <https://github.com/kubernetes/ingress-nginx>


---

## v23-11-24

### Background

ingress-nginx chart 4.8.3 updates chart parameters in appVersion 1.9.4.

This procedure updates ingress-nginx installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

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
helm pull ingress-nginx/ingress-nginx --version 4.8.3 --untar

EOF
)"
```

- Save file
- Edit `README.md` configuration file, and change header as follows:

``` bash
## v23-11-24 <!-- omit in toc -->

## Helm charts: ingress-nginx/ingress-nginx v4.8.3 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/ingress-nginx` repository directory.

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

- <https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx>
- <https://github.com/kubernetes/ingress-nginx>


---

## v23-04-27

### Background

ingress-nginx chart 4.6.0 updates chart parameters in appVersion 1.7.0.

This procedure updates ingress-nginx installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

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
helm pull ingress-nginx/ingress-nginx --version 4.6.0 --untar

EOF
)"
```

- Save file
- Edit `README.md` configuration file, and change header as follows:

``` bash
## v22-12-19 <!-- omit in toc -->

## Helm charts: ingress-nginx/ingress-nginx v4.6.0 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/ingress-nginx` repository directory.

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

- <https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx>
- <https://github.com/kubernetes/ingress-nginx>


---


## v22-12-19

### Background

ingress-nginx chart 4.4.0 updates chart parameters in appVersion 1.5.1.

This procedure updates ingress-nginx installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

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
helm pull ingress-nginx/ingress-nginx --version 4.4.0 --untar

EOF
)"
```

- Save file
- Edit `README.md` configuration file, and change header as follows:

``` bash
## v22-12-19 <!-- omit in toc -->

## Helm charts: ingress-nginx/ingress-nginx v4.4.0 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/ingress-nginx` repository directory.

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

- <https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx>
- <https://github.com/kubernetes/ingress-nginx>


---

## v22-08-21

### Background

ingress-nginx chart 4.2.1 updates chart parameters in appVersion 1.3.0.

This procedure updates ingress-nginx installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

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
helm pull ingress-nginx/ingress-nginx --version 4.2.1 --untar

EOF
)"
```

- Save file
- Edit `README.md` configuration file, and change header as follows:

``` bash
## v22-08-21 <!-- omit in toc -->

## Helm charts: ingress-nginx/ingress-nginx v4.2.1 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/ingress-nginx` repository directory.

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

- <https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx>
- <https://github.com/kubernetes/ingress-nginx>


---
## v22-03-23

### Background

ingress-nginx chart 4.0.18 updates chart parameters in appVersion 1.1.2.

This procedure updates ingress-nginx installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

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
helm pull ingress-nginx/ingress-nginx --version 4.0.18 --untar

EOF
)"
```

- Save file
- Edit `README.md` configuration file, and change header as follows:

``` bash
## v22-03-23 <!-- omit in toc -->

## Helm charts: ingress-nginx/ingress-nginx v4.0.18 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & update namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/ingress-nginx` repository directory.

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

- <https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx>
- <https://github.com/kubernetes/ingress-nginx>

---

## v22-01-05

### Background

ingress-nginx chart 4.0.13 updates chart parameters in appVersion 1.1.0.

This procedure updates ingress-nginx installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

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
helm pull ingress-nginx/ingress-nginx --version 4.0.13 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: ingress-nginx/ingress-nginx v4.0.13 <!-- omit in toc -->
```

- Save file

#### 2.- Pull charts & upgrade

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

### Reference

- <https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx>
- <https://github.com/kubernetes/ingress-nginx>

---

## v21-12-06

### Background

ingress-nginx chart 4.0.12 updates chart parameters in appVersion 1.1.0.

This procedure updates ingress-nginx installation in k8s-mod cluster.

### How-to guides

#### 1.- Update configuration files

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

#### 2.- Pull charts & upgrade

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

### Reference

- <https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx>
- <https://github.com/kubernetes/ingress-nginx>
