# ubt2404srv-kvm

This machine runs a KVM host on Ubuntu Server 24.04 LTS.

Virtual machines are created on storage supported by LVM services.

## Generate configuration files with cskygen

To generate configuration files with **cskygen**:

**Set ENV variables**:

- `RB_REPO_DIR`: Your repository root directory
- `RB_ZONE`: Your deployment zone (e.g., "cs-mod", "cs-pro")
- `RB_TEMPLATE`: Template directory

Update env variables with your own values, copy and run the following command:

```bash
echo \
&& export RB_REPO_DIR="Your_Repository_Root_Directory" \
&& export RB_ZONE="cs-mod" \
&& export RB_MACHINE_NAME="ubt2404srv-kvm" \
&& export RB_TEMPLATE="${RB_REPO_DIR}/tpl-cskylab/ubt2404srv-kvm" \
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

## Machine related configuration values
machine:
  hostname: ubt2404srv-kvm
  domainname: cskylab.net
  localadminusername: kos
  localadminpassword: "NoFear21"
  timezone: "UTC"
  # networkinterface: enp1s0
  ipaddress: 192.168.80.9
  netmask: 24
  gateway4: 192.168.80.1
  searchdomainnames:
    - cskylab.net
  nameservers:
    - 192.168.80.1
  ## Setup directory where configuration files will be injected
  setupdir: "/etc/csky-setup"
  systemlocale: "C.UTF-8"
  systemkeyboard: "us"
  
restic:
  ## Restic password is mandatory to access repository
  password: 'NoFear21'

  ## Restic repositories can be located in local paths, sftp paths and s3 buckets
  ## Local path example:
  # repo: '/srv/restic/mydir'
  ## S3 example:
  # repo: 's3:https://backup.cskylab.net/restic/mydir'
  ## sftp example:
  repo: 'sftp:kos@hostname.cskylab.net:/media/data/restic/mydir'
  
  ## S3 Bucket access and secret keys must be specified for S3 located repositories
  aws_access: 'restic_rw'
  aws_secret: 'iZ6Qpx1WiqmXXoXKxBxhiCMKWCsYOrgZKr'

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
          -d ${RB_REPO_DIR}/${RB_ZONE}/${RB_MACHINE_NAME} \
          -f cskygen_tpl_overrides \
&& echo \
&& [[ -f /tmp/cskygen_tpl_overrides.yaml ]] && rm /tmp/cskygen_tpl_overrides.yaml \
; cd ${RB_REPO_DIR}/${RB_ZONE}/${RB_MACHINE_NAME} \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```
