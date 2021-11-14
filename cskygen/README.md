# cskygen - cSkyLab Configuration Genesis <!-- omit in toc -->

## v1.0.1 <!-- omit in toc -->

`cskygen` is a CLI application that generates configuration files from pre-configured templates.

It is widely used in cSkyLab project to create configuration files for machines, services and applications.

cskygen is developed to be used with templates using [Go templates](https://godoc.org/text/template) specifications.

It is compatible and integrates the use of [Helm Charts](https://helm.sh/) in kubernetes services deployment.

- [Background](#background)
  - [Template Libraries](#template-libraries)
    - [Template name conventions](#template-name-conventions)
    - [Template development](#template-development)
- [How-to guides](#how-to-guides)
  - [Build & install cskygen](#build--install-cskygen)
    - [Build binary file](#build-binary-file)
  - [Create configuration files for a new deployment](#create-configuration-files-for-a-new-deployment)
    - [Prepare the overriding file](#prepare-the-overriding-file)
    - [Create your service configuration directory from the template](#create-your-service-configuration-directory-from-the-template)
- [License](#license)

---

## Background

At cSkyLab project, machine services and applications are based on pre-configured templates files (models of applications and services).

When creating a new deployment, cskygen uses a configuration process based on 2 layers that are applied with the following order:

1. Pre-configured Template default values file: `_values-tpl.yaml`. It contains default customizable values. It must exist with that name inside the template directory.

2. Overriding file : `service_name.yaml` contains overriding values that define the service according to the customizations you made.

Values from the `service_name.yaml` file take precedence over the  `_values-tpl.yaml`.

cskygen uses [Viper](https://github.com/spf13/viper) to read and merge `.yaml` configuration files.

![ ](./images/cskygen.png)

> **NOTE**: To avoid parsing images and [Helm Charts](https://helm.sh/), files below directories named `images` or `charts` will not be considered by cskygen.

### Template Libraries

Template libraries directories (Ex.: `tpl-cskylab`) contains templates for generating configuration files for machines, applications and services using the `cskygen` utility.

You can create your own library forking another or creating new templates.

Your library directory should be created at the same level and by named following the convention:

***tpl-yourlibraryname***

Example:

- **tpl-cskylab**: cSkyLab templates library

#### Template name conventions

Template directories should be named according to the following convention:

`env-app`

- ***-env-***: Running environment prefix.
- ***-app-***: Application or service.

Examples:

- **ubt2004srv-naked**
  - `ubt2004srv`: Ubuntu Server 20.04
  - `naked`: Operating system basic installation
- **ubt2004srv-kvm**
  - `ubt2004srv`: Ubuntu Server 20.04
  - `kvm`: KVM Host installation
- **k8s-metallb**
  - `k8s`: Kubernetes
  - `metallb`: Metallb bare metal load-balancer
- **k8s-harbor**
  - `k8s`: Kubernetes
  - `harbor`: Harbor registry

#### Template development

Template resource files must be developed according to [Go templates](https://godoc.org/text/template) specifications.

> **NOTE**: All keys in override and template values files must be in lowercase. Files cannot have empty keys configured.

## How-to guides

### Build & install cskygen

**Prerequisites**:

- cSkyLab git repository cloned
- Go language installed

#### Build binary file

`cskygen` uses go modules `go.mod` and can be installed directly from the git repository.

To build and install cskygen binary file in $GOPATH/bin, open a terminal in the `cskygen` directory, and execute:

``` console
go install .
```

### Create configuration files for a new deployment

#### Prepare the overriding file

- In `tpl_overriding-files` directory create your overriding file (Ex.: `service_name.yaml`) copying contents from `_overriding-model.yaml` file.

It is highly recommended to name the overriding file, according to the service and destination directory names (Ex. `k8s-mod-n1.yaml`, `k8s-mod-metallb.yaml`...).

- Go to the directory of the template you want to use, and open the values file `_values-tpl`
- Copy the `values to override` section from the file `_values-tpl` into the same section in your overriding file.
- Change the desired values for your installation.
- Modify the code commented command `cskygen create` with the appropriate flags:

  | flag |                                                                       |
  | ---- | --------------------------------------------------------------------- |
  | `-d` | Destination service directory (Must not exist)                        |
  | `-t` | Template directory                                                    |
  | `-f` | Overrides file (.yaml extension required on filename but not in flag) |

- Save the file

**Example:**

Overrides file to create metallb-system service in k8s-mod cluster:

```yaml
#
#   cskygen configuration values file
#
#   Copyright © 2021 cSkyLab.com
#

# 
#   Command:
#
#   cskygen create -t ../tpl/k8s-metallb-system -d ../cs-mod/k8s-mod/metallb-system -f k8s-mod-metallb-system
#

#
# Values to override
#

## k8s cluster credentials kubeconfig file
kubeconfig: config-k8s-mod

namespace:
  ## k8s namespace name
  name: metallb-system

## MetalLB static and dynamc ip addresses pools
metallb:
  staticpooladdr: 
    - 192.168.82.20/32  # k8s-ingress
  dynamicpooladdr: 
    - 192.168.82.75-192.168.82.90   # Auto assigned
  ```

#### Create your service configuration directory from the template

- Open a terminal in `tpl_overriding-files` directory
- Copy and execute the code commented `cskygen create` command in the overriding file
- Check the created configuration directory.

If you need to repeat the process with different overriding values, simply delete the configuration directory, change the overriding values, and execute again the `cskygen create` command to generate the new configuration directory.

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
