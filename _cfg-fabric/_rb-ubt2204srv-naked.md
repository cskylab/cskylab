# ubt2204srv-naked

This template contains the configuration files needed to run a basic installation of Ubuntu Server 22.04 LTS.

It is intended to create configuration files for physical or virtual machines when there is no need to use LVM storage services.

## Generate configuration files with cskygen

To generate configuration files with **cskygen**:

**Set ENV variables**:

- `RB_REPO_DIR`: Your repository root directory
- `RB_ZONE`: Your deployment zone (e.g., "cs-mod", "cs-pro")
- `RB_TEMPLATE`: Template directory

Update env variables with your own values, copy and run the following command:

```bash
echo \
&& export RB_REPO_DIR="/Users/grenes/git/cskylab-github" \
&& export RB_ZONE="cs-mod" \
&& export RB_MACHINE_NAME="ubt2204srv-naked" \
&& export RB_TEMPLATE="${RB_REPO_DIR}/tpl-cskylab/ubt2204srv-naked" \
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
  hostname: ubt2204srv-naked
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
