# MetalLB Load-balancer for kubernetes<!-- omit in toc -->

## v99-99-99 <!-- omit in toc -->

## MetalLB manifest version v0.13.12 <!-- omit in toc -->

[MetalLB](https://metallb.universe.tf/) is a load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols.


> **Note**: [MetalLB](https://metallb.universe.tf/) is a cluster service, and as such can only be deployed as a cluster singleton. Running multiple installations of [MetalLB](https://metallb.universe.tf/) in a single cluster is not supported.

Configuration files are deployed from template {{ ._tpldescription }} version {{ ._tplversion }}.

- [TL;DR](#tldr)
- [Prerequisites](#prerequisites)
- [How-to guides](#how-to-guides)
  - [Install](#install)
  - [Configure IP Addresses pools](#configure-ip-addresses-pools)
  - [Remove](#remove)
  - [Display status](#display-status)
- [Reference](#reference)
  - [Scripts](#scripts)
    - [csdeploy](#csdeploy)
- [License](#license)

## TL;DR

- Before deploying, review or modify IP address pools values in file `config.yaml`
- To deploy namespace and chart:

```bash
# Install  
./csdeploy.sh -m install

# Config IP address pools
./csdeploy.sh -m config

# Check status
./csdeploy.sh -l
```

---

## Prerequisites

- Administrative access to Kubernetes cluster.
- No instance of MetalLB running on K8s cluster.
- MetalLB IP Addresses pools configured in file `resources.yaml`

## How-to guides

### Install

To Create namespace and apply manifest:

```bash
    ./csdeploy.sh -m install
```

- After installing you must configure the desired IP Addresses pools.

>**Note**: Be sure all metallb pods are running before configuring IP pools.

### Configure IP Addresses pools

To modify IP Addresses pools edit file `resources.yaml` and configure addresses for static and dynamic pools.

Configure IP pools by running:

```bash
    ./csdeploy.sh -m config
```

>**Note**: `config` deploy mode will only update IP addresses & configuration values in `resources.yaml`. MetalLB manifest is only applied in `install` deploy mode.

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
  MetalLB v0.13.4 configuration.
  Use this script to deploy and configure metallb-system namespace.

Usage:
  sudo csdeploy.sh [-l] [-m <execution_mode>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List current status.
  -m  <execution_mode>  - Valid modes are:

      [install]         - Install metallb-system namespace and manifests.
      [remove]          - Remove manifests and metallb-system namespace.
      [config]          - Configure resources.yaml with address pools and options.

Options and arguments:  
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Install namespace and mainfests:
    ./csdeploy.sh -m install

  # Configure address pools and options in file resources.yaml:
    ./csdeploy.sh -m config

  # Remove manifests and metallb-system namespace
    ./csdeploy.sh -m remove

  # Display namespace status:
    ./csdeploy.sh -l
```

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
