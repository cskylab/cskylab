<!-- markdownlint-disable MD024 -->

# cSkyLab Update Guides <!-- omit in toc -->

- [v22-08-21](#v22-08-21)
  - [Release notes](#release-notes)
  - [Application updates](#application-updates)
- [v22-03-23](#v22-03-23)
  - [Release notes](#release-notes-1)
  - [Application updates](#application-updates-1)
- [v22-01-05](#v22-01-05)
  - [Release notes](#release-notes-2)
  - [Application updates](#application-updates-2)
- [v21-12-06](#v21-12-06)
  - [Release notes](#release-notes-3)
  - [Patches](#patches)
  - [Application updates](#application-updates-3)
- [v21-11-24](#v21-11-24)
  - [Baseline build AM](#baseline-build-am)

---
## v22-08-21

### Release notes

Welcome to cSkyLab release of v22-08-21.

To perform any upgrade, you must first update your tpl-cskylab template library in your installation git repository by running:

```bash
# Check your remote git repositories
git remote -v

# Update your repository from remote upstream
git pull upstream master
```

New services added to `tpl-cskylab` template library:

- `k8s-iot-studio` supports an IOT backend environment in Kubernetes with the following applications:
  - Mosquitto MQTT broker
  - Node-Red
  - InfluxDB
  - Grafana
  
- `k8s-keycloakx` This service deploys the new default Keycloak distribution based on Quarkus. Note that this chart is the logical successor of the Wildfly based codecentric/keycloak chart.

This release also includes updates for 9 applications and kubernetes version update to v1.24.4-00.

All changes have been incorporated to templates library `tpl-cskylab`. New services and applications deployments created with this release, will have all these updates applied. Only previously deployed applications and services should be updated.

It is highly recommended to update zone `cs-mod`, before proceeding to update zones `cs-pro` and `cs-sys`.

### Application updates

Application update procedures in this release:

| Procedures                                       |
| ------------------------------------------------ |
| [k8s-metallb-system](./k8s-metallb-system.md)    |
| [k8s-ingress-nginx](./k8s-ingress-nginx.md)      |
| [k8s-cert-manager](./k8s-cert-manager.md)        |
| [k8s-harbor.md](./k8s-harbor.md)                 |
| [k8s-keycloak.md](./k8s-keycloak.md)             |
| [k8s-gitlab.md](./k8s-gitlab.md)                 |
| [k8s-nextcloud.md](./k8s-nextcloud.md)           |
| [k8s-miniostalone.md](./k8s-miniostalone.md)     |
| [k8s-minio-operator.md](./k8s-minio-operator.md) |
| [kubeadm-clusters.md](./kubeadm-clusters.md)     |

---
## v22-03-23

### Release notes

Welcome to cSkyLab release of March 23, 2022.

This release introduces the use of configuration runbooks to make it easier to generate service configuration directories from the template library. Follow instructions on `_cfg-fabric/README.md` to work with these new runbooks.

Two new services has been added to `tpl-cskylab` template library:

- k8s-minio-operator
- k8s-minio-tenant

To run these services, 4 worker nodes have to be deployed for both `k8s-mod` and `k8s-pro` k8s clusters. Platforms linux/amrv7 and linux/arm64 are supported for k8s nodes, in addition to linux/amd64

This release also includes updates for 8 applications and kubernetes version update to v1.23.5-00.

All changes have been incorporated to templates library `tpl-cskylab`. New services and applications deployments created with this release, will have all these updates applied. Only previously deployed applications and services should be updated.

It is highly recommended to update zone `cs-mod`, before proceeding to update zones `cs-pro` and `cs-sys`.

### Application updates

Application update procedures in this release:

| Procedures                                    |
| --------------------------------------------- |
| [k8s-metallb-system](./k8s-metallb-system.md) |
| [k8s-ingress-nginx](./k8s-ingress-nginx.md)   |
| [k8s-cert-manager](./k8s-cert-manager.md)     |
| [k8s-harbor.md](./k8s-harbor.md)              |
| [k8s-keycloak.md](./k8s-keycloak.md)          |
| [k8s-gitlab.md](./k8s-gitlab.md)              |
| [k8s-nextcloud.md](./k8s-nextcloud.md)        |
| [k8s-miniostalone.md](./k8s-miniostalone.md)  |
| [kubeadm-clusters.md](./kubeadm-clusters.md)  |

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
