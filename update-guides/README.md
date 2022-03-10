<!-- markdownlint-disable MD024 -->

# cSkyLab Update Guides <!-- omit in toc -->

- [v909-909-909](#v909-909-909)
  - [Release notes](#release-notes)
  - [Application updates](#application-updates)
- [v22-01-05](#v22-01-05)
  - [Release notes](#release-notes-1)
  - [Application updates](#application-updates-1)
- [v21-12-06](#v21-12-06)
  - [Release notes](#release-notes-2)
  - [Patches](#patches)
  - [Application updates](#application-updates-2)
- [v21-11-24](#v21-11-24)
  - [Baseline build AM](#baseline-build-am)

---

## v909-909-909

### Release notes

Welcome to cSkyLab release of 909-909-909. This release includes updates for 7 applications and kubernetes version update to v1.23.4-00

All changes have been incorporated to templates library `tpl-cskylab`. New services and applications deployments from this release, will have all these updates applied.

To keep your cSkyLab installation up to date you must apply the patches and applications upgrades in your actual deployments, according to the following procedures.

It is highly recommended to update zone `cs-mod`, before proceeding to update zones `cs-pro` and `cs-sys`.

### Application updates

Application update procedures in this release:

| Procedures                                    |
| --------------------------------------------- |
| [k8s-metallb-system](./k8s-metallb-system.md) |
| [k8s-ingress-nginx](./k8s-ingress-nginx.md)   |
| [k8s-cert-manager](./k8s-cert-manager.md)     |
| [k8s-harbor.md](./k8s-harbor.md)              |

---

## v22-01-05

### Release notes

Welcome to cSkyLab release of January 5, 2022. This release includes updates for 7 applications and kubernetes version update to v1.23.1-00

All changes have been incorporated to templates library `tpl-cskylab`. New services and applications deployments from this release, will have all these updates applied.

To keep your cSkyLab installation up to date you must apply the patches and applications upgrades in your actual deployments, according to the following procedures.

It is highly recommended to update zone `cs-mod`, before proceeding to update zones `cs-pro` and `cs-sys`.

### Application updates

Application update procedures in this release:

| Procedures                                    |
| --------------------------------------------- |
| [k8s-metallb-system](./k8s-metallb-system.md) |
| [k8s-ingress-nginx](./k8s-ingress-nginx.md)   |
| [k8s-harbor.md](./k8s-harbor.md)              |
| [k8s-gitlab.md](./k8s-gitlab.md)              |
| [k8s-keycloak.md](./k8s-keycloak.md)          |
| [k8s-miniostalone.md](./k8s-miniostalone.md)  |
| [k8s-nextcloud.md](./k8s-nextcloud.md)        |
| [kubeadm-clusters.md](./kubeadm-clusters.md)  |

---

## v21-12-06

### Release notes

Welcome to cSkyLab release of December 6, 2021.

On this release we have an important patch related to cron-jobs and LVM snapshots, as well as 6 regular applications updates.

All changes have been incorporated to templates library `tpl-cskylab`. New services and applications deployments from this release, will have all these updates applied.

To keep your cSkyLab installation up to date you must apply the patches and applications upgrades in your actual deployments, according to the following procedures.

It is highly recommended to update zone `cs-mod`, before proceeding to update zones `cs-pro` and `cs-sys`.

### Patches

| Procedures                                                                   |
| ---------------------------------------------------------------------------- |
| [v21-12-06_cron-job-snapshots.md](./patches/v21-12-06_cron-job-snapshots.md) |

### Application updates

| Procedures                                    |
| --------------------------------------------- |
| [k8s-metallb-system](./k8s-metallb-system.md) |
| [k8s-ingress-nginx](./k8s-ingress-nginx.md)   |
| [k8s-gitlab.md](./k8s-gitlab.md)              |
| [k8s-harbor.md](./k8s-harbor.md)              |
| [k8s-miniostalone.md](./k8s-miniostalone.md)  |
| [k8s-nextcloud.md](./k8s-nextcloud.md)        |

---

## v21-11-24

### Baseline build AM

This is cSkyLab baseline configuration. Update guides will come after this release.

Enjoy building and using your own private cloud with cSkyLab!
