# Ingress nginx controller for kubernetes <!-- omit in toc -->

## v22-12-19 <!-- omit in toc -->

## Helm charts: ingress-nginx/ingress-nginx v4.4.0 <!-- omit in toc -->

`k8s-ingress-nginx` ingress controller uses NGINX as a reverse proxy and load balancer.

To use in your deployments, add the `kubernetes.io/ingress.class: nginx` annotation to your Ingress resources.

Configuration files are deployed from template Ingress nginx controller for Kubernetes. version 22-12-19.

> **Note**: `k8s-ingress-nginx` should be considered as cluster service. It is recommended to deploy it as a cluster singleton.

- [TL;DR](#tldr)
- [Prerequisites](#prerequisites)
- [How-to guides](#how-to-guides)
  - [Configure ingress-nginx options](#configure-ingress-nginx-options)
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

- Before deploying, review or modify `loadBalancerIP` value in file `values-ingress-nginx.yaml`
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
- Service `k8s-metallb-system` must be deployed and `loadBalancerIP` address must be configured as static-pool.

## How-to guides

### Configure ingress-nginx options

Check `loadBalancerIP` and other override configuration values on file `values-ingress-nginx.yaml`.

After configuring the desired values, you can install or update the service.

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

To create namespace and install chart:

```bash
  # Create namespace and install chart
    ./csdeploy.sh -m install
```

### Update

To update chart settings, change values in file `values-ingress-nginx.yaml`.

Redeploy or upgrade the chart running:

```bash
  # Redeploy chart and update settings
    ./csdeploy.sh -m update
```

### Uninstall

To uninstall chart and remove namespace, run:

```bash
  # Uninstall chart and remove namespace
    ./csdeploy.sh -m uninstall
```

### Remove

This option is intended to use only to remove the namespace when chart deployment is failed. Otherwise, you must run `./csdeploy.sh -m uninstall`.

To remove namespace and all its contents run:

```bash
  # Remove namespace and all its contents
    ./csdeploy.sh -m remove
```

This action deletes the namespace and chart deployment.

### Display status

To display namespace and chart status run:

```bash
  # Display namespace status:
    csdeploy.sh -l
```

## Reference

To learn more see:

- <https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx>
- <https://github.com/kubernetes/ingress-nginx>

### Helm charts and values

| Chart                       | Values                      |
| --------------------------- | --------------------------- |
| ingress-nginx/ingress-nginx | `values-ingress-nginx.yaml` |

### Scripts

#### csdeploy

```console
Purpose:
  ingress-nginx kubernetes configuration.

Usage:
  sudo csdeploy.sh [-l] [-m <execution_mode>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List current status.
  -m  <execution_mode>  - Valid modes are:

      [pull-charts]     - Pull charts to './charts/' directory.
      [install]         - Create namespace, PV's and install charts.
      [update]          - Redeploy or upgrade charts.
      [uninstall]       - Uninstall charts, remove PV's and namespace.
      [remove]          - Remove PV's namespace and all its contents.

Options and arguments:  
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Pull charts to './charts/' directory
    ./csdeploy.sh -m pull-charts

  # Create namespace, PV's and install charts
    ./csdeploy.sh -m install

  # Redeploy or upgrade charts
    ./csdeploy.sh -m update

  # Uninstall charts, remove PV's and namespace
    ./csdeploy.sh -m uninstall

  # Remove PV's namespace and all its contents
    ./csdeploy.sh -m remove

  # Display namespace, persistence and charts status:
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
|                                  | Display namespace          | Display namespace and object status.                                        |
|                                  | Display charts             | Charts releases history information.                                        |
|                                  |                            |                                                                             |

### Template values

The following table lists template configuration parameters and their specified values, when machine configuration files were created from the template:

| Parameter                     | Description              | Values                               |
| ----------------------------- | ------------------------ | ------------------------------------ |
| `_tplname`                    | template name            | `k8s-ingress-nginx`                    |
| `_tpldescription`             | template description     | `Ingress nginx controller for Kubernetes.`             |
| `_tplversion`                 | template version         | `22-12-19`                 |
| `kubeconfig`                  | kubeconfig file          | `config-k8s-pro`                  |
| `namespace.name`              | namespace name           | `ingress-nginx`              |
| `ingressnginx.loadbalancerip` | load-balancer IP Address | `192.168.83.20` |

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
