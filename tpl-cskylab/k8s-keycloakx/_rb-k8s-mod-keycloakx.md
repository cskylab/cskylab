# k8s-mod-keycloakx

[Keycloak](https://www.keycloak.org) is a high performance Java-based identity and access management solution. It lets developers add an authentication layer to their applications with minimum effort.

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
&& export RB_K8S_NAMESPACE="keycloakx" \
&& export RB_TEMPLATE="${RB_REPO_DIR}/tpl-cskylab/k8s-keycloakx" \
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
  name: keycloakx
  ## Service domain name
  domain: cskylab.net

publishing:
  ## External url
  url: keycloakx.mod.cskylab.net
  ## Password for administrative user
  password: 'NoFear21'

certificate:
  ## Cert-manager clusterissuer
  clusterissuer: ca-test-internal

registry:
  ## Proxy Repository for Docker
  proxy: harbor.cskylab.net/dockerhub
  ## Private Repository for private images uploading
  private: harbor.cskylab.net/cskylab
  username: admin
  password: 'NoFear21'

restic:
  ## Restic password is mandatory to access repository
  password: 'NoFear21'

  ## Restic repositories can be located in local paths, sftp paths and s3 buckets
  ## Local path example:
  # repo: '/srv/restic/keycloakx'
  ## S3 example:
  # repo: 's3:https://backup.cskylab.net/restic/keycloakx'
  ## sftp example:
  repo: 'sftp:kos@kvm-main.cskylab.net:/media/data/restic/keycloakx'
  
  ## S3 Bucket access and secret keys must be specified for S3 located repositories
  aws_access: 'restic_rw'
  aws_secret: 'iZ6Qpx1WiqmXXoXKxBxhiCMKWCsYOrgZKr'

## Local storage PV's node affinity (Configured in pv*.yaml)
localpvnodes:    # (k8s node names)
  all_pv: k8s-mod-n1
localrsyncnodes: # (k8s node names)
  all_pv: k8s-mod-n2

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
