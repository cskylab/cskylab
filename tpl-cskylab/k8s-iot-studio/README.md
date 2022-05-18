# Kubernetes IOT Studio<!-- omit in toc -->

## k8s-iot-studio v99-99-99 <!-- omit in toc -->

## Helm charts:<!-- omit in toc -->

- k8s-at-home/mosquitto
- k8s-at-home/node-red 
- influxdata/influxdb2 
- bitnami/grafana      

This namespace is intended to deploy an IOT service environment in Kubernetes with the following applications:

- **Mosquitto MQTT broker**: Eclipse Mosquitto is an open source (EPL/EDL licensed) message broker that implements the MQTT protocol versions 5.0, 3.1.1 and 3.1. 
- **Node-Red**: Node-Red is a flow-based programming tool, originally developed by IBM's Emerging Technology Services team and now a part of the OpenJS Foundation.
- **InfluxDB**: InfluxDB is a Time Series Data Platform where developers build IoT, analytics, and cloud applications.
- **Grafana**: Grafana allows you to query, visualize, alert on and understand metrics.

---  

- [TL;DR](#tldr)
- [Prerequisites](#prerequisites)
  - [MetalLB configuration](#metallb-configuration)
  - [Administrative tools](#administrative-tools)
  - [LVM Data Services](#lvm-data-services)
    - [Persistent Volumes](#persistent-volumes)
  - [Configuration files](#configuration-files)
    - [node-red](#node-red)
    - [mosquitto](#mosquitto)
- [How-to guides](#how-to-guides)
  - [Install](#install)
  - [Update](#update)
  - [Uninstall](#uninstall)
  - [Remove](#remove)
  - [Display status](#display-status)
  - [Backup & data protection](#backup--data-protection)
    - [RSync HA copies](#rsync-ha-copies)
    - [Restic backup](#restic-backup)
- [Reference](#reference)
  - [Scripts](#scripts)
    - [cs-deploy](#cs-deploy)
- [License](#license)

---

## TL;DR

>**Note:** Prerequisites section must be previously completed

```bash
# Install  
./csdeploy.sh -m install
# Check status
./csdeploy.sh -l
# Uninstall 
./csdeploy.sh -m uninstall
```

## Prerequisites

- Administrative access to kubernetes cluster.
- SSH keys deployed in kubernetes nodes.
- Helm v3.

### MetalLB configuration

Review and deploy if necessary file `config.yaml` in MetalLB configuration for k8s-mod and k8s-pro cluster in order to include load balanced IP addresses for mosquitto service.

Example:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
      - name: static-pool
        auto-assign: false
        protocol: layer2
        addresses:
        - 192.168.82.20/32  # k8s-ingress   
        - 192.168.82.21/32  # mosquitto iot-studio
      - name: dynamic-pool
        protocol: layer2
        addresses:
        - 192.168.82.75-192.168.82.90
```

### Administrative tools

- Install mosquitto and node-red admin tools in mcc

```bash
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - \
&& sudo apt-get install -y nodejs \
&& sudo npm install -g --unsafe-perm node-red-admin \
&& sudo apt install -y mosquitto \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

### LVM Data Services

Data services are supported by the following nodes:

| Data service                           | Kubernetes PV node           | Kubernetes RSync node           |
| -------------------------------------- | ---------------------------- | ------------------------------- |
| `/srv/{{ .namespace.name }}-mosquitto` | `{{ .localpvnodes.all_pv }}` | `{{ .localrsyncnodes.all_pv }}` |
| `/srv/{{ .namespace.name }}-node-red`  | `{{ .localpvnodes.all_pv }}` | `{{ .localrsyncnodes.all_pv }}` |
| `/srv/{{ .namespace.name }}-influxdb`  | `{{ .localpvnodes.all_pv }}` | `{{ .localrsyncnodes.all_pv }}` |
| `/srv/{{ .namespace.name }}-grafana`   | `{{ .localpvnodes.all_pv }}` | `{{ .localrsyncnodes.all_pv }}` |

`PV node` is the node that supports the data service in normal operation.

`RSync node` is the node that receives data service copies synchronized by cron-jobs for HA.


To **create** the corresponding LVM data services, execute from your **mcc** management machine the following commands:

```bash
#
# Create LVM data services in PV node
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }} \
  'sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-node-red" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-influxdb" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-grafana" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-mosquitto" \
&& mkdir "/srv/{{ .namespace.name }}-mosquitto/data/configinc" \
&& mkdir "/srv/{{ .namespace.name }}-mosquitto/data/data"' \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

```bash
#
# Create LVM data services in RSync node
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localrsyncnodes.localadminusername }}@{{ .localrsyncnodes.all_pv }}.{{ .localrsyncnodes.domain }} \
  'sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-node-red" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-influxdb" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-grafana" \
&& sudo cs-lvmserv.sh -m create -qd "/srv/{{ .namespace.name }}-mosquitto" \
&& mkdir "/srv/{{ .namespace.name }}-mosquitto/data/configinc" \
&& mkdir "/srv/{{ .namespace.name }}-mosquitto/data/data"' \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```


To **delete** the corresponding LVM data services, execute from your **mcc** management machine the following commands:

```bash
#
# Delete LVM data services in PV node
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }} \
  'sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-node-red" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-influxdb" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-grafana" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-mosquitto"' \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

```bash
#
# Delete LVM data services in RSync node
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localrsyncnodes.localadminusername }}@{{ .localrsyncnodes.all_pv }}.{{ .localrsyncnodes.domain }} \
  'sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-node-red" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-influxdb" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-grafana" \
&& sudo cs-lvmserv.sh -m delete -qd "/srv/{{ .namespace.name }}-mosquitto"' \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```



#### Persistent Volumes

Review values in all Persistent volume manifests with the name format `./pv-*.yaml`.

The following PersistentVolume & StorageClass manifests are applied:

```bash
# PV manifests
{{ .namespace.name }}-mosquitto-data
{{ .namespace.name }}-mosquitto-configinc
{{ .namespace.name }}-node-red
{{ .namespace.name }}-influxdb
{{ .namespace.name }}-grafana
```

The node assigned in `nodeAffinity` section of the PV manifest, will be used when scheduling the pod that holds the service.


### Configuration files

After creating LVM data services, you must copy configuration files before deploying.

#### node-red

User authentication is defined on the following properties in your node-red settings file `node-red-settings.js`:

- **adminAuth**: User authentication in the editor and admin API
- **httpNodeAuth**: User authentication on the dashboard
- **httpStaticAuth**: User authentication on static content

You can generate a new password with:

```bash
echo $(head -c 512 /dev/urandom | LC_ALL=C tr -cd 'a-zA-Z0-9' | head -c 64)
```

To customize and inject the configuration file `node-red-settings.js` execute the following scripts in your configuration directory:

**Set ENV variables**:


Update env variables if needed, copy and execute the following command:

```bash
echo \
&& export RB_NODERED_USER="{{ .nodered.user }}"  \
&& export RB_NODERED_PASSWORD="{{ .nodered.password }}"  \
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
&& echo "******** Customizing file node-red-settings.js" \
&& echo \
&& export RB_NODERED_OBF_PASSWORD=$(echo ${RB_NODERED_PASSWORD} | node-red-admin hash-pw | cut -c 11-)  \
&& cp -v ./tpl-node-red-settings.js ./node-red-settings.js \
&& find . -name "node-red-settings.js" | \
        xargs -n 1 sed -i "s#__node_red_obfuscated_password__#${RB_NODERED_OBF_PASSWORD}#g" \
&& echo \
&& ls -lah ./node-red-settings.js \
&& echo \
&& echo \
&& echo "******** Injecting file node-red-settings.js in node-red configuration" \
&& echo \
&& scp ./node-red-settings.js {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }}:/srv/{{ .namespace.name }}-node-red/data/settings.js \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

>**Note:** You must have installed locally node-red package to generate the obfuscated password. Keep the original password to authenticate in login screen.


#### mosquitto

Mosquitto broker is configured to listen port 1883 for unencrypted MQTT and port 8883 for encrypted TLS over MQTT. You must provide a mosquitto certificate with the appropriate SAN's for your mosquitto server and customize the following files in your deployment:

- `mosquito_ca.crt`: Public certificate of the CA that issues the mosquitto certificate.
- `mosquito_cert.crt`: Public certificate of the mosquitto certificate.
- `mosquito_cert.key`: Private key of the mosquitto certificate.

To can create this certificate with your opnsense server see section **Create and sign certificates** in your opnsense cluster documentation README.md file.

User authentication is defined on mosquitto configuration files `mosquitto_config.conf` and `mosquitto_passwd.txt` with an obfuscated version of the password.

To customize `mosquitto_passwd.txt` with obfuscated password and inject configuration and certificate files, execute the following scripts in your configuration directory:

**Set ENV variables**:


Update env variables if needed, copy and execute the following command:

```bash
echo \
&& export RB_MOSQUITTO_USER="{{ .mosquitto.user }}"  \
&& export RB_MOSQUITTO_PASSWORD="{{ .mosquitto.password }}"  \
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
&& echo "******** Customizing file mosquitto_passwd.txt" \
&& echo \
&& ls -lah ./mosquitto_* \
&& echo \
&& echo \
&& touch ./mosquitto_passwd.txt && rm ./mosquitto_passwd.txt && touch ./mosquitto_passwd.txt \
&& mosquitto_passwd -b mosquitto_passwd.txt ${RB_MOSQUITTO_USER} ${RB_MOSQUITTO_PASSWORD}  \
&& echo \
&& echo "******** Injecting files in mosquitto configuration" \
&& echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }} \
  'sudo touch ${HOME}/mosquitto_config.conf && sudo rm -v ${HOME}/mosquitto_* ' \
&& scp ./mosquitto_* {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }}:~ \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }} \
  'sudo cp -av ${HOME}/mosquitto_* /srv/{{ .namespace.name }}-mosquitto/data/configinc/ \
&& sudo chown -R 1883:1883 "/srv/{{ .namespace.name }}-mosquitto/data/configinc"' \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

>**Note:** You must have installed mosquitto package to generate the obfuscated password. Keep the original password to authenticate at login.


To learn more about **mosquito_passwd** see https://mosquitto.org/man/mosquitto_passwd-1.html

## How-to guides

### Install

To Create namespace:

```bash
  #  Create namespace, secrets, config-maps, PV's, apply manifests and install charts.
    ./csdeploy.sh -m install
```

### Update

Reapply module manifests by running:

```bash
  # Reapply manifests
    ./csdeploy.sh -m update
```

### Uninstall

To delete module manifests and namespace run:

```bash
  # Delete manifests, and namespace
    ./csdeploy.sh -m uninstall
```

### Remove

This option is intended to be used only to remove the namespace when uninstall is failed. Otherwise, you must run `./csdeploy.sh -m uninstall`.

To remove namespace and all its contents run:

```bash
  # Remove namespace and all its contents
    ./csdeploy.sh -m remove
```

### Display status

To display namespace status run:

```bash
  # Display namespace, status:
    ./csdeploy.sh -l
```

### Backup & data protection

Backup & data protection must be configured on file `cs-cron_scripts` of the node that supports the data services.

#### RSync HA copies

Rsync cronjobs are used to achieve service HA for LVM data services that supports the persistent volumes. The script `cs-rsync.sh` perform the following actions:

- Take a snapshot of LVM data service in the node that supports the service (PV node)
- Copy and syncrhonize the data to the mirrored data service in the kubernetes node designed for HA (RSync node)
- Remove snapshot in LVM data service

To perform RSync manual copies on demand, execute from your **mcc** management machine the following commands:

>**Warning:** You should not make two copies at the same time. You must check the scheduled jobs in `cs-cron-scripts` and disable them if necesary, in order to avoid conflicts.

```bash
#
# RSync node-red data services
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }} \
  'sudo cs-rsync.sh -q -m rsync-to -d /srv/{{ .namespace.name }}-node-red \
  -t {{ .localrsyncnodes.all_pv }}.{{ .namespace.domain }}'
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

```bash
#
# RSync influxdb data services
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }} \
  'sudo cs-rsync.sh -q -m rsync-to -d /srv/{{ .namespace.name }}-influxdb \
  -t {{ .localrsyncnodes.all_pv }}.{{ .namespace.domain }}'
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

```bash
#
# RSync grafana data services
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }} \
  'sudo cs-rsync.sh -q -m rsync-to -d /srv/{{ .namespace.name }}-grafana \
  -t {{ .localrsyncnodes.all_pv }}.{{ .namespace.domain }}'
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

```bash
#
# RSync mosquitto data services
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }} \
  'sudo cs-rsync.sh -q -m rsync-to -d /srv/{{ .namespace.name }}-mosquitto \
  -t {{ .localrsyncnodes.all_pv }}.{{ .namespace.domain }}'
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

**RSync cronjobs:**

The following cron jobs should be added to file `cs-cron-scripts` on the node that supports the service (PV node). Change time schedule as needed:

```bash
################################################################################
# /srv/{{ .namespace.name }}-node-red - RSync LVM data services
################################################################################
##
## RSync path:  /srv/{{ .namespace.name }}-node-red
## To Node:     {{ .localrsyncnodes.all_pv }}
## At minute 0 past every hour from 8 through 23.
# 0 8-23 * * *     root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/{{ .namespace.name }}-node-red >> /var/log/cs-rsync.log 2>&1 ; run-one cs-rsync.sh -q -m rsync-to -d /srv/{{ .namespace.name }}-node-red  -t {{ .localrsyncnodes.all_pv }}.{{ .namespace.domain }}  >> /var/log/cs-rsync.log 2>&1
```

```bash
################################################################################
# /srv/{{ .namespace.name }}-influxdb - RSync LVM data services
################################################################################
##
## RSync path:  /srv/{{ .namespace.name }}-influxdb
## To Node:     {{ .localrsyncnodes.all_pv }}
## At minute 0 past every hour from 8 through 23.
# 0 8-23 * * *     root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/{{ .namespace.name }}-influxdb >> /var/log/cs-rsync.log 2>&1 ; run-one cs-rsync.sh -q -m rsync-to -d /srv/{{ .namespace.name }}-influxdb  -t {{ .localrsyncnodes.all_pv }}.{{ .namespace.domain }}  >> /var/log/cs-rsync.log 2>&1
```

```bash
################################################################################
# /srv/{{ .namespace.name }}-grafana - RSync LVM data services
################################################################################
##
## RSync path:  /srv/{{ .namespace.name }}-grafana
## To Node:     {{ .localrsyncnodes.all_pv }}
## At minute 0 past every hour from 8 through 23.
# 0 8-23 * * *     root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/{{ .namespace.name }}-grafana >> /var/log/cs-rsync.log 2>&1 ; run-one cs-rsync.sh -q -m rsync-to -d /srv/{{ .namespace.name }}-grafana  -t {{ .localrsyncnodes.all_pv }}.{{ .namespace.domain }}  >> /var/log/cs-rsync.log 2>&1
```

```bash
################################################################################
# /srv/{{ .namespace.name }}-mosquitto - RSync LVM data services
################################################################################
##
## RSync path:  /srv/{{ .namespace.name }}-mosquitto
## To Node:     {{ .localrsyncnodes.all_pv }}
## At minute 0 past every hour from 8 through 23.
# 0 8-23 * * *     root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/{{ .namespace.name }}-mosquitto >> /var/log/cs-rsync.log 2>&1 ; run-one cs-rsync.sh -q -m rsync-to -d /srv/{{ .namespace.name }}-mosquitto  -t {{ .localrsyncnodes.all_pv }}.{{ .namespace.domain }}  >> /var/log/cs-rsync.log 2>&1
```

#### Restic backup

Restic can be configured to perform data backups to local USB disks, remote disk via sftp or cloud S3 storage.

To perform on-demand restic backups execute from your **mcc** management machine the following commands:

>**Warning:** You should not launch two backups at the same time. You must check the scheduled jobs in `cs-cron-scripts` and disable them if necesary, in order to avoid conflicts.

```bash
#
# Restic backup node-red data services
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }} \
  'sudo cs-restic.sh -q -m restic-bck -d  /srv/{{ .namespace.name }}-node-red -t {{ .namespace.name }}-node-red'
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

```bash
#
# Restic backup influxdb data services
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }} \
  'sudo cs-restic.sh -q -m restic-bck -d  /srv/{{ .namespace.name }}-influxdb   -t {{ .namespace.name }}-influxdb'
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

```bash
#
# Restic backup grafana data services
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }} \
  'sudo cs-restic.sh -q -m restic-bck -d  /srv/{{ .namespace.name }}-grafana   -t {{ .namespace.name }}-grafana'
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

```bash
#
# Restic backup mosquitto data services
#
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }} \
  'sudo cs-restic.sh -q -m restic-bck -d  /srv/{{ .namespace.name }}-mosquitto   -t {{ .namespace.name }}-mosquitto'
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

To view available backups:

```bash
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& ssh {{ .localpvnodes.localadminusername }}@{{ .localpvnodes.all_pv }}.{{ .localpvnodes.domain }} \
  'sudo cs-restic.sh -q -m restic-list  -t \
  {{ .namespace.name }}-node-red, \
  {{ .namespace.name }}-influxdb, \
  {{ .namespace.name }}-grafana, \
  {{ .namespace.name }}-mosquitto, \
  '
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```

**Restic cronjobs:**

The following cron jobs should be added to file `cs-cron-scripts` on the node that supports the service (PV node). Change time schedule as needed:

```bash
################################################################################
# /srv/{{ .namespace.name }}-node-red - Restic backups
################################################################################
##
## Data service:  /srv/{{ .namespace.name }}-node-red
## At minute 30 past every hour from 8 through 23.
# 30 8-23 * * *   root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/{{ .namespace.name }}-node-red >> /var/log/cs-restic.log 2>&1 ; run-one cs-restic.sh -q -m restic-bck -d  /srv/{{ .namespace.name }}-node-red   -t {{ .namespace.name }}-node-red  >> /var/log/cs-restic.log 2>&1 && run-one cs-restic.sh -q -m restic-forget   -t {{ .namespace.name }}-node-red  -f "--keep-hourly 6 --keep-daily 31 --keep-weekly 5 --keep-monthly 13 --keep-yearly 10" >> /var/log/cs-restic.log 2>&1
```

```bash
################################################################################
# /srv/{{ .namespace.name }}-influxdb - Restic backups
################################################################################
##
## Data service:  /srv/{{ .namespace.name }}-influxdb
## At minute 30 past every hour from 8 through 23.
# 30 8-23 * * *   root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/{{ .namespace.name }}-influxdb >> /var/log/cs-restic.log 2>&1 ; run-one cs-restic.sh -q -m restic-bck -d  /srv/{{ .namespace.name }}-influxdb   -t {{ .namespace.name }}-influxdb  >> /var/log/cs-restic.log 2>&1 && run-one cs-restic.sh -q -m restic-forget   -t {{ .namespace.name }}-influxdb  -f "--keep-hourly 6 --keep-daily 31 --keep-weekly 5 --keep-monthly 13 --keep-yearly 10" >> /var/log/cs-restic.log 2>&1
```

```bash
################################################################################
# /srv/{{ .namespace.name }}-grafana - Restic backups
################################################################################
##
## Data service:  /srv/{{ .namespace.name }}-grafana
## At minute 30 past every hour from 8 through 23.
# 30 8-23 * * *   root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/{{ .namespace.name }}-grafana >> /var/log/cs-restic.log 2>&1 ; run-one cs-restic.sh -q -m restic-bck -d  /srv/{{ .namespace.name }}-grafana   -t {{ .namespace.name }}-grafana  >> /var/log/cs-restic.log 2>&1 && run-one cs-restic.sh -q -m restic-forget   -t {{ .namespace.name }}-grafana  -f "--keep-hourly 6 --keep-daily 31 --keep-weekly 5 --keep-monthly 13 --keep-yearly 10" >> /var/log/cs-restic.log 2>&1
```

```bash
################################################################################
# /srv/{{ .namespace.name }}-mosquitto - Restic backups
################################################################################
##
## Data service:  /srv/{{ .namespace.name }}-mosquitto
## At minute 30 past every hour from 8 through 23.
# 30 8-23 * * *   root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/{{ .namespace.name }}-mosquitto >> /var/log/cs-restic.log 2>&1 ; run-one cs-restic.sh -q -m restic-bck -d  /srv/{{ .namespace.name }}-mosquitto   -t {{ .namespace.name }}-mosquitto  >> /var/log/cs-restic.log 2>&1 && run-one cs-restic.sh -q -m restic-forget   -t {{ .namespace.name }}-mosquitto  -f "--keep-hourly 6 --keep-daily 31 --keep-weekly 5 --keep-monthly 13 --keep-yearly 10" >> /var/log/cs-restic.log 2>&1
```

## Reference

### Scripts

#### cs-deploy

```console
Purpose:
  Kubernetes IOT Studio.

Usage:
  sudo csdeploy.sh [-l] [-m <execution_mode>] [-h] [-q]

Execution modes:
  -l  [list-status]     - List current status.
  -m  <execution_mode>  - Valid modes are:

      [pull-charts]     - Pull charts to './charts/' directory.
      [install]         - Create namespace, secrets, config-maps, PV's,
                          apply manifests and install charts.
      [update]          - Reapply manifests and update or upgrade charts.
      [uninstall]       - Uninstall charts, delete manifests, remove PV's and namespace.
      [remove]          - Remove PV's, namespace and all its contents.

Options and arguments:  
  -h  Help
  -q  Quiet (Nonstop) execution.

Examples:
  # Pull charts to './charts/' directory
    ./csdeploy.sh -m pull-charts

  # Create namespace, secrets, config-maps, PV's, apply manifests and install charts.
    ./csdeploy.sh -m install

  # Reapply manifests and update or upgrade charts.
    ./csdeploy.sh -m update

  # Uninstall charts, delete manifests, remove PV's and namespace.
    ./csdeploy.sh -m uninstall

  # Remove PV's, namespace and all its contents
    ./csdeploy.sh -m remove

  # Display namespace, persistence and charts status:
    ./csdeploy.sh -l
```

**Tasks performed:**

| ${execution_mode}                | Tasks                      | Block / Description                                                         |
| -------------------------------- | -------------------------- | --------------------------------------------------------------------------- |
| [pull-charts]                    |                            | **Pull helm charts from repositories**                                      |
|                                  | Clean `./charts` directory | Remove all contents in `./charts` directory.                                |
|                                  | Pull helm charts           | Pull new charts according to sourced script in variable `source_charts`.    |
|                                  | Show charts                | Show Helm charts pulled into `./charts` directory.                          |
| [install]                        |                            | **Create namespace, config-maps, secrets and PV's**                         |
|                                  | Create namespace           | Namespace must be unique in cluster.                                        |
|                                  | Create secrets             | Create secrets containing usernames, passwords... etc.                      |
|                                  | Create PV's                | Apply all persistent volume manifests in the form `pv-*.yaml`.              |
| [update] [install]               |                            | **Deploy app mod's and charts**                                             |
|                                  | Apply manifests            | Apply all app module manifests in the form `mod-*.yaml`.                    |
|                                  | Deploy charts              | Deploy all charts in `./charts` directory with `upgrade --install` options. |
| [uninstall]                      |                            | **Uninstall charts and app mod's**                                          |
|                                  | Delete manifests           | Delete all app module manifests in the form `mod-*.yaml`.                   |
|                                  | Uninstall charts           | Uninstall all charts in `./charts` directory.                               |
| [uninstall] [remove]             |                            | **Remove namespace and PV's**                                               |
|                                  | Remove namespace           | Remove namespace and all its objects.                                       |
|                                  | Delete PV's                | Delete all persistent volume manifests in the form `pv-*.yaml`.             |
| [install] [update] [list-status] |                            | **Display status information**                                              |
|                                  | Display namespace          | Namespace and object status.                                                |
|                                  | Display certificates       | Certificate status information.                                             |
|                                  | Display secrets            | Secret status information.                                                  |
|                                  | Display persistence        | Persistence status information.                                             |
|                                  | Display charts             | Charts releases history information.                                        |
|                                  |                            |                                                                             |

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
