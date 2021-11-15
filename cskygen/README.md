# cskygen - cSkyLab Configuration Genesis <!-- omit in toc -->

## v1.0.1 <!-- omit in toc -->

`cskygen` is a CLI application that generates configuration files from pre-configured templates.

It is widely used in cSkyLab project to create configuration files for machines, services and applications.

cskygen is developed to be used with templates using [Go templates](https://godoc.org/text/template) specifications.

It is compatible and integrates the use of [Helm Charts](https://helm.sh/) in kubernetes services deployment.

- [Background](#background)
  - [Templates Libraries](#templates-libraries)
    - [Template development](#template-development)
- [How-to guides](#how-to-guides)
  - [Build & install cskygen](#build--install-cskygen)
    - [Build binary file](#build-binary-file)
  - [Creating service and application configuration files from a template](#creating-service-and-application-configuration-files-from-a-template)
    - [1.- Prepare the overriding file](#1--prepare-the-overriding-file)
    - [2.- Execute cskygen](#2--execute-cskygen)
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

### Templates Libraries

Templates libraries contains templates to generate configuration files for machines, applications and services using the `cskygen` utility.

You can create your own library either by forking cSkyLab templates library or by creating it from scratch.

To learn more about cSkylab template library see documentation at [cSkyLab Templates Library](../tpl-cskylab/README.md)

#### Template development

Template resource files must be developed according to [Go templates](https://godoc.org/text/template) specifications.

> **NOTE**: All keys in overriding and template values files must be in lowercase. Files cannot have empty keys configured.

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

### Creating service and application configuration files from a template

To create service and application configuration files from a template you must follow two steps:

1. Prepare the overriding file
2. Execute cskygen

#### 1.- Prepare the overriding file

- In `tpl_overriding-files` directory create your overriding file (Ex.: `service_name.yaml`) copying contents from `_overriding-model.yaml` file.

It is highly recommended to name the overriding file, according to the service and destination directory names (Ex. `k8s-mod-n1.yaml`, `k8s-mod-metallb.yaml`...).

- Go to the directory of the template you want to use, and open the values file `_values-tpl.yaml`
- Copy the `values to override` section from the file `_values-tpl.yaml` into the same section in your overriding file.
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

#### 2.- Execute cskygen

- Open a terminal in `tpl_overriding-files` directory
- Copy and execute the `cskygen create` command in the overriding file
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
