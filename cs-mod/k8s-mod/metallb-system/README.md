# MetalLB Load-balancer for kubernetes<!-- omit in toc -->

## v22-03-23 <!-- omit in toc -->

## MetalLB manifest version v0.12.1 <!-- omit in toc -->

[MetalLB](https://metallb.universe.tf/) is a load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols.


> **Note**: [MetalLB](https://metallb.universe.tf/) is a cluster service, and as such can only be deployed as a cluster singleton. Running multiple installations of [MetalLB](https://metallb.universe.tf/) in a single cluster is not supported.

Configuration files are deployed from template MetalLB load-balancer for bare metal Kubernetes clusters version 22-03-23.

- [TL;DR](#tldr)
- [Prerequisites](#prerequisites)
- [How-to guides](#how-to-guides)
  - [Configure IP Addresses pools](#configure-ip-addresses-pools)
  - [Install](#install)
  - [Update](#update)
  - [Remove](#remove)
  - [Display status](#display-status)
- [Reference](#reference)
  - [Scripts](#scripts)
    - [csdeploy](#csdeploy)
  - [Template values](#template-values)
- [License](#license)

## TL;DR

- Before deploying, review or modify IP address pools values in file `config.yaml`
- To deploy namespace and chart:

```bash
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
- MetalLB IP Addresses pools configured in file `config.yaml`

## How-to guides

### Configure IP Addresses pools

MetalLB configures static and dynamic addresses pools. Initial addresses pools values are provided by the template. You must review or modify these values before installing.

- To modify IP Addresses pools edit file `config.yaml` and configure addresses for static and dynamic pools.

- After configuring the desired IP Addresses pools, you can install or update the service.

### Install

To Create namespace and apply manifest:

```bash
    ./csdeploy.sh -m install
```

### Update

To update IP Addresses pools, change values in file `config.yaml`.

Update namespace deployment by running:

```bash
    ./csdeploy.sh -m update
```

>**Note**: Update deploy mode will only update IP addresses & configuration values in `config.yaml`. MetalLB manifest is only applied in install deploy mode.

### Remove

To remove namespace and all its contents run:

```bash
    ./csdeploy.sh -m remove
```

### Display status

To display namespace status run:

```bash
  # Display namespace config-map and chart status:
    ./csdeploy.sh -l
```

## Reference

To learn more see:

- <https://metallb.universe.tf>

### Scripts

#### csdeploy

```console
  MetalLB v0.12.1 configuration.
  Use this script to deploy and configure metallb-system namespace.

Usage:
  sudo csdeploy.sh [-l] [-m <execution_mode>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List current status.
  -m  <execution_mode>  - Valid modes are:

      [install]         - Install metallb-system namespace and manifests.
      [remove]          - Remove manifests and metallb-system namespace.
      [update]          - Update config-map with address pools and options.

Options and arguments:  
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Install namespace and mainfests:
    ./csdeploy.sh -m install

  # Update config-map with address pools and options in file config.yaml:
    ./csdeploy.sh -m update

  # Remove manifests and metallb-system namespace
    ./csdeploy.sh -m remove

  # Display namespace status:
    ./csdeploy.sh -l
```

**Tasks performed:**

| ${execution_mode}                | Tasks              | Block / Description                                            |
| -------------------------------- | ------------------ | -------------------------------------------------------------- |
| [install]                        |                    | **Install MetalLB**                                            |
|                                  | Create namespace   | Namespace must be unique in cluster and named `metallb-system` |
|                                  | Apply manifest     | Apply `metallb.yaml` manifest                                  |
| [update] [install]               |                    | **Update config-map**                                           |
|                                  | Apply config-map   | Apply address pool configuration in file `config.yaml`         |
| [remove]                         |                    | **Remove namespace**                                           |
|                                  | Remove namespace   | Remove namespace and all its objects.                          |
| [install] [update] [list-status] |                    | **Display status information**                                 |
|                                  | Display namespace  | Namespace and object status.                                   |
|                                  | Display config-map | Status of addresses pools.                                     |
|                                  | Display charts     | Charts releases history information.                           |
|                                  |                    |                                                                |

### Template values

The following table lists template configuration parameters and their specified values, when machine configuration files were created from the template:

| Parameter                 | Description               | Values                                                   |
| ------------------------- | ------------------------- | -------------------------------------------------------- |
| `_tplname`                | template name             | `k8s-metallb-system`                                        |
| `_tpldescription`         | template description      | `MetalLB load-balancer for bare metal Kubernetes clusters`                                 |
| `_tplversion`             | template version          | `22-03-23`                                     |
| `kubeconfig`              | kubeconfig file           | `config-k8s-mod`                                      |
| `namespace.name`          | namespace name            | `metallb-system`                                  |
| `metallb.staticpooladdr`  | static pool IP addresses  | `192.168.82.20/32, `  |
| `metallb.dynamicpooladdr` | dynamic pool IP addresses | `192.168.82.75-192.168.82.90, ` |

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
