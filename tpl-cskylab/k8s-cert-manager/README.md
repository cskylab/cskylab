# x509 Certificate management for Kubernetes <!-- omit in toc -->

## v22-12-19 <!-- omit in toc -->

## Helm charts: jetstack/cert-manager v1.10.1 <!-- omit in toc -->

[cert-manager](https://cert-manager.io/docs/) is a native Kubernetes certificate management controller. It can help with issuing certificates from a variety of sources, such as Let’s Encrypt, HashiCorp Vault, Venafi, a simple signing key pair, or self signed.

> **Warning**: You should not install multiple instances of cert-manager on a single cluster. This will lead to undefined behavior and you may be banned from providers such as Let’s Encrypt.

Configuration files are deployed from template {{ ._tpldescription }} version {{ ._tplversion }}.

- [TL;DR](#tldr)
- [Prerequisites](#prerequisites)
- [How-to guides](#how-to-guides)
  - [Prepare clusterissuers manifests](#prepare-clusterissuers-manifests)
    - [Let's Encrypt clusterissuers](#lets-encrypt-clusterissuers)
    - [Private CA clusterissuers](#private-ca-clusterissuers)
  - [Pull Charts](#pull-charts)
  - [Install](#install)
  - [Apply clusterissuers](#apply-clusterissuers)
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

---

## TL;DR

- To deploy namespace and chart:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Install  
./csdeploy.sh -m install

# Check status
./csdeploy.sh -l
```

- To deploy clusterissuers after install is completed:

```bash
# Apply clusterissuers (after install is completed)
./csdeploy.sh -m apply-cliss
```

## Prerequisites

- Administrative access to Kubernetes cluster.
- Helm v3

## How-to guides

### Prepare clusterissuers manifests

Clusterissuers manifest are applied by `cs-deploy.sh` script. All manifests files must follow the format name `./clusterissuer-*.yaml`.

#### Let's Encrypt clusterissuers

Let's Encrypt clusterissuers are provided in two files:

- **Staging**: `clusterissuer-letsencrypt-staging.yaml`
- **Production**: `clusterissuer-letsencrypt.yaml`

Review values and modify `email` if needed in both files.

#### Private CA clusterissuers

Private CA's clusterissuers manifests must include a TLS Secret manifest with public and private keys. Be sure to keep the private key safe and secret. Note that, like all secrets, data must be base64 encoded.

You can obtain the base64 values `tls.crt` and `tls.key` from the private and public CA keys with the command:

```bash
# Base64 encoding with single line format
# Public key
base64 -i ca-test-internal.crt -o ca-test-internal.crt.b64
# Private key
base64 -i ca-test-internal.key -o ca-test-internal.key.b64
```

To prepare a private `./clusterissuer-*.yaml` file, you can use the following example:

```yaml
# clusterissuer-ca-test-internal.yaml
apiVersion: v1
kind: Secret
metadata:
  name: ca-test-internal
  namespace: cert-manager
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSU.... # Copy value from ca-test-internal.crt.b64
  tls.key: LS0tLS1CRUdJTiBSU0EgUF.... # Copy value from ca-test-internal.key.b64

---

apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-test-internal
  namespace: cert-manager
spec:
  ca:
    secretName: ca-test-internal
```

>**NOTE**: You must prepare your own Private CA Keys.

### Pull Charts

To pull charts, change the repositories and charts needed in variable `source_charts` inside the script `csdeploy.sh`  and run:

```bash
# Pull charts to './charts/' directory
  ./csdeploy.sh -m pull-charts
```

When pulling new charts, all the content of `./charts` directory will be removed, and replaced by the new pulled charts.

After pulling new charts redeploy the new versions with: `./csdeploy -m update`.

### Install

To create namespace and install chart:

```bash
  # Create namespace and install chart
    ./csdeploy.sh -m install
```

`CustomResourceDefinition` resources are installed with the helm chart. You must uninstall the chart release with `./csdeploy.sh -m uninstall` to appropriately remove these resources.

### Apply clusterissuers

Chart installation process must be completed to apply clusterissuers. First time installation requires a while to create the neccesary resources.

To apply clusterissuers:

```bash
  # Apply clusterissuers (after install is completed)
    ./csdeploy.sh -m apply-cliss
```

### Update

To update chart settings, change values in the file `values-cert-manager.yaml`.

Redeploy or upgrade the chart and apply clusterissuers manifests running:

```bash
  # Redeploy or upgrade chart and apply clusterissuers
    ./csdeploy.sh -m update
```

### Uninstall

To delete clusterissuers, uninstall chart and remove namespace run:

```bash
  # Delete clusterissuers, uninstall chart and remove namespace
    ./csdeploy.sh -m uninstall
```

This option removes `CustomResourceDefinition` resources appropriately from cluster and also removes the namespace.

### Remove

This option is intended to use only to remove the namespace when chart deployment is failed. Otherwise, you must run `./csdeploy.sh -m uninstall`.

To remove namespace and all its contents run:

```bash
  # Remove namespace and all its contents
    ./csdeploy.sh -m remove
```

### Display status

To display namespace, chart status and clusterissuers resources status run:

```bash
  # Display namespace status:
    csdeploy.sh -l
```

## Reference

To learn more see:

- <https://cert-manager.io/docs/>

### Helm charts and values

| Chart                 | Values                     |
| --------------------- | -------------------------- |
| jetstack/cert-manager | `values-cert-manager.yaml` |

### Scripts

#### csdeploy

```console
Purpose:
  cert-manager kubernetes configuration.

Usage:
  sudo csdeploy.sh [-l] [-m <execution_mode>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List current status.
  -m  <execution_mode>  - Valid modes are:

      [install]         - Create namespace and install chart.
      [apply-cliss]     - Apply clusterissuers (after install is completed).
      [update]          - Redeploy or upgrade chart and apply clusterissuers.
      [uninstall]       - Delete clusterissuers, uninstall chart and remove namespace.
      [remove]          - Remove namespace and all its contents.

Options and arguments:  
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Pull charts to './charts/' directory
    ./csdeploy.sh -m pull-charts

  # Create namespace and install chart
    ./csdeploy.sh -m install

  # Apply clusterissuers (after install is completed)
    ./csdeploy.sh -m apply-cliss

  # Redeploy or upgrade chart and apply clusterissuers
    ./csdeploy.sh -m update

  # Delete clusterissuers, uninstall chart and remove namespace
    ./csdeploy.sh -m uninstall

  # Remove namespace and all its contents
    ./csdeploy.sh -m remove

  # Display namespace and chart status:
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
| [update] [apply-cliss]           |                            | **Apply clusterissuers**                                                    |
|                                  | Apply clusterissuers       | Apply all clusterissuers manifests in the form `clusterissuers-*.yaml`.     |
| [uninstall]                      |                            | **Uninstall charts**                                                        |
|                                  | Delete clusterissuers      | Delete all clusterissuers manifests in the form `clusterissuers-*.yaml`.    |
|                                  | Uninstall charts           | Uninstall all charts in `./charts` directory.                               |
| [uninstall] [remove]             |                            | **Remove namespace**                                                        |
|                                  | Remove namespace           | Remove namespace and all its objects.                                       |
| [install] [update] [list-status] |                            | **Display status information**                                              |
|                                  | Display namespace          | Display namespace and object status.                                        |
|                                  | Display clusterissuers     | Display clusterissuers status information.                                  |
|                                  | Display charts             | Charts releases history information.                                        |
|                                  |                            |                                                                             |

### Template values

The following table lists template configuration parameters and their specified values, when machine configuration files were created from the template:

| Parameter           | Description                 | Values                     |
| ------------------- | --------------------------- | -------------------------- |
| `_tplname`          | template name               | `{{ ._tplname }}`          |
| `_tpldescription`   | template description        | `{{ ._tpldescription }}`   |
| `_tplversion`       | template version            | `{{ ._tplversion }}`       |
| `kubeconfig`        | kubeconfig file             | `{{ .kubeconfig }}`        |
| `namespace.name`    | namespace name              | `{{ .namespace.name }}`    |
| `letsencrypt.email` | Let's Encrypt contact email | `{{ .letsencrypt.email }}` |

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
