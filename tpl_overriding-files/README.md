# tpl-overriding files

This folder contains the values overriding files used to create configuration directories for your applications and services from template libraries.

## Prepare the overriding file

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
#   cskygen create -t ../tpl-cskylab/k8s-metallb-system -d ../cs-mod/k8s-mod/metallb-system -f k8s-mod-metallb-system
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

## Create your service configuration directory from the template

- Open a terminal in `tpl_overriding-files` directory
- Copy and execute the code commented `cskygen create` command in the overriding file
- Check the created configuration directory.

If you need to repeat the process with different overriding values, simply delete the configuration directory, change the overriding values, and execute again the `cskygen create` command to generate the new configuration directory.
