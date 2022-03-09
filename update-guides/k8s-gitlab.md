<!-- markdownlint-disable MD024 -->

# k8s-gitlab Update Guides <!-- omit in toc -->

- [v22-01-05](#v22-01-05)
  - [Background](#background)
    - [Prerequisites](#prerequisites)
  - [How-to guides](#how-to-guides)
    - [1.- Intermediate update to gitlab chart 5.5.2](#1--intermediate-update-to-gitlab-chart-552)
      - [1a.- Update configuration files](#1a--update-configuration-files)
      - [1b.- Pull charts & upgrade](#1b--pull-charts--upgrade)
    - [2.- Update to gitlab chart 5.6.0](#2--update-to-gitlab-chart-560)
      - [2a.- Update configuration files](#2a--update-configuration-files)
      - [2b.- Pull charts & upgrade](#2b--pull-charts--upgrade)
  - [Reference](#reference)
- [v21-12-06](#v21-12-06)
  - [Background](#background-1)
  - [How-to guides](#how-to-guides-1)
    - [1.- Rename section in values-gitlab.yaml](#1--rename-section-in-values-gitlabyaml)
    - [2.- Update configuration files](#2--update-configuration-files)
    - [3.- Pull charts & upgrade](#3--pull-charts--upgrade)
  - [Reference](#reference-1)

---

## v22-01-05

### Background

This procedure updates GitLab chart to version 5.6.0 with appVersion 14.6.0. Before applying chart 5.6.0 it is mandatory to perform an intermediate update to chart 5.5.2.

This procedure updates gitlab installation in k8s-mod cluster.

#### Prerequisites

You must be running chart 5.5.1 (Updated or deployed from cSkyLab v21-12-06)

### How-to guides

#### 1.- Intermediate update to gitlab chart 5.5.2

##### 1a.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add gitlab https://charts.gitlab.io/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull gitlab/gitlab --version 5.5.2 --untar
helm pull bitnami/postgresql --version 10.13.11 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: gitlab/gitlab v5.5.2 bitnami/postgresql v10.13.11<!-- omit in toc -->
```

- Save file

##### 1b.- Pull charts & upgrade

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` folder repository.

Execute the following commands to pull charts and upgrade gitlab:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l

# Save rail secrets to rail-secrets.yaml
kubectl -n={{ .namespace.name }} get secret gitlab-rails-secret -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > rail-secrets.yaml
```

#### 2.- Update to gitlab chart 5.6.0

##### 2a.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add gitlab https://charts.gitlab.io/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull gitlab/gitlab --version 5.6.0 --untar
helm pull bitnami/postgresql --version 10.14.0 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: gitlab/gitlab v5.6.0 bitnami/postgresql v10.14.0<!-- omit in toc -->
```

- Save file

##### 2b.- Pull charts & upgrade

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` folder repository.

Execute the following commands to pull charts and upgrade gitlab:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l

# Save rail secrets to rail-secrets.yaml
kubectl -n={{ .namespace.name }} get secret gitlab-rails-secret -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > rail-secrets.yaml
```

### Reference

- <https://docs.gitlab.com/charts/>

---

## v21-12-06

### Background

GitLab chart 5.5.1 implements appVersion 14.5.1. In this version `gitlab-task-runner` pod must be renamed to `gitlab-toolbox`.

This procedure updates gitlab installation in k8s-mod cluster.

### How-to guides

#### 1.- Rename section in values-gitlab.yaml

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` folder repository.

- Edit `values-gitlab.yaml` file
- Look for the following section:

```yaml
gitlab:
  ## doc/charts/gitlab/task-runner
  task-runner:
```

- Change values as follow:

```yaml
gitlab:
  ## doc/charts/gitlab/toolbox
  toolbox:
```

- Save the file

#### 2.- Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` folder repository.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

# Repositories
helm repo add gitlab https://charts.gitlab.io/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Charts
helm pull gitlab/gitlab --version 5.5.1 --untar
helm pull bitnami/postgresql --version 10.13.11 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: gitlab/gitlab v5.5.1 bitnami/postgresql v10.13.11<!-- omit in toc -->
```

- Save file

#### 3.- Pull charts & upgrade

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` folder repository.

Execute the following commands to pull charts and upgrade gitlab:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Update
./csdeploy.sh -m update

# Check status
./csdeploy.sh -l

# Save rail secrets to rail-secrets.yaml
kubectl -n={{ .namespace.name }} get secret gitlab-rails-secret -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > rail-secrets.yaml
```

### Reference

- <https://docs.gitlab.com/ee/update/deprecations.html#rename-task-runner-pod-to-toolbox>
