# cron-job snapshots patch <!-- omit in toc -->

- [Background](#background)
- [How-to guides](#how-to-guides)
  - [Snapshot removal without confirmation update](#snapshot-removal-without-confirmation-update)
    - [Update scripts in repository](#update-scripts-in-repository)
    - [Inject & deploy modifications in k8s-mod & k8s-pro nodes](#inject--deploy-modifications-in-k8s-mod--k8s-pro-nodes)
  - [Install & deploy cron-job snapshots patch](#install--deploy-cron-job-snapshots-patch)
    - [Customize cron-job-snapshots.yaml file](#customize-cron-job-snapshotsyaml-file)
    - [Change commands for every application](#change-commands-for-every-application)
    - [Inject and deploy files in k8s-mod-n1 node](#inject-and-deploy-files-in-k8s-mod-n1-node)
    - [Review cron-job execution in k8s-mod-n1](#review-cron-job-execution-in-k8s-mod-n1)
- [Reference](#reference)

---

## Background

RSync and Restic cron-jobs are used throughout cSkyLab to achieve high availability and data protection. These cron-jobs depend on LVM snapshots that must be taken before executing rsync or restic commands.

When a previous job is not properly finished, the snapshot is not removed and future rsync and restic jobs will fail.

This patch schedules a previous removal of snapshots in cron-jobs to make sure that **rsync and restic jobs will always be executed**. (Note that the removal job will fail if the snapshot was appropriately deleted before, but the concatenated cs-rsync or cs-restic jobs will always be executed).

This patch will also update the commands proposed in README.md files for further use.

Prior to this cron-job modification, the scripts `cs-lvmserv.sh`, `cs-rsync.sh`, and `cs-restic.sh` must be modified to allow snapshot removals without confirmation.

This procedure provides how-to guides to perform all these modifications.

## How-to guides

### Snapshot removal without confirmation update

#### Update scripts in repository

- In your VS Code side bar, righ-click your `cs-mod` folder in your repository and select **Find in folder...**

- Search for: `lvremove "${vg_name}/${snap_name}" --force`
- Replace for: `lvremove "${vg_name}/${snap_name}"`

- Search for: `lvremove "${vg_name}/${snap_name}"`
- Replace for: `lvremove --yes "${vg_name}/${snap_name}"`

- Repeat the same procedure in your `cs-pro`, folder.
- Repeat the same procedure in your `cs-sys`, folder. (Not in FastStart installations)

#### Inject & deploy modifications in k8s-mod & k8s-pro nodes

- From VS Code Remote connected to `mcc`, open 2 terminals at root folder repository
- Customize & execute in parallel the following commands to inject and execute install in k8s nodes:

```bash
# Set environment variables
export REPO_DIR="$HOME/mpb-1100"

# Inject and deploy new configuration in k8s-mod nodes
echo && echo "******** SOE - START of execution ********" && echo \
; cd ${REPO_DIR}/cs-mod/k8s-mod-master \
; ./csinject.sh -qdm config \
; cd ${REPO_DIR}/cs-mod/k8s-mod-n1 \
; ./csinject.sh -qdm config \
; cd ${REPO_DIR}/cs-mod/k8s-mod-n2 \
; ./csinject.sh -qdm config \
; echo && echo "******** EOE - END of execution ********" && echo
```

```bash
# Set environment variables
export REPO_DIR="$HOME/mpb-1100"

# Inject and deploy new configuration in k8s-pro nodes
echo && echo "******** SOE - START of execution ********" && echo \
; cd ${REPO_DIR}/cs-pro/k8s-pro-master \
; ./csinject.sh -qdm config \
; cd ${REPO_DIR}/cs-pro/k8s-pro-n1 \
; ./csinject.sh -qdm config \
; cd ${REPO_DIR}/cs-pro/k8s-pro-n2 \
; ./csinject.sh -qdm config \
; echo && echo "******** EOE - END of execution ********" && echo
```

### Install & deploy cron-job snapshots patch

#### Customize cron-job-snapshots.yaml file

The file `cron-job-snapshots.yaml` file contains a template for the changes to be made. It must be customized with the restic repository name for your installation.

- Edit `cron-job-snapshots.yaml` file
- Change `s3:https://minio-promise.csky.cloud/mpb-xxxx/restic` with your restic repository name.
- Save the file.

#### Change commands for every application

This will make changes in **cron-job** and **README.md** files in your `cs-mod` scope:

- Open the `cron-job-snapshots.yaml` file updated in previous step
- In your VS Code side bar, righ-click your `cs-mod` folder in your repository and select **Find in folder...**
- Copy each **from** and **to** fields into the change dialog box and execute all the changes proposed for rsync and restic for each application (gitlab, harbor, keycloak, miniostalone and nextcloud).

>**Note:** Every change should update 2 files: `cs-cron_scripts` in node k8s-mod-n1 and `README.md` in every k8s-mod application folder

#### Inject and deploy files in k8s-mod-n1 node

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod-n1` folder repository. Inject and deploy configuration by executing:

```bash
# Run csinject.sh to inject & deploy configuration in [config] deploy mode (default)
./csinject.sh -qdm config
```

#### Review cron-job execution in k8s-mod-n1

- From VS Code Remote in mcc, open terminal at `cs-mod/k8s-mod-n1` and connect to the machine with `./csconnect.sh`

- Check restic backup status by executing `sudo cs-restic.sh -m restic-list`
- Check the absence of unwanted snapshots by executing `sudo cs-lvmserv.sh -l`
- For more information, check logs `/var/log/cs-rsync.log` `/var/log/cs-restic.log`

## Reference

`cs-cron_script` model with patch applied:

>**Warning:** Do not break lines in cron files

```bash
#
#   crontab file
#   
#       These file contains jobs for every cs_* script suitable for crontab
#       Modify or comment jobs as needed
#
#       To set the appropriate schedule see: https://crontab.guru
#
#       Independent files can also be created with the name pattern cron-cs_*
#       to be deployed in /etc/cron.d directory
#               
#   Copyright © 2021 cSkyLab.com
#

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#
# Warning: Do not break lines in cron files
#

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name   command to be executed >> log file redirection for stderr and stdout

################################################################################
# Thin-Pool Maintenance
################################################################################

## Free space inside thinpools
## At 00:00.
0 0 * * *       root        run-one cs-lvmserv.sh -q -m trim-space >> /var/log/cs-lvmserv.log 2>&1
## At 06:00.
0 6 * * *       root        run-one cs-lvmserv.sh -q -m trim-space >> /var/log/cs-lvmserv.log 2>&1

################################################################################
# gitlab - RSync LVM data services
################################################################################
##
## RSync path:  /srv/gitlab
## To Node:     k8s-mod-n2
## At minute 0 past every hour from 8 through 23.
0 8-23 * * *     root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/gitlab  >> /var/log/cs-rsync.log 2>&1 ; run-one cs-rsync.sh -qm rsync-to -d /srv/gitlab  -t k8s-mod-n2.cskylab.net  >> /var/log/cs-rsync.log 2>&1

################################################################################
# gitlab - Restic backups
################################################################################
##
## Data service:  /srv/gitlab
## At minute 30 past every hour from 8 through 23.
## Restic repo:   s3:https://minio-promise.csky.cloud/mpb-xxxx/restic
30 8-23 * * *   root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/gitlab  >> /var/log/cs-restic.log 2>&1 ; run-one cs-restic.sh -qm restic-bck -d  /srv/gitlab -r s3:https://minio-promise.csky.cloud/mpb-xxxx/restic  -t gitlab  >> /var/log/cs-restic.log 2>&1 && run-one cs-restic.sh -q -m restic-forget -r s3:https://minio-promise.csky.cloud/mpb-xxxx/restic  -t gitlab  -f "--keep-hourly 6 --keep-daily 31 --keep-weekly 5 --keep-monthly 13 --keep-yearly 10" >> /var/log/cs-restic.log 2>&1

################################################################################
# harbor - RSync LVM data services
################################################################################
##
## RSync path:  /srv/harbor
## To Node:     k8s-mod-n2
## At minute 5 past every hour from 8 through 23.
5 8-23 * * *     root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/harbor  >> /var/log/cs-rsync.log 2>&1 ; run-one cs-rsync.sh -qm rsync-to -d /srv/harbor  -t k8s-mod-n2.cskylab.net  >> /var/log/cs-rsync.log 2>&1

################################################################################
# harbor - Restic backups
################################################################################
##
## Data service:  /srv/harbor
## At minute 35 past every hour from 8 through 23.
## Restic repo:   s3:https://minio-promise.csky.cloud/mpb-xxxx/restic
35 8-23 * * *   root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/harbor  >> /var/log/cs-restic.log 2>&1 ; run-one cs-restic.sh -qm restic-bck -d  /srv/harbor -r s3:https://minio-promise.csky.cloud/mpb-xxxx/restic  -t harbor  >> /var/log/cs-restic.log 2>&1 && run-one cs-restic.sh -q -m restic-forget -r s3:https://minio-promise.csky.cloud/mpb-xxxx/restic  -t harbor  -f "--keep-hourly 6 --keep-daily 31 --keep-weekly 5 --keep-monthly 13 --keep-yearly 10" >> /var/log/cs-restic.log 2>&1

################################################################################
# keycloak - RSync LVM data services
################################################################################
##
## RSync path:  /srv/keycloak
## To Node:     k8s-mod-n2
## At minute 10 past every hour from 8 through 23.
10 8-23 * * *     root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/keycloak  >> /var/log/cs-rsync.log 2>&1 ; run-one cs-rsync.sh -qm rsync-to -d /srv/keycloak  -t k8s-mod-n2.cskylab.net  >> /var/log/cs-rsync.log 2>&1

################################################################################
# keycloak - Restic backups
################################################################################
##
## Data service:  /srv/keycloak
## At minute 40 past every hour from 8 through 23.
## Restic repo:   s3:https://minio-promise.csky.cloud/mpb-xxxx/restic
40 8-23 * * *   root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/keycloak  >> /var/log/cs-restic.log 2>&1 ; run-one cs-restic.sh -qm restic-bck -d  /srv/keycloak -r s3:https://minio-promise.csky.cloud/mpb-xxxx/restic  -t keycloak  >> /var/log/cs-restic.log 2>&1 && run-one cs-restic.sh -q -m restic-forget -r s3:https://minio-promise.csky.cloud/mpb-xxxx/restic  -t keycloak  -f "--keep-hourly 6 --keep-daily 31 --keep-weekly 5 --keep-monthly 13 --keep-yearly 10" >> /var/log/cs-restic.log 2>&1

################################################################################
# miniostalone - RSync LVM data services
################################################################################
##
## RSync path:  /srv/miniostalone
## To Node:     k8s-mod-n2
## At minute 15 past every hour from 8 through 23.
15 8-23 * * *     root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/miniostalone  >> /var/log/cs-rsync.log 2>&1 ; run-one cs-rsync.sh -qm rsync-to -d /srv/miniostalone  -t k8s-mod-n2.cskylab.net  >> /var/log/cs-rsync.log 2>&1

################################################################################
# miniostalone - Restic backups
################################################################################
##
## Data service:  /srv/miniostalone
## At minute 45 past every hour from 8 through 23.
## Restic repo:   s3:https://minio-promise.csky.cloud/mpb-xxxx/restic
45 8-23 * * *   root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/miniostalone  >> /var/log/cs-restic.log 2>&1 ; run-one cs-restic.sh -qm restic-bck -d  /srv/miniostalone -r s3:https://minio-promise.csky.cloud/mpb-xxxx/restic  -t miniostalone  >> /var/log/cs-restic.log 2>&1 && run-one cs-restic.sh -q -m restic-forget -r s3:https://minio-promise.csky.cloud/mpb-xxxx/restic  -t miniostalone  -f "--keep-hourly 6 --keep-daily 31 --keep-weekly 5 --keep-monthly 13 --keep-yearly 10" >> /var/log/cs-restic.log 2>&1

################################################################################
# nextcloud - RSync LVM data services
################################################################################
##
## RSync path:  /srv/nextcloud
## To Node:     k8s-mod-n2
## At minute 20 past every hour from 8 through 23.
20 8-23 * * *     root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/nextcloud  >> /var/log/cs-rsync.log 2>&1 ; run-one cs-rsync.sh -qm rsync-to -d /srv/nextcloud  -t k8s-mod-n2.cskylab.net  >> /var/log/cs-rsync.log 2>&1

################################################################################
# nextcloud - Restic backups
################################################################################
##
## Data service:  /srv/nextcloud
## At minute 50 past every hour from 8 through 23.
## Restic repo:   s3:https://minio-promise.csky.cloud/mpb-xxxx/restic
50 8-23 * * *   root run-one cs-lvmserv.sh -q -m snap-remove -d /srv/nextcloud  >> /var/log/cs-restic.log 2>&1 ; run-one cs-restic.sh -qm restic-bck -d  /srv/nextcloud -r s3:https://minio-promise.csky.cloud/mpb-xxxx/restic  -t nextcloud  >> /var/log/cs-restic.log 2>&1 && run-one cs-restic.sh -q -m restic-forget -r s3:https://minio-promise.csky.cloud/mpb-xxxx/restic  -t nextcloud  -f "--keep-hourly 6 --keep-daily 31 --keep-weekly 5 --keep-monthly 13 --keep-yearly 10" >> /var/log/cs-restic.log 2>&1
```
