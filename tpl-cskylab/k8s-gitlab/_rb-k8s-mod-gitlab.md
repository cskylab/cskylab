# k8s-mod-gitlab

[Gitlab](https://about.gitlab.com/what-is-gitlab/) is the open DevOps platform, delivered as a single application. GitLab is a web-based DevOps lifecycle tool that provides a Git repository manager providing wiki, issue-tracking and continuous integration and deployment pipeline features, using an open-source license, developed by GitLab Inc.

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
&& export RB_ZONE="cs-mod" \
&& export RB_K8S_CLUSTER="k8s-mod" \
&& export RB_K8S_NAMESPACE="gitlab" \
&& export RB_TEMPLATE="${RB_REPO_DIR}/tpl-cskylab/k8s-gitlab" \
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
kubeconfig: config-k8s-mod

namespace:
  ## k8s namespace name
  name: gitlab
  ## Service domain name
  domain: cskylab.net

publishing:
  ## External url
  url: gitlab.mod.cskylab.net
  ## Password for administrative user
  password: "NoFear21"

certificate:
  ## Cert-manager clusterissuer
  clusterissuer: ca-test-internal

## Keycloak issuer and secret must be previously configured in Keycloak
keycloak:
  issuer: "https://keycloak.cskylab.net/auth/realms/cskylab"
  secret: "5edffd1e-c3ab-47d3-a32e-b38a4977d6d3"

registry:
  ## Proxy Repository for Docker
  proxy: harbor.cskylab.net/dockerhub

## Local storage PV's node affinity (Configured in pv*.yaml)
localpvnodes:    # (k8s node names)
  all_pv: k8s-mod-n1
  # k8s nodes domain name
  domain: cskylab.net
  # k8s nodes local administrator
  localadminusername: kos
localrsyncnodes: # (k8s node names)
  all_pv: k8s-mod-n2
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