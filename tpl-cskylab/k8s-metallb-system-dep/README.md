# MetalLB Load-balancer for kubernetes<!-- omit in toc -->

>**DEPRECATED**: This template is no longer maintained. To deploy metallb-system use template `k8s-metallb-system`

## v22-01-05 <!-- omit in toc -->

## Helm charts: bitnami/metallb v2.5.16 <!-- omit in toc -->

[MetalLB](https://metallb.universe.tf/) is a load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols.

Configuration files are deployed from template {{ ._tpldescription }} version {{ ._tplversion }}.

> **Note**: [MetalLB](https://metallb.universe.tf/) is a cluster service, and as such can only be deployed as a
cluster singleton. Running multiple installations of [MetalLB](https://metallb.universe.tf/) in a
single cluster is not supported.

- [TL;DR](#tldr)
- [Prerequisites](#prerequisites)
- [How-to guides](#how-to-guides)
  - [Configure IP Addresses pools](#configure-ip-addresses-pools)
  - [Pull Helm charts](#pull-helm-charts)
  - [Install](#install)
  - [Update](#update)
  - [Uninstall](#uninstall)
  - [Remove](#remove)
  - [Display status](#display-status)
- [Reference](#reference)
  - [Helm charts and values](#helm-charts-and-values)
  - [Scripts](#scripts)
    - [csdeploy](#csdeploy)
  - [Template values](#template-values)
- [License](#license)

## TL;DR

- Before deploying, review or modify override values in file `values-metallb.yaml`
- To deploy namespace and chart:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Install  
./csdeploy.sh -m install

# Check status
./csdeploy.sh -l
```

---

## Prerequisites

- Administrative access to Kubernetes cluster.
- Helm v3
- No instance of MetalLB running on K8s cluster.
- MetalLB IP Addresses pools configured.

## How-to guides

### Configure IP Addresses pools

MetalLB configures static and dynamic addresses pools. Initial addresses pools values are provided by the template. You must review or modify these values before installing.

- To modify IP Addresses pools edit the `configInline` section on chart overrides file `values-metallb.yaml`.

- After configuring the desired IP Addresses pools, you can install or update the service.

### Pull Helm charts

- Modify repositories and versions needed in the variable `source_charts` inside the script `csdeploy.sh`.

- To pull the new versions run:

```bash
# Pull charts to './charts/' directory
  ./csdeploy.sh -m pull-charts
```

>Note: When pulling new charts, all the content of `./charts` directory will be removed, and replaced by the new pulled charts.

- To redeploy the new versions run:

```bash
# Redeploy and upgrade charts
  ./csdeploy.sh -m update
```

### Install

To Create namespace and install charts:

```bash
  #  Create namespace, secrets, config-maps, PV's, apply manifests and install charts.
    ./csdeploy.sh -m install
```

### Update

To update IP Addresses pools and charts settings, change values in files `values-metallb.yaml`.

Update or upgrade chart by running:

```bash
  # Reapply manifests and update or upgrade charts
    ./csdeploy.sh -m update
```

### Uninstall

To uninstall charts and remove namespace run:

```bash
  # Uninstall charts, delete manifests, remove PV's and namespace
    ./csdeploy.sh -m uninstall
```

### Remove

This option is intended to be used only to remove the namespace when chart deployment is failed. Otherwise, you must run `./csdeploy.sh -m uninstall`.

To remove namespace and all its contents run:

```bash
  # Remove PV's namespace and all its contents
    ./csdeploy.sh -m remove
```

### Display status

To display namespace and chart status run:

```bash
  # Display namespace config-map and chart status:
    ./csdeploy.sh -l
```

## Reference

To learn more see:

- <https://metallb.universe.tf>
- <https://github.com/bitnami/charts/tree/master/bitnami/metallb/>

### Helm charts and values

| Chart           | Values                |
| --------------- | --------------------- |
| bitnami/metallb | `values-metallb.yaml` |

### Scripts

#### csdeploy

```console
Purpose:
  MetalLB load-balancer.

Usage:
  sudo csdeploy.sh [-l] [-m <execution_mode>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List current status.
  -m  <execution_mode>  - Valid modes are:

      [pull-charts]     - Pull charts to './charts/' directory.
      [install]         - Create namespace and install charts.
      [update]          - Modify addresses pools and upgrade charts versions.
      [uninstall]       - Uninstall charts and remove namespace.
      [remove]          - Remove namespace and all its contents.

Options and arguments:  
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Pull charts to './charts/' directory
    ./csdeploy.sh -m pull-charts

  # Create namespace and install charts.
    ./csdeploy.sh -m install

  # Modify addresses pools and upgrade charts.
    ./csdeploy.sh -m update

  # Uninstall charts, and namespace.
    ./csdeploy.sh -m uninstall

  # Remove namespace and all its contents
    ./csdeploy.sh -m remove

  # Display namespace, addresses pools  and charts status.
    ./csdeploy.sh -l
```

**Tasks performed:**

| ${execution_mode}                | Tasks                      | Block / Description                                                         |
| -------------------------------- | -------------------------- | --------------------------------------------------------------------------- |
| [pull-charts]                    |                            | **Pull helm charts from repositories**                                      |
|                                  | Clean `./charts` directory | Remove all contents in `./charts` directory.                                |
|                                  | Pull helm charts           | Pull new charts according to sourced script in variable `source_charts`.    |
|                                  | Show charts                | Show Helm charts pulled into `./charts` directory.                          |
| [install]                        |                            | **Create namespace**                                                        |
|                                  | Create namespace           | Namespace must be unique in cluster.                                        |
| [update] [install]               |                            | **Deploy charts**                                                           |
|                                  | Deploy charts              | Deploy all charts in `./charts` directory with `upgrade --install` options. |
| [uninstall]                      |                            | **Uninstall charts**                                                        |
|                                  | Uninstall charts           | Uninstall all charts in `./charts` directory.                               |
| [uninstall] [remove]             |                            | **Remove namespace**                                                        |
|                                  | Remove namespace           | Remove namespace and all its objects.                                       |
| [install] [update] [list-status] |                            | **Display status information**                                              |
|                                  | Display namespace          | Namespace and object status.                                                |
|                                  | Display config-map         | Status of addresses pools.                                                  |
|                                  | Display charts             | Charts releases history information.                                        |
|                                  |                            |                                                                             |

### Template values

The following table lists template configuration parameters and their specified values, when machine configuration files were created from the template:

| Parameter                 | Description               | Values                                                   |
| ------------------------- | ------------------------- | -------------------------------------------------------- |
| `_tplname`                | template name             | `{{ ._tplname }}`                                        |
| `_tpldescription`         | template description      | `{{ ._tpldescription }}`                                 |
| `_tplversion`             | template version          | `{{ ._tplversion }}`                                     |
| `kubeconfig`              | kubeconfig file           | `{{ .kubeconfig }}`                                      |
| `namespace.name`          | namespace name            | `{{ .namespace.name }}`                                  |
| `metallb.staticpooladdr`  | static pool IP addresses  | `{{ range .metallb.staticpooladdr }}{{ . }}, {{ end }}`  |
| `metallb.dynamicpooladdr` | dynamic pool IP addresses | `{{ range .metallb.dynamicpooladdr }}{{ . }}, {{ end }}` |

## License

Copyright © 2021 cSkyLab.com ™

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
