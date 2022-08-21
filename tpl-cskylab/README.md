# cSkyLab Templates Library

This directory contains templates to generate configuration files for machines, applications and services using the `cskygen` utility.

You can create your own library either by forking cSkyLab templates library or by creating it from scratch.

Your library directory should be created at the same level, and should be named after the following convention:

***tpl-yourlibraryname***

Example:

- **tpl-cskylab**: cSkyLab templates library

## Name conventions

Template directories should be named according to the following convention:

`env-app`

- ***-env-***: Running environment prefix.
- ***-app-***: Application or service.

Examples:

- **ubt2004srv-naked**
  - `ubt2004srv`: Ubuntu Server 20.04
  - `naked`: Operating system basic installation
- **ubt2004srv-kvm**
  - `ubt2004srv`: Ubuntu Server 20.04
  - `kvm`: KVM Host installation
- **k8s-metallb**
  - `k8s`: Kubernetes
  - `metallb`: Metallb bare metal load-balancer
- **k8s-harbor**
  - `k8s`: Kubernetes
  - `harbor`: Harbor registry

## Template development

Template resource files must be developed according to [Go templates](https://godoc.org/text/template) specifications.

To avoid parsing images and helm charts, files below directories named `images` or `charts` will not be considered to be rendered by `cskygen`.

> **NOTE**: All keys in override and template values files must be in lowercase. Files cannot have empty keys configured.

## Kubernetes applications templates

| Template           |                                                                       |
| ------------------ | --------------------------------------------------------------------- |
| k8s-metallb-system | Load-balancer implementation for bare metal                           |
| k8s-ingress-nginx  | Ingress controller based on NGINX                                     |
| k8s-cert-manager   | Native Kubernetes certificate management controller                   |
| k8s-harbor         | Opensource registry                                                   |
| k8s-keycloak       | Identity and access management                                        |
| k8s-gitlab         | Open DevOps platform                                                  |
| k8s-hello          | Hello-world application                                               |
| k8s-nextcloud      | File sharing server                                                   |
| k8s-miniostalone   | Object storage server, compatible with Amazon S3 - Standalone service |
| k8s-minio-operator | Object storage server, compatible with Amazon S3 - Operator service   |
| k8s-minio-tenant   | Object storage server, compatible with Amazon S3 - Tenantservice      |

## Server templates

| Template         |                                                                          |
| ---------------- | ------------------------------------------------------------------------ |
| ubt2004srv-naked | Basic installation of Ubuntu Server 20.04 LTS                            |
| ubt2004srv-ca    | Certification Authority on Ubuntu Server 20.04 LTS                       |
| ubt2004srv-dns   | Bind 9 DNS Services on Ubuntu Server 20.04 LTS                           |
| ubt2004srv-lvm   | Basic installation of Ubuntu Server 20.04 LTS with LVM storage services  |
| ubt2004srv-k8s   | Kubernetes node on Ubuntu Server 20.04 LTS                               |
| ubt2004srv-kvm   | KVM host on Ubuntu Server 20.04 LTS                                      |
| ubt2004srv-mcc   | Management host (mcc: Mission Control Center) on Ubuntu Server 20.04 LTS |
| opnsense         | Firewall, networking infrastructure and security                         |
