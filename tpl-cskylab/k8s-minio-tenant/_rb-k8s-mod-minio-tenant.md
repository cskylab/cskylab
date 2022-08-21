# k8s-mod-minio-tenant

[MinIO](https://min.io/) is a Kubernetes-native high performance object store with an S3-compatible API. The [MinIO Kubernetes Operator](https://github.com/minio/operator) supports deploying MinIO Tenants onto private and public cloud infrastructures ("Hybrid" Cloud). This service creates a X-node MinIO Tenant using MinIO for object storage.

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
&& export RB_K8S_NAMESPACE="minio-tenant" \
&& export RB_TEMPLATE="${RB_REPO_DIR}/tpl-cskylab/k8s-minio-tenant" \
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
  name: minio-tenant

publishing:
  ## External api url used by mc
  miniourl: minio-tenant.mod.cskylab.net
  ## External api url used by console
  consoleurl: minio-tenant-console.mod.cskylab.net

credentials:
  # MinIO root user credentials
  minio_accesskey: "admin"
  minio_secretkey: "NoFear21"

certificate:
  ## Cert-manager clusterissuer
  clusterissuer: ca-test-internal

registry:
  ## Proxy Repository for Docker
  proxy: harbor.cskylab.net/dockerhub

localpvnodes:    # (k8s node names)
  srv00: k8s-mod-n1
  srv01: k8s-mod-n2
  srv02: k8s-mod-n3
  srv03: k8s-mod-n4
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
