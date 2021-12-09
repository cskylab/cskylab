# v2021-12-06

## Release notes

Welcome to cSkyLab release of December 6, 2021.

On this release we have an important patch related to cron-jobs and LVM snapshots, as well as 6 regular applications updates.

All changes have been incorporated to templates library `tpl-cskylab`. New services and applications deployments from this release, will have all these updates applied.

To keep your cSkyLab installation up to date you must apply the patches and applications upgrades in your actual deployments, according to the following procedures.

It is highly recommended to update zone `cs-mod`, before proceeding to update zones `cs-pro` and `cs-sys`.

## Patches

| Patch              | Procedure                                        |
| ------------------ | ------------------------------------------------ |
| cron-job snapshots | [cron-job-snapshots.md](./cron-job-snapshots.md) |

## Applications upgrades

| Update                     | Procedure                                        |
| -------------------------- | ------------------------------------------------ |
| MetalLB chart 2.5.13       | [metallb-2513.md](./metallb-2513.md)             |
| Ingress-nginx chart 4.0.12 | [ingress-nginx-4012.md](./ingress-nginx-4012.md) |
| GitLab chart 5.5.1         | [gitlab-551.md](./gitlab-551.md)                 |
| Harbor chart 11.1.5        | [harbor-1115.md](./harbor-1115.md)               |
| MinIO chart 9.2.3          | [minio-923.md](./minio-923.md)                   |
| Nextcloud chart 2.10.2     | [nextcloud-2102.md](./nextcloud-2102.md)         |
