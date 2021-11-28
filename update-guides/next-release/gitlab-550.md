# gitlab 5.5.0 Upgrade <!-- omit in toc -->

- [Background](#background)
- [How-to guides](#how-to-guides)
  - [Rename section in values-gitlab.yaml](#rename-section-in-values-gitlabyaml)
  - [Update configuration files](#update-configuration-files)
  - [Pull charts & upgrade](#pull-charts--upgrade)
- [Reference](#reference)

---

## Background

GitLab chart 5.5.0 implements appVersion 14.5.0. In this version `gitlab-task-runner` pod must be renamed to `gitlab-toolbox`.

This procedure updates gitlab installation in k8s-mod cluster.

## How-to guides

### Rename section in values-gitlab.yaml

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

### Update configuration files

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/gitlab` folder repository.

- Edit `csdeploy.sh` file
- Change `souce_charts` variable to the following values:

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
helm pull gitlab/gitlab --version 5.5.0 --untar
helm pull bitnami/postgresql --version 10.13.8 --untar

EOF
)"
```

- Save file
- Edit `README.md` documentation file, and change header as follows:

``` bash
## Helm charts: gitlab/gitlab v5.5.0 bitnami/postgresql v10.13.8<!-- omit in toc -->
```

- Save file

### Pull charts & upgrade

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

## Reference

- <https://docs.gitlab.com/ee/update/deprecations.html#rename-task-runner-pod-to-toolbox>
