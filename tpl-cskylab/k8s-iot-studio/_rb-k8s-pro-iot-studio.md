# k8s-pro-iot-studio

This namespace is intended to deploy an IOT service environment in Kubernetes.

## Generate configuration files with cskygen

To generate configuration files with **cskygen**:

**Set ENV variables**:

- `RB_REPO_DIR`: Your repository root directory
- `RB_ZONE`: Your deployment zone (e.g., "cs-mod", "cs-pro")
- `RB_K8S_CLUSTER`: Kubernetes cluster (e.g., "k8s-mod", "k8s-pro")
- `RB_K8S_NAMESPACE`: Kubernetes namespace
- `RB_TEMPLATE`: Template directory

Update env variables with your own values, copy and run the following command:

```bash
echo \
&& export RB_REPO_DIR="Your_Repository_Root_Directory" \
&& export RB_ZONE="cs-pro" \
&& export RB_K8S_CLUSTER="k8s-pro" \
&& export RB_K8S_NAMESPACE="iot-studio" \
&& export RB_TEMPLATE="${RB_REPO_DIR}/tpl-cskylab/k8s-iot-studio" \
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
  name: iot-studio
  ## Service domain name
  domain: cskylab.net

certificate:
  ## Cert-manager clusterissuer
  clusterissuer: ca-test-internal

registry:
  ## Proxy Repository for Docker
  proxy: harbor.cskylab.net/dockerhub

mosquitto:
  ## LoadBanancer IP static address
  ## Must be previously configured in MetalLB
  loadbalancerip: 192.168.83.21
  ## External url
  url: mosquitto-iot-studio.pro.cskylab.net
  ## Credentials
  user: "admin"
  password: "5kiJuI5OUcRKPBH3KLSEQbqjAtdWhvBRM1GGALrw4Gy9iLRNHZv6BlaX3pNA8kQY"

nodered:
  ## Container timezone
  timezone: "UTC"
  ## External url
  url: node-red-iot-studio.pro.cskylab.net
  ## Credentials
  user: "admin"
  password: "5kiJuI5OUcRKPBH3KLSEQbqjAtdWhvBRM1GGALrw4Gy9iLRNHZv6BlaX3pNA8kQY"

influxdb:
  # influxdb organization name
  organization: "cskylab"
  # influxdb bucket
  bucket: "iot-studio"
  # influxdb ui
  url: influxdb-iot-studio.pro.cskylab.net
  ## Credentials
  user: "admin"
  password: "5kiJuI5OUcRKPBH3KLSEQbqjAtdWhvBRM1GGALrw4Gy9iLRNHZv6BlaX3pNA8kQY"

grafana:
  # grafana ui access
  url: grafana-iot-studio.pro.cskylab.net
  ## Credentials
  user: "admin"
  password: "5kiJuI5OUcRKPBH3KLSEQbqjAtdWhvBRM1GGALrw4Gy9iLRNHZv6BlaX3pNA8kQY"

publishing:
  ## External url
  url: iot-studio.pro.cskylab.net

oauthconfig:
  ## Client secret from keycloak
  client_secret: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  ## cookie secret (random)
  cookie_secret: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

## Local storage PV's node affinity (Configured in pv*.yaml)
datadirectoryname: iot-studio
localpvnodes:    # (k8s node names)
  all_pv: k8s-pro-n1
  # k8s nodes domain name
  domain: cskylab.net
  # k8s nodes local administrator
  localadminusername: kos
localrsyncnodes: # (k8s node names)
  all_pv: k8s-pro-n2
  # k8s nodes domain name
  domain: cskylab.net
  # k8s nodes local administrator
  localadminusername: kos

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
          -d ${RB_REPO_DIR}/${RB_ZONE}/${RB_K8S_CLUSTER}/${RB_K8S_NAMESPACE} \
          -f cskygen_tpl_overrides \
&& echo \
&& [[ -f /tmp/cskygen_tpl_overrides.yaml ]] && rm /tmp/cskygen_tpl_overrides.yaml \
; cd ${RB_REPO_DIR}/${RB_ZONE}/${RB_K8S_CLUSTER}/${RB_K8S_NAMESPACE} \
&& direnv allow \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```
