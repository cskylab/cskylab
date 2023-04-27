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
