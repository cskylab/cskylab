# Kubernetes Hello World app<!-- omit in toc -->

## `k8s-hello` v23-04-27 <!-- omit in toc -->

This namespace is intended to deploy a simple Hello World application in Kubernetes for testing purposes.

Configuration files are deployed from template Kubernetes hello world app version 23-04-27.

- [TL;DR](#tldr)
- [Prerequisites](#prerequisites)
- [How-to guides](#how-to-guides)
  - [Install](#install)
  - [Update](#update)
  - [Uninstall](#uninstall)
  - [Remove](#remove)
  - [Display status](#display-status)
  - [Update Welcome Message](#update-welcome-message)
- [Reference](#reference)
  - [Application modules](#application-modules)
  - [Scripts](#scripts)
    - [cs-deploy](#cs-deploy)
  - [Template values](#template-values)
- [License](#license)

---

## TL;DR

```bash
# Install  
./csdeploy.sh -m install
# Check status
./csdeploy.sh -l
```

Run:

- Published at: `hello.pro.cskylab.net`

## Prerequisites

- Administrative access to Kubernetes cluster.
- Helm v3.

## How-to guides

### Install

To Create namespace:

```bash
  #  Create namespace, secrets, config-maps, PV's, apply manifests and install charts.
    ./csdeploy.sh -m install
```

### Update

Reapply module manifests by running:

```bash
  # Reapply manifests
    ./csdeploy.sh -m update
```

### Uninstall

To delete module manifests and namespace run:

```bash
  # Delete manifests, and namespace
    ./csdeploy.sh -m uninstall
```

### Remove

This option is intended to be used only to remove the namespace when uninstall is failed. Otherwise, you must run `./csdeploy.sh -m uninstall`.

To remove namespace and all its contents run:

```bash
  # Remove namespace and all its contents
    ./csdeploy.sh -m remove
```

### Display status

To display namespace status run:

```bash
  # Display namespace, status:
    ./csdeploy.sh -l
```

### Update Welcome Message

You can change the welcome message by editing and changing the manifest file `mod-hello-kubernetes.yaml`.

## Reference

### Application modules

| Module                      | Description                |
| --------------------------- | -------------------------- |
| `mod-hello-kubernetes.yaml` | hello-kubernetes manifests |

### Scripts

#### cs-deploy

```console
Purpose:
  Kubernetes Hello World app.

Usage:
  sudo csdeploy.sh [-l] [-m <execution_mode>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List current status.
  -m  <execution_mode>  - Valid modes are:

      [pull-charts]     - Pull charts to './charts/' directory.
      [install]         - Create namespace, secrets, config-maps, PV's,
                          apply manifests and install charts.
      [update]          - Reapply manifests and update or upgrade charts.
      [uninstall]       - Uninstall charts, delete manifests, remove PV's and namespace.
      [remove]          - Remove PV's, namespace and all its contents.

Options and arguments:  
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Pull charts to './charts/' directory
    ./csdeploy.sh -m pull-charts

  # Create namespace, secrets, config-maps, PV's, apply manifests and install charts.
    ./csdeploy.sh -m install

  # Reapply manifests and update or upgrade charts.
    ./csdeploy.sh -m update

  # Uninstall charts, delete manifests, remove PV's and namespace.
    ./csdeploy.sh -m uninstall

  # Remove PV's, namespace and all its contents
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
| [install]                        |                            | **Create namespace, config-maps, secrets and PV's**                         |
|                                  | Create namespace           | Namespace must be unique in cluster.                                        |
|                                  | Create secrets             | Create secrets containing usernames, passwords... etc.                      |
|                                  | Create PV's                | Apply all persistent volume manifests in the form `pv-*.yaml`.              |
| [update] [install]               |                            | **Deploy app mod's and charts**                                             |
|                                  | Apply manifests            | Apply all app module manifests in the form `mod-*.yaml`.                    |
|                                  | Deploy charts              | Deploy all charts in `./charts` directory with `upgrade --install` options. |
| [uninstall]                      |                            | **Uninstall charts and app mod's**                                          |
|                                  | Delete manifests           | Delete all app module manifests in the form `mod-*.yaml`.                   |
|                                  | Uninstall charts           | Uninstall all charts in `./charts` directory.                               |
| [uninstall] [remove]             |                            | **Remove namespace and PV's**                                               |
|                                  | Remove namespace           | Remove namespace and all its objects.                                       |
|                                  | Delete PV's                | Delete all persistent volume manifests in the form `pv-*.yaml`.             |
| [install] [update] [list-status] |                            | **Display status information**                                              |
|                                  | Display namespace          | Namespace and object status.                                                |
|                                  | Display certificates       | Certificate status information.                                             |
|                                  | Display secrets            | Secret status information.                                                  |
|                                  | Display persistence        | Persistence status information.                                             |
|                                  | Display charts             | Charts releases history information.                                        |
|                                  |                            |                                                                             |

### Template values

The following table lists template configuration parameters and their specified values, when machine configuration files were created from the template:

| Parameter                   | Description                                      | Values                             |
| --------------------------- | ------------------------------------------------ | ---------------------------------- |
| `_tplname`                  | template name                                    | `k8s-hello`                  |
| `_tpldescription`           | template description                             | `Kubernetes hello world app`           |
| `_tplversion`               | template version                                 | `23-04-27`               |
| `kubeconfig`                | kubeconfig file                                  | `/Users/grenes/.kube//Users/grenes/.kube//Users/grenes/.kube/config-k8s-mod`                |
| `namespace.name`            | namespace name                                   | `hello-pro`            |
| `namespace.domain`          | domain name                                      | `cskylab.net`          |
| `publishing.url`            | external URL                                     | `hello.pro.cskylab.net`            |
| `certificate.clusterissuer` | cert-manager clusterissuer                       | `ca-test-internal` |
| `registry.proxy`            | docker private proxy URL                         | `harbor.cskylab.net/dockerhub`            |

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
