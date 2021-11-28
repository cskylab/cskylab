# cron-job snapshots patch <!-- omit in toc -->

- [Background](#background)
- [How-to guides](#how-to-guides)
  - [Install & deploy the patch](#install--deploy-the-patch)
  - [Customize cron-job-snapshots.yaml file](#customize-cron-job-snapshotsyaml-file)
  - [Change commands for every application](#change-commands-for-every-application)
  - [Inject and deploy files in k8s-mod-n1 node](#inject-and-deploy-files-in-k8s-mod-n1-node)
  - [Review cron-job execution in k8s-mod-n1](#review-cron-job-execution-in-k8s-mod-n1)
- [Reference](#reference)

---

## Background

RSync and Restic cron-jobs are used throughout cSkyLab to achieve high availability and data protection. These cron-jobs depend on LVM snapshots that must be taken before executing rsync or restic commands.

When a previous job is not properly finished, the snapshot is not removed and future rsync and restic jobs will fail.

This patch schedule a previous removal of snapshots in cron-jobs to make sure that **rsync and restic jobs will always be executed**. (Note that the removal job will fail if the snapshot was appropriately deleted before, but the concatenated cs-rsync or cs-restic jobs will always be executed).

It will update also the commands proposed in README.md files in deployed applications for further use.

## How-to guides

### Install & deploy the patch

### Customize cron-job-snapshots.yaml file

The file `cron-job-snapshots.yaml` file contains a template for the changes to be made. It must be customized with the restic repository name for your installation.

- Edit `cron-job-snapshots.yaml` file
- Change `s3:https://minio-promise.csky.cloud/mpb-xxxx/restic` with your restic repository name.
- Save the file.

### Change commands for every application

This will make changes in **cron-job** and **README.md** files in your `cs-mod` scope:

- Open the `cron-job-snapshots.yaml` file updated in previous step
- In your VS Code side bar, righ-click your `cs-mod` folder in your repository and select **Find in folder...**
- Copy each **from** and **to** fields into the change dialog box and execute all the changes proposed for rsync and restic for each application (gitlab, harbor, keycloak, miniostalone and nextcloud).

>**Note:** Every change should update 2 files: `cs-cron_scripts` in node k8s-mod-n1 and `README.md` in every k8s-mod application folder

### Inject and deploy files in k8s-mod-n1 node

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod-n1` folder repository. Inject and deploy configuration by executing:

```bash
# Run csinject.sh to inject & deploy configuration in [config] deploy mode (default)
./csinject.sh -qdm config
```

### Review cron-job execution in k8s-mod-n1

- From VS Code Remote in mcc, open terminal at `cs-mod/k8s-mod-n1` and connect to the machine with `./csconnect.sh`

- Check restic backup status by executing `sudo cs-restic.sh -m restic-list`
- Check the absence of unwanted snapshots by executing `sudo cs-lvmserv.sh -l`
- For more information, check logs `/var/log/cs-rsync.log` `/var/log/cs-restic.log`

## Reference

`cs-cron_script` model with patch applied:
