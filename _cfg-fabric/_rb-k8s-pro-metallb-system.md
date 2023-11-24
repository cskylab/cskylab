# k8s-pro-metallb-system

[MetalLB](https://metallb.universe.tf/) is a load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols.

> **Note**: Namespace `metallb-system` should be considered as cluster service. It is mandatory to deploy it with this name as a cluster singleton.

## Generate configuration files with cskygen

To generate configuration files with **cskygen**:

**Set ENV variables**:

- `RB_REPO_DIR`: Your repository root directory
- `RB_ZONE`: Your deployment zone (e.g., "cs-mod", "cs-pro")
- `RB_K8S_CLUSTER`: Kubernetes cluster (e.g., "k8s-mod", "k8s-pro")
- `RB_TEMPLATE`: Template directory

Update env variables with your own values, copy and run the following command:

```bash
echo \
&& export RB_REPO_DIR="/Users/grenes/git/cskylab-github" \
&& export RB_ZONE="cs-pro" \
&& export RB_K8S_CLUSTER="k8s-pro" \
&& export RB_TEMPLATE="${RB_REPO_DIR}/tpl-cskylab/k8s-metallb-system" \
&& echo
```

**Set override values**:

Update `Values to override` section with your own values, copy and run the following command:

```yaml
echo \
&& [[ -f /tmp/cskygen_tpl_overrides.yaml ]] && rm /tmp/cskygen_tpl_overrides.yaml \
; export CSKYGEN_TPL_OVERRIDES="$(cat <<EOF

#
# Values to override
#

## k8s cluster credentials kubeconfig file
kubeconfig: config-k8s-pro

namespace:
  ## k8s namespace name
  name: metallb-system

## MetalLB static and dynamc ip addresses pools
metallb:
  staticpooladdr: 
    - 192.168.83.20/32  # k8s-ingress
    - 192.168.83.21/32  # mosquitto iot-studio
    - 192.168.83.22/32  # mosquitto iot-edge
  dynamicpooladdr: 
    - 192.168.83.75-192.168.83.90   # Auto assigned
   
EOF
)" \
&& echo "${CSKYGEN_TPL_OVERRIDES}" >/tmp/cskygen_tpl_overrides.yaml \
&& echo
```

**Run Snippet**:

After setting ENV variables, copy and run the following snippet:

```bash
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& echo "******** Environment variables declared:" \
&& echo \
&& printenv | grep -e "RB_*" \
&& echo \
&& read -r -s -p $'Press Enter to continue or Ctrl+C to abort...' \
&& echo \
&& echo \
&& cd /tmp \
&& cskygen create -q \
          -t ${RB_TEMPLATE} \
          -d ${RB_REPO_DIR}/${RB_ZONE}/${RB_K8S_CLUSTER}/metallb-system \
          -f cskygen_tpl_overrides \
&& echo \
&& [[ -f /tmp/cskygen_tpl_overrides.yaml ]] && rm /tmp/cskygen_tpl_overrides.yaml \
; cd ${RB_REPO_DIR}/${RB_ZONE}/${RB_K8S_CLUSTER}/metallb-system \
&& direnv allow \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```
