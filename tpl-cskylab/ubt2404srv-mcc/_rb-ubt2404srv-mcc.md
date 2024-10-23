# ubt2404srv-mcc

This machine runs a management host (Mission Control Center) on Ubuntu Server 24.04 LTS.

It is intended to host VS Code Remote Server and to be accessed with VS Code Remote via ssh.

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
&& export RB_ZONE="cs-sys" \
&& export RB_MACHINE_NAME="mcc" \
&& export RB_TEMPLATE="${RB_REPO_DIR}/tpl-cskylab/ubt2404srv-mcc" \
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

## Kubernetes version for kubectl
k8s_version: "1.29.3-1.1"

## Go version
go_version: "go1.22.2.linux-amd64.tar.gz"

## Machine related configuration values
machine:
  hostname: mcc
  domainname: cskylab.net
  localadminusername: kos
  localadminpassword: "NoFear21"
  timezone: "UTC"
  networkinterface: enp1s0
  ipaddress: 192.168.82.9
  netmask: 24
  gateway4: 192.168.82.1
  searchdomainnames:
    - cskylab.net
  nameservers:
    - 192.168.82.1
  ## Setup directory where configuration files will be injected
  setupdir: "/etc/csky-setup"
  systemlocale: "C.UTF-8"
  systemkeyboard: "us"

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
