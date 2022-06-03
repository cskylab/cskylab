<!--- app-name: Grafana -->

# Grafana packaged by Bitnami

Grafana is an open source metric analytics and visualization suite for visualizing time series data that supports various types of data sources.

[Overview of Grafana](https://grafana.com/)

Trademarks: This software listing is packaged by Bitnami. The respective trademarks mentioned in the offering are owned by the respective companies, and use of them does not imply any affiliation or endorsement.
                           
## TL;DR

```console
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm install my-release bitnami/grafana
```

## Introduction

This chart bootstraps a [grafana](https://github.com/bitnami/bitnami-docker-grafana) deployment on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

Bitnami charts can be used with [Kubeapps](https://kubeapps.com/) for deployment and management of Helm Charts in clusters.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure
- ReadWriteMany volumes for deployment scaling

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm install my-release bitnami/grafana
```

These commands deploy grafana on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release. Use the option `--purge` to delete all persistent volumes too.

## Differences between the Bitnami Grafana chart and the Bitnami Grafana Operator chart

In the Bitnami catalog we offer both the bitnami/grafana and bitnami/grafana-operator charts. Each solution covers different needs and use cases.

The *bitnami/grafana* chart deploys a single Grafana installation (with grafana-image-renderer) using a Kubernetes Deployment object (together with Services, PVCs, ConfigMaps, etc.). The figure below shows the deployed objects in the cluster after executing *helm install*:

```
                    +--------------+             +-----+
                    |              |             |     |
 Service & Ingress  |    Grafana   +<------------+ PVC |
<-------------------+              |             |     |
                    |  Deployment  |             +-----+
                    |              |
                    +-----------+--+
                                ^                +------------+
                                |                |            |
                                +----------------+ Configmaps |
                                                 |   Secrets  |
                                                 |            |
                                                 +------------+

```

Its lifecycle is managed using Helm and, at the Grafana container level, the following operations are automated: persistence management, configuration based on environment variables and plugin initialization. The chart also allows deploying dashboards and data sources using ConfigMaps. The Deployments do not require any ServiceAccounts with special RBAC privileges so this solution would fit better in more restricted Kubernetes installations.

The *bitnami/grafana-operator* chart deploys a Grafana Operator installation using a Kubernetes Deployment.  The figure below shows the Grafana operator deployment after executing *helm install*:

```
+--------------------+
|                    |      +---------------+
|  Grafana Operator  |      |               |
|                    |      |     RBAC      |
|    Deployment      |      |   Privileges  |
|                    |      |               |
+-------+------------+      +-------+-------+
        ^                           |
        |   +-----------------+     |
        +---+ Service Account +<----+
            +-----------------+
```

The operator will extend the Kubernetes API with the following objects: *Grafana*, *GrafanaDashboards* and *GrafanaDataSources*. From that moment, the user will be able to deploy objects of these kinds and the previously deployed Operator will take care of deploying all the required Deployments, ConfigMaps and Services for running a Grafana instance. Its lifecycle is managed using *kubectl* on the Grafana, GrafanaDashboards and GrafanaDataSource objects. The following figure shows the deployed objects after
 deploying a *Grafana* object using *kubectl*:

```
+--------------------+
|                    |      +---------------+
|  Grafana Operator  |      |               |
|                    |      |     RBAC      |
|    Deployment      |      |   Privileges  |
|                    |      |               |
+--+----+------------+      +-------+-------+
   |    ^                           |
   |    |   +-----------------+     |
   |    +---+ Service Account +<----+
   |        +-----------------+
   |
   |
   |
   |
   |                                                   Grafana
   |                     +---------------------------------------------------------------------------+
   |                     |                                                                           |
   |                     |                          +--------------+             +-----+             |
   |                     |                          |              |             |     |             |
   +-------------------->+       Service & Ingress  |    Grafana   +<------------+ PVC |             |
                         |      <-------------------+              |             |     |             |
                         |                          |  Deployment  |             +-----+             |
                         |                          |              |                                 |
                         |                          +-----------+--+                                 |
                         |                                      ^                +------------+      |
                         |                                      |                |            |      |
                         |                                      +----------------+ Configmaps |      |
                         |                                                       |   Secrets  |      |
                         |                                                       |            |      |
                         |                                                       +------------+      |
                         |                                                                           |
                         +---------------------------------------------------------------------------+

```

This solution allows to easily deploy multiple Grafana instances compared to the *bitnami/grafana* chart. As the operator automatically deploys Grafana installations, the Grafana Operator pods will require a ServiceAccount with privileges to create and destroy mulitple Kubernetes objects. This may be problematic for Kubernetes clusters with strict role-based access policies.

## Parameters

### Global parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `global.imageRegistry`    | Global Docker image registry                    | `""`  |
| `global.imagePullSecrets` | Global Docker registry secret names as an array | `[]`  |
| `global.storageClass`     | Global StorageClass for Persistent Volume(s)    | `""`  |


### Common parameters

| Name                | Description                                                                             | Value           |
| ------------------- | --------------------------------------------------------------------------------------- | --------------- |
| `kubeVersion`       | Force target Kubernetes version (using Helm capabilities if not set)                    | `""`            |
| `extraDeploy`       | Array of extra objects to deploy with the release                                       | `[]`            |
| `nameOverride`      | String to partially override grafana.fullname template (will maintain the release name) | `""`            |
| `fullnameOverride`  | String to fully override grafana.fullname template                                      | `""`            |
| `clusterDomain`     | Default Kubernetes cluster domain                                                       | `cluster.local` |
| `commonLabels`      | Labels to add to all deployed objects                                                   | `{}`            |
| `commonAnnotations` | Annotations to add to all deployed objects                                              | `{}`            |


### Grafana parameters

| Name                               | Description                                                                                                                                          | Value                             |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| `image.registry`                   | Grafana image registry                                                                                                                               | `docker.io`                       |
| `image.repository`                 | Grafana image repository                                                                                                                             | `bitnami/grafana`                 |
| `image.tag`                        | Grafana image tag (immutable tags are recommended)                                                                                                   | `8.5.4-debian-10-r0`              |
| `image.pullPolicy`                 | Grafana image pull policy                                                                                                                            | `IfNotPresent`                    |
| `image.pullSecrets`                | Grafana image pull secrets                                                                                                                           | `[]`                              |
| `admin.user`                       | Grafana admin username                                                                                                                               | `admin`                           |
| `admin.password`                   | Admin password. If a password is not provided a random password will be generated                                                                    | `""`                              |
| `admin.existingSecret`             | Name of the existing secret containing admin password                                                                                                | `""`                              |
| `admin.existingSecretPasswordKey`  | Password key on the existing secret                                                                                                                  | `password`                        |
| `smtp.enabled`                     | Enable SMTP configuration                                                                                                                            | `false`                           |
| `smtp.user`                        | SMTP user                                                                                                                                            | `user`                            |
| `smtp.password`                    | SMTP password                                                                                                                                        | `password`                        |
| `smtp.host`                        | Custom host for the smtp server                                                                                                                      | `""`                              |
| `smtp.fromAddress`                 | From address                                                                                                                                         | `""`                              |
| `smtp.fromName`                    | From name                                                                                                                                            | `""`                              |
| `smtp.skipVerify`                  | Enable skip verify                                                                                                                                   | `false`                           |
| `smtp.existingSecret`              | Name of existing secret containing SMTP credentials (user and password)                                                                              | `""`                              |
| `smtp.existingSecretUserKey`       | User key on the existing secret                                                                                                                      | `user`                            |
| `smtp.existingSecretPasswordKey`   | Password key on the existing secret                                                                                                                  | `password`                        |
| `plugins`                          | Grafana plugins to be installed in deployment time separated by commas                                                                               | `""`                              |
| `ldap.enabled`                     | Enable LDAP for Grafana                                                                                                                              | `false`                           |
| `ldap.allowSignUp`                 | Allows LDAP sign up for Grafana                                                                                                                      | `false`                           |
| `ldap.configuration`               | Specify content for ldap.toml configuration file                                                                                                     | `""`                              |
| `ldap.configMapName`               | Name of the ConfigMap with the ldap.toml configuration file for Grafana                                                                              | `""`                              |
| `ldap.secretName`                  | Name of the Secret with the ldap.toml configuration file for Grafana                                                                                 | `""`                              |
| `ldap.uri`                         | Server URI, eg. ldap://ldap_server:389                                                                                                               | `""`                              |
| `ldap.binddn`                      | DN of the account used to search in the LDAP server.                                                                                                 | `""`                              |
| `ldap.bindpw`                      | Password for binddn account.                                                                                                                         | `""`                              |
| `ldap.basedn`                      | Base DN path where binddn account will search for the users.                                                                                         | `""`                              |
| `ldap.searchAttribute`             | Field used to match with the user name (uid, samAccountName, cn, etc). This value will be ignored if 'ldap.searchFilter' is set                      | `uid`                             |
| `ldap.searchFilter`                | User search filter, for example "(cn=%s)" or "(sAMAccountName=%s)" or "(|(sAMAccountName=%s)(userPrincipalName=%s)"                                  | `""`                              |
| `ldap.extraConfiguration`          | Extra ldap configuration.                                                                                                                            | `""`                              |
| `ldap.tls.enabled`                 | Enabled TLS configuration.                                                                                                                           | `false`                           |
| `ldap.tls.startTls`                | Use STARTTLS instead of LDAPS.                                                                                                                       | `false`                           |
| `ldap.tls.skipVerify`              | Skip any SSL verification (hostanames or certificates)                                                                                               | `false`                           |
| `ldap.tls.certificatesMountPath`   | Where LDAP certifcates are mounted.                                                                                                                  | `/opt/bitnami/grafana/conf/ldap/` |
| `ldap.tls.certificatesSecret`      | Secret with LDAP certificates.                                                                                                                       | `""`                              |
| `ldap.tls.CAFilename`              | CA certificate filename. Should match with the CA entry key in the ldap.tls.certificatesSecret.                                                      | `""`                              |
| `ldap.tls.certFilename`            | Client certificate filename to authenticate against the LDAP server. Should match with certificate the entry key in the ldap.tls.certificatesSecret. | `""`                              |
| `ldap.tls.certKeyFilename`         | Client Key filename to authenticate against the LDAP server. Should match with certificate the entry key in the ldap.tls.certificatesSecret.         | `""`                              |
| `config.useGrafanaIniFile`         | Allows to load a `grafana.ini` file                                                                                                                  | `false`                           |
| `config.grafanaIniConfigMap`       | Name of the ConfigMap containing the `grafana.ini` file                                                                                              | `""`                              |
| `config.grafanaIniSecret`          | Name of the Secret containing the `grafana.ini` file                                                                                                 | `""`                              |
| `dashboardsProvider.enabled`       | Enable the use of a Grafana dashboard provider                                                                                                       | `false`                           |
| `dashboardsProvider.configMapName` | Name of a ConfigMap containing a custom dashboard provider                                                                                           | `""`                              |
| `dashboardsConfigMaps`             | Array with the names of a series of ConfigMaps containing dashboards files                                                                           | `[]`                              |
| `datasources.secretName`           | Secret name containing custom datasource files                                                                                                       | `""`                              |
| `notifiers.configMapName`          | Name of a ConfigMap containing Grafana notifiers configuration                                                                                       | `""`                              |


### Grafana Deployment parameters

| Name                                         | Description                                                                                             | Value           |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------- | --------------- |
| `grafana.replicaCount`                       | Number of Grafana nodes                                                                                 | `1`             |
| `grafana.updateStrategy.type`                | Set up update strategy for Grafana installation.                                                        | `RollingUpdate` |
| `grafana.hostAliases`                        | Add deployment host aliases                                                                             | `[]`            |
| `grafana.schedulerName`                      | Alternative scheduler                                                                                   | `""`            |
| `grafana.terminationGracePeriodSeconds`      | In seconds, time the given to the Grafana pod needs to terminate gracefully                             | `""`            |
| `grafana.priorityClassName`                  | Priority class name                                                                                     | `""`            |
| `grafana.podLabels`                          | Extra labels for Grafana pods                                                                           | `{}`            |
| `grafana.podAnnotations`                     | Grafana Pod annotations                                                                                 | `{}`            |
| `grafana.podAffinityPreset`                  | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                     | `""`            |
| `grafana.podAntiAffinityPreset`              | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                | `soft`          |
| `grafana.containerPorts.grafana`             | Grafana container port                                                                                  | `3000`          |
| `grafana.nodeAffinityPreset.type`            | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`               | `""`            |
| `grafana.nodeAffinityPreset.key`             | Node label key to match Ignored if `affinity` is set.                                                   | `""`            |
| `grafana.nodeAffinityPreset.values`          | Node label values to match. Ignored if `affinity` is set.                                               | `[]`            |
| `grafana.affinity`                           | Affinity for pod assignment                                                                             | `{}`            |
| `grafana.nodeSelector`                       | Node labels for pod assignment                                                                          | `{}`            |
| `grafana.tolerations`                        | Tolerations for pod assignment                                                                          | `[]`            |
| `grafana.topologySpreadConstraints`          | Topology spread constraints rely on node labels to identify the topology domain(s) that each Node is in | `[]`            |
| `grafana.podSecurityContext.enabled`         | Enable securityContext on for Grafana deployment                                                        | `true`          |
| `grafana.podSecurityContext.fsGroup`         | Group to configure permissions for volumes                                                              | `1001`          |
| `grafana.podSecurityContext.runAsUser`       | User for the security context                                                                           | `1001`          |
| `grafana.podSecurityContext.runAsNonRoot`    | Run containers as non-root users                                                                        | `true`          |
| `grafana.containerSecurityContext.enabled`   | Enabled Grafana Image Renderer containers' Security Context                                             | `true`          |
| `grafana.containerSecurityContext.runAsUser` | Set Grafana Image Renderer containers' Security Context runAsUser                                       | `1001`          |
| `grafana.resources.limits`                   | The resources limits for Grafana containers                                                             | `{}`            |
| `grafana.resources.requests`                 | The requested resources for Grafana containers                                                          | `{}`            |
| `grafana.livenessProbe.enabled`              | Enable livenessProbe                                                                                    | `true`          |
| `grafana.livenessProbe.path`                 | Path for livenessProbe                                                                                  | `/api/health`   |
| `grafana.livenessProbe.scheme`               | Scheme for livenessProbe                                                                                | `HTTP`          |
| `grafana.livenessProbe.initialDelaySeconds`  | Initial delay seconds for livenessProbe                                                                 | `120`           |
| `grafana.livenessProbe.periodSeconds`        | Period seconds for livenessProbe                                                                        | `10`            |
| `grafana.livenessProbe.timeoutSeconds`       | Timeout seconds for livenessProbe                                                                       | `5`             |
| `grafana.livenessProbe.failureThreshold`     | Failure threshold for livenessProbe                                                                     | `6`             |
| `grafana.livenessProbe.successThreshold`     | Success threshold for livenessProbe                                                                     | `1`             |
| `grafana.readinessProbe.enabled`             | Enable readinessProbe                                                                                   | `true`          |
| `grafana.readinessProbe.path`                | Path for readinessProbe                                                                                 | `/api/health`   |
| `grafana.readinessProbe.scheme`              | Scheme for readinessProbe                                                                               | `HTTP`          |
| `grafana.readinessProbe.initialDelaySeconds` | Initial delay seconds for readinessProbe                                                                | `30`            |
| `grafana.readinessProbe.periodSeconds`       | Period seconds for readinessProbe                                                                       | `10`            |
| `grafana.readinessProbe.timeoutSeconds`      | Timeout seconds for readinessProbe                                                                      | `5`             |
| `grafana.readinessProbe.failureThreshold`    | Failure threshold for readinessProbe                                                                    | `6`             |
| `grafana.readinessProbe.successThreshold`    | Success threshold for readinessProbe                                                                    | `1`             |
| `grafana.startupProbe.enabled`               | Enable startupProbe                                                                                     | `false`         |
| `grafana.startupProbe.path`                  | Path for readinessProbe                                                                                 | `/api/health`   |
| `grafana.startupProbe.scheme`                | Scheme for readinessProbe                                                                               | `HTTP`          |
| `grafana.startupProbe.initialDelaySeconds`   | Initial delay seconds for startupProbe                                                                  | `30`            |
| `grafana.startupProbe.periodSeconds`         | Period seconds for startupProbe                                                                         | `10`            |
| `grafana.startupProbe.timeoutSeconds`        | Timeout seconds for startupProbe                                                                        | `5`             |
| `grafana.startupProbe.failureThreshold`      | Failure threshold for startupProbe                                                                      | `6`             |
| `grafana.startupProbe.successThreshold`      | Success threshold for startupProbe                                                                      | `1`             |
| `grafana.customLivenessProbe`                | Custom livenessProbe that overrides the default one                                                     | `{}`            |
| `grafana.customReadinessProbe`               | Custom readinessProbe that overrides the default one                                                    | `{}`            |
| `grafana.customStartupProbe`                 | Custom startupProbe that overrides the default one                                                      | `{}`            |
| `grafana.lifecycleHooks`                     | for the Grafana container(s) to automate configuration before or after startup                          | `{}`            |
| `grafana.sidecars`                           | Attach additional sidecar containers to the Grafana pod                                                 | `[]`            |
| `grafana.initContainers`                     | Add additional init containers to the Grafana pod(s)                                                    | `[]`            |
| `grafana.extraVolumes`                       | Additional volumes for the Grafana pod                                                                  | `[]`            |
| `grafana.extraVolumeMounts`                  | Additional volume mounts for the Grafana container                                                      | `[]`            |
| `grafana.extraEnvVarsCM`                     | Name of existing ConfigMap containing extra env vars for Grafana nodes                                  | `""`            |
| `grafana.extraEnvVarsSecret`                 | Name of existing Secret containing extra env vars for Grafana nodes                                     | `""`            |
| `grafana.extraEnvVars`                       | Array containing extra env vars to configure Grafana                                                    | `[]`            |
| `grafana.extraConfigmaps`                    | Array to mount extra ConfigMaps to configure Grafana                                                    | `[]`            |
| `grafana.command`                            | Override default container command (useful when using custom images)                                    | `[]`            |
| `grafana.args`                               | Override default container args (useful when using custom images)                                       | `[]`            |


### Persistence parameters

| Name                        | Description                                                                                               | Value           |
| --------------------------- | --------------------------------------------------------------------------------------------------------- | --------------- |
| `persistence.enabled`       | Enable persistence                                                                                        | `true`          |
| `persistence.annotations`   | Persistent Volume Claim annotations                                                                       | `{}`            |
| `persistence.accessMode`    | Persistent Volume Access Mode                                                                             | `ReadWriteOnce` |
| `persistence.accessModes`   | Persistent Volume Access Modes                                                                            | `[]`            |
| `persistence.storageClass`  | Storage class to use with the PVC                                                                         | `""`            |
| `persistence.existingClaim` | If you want to reuse an existing claim, you can pass the name of the PVC using the existingClaim variable | `""`            |
| `persistence.size`          | Size for the PV                                                                                           | `10Gi`          |


### RBAC parameters

| Name                                          | Description                                                                                                           | Value   |
| --------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | ------- |
| `serviceAccount.create`                       | Specifies whether a ServiceAccount should be created                                                                  | `true`  |
| `serviceAccount.name`                         | The name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template | `""`    |
| `serviceAccount.annotations`                  | Annotations to add to the ServiceAccount Metadata                                                                     | `{}`    |
| `serviceAccount.automountServiceAccountToken` | Automount service account token for the application controller service account                                        | `false` |


### Traffic exposure parameters

| Name                               | Description                                                                                                                      | Value                    |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `service.type`                     | Kubernetes Service type                                                                                                          | `ClusterIP`              |
| `service.clusterIP`                | Grafana service Cluster IP                                                                                                       | `""`                     |
| `service.ports.grafana`            | Grafana service port                                                                                                             | `3000`                   |
| `service.nodePorts.grafana`        | Specify the nodePort value for the LoadBalancer and NodePort service types                                                       | `""`                     |
| `service.loadBalancerIP`           | loadBalancerIP if Grafana service type is `LoadBalancer` (optional, cloud specific)                                              | `""`                     |
| `service.loadBalancerSourceRanges` | loadBalancerSourceRanges if Grafana service type is `LoadBalancer` (optional, cloud specific)                                    | `[]`                     |
| `service.annotations`              | Provide any additional annotations which may be required.                                                                        | `{}`                     |
| `service.externalTrafficPolicy`    | Grafana service external traffic policy                                                                                          | `Cluster`                |
| `service.extraPorts`               | Extra port to expose on Redmine service                                                                                          | `[]`                     |
| `service.sessionAffinity`          | Session Affinity for Kubernetes service, can be "None" or "ClientIP"                                                             | `None`                   |
| `service.sessionAffinityConfig`    | Additional settings for the sessionAffinity                                                                                      | `{}`                     |
| `ingress.enabled`                  | Set to true to enable ingress record generation                                                                                  | `false`                  |
| `ingress.pathType`                 | Ingress Path type                                                                                                                | `ImplementationSpecific` |
| `ingress.apiVersion`               | Override API Version (automatically detected if not set)                                                                         | `""`                     |
| `ingress.hostname`                 | When the ingress is enabled, a host pointing to this will be created                                                             | `grafana.local`          |
| `ingress.path`                     | Default path for the ingress resource                                                                                            | `/`                      |
| `ingress.annotations`              | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. | `{}`                     |
| `ingress.tls`                      | Enable TLS configuration for the hostname defined at ingress.hostname parameter                                                  | `false`                  |
| `ingress.extraHosts`               | The list of additional hostnames to be covered with this ingress record.                                                         | `[]`                     |
| `ingress.extraPaths`               | Any additional arbitrary paths that may need to be added to the ingress under the main host.                                     | `[]`                     |
| `ingress.extraTls`                 | The tls configuration for additional hostnames to be covered with this ingress record.                                           | `[]`                     |
| `ingress.secrets`                  | If you're providing your own certificates, please use this to add the certificates as secrets                                    | `[]`                     |
| `ingress.secrets`                  | It is also possible to create and manage the certificates outside of this helm chart                                             | `[]`                     |
| `ingress.selfSigned`               | Create a TLS secret for this ingress record using self-signed certificates generated by Helm                                     | `false`                  |
| `ingress.ingressClassName`         | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+)                                                    | `""`                     |
| `ingress.extraRules`               | Additional rules to be covered with this ingress record                                                                          | `[]`                     |


### Metrics parameters

| Name                                       | Description                                                                                                                               | Value   |
| ------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `metrics.enabled`                          | Enable the export of Prometheus metrics                                                                                                   | `false` |
| `metrics.service.annotations`              | Annotations for Prometheus metrics service                                                                                                | `{}`    |
| `metrics.serviceMonitor.enabled`           | if `true`, creates a Prometheus Operator ServiceMonitor (also requires `metrics.enabled` to be `true`)                                    | `false` |
| `metrics.serviceMonitor.namespace`         | Namespace in which Prometheus is running                                                                                                  | `""`    |
| `metrics.serviceMonitor.interval`          | Interval at which metrics should be scraped.                                                                                              | `""`    |
| `metrics.serviceMonitor.scrapeTimeout`     | Timeout after which the scrape is ended                                                                                                   | `""`    |
| `metrics.serviceMonitor.selector`          | Prometheus instance selector labels                                                                                                       | `{}`    |
| `metrics.serviceMonitor.relabelings`       | RelabelConfigs to apply to samples before scraping                                                                                        | `[]`    |
| `metrics.serviceMonitor.metricRelabelings` | MetricRelabelConfigs to apply to samples before ingestion                                                                                 | `[]`    |
| `metrics.serviceMonitor.honorLabels`       | Labels to honor to add to the scrape endpoint                                                                                             | `false` |
| `metrics.serviceMonitor.labels`            | Additional custom labels for the ServiceMonitor                                                                                           | `{}`    |
| `metrics.serviceMonitor.jobLabel`          | The name of the label on the target service to use as the job name in prometheus.                                                         | `""`    |
| `metrics.prometheusRule.enabled`           | if `true`, creates a Prometheus Operator PrometheusRule (also requires `metrics.enabled` to be `true` and `metrics.prometheusRule.rules`) | `false` |
| `metrics.prometheusRule.namespace`         | Namespace for the PrometheusRule Resource (defaults to the Release Namespace)                                                             | `""`    |
| `metrics.prometheusRule.additionalLabels`  | Additional labels that can be used so PrometheusRule will be discovered by Prometheus                                                     | `{}`    |
| `metrics.prometheusRule.rules`             | PrometheusRule rules to configure                                                                                                         | `[]`    |


### Grafana Image Renderer parameters

| Name                                                     | Description                                                                                                                               | Value                            |
| -------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------- |
| `imageRenderer.enabled`                                  | Enable using a remote rendering service to render PNG images                                                                              | `false`                          |
| `imageRenderer.image.registry`                           | Grafana Image Renderer image registry                                                                                                     | `docker.io`                      |
| `imageRenderer.image.repository`                         | Grafana Image Renderer image repository                                                                                                   | `bitnami/grafana-image-renderer` |
| `imageRenderer.image.tag`                                | Grafana Image Renderer image tag (immutable tags are recommended)                                                                         | `3.4.2-debian-10-r64`            |
| `imageRenderer.image.pullPolicy`                         | Grafana Image Renderer image pull policy                                                                                                  | `IfNotPresent`                   |
| `imageRenderer.image.pullSecrets`                        | Grafana image Renderer pull secrets                                                                                                       | `[]`                             |
| `imageRenderer.replicaCount`                             | Number of Grafana Image Renderer Pod replicas                                                                                             | `1`                              |
| `imageRenderer.updateStrategy.type`                      | Grafana Image Renderer deployment strategy type.                                                                                          | `RollingUpdate`                  |
| `imageRenderer.podAnnotations`                           | Grafana Image Renderer Pod annotations                                                                                                    | `{}`                             |
| `imageRenderer.podLabels`                                | Extra labels for Grafana Image Renderer pods                                                                                              | `{}`                             |
| `imageRenderer.nodeSelector`                             | Node labels for pod assignment                                                                                                            | `{}`                             |
| `imageRenderer.hostAliases`                              | Grafana Image Renderer pods host aliases                                                                                                  | `[]`                             |
| `imageRenderer.tolerations`                              | Tolerations for pod assignment                                                                                                            | `[]`                             |
| `imageRenderer.priorityClassName`                        | Grafana Image Renderer pods' priorityClassName                                                                                            | `""`                             |
| `imageRenderer.schedulerName`                            | Name of the k8s scheduler (other than default)                                                                                            | `""`                             |
| `imageRenderer.terminationGracePeriodSeconds`            | In seconds, time the given to the Grafana Image Renderer pod needs to terminate gracefully                                                | `""`                             |
| `imageRenderer.topologySpreadConstraints`                | Topology Spread Constraints for pod assignment                                                                                            | `[]`                             |
| `imageRenderer.podAffinityPreset`                        | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                                       | `""`                             |
| `imageRenderer.podAntiAffinityPreset`                    | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                                  | `soft`                           |
| `imageRenderer.nodeAffinityPreset.type`                  | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`                                                 | `""`                             |
| `imageRenderer.nodeAffinityPreset.key`                   | Node label key to match Ignored if `affinity` is set.                                                                                     | `""`                             |
| `imageRenderer.nodeAffinityPreset.values`                | Node label values to match. Ignored if `affinity` is set.                                                                                 | `[]`                             |
| `imageRenderer.extraEnvVars`                             | Array containing extra env vars to configure Grafana                                                                                      | `{}`                             |
| `imageRenderer.affinity`                                 | Affinity for pod assignment                                                                                                               | `{}`                             |
| `imageRenderer.resources.limits`                         | The resources limits for Grafana containers                                                                                               | `{}`                             |
| `imageRenderer.resources.requests`                       | The requested resources for Grafana containers                                                                                            | `{}`                             |
| `imageRenderer.podSecurityContext.enabled`               | Enable securityContext on for Grafana Image Renderer deployment                                                                           | `true`                           |
| `imageRenderer.podSecurityContext.fsGroup`               | Group to configure permissions for volumes                                                                                                | `1001`                           |
| `imageRenderer.podSecurityContext.runAsUser`             | User for the security context                                                                                                             | `1001`                           |
| `imageRenderer.podSecurityContext.runAsNonRoot`          | Run containers as non-root users                                                                                                          | `true`                           |
| `imageRenderer.containerSecurityContext.enabled`         | Enabled Grafana Image Renderer containers' Security Context                                                                               | `true`                           |
| `imageRenderer.containerSecurityContext.runAsUser`       | Set Grafana Image Renderer containers' Security Context runAsUser                                                                         | `1001`                           |
| `imageRenderer.service.type`                             | Kubernetes Service type                                                                                                                   | `ClusterIP`                      |
| `imageRenderer.service.clusterIP`                        | Grafana service Cluster IP                                                                                                                | `""`                             |
| `imageRenderer.service.ports.imageRenderer`              | Grafana Image Renderer metrics port                                                                                                       | `8080`                           |
| `imageRenderer.service.nodePorts.grafana`                | Specify the nodePort value for the LoadBalancer and NodePort service types                                                                | `""`                             |
| `imageRenderer.service.loadBalancerIP`                   | loadBalancerIP if Grafana service type is `LoadBalancer` (optional, cloud specific)                                                       | `""`                             |
| `imageRenderer.service.loadBalancerSourceRanges`         | loadBalancerSourceRanges if Grafana service type is `LoadBalancer` (optional, cloud specific)                                             | `[]`                             |
| `imageRenderer.service.annotations`                      | Provide any additional annotations which may be required.                                                                                 | `{}`                             |
| `imageRenderer.service.externalTrafficPolicy`            | Grafana service external traffic policy                                                                                                   | `Cluster`                        |
| `imageRenderer.service.extraPorts`                       | Extra port to expose on Redmine service                                                                                                   | `[]`                             |
| `imageRenderer.service.sessionAffinity`                  | Session Affinity for Kubernetes service, can be "None" or "ClientIP"                                                                      | `None`                           |
| `imageRenderer.service.sessionAffinityConfig`            | Additional settings for the sessionAffinity                                                                                               | `{}`                             |
| `imageRenderer.metrics.enabled`                          | Enable the export of Prometheus metrics                                                                                                   | `false`                          |
| `imageRenderer.metrics.annotations`                      | Annotations for Prometheus metrics service[object] Prometheus annotations                                                                 | `{}`                             |
| `imageRenderer.metrics.serviceMonitor.enabled`           | if `true`, creates a Prometheus Operator ServiceMonitor (also requires `metrics.enabled` to be `true`)                                    | `false`                          |
| `imageRenderer.metrics.serviceMonitor.namespace`         | Namespace in which Prometheus is running                                                                                                  | `""`                             |
| `imageRenderer.metrics.serviceMonitor.jobLabel`          | The name of the label on the target service to use as the job name in prometheus.                                                         | `""`                             |
| `imageRenderer.metrics.serviceMonitor.interval`          | Interval at which metrics should be scraped.                                                                                              | `""`                             |
| `imageRenderer.metrics.serviceMonitor.scrapeTimeout`     | Timeout after which the scrape is ended                                                                                                   | `""`                             |
| `imageRenderer.metrics.serviceMonitor.relabelings`       | RelabelConfigs to apply to samples before scraping                                                                                        | `[]`                             |
| `imageRenderer.metrics.serviceMonitor.metricRelabelings` | MetricRelabelConfigs to apply to samples before ingestion                                                                                 | `[]`                             |
| `imageRenderer.metrics.serviceMonitor.selector`          | ServiceMonitor selector labels                                                                                                            | `{}`                             |
| `imageRenderer.metrics.serviceMonitor.labels`            | Extra labels for the ServiceMonitor                                                                                                       | `{}`                             |
| `imageRenderer.metrics.serviceMonitor.honorLabels`       | honorLabels chooses the metric's labels on collisions with target labels                                                                  | `false`                          |
| `imageRenderer.metrics.prometheusRule.enabled`           | if `true`, creates a Prometheus Operator PrometheusRule (also requires `metrics.enabled` to be `true` and `metrics.prometheusRule.rules`) | `false`                          |
| `imageRenderer.metrics.prometheusRule.namespace`         | Namespace for the PrometheusRule Resource (defaults to the Release Namespace)                                                             | `""`                             |
| `imageRenderer.metrics.prometheusRule.additionalLabels`  | Additional labels that can be used so PrometheusRule will be discovered by Prometheus                                                     | `{}`                             |
| `imageRenderer.metrics.prometheusRule.rules`             | Prometheus Rule definitions                                                                                                               | `[]`                             |
| `imageRenderer.initContainers`                           | Add additional init containers to the Grafana Image Renderer pod(s)                                                                       | `[]`                             |
| `imageRenderer.sidecars`                                 | Add additional sidecar containers to the Grafana Image Renderer pod(s)                                                                    | `[]`                             |
| `imageRenderer.extraEnvVarsCM`                           | Name of existing ConfigMap containing extra env vars for Grafana Image Renderer nodes                                                     | `""`                             |
| `imageRenderer.extraEnvVarsSecret`                       | Name of existing Secret containing extra env vars for Grafana Image Renderer nodes                                                        | `""`                             |
| `imageRenderer.extraVolumes`                             | Optionally specify extra list of additional volumes for the Grafana Image Renderer pod(s)                                                 | `[]`                             |
| `imageRenderer.extraVolumeMounts`                        | Optionally specify extra list of additional volumeMounts for the Grafana Image Renderer container(s)                                      | `[]`                             |
| `imageRenderer.command`                                  | Override default container command (useful when using custom images)                                                                      | `[]`                             |
| `imageRenderer.args`                                     | Override default container args (useful when using custom images)                                                                         | `[]`                             |
| `imageRenderer.lifecycleHooks`                           | for the Grafana Image Renderer container(s) to automate configuration before or after startup                                             | `{}`                             |


### Volume permissions init Container Parameters

| Name                                                   | Description                                                                                     | Value                   |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------------------- | ----------------------- |
| `volumePermissions.enabled`                            | Enable init container that changes the owner/group of the PV mount point to `runAsUser:fsGroup` | `false`                 |
| `volumePermissions.image.registry`                     | Bitnami Shell image registry                                                                    | `docker.io`             |
| `volumePermissions.image.repository`                   | Bitnami Shell image repository                                                                  | `bitnami/bitnami-shell` |
| `volumePermissions.image.tag`                          | Bitnami Shell image tag (immutable tags are recommended)                                        | `10-debian-10-r441`     |
| `volumePermissions.image.pullPolicy`                   | Bitnami Shell image pull policy                                                                 | `IfNotPresent`          |
| `volumePermissions.image.pullSecrets`                  | Bitnami Shell image pull secrets                                                                | `[]`                    |
| `volumePermissions.resources.limits`                   | The resources limits for the init container                                                     | `{}`                    |
| `volumePermissions.resources.requests`                 | The requested resources for the init container                                                  | `{}`                    |
| `volumePermissions.containerSecurityContext.runAsUser` | Set init container's Security Context runAsUser                                                 | `0`                     |


### Diagnostic Mode Parameters

| Name                     | Description                                                                             | Value          |
| ------------------------ | --------------------------------------------------------------------------------------- | -------------- |
| `diagnosticMode.enabled` | Enable diagnostic mode (all probes will be disabled and the command will be overridden) | `false`        |
| `diagnosticMode.command` | Command to override all containers in the deployment                                    | `["sleep"]`    |
| `diagnosticMode.args`    | Args to override all containers in the deployment                                       | `["infinity"]` |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm install my-release \
  --set admin.user=admin-user bitnami/grafana
```

The above command sets the Grafana admin user to `admin-user`.

> NOTE: Once this chart is deployed, it is not possible to change the application's access credentials, such as usernames or passwords, using Helm. To change these application credentials after deployment, delete any persistent volumes (PVs) used by the chart and re-deploy it, or use the application's built-in administrative tools if available.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
$ helm install my-release -f values.yaml bitnami/grafana
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Configuration and installation details

### [Rolling VS Immutable tags](https://docs.bitnami.com/containers/how-to/understand-rolling-tags-containers/)

It is strongly recommended to use immutable tags in a production environment. This ensures your deployment does not change automatically if the same tag is updated with a different image.

Bitnami will release a new chart updating its containers if a new version of the main container, significant changes, or critical vulnerabilities exist.

### Using custom configuration

Grafana supports multiples configuration files. Using kubernetes you can mount a file using a ConfigMap or a Secret. For example, to mount a custom `grafana.ini` file or `custom.ini` file you can create a ConfigMap like the following:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myconfig
data:
  grafana.ini: |-
    # Raw text of the file
```

And now you need to pass the ConfigMap name, to the corresponding parameters: `config.useGrafanaIniFile=true` and `config.grafanaIniConfigMap=myconfig`.

To provide dashboards on deployment time, Grafana needs a dashboards provider and the dashboards themselves.
A default provider is created if enabled, or you can mount your own provider using a ConfigMap, but have in mind that the path to the dashboard folder must be `/opt/bitnami/grafana/dashboards`.
  1. To create a dashboard, it is needed to have a datasource for it. The datasources must be created mounting a secret with all the datasource files in it. In this case, it is not a ConfigMap because the datasource could contain sensitive information.
  2. To load the dashboards themselves you need to create a ConfigMap for each one containing the `json` file that defines the dashboard and set the array with the ConfigMap names into the `dashboardsConfigMaps` parameter.
Note the difference between the datasources and the dashboards creation. For the datasources we can use just one secret with all of the files, while for the dashboards we need one ConfigMap per file.

For example, create the dashboard ConfigMap(s) and datasource Secret as described below:

```console
$ kubectl create secret generic datasource-secret --from-file=datasource-secret.yaml
$ kubectl create configmap my-dashboard-1 --from-file=my-dashboard-1.json
$ kubectl create configmap my-dashboard-2 --from-file=my-dashboard-2.json
```

> Note: the commands above assume you had previously exported your dashboards in the JSON files: *my-dashboard-1.json* and *my-dashboard-2.json*

> Note: the commands above assume you had previously created a datasource config file *datasource-secret.yaml*. Find an example at https://grafana.com/docs/grafana/latest/administration/provisioning/#example-datasource-config-file

Once you have them, use the following parameters to deploy Grafana with 2 custom dashboards:

```console
dashboardsProvider.enabled=true
datasources.secretName=datasource-secret
dashboardsConfigMaps[0].configMapName=my-dashboard-1
dashboardsConfigMaps[0].fileName=my-dashboard-1.json
dashboardsConfigMaps[1].configMapName=my-dashboard-2
dashboardsConfigMaps[1].fileName=my-dashboard-2.json
```

More info at [Grafana documentation](https://grafana.com/docs/grafana/latest/administration/provisioning/#dashboards).

### LDAP configuration

To enable LDAP authentication it is necessary to provide a ConfigMap with the Grafana LDAP configuration file. For instance:

**configmap.yaml**:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ldap-config
data:
  ldap.toml: |-
      [[servers]]
      # Ldap server host (specify multiple hosts space separated)
      host = "ldap"
      # Default port is 389 or 636 if use_ssl = true
      port = 389
      # Set to true if ldap server supports TLS
      use_ssl = false
      # Set to true if connect ldap server with STARTTLS pattern (create connection in insecure, then upgrade to secure connection with TLS)
      start_tls = false
      # set to true if you want to skip ssl cert validation
      ssl_skip_verify = false
      # set to the path to your root CA certificate or leave unset to use system defaults
      # root_ca_cert = "/path/to/certificate.crt"
      # Authentication against LDAP servers requiring client certificates
      # client_cert = "/path/to/client.crt"
      # client_key = "/path/to/client.key"

      # Search user bind dn
      bind_dn = "cn=admin,dc=example,dc=org"
      # Search user bind password
      # If the password contains # or ; you have to wrap it with triple quotes. Ex """#password;"""
      bind_password = 'admin'

      # User search filter, for example "(cn=%s)" or "(sAMAccountName=%s)" or "(uid=%s)"
      # Allow login from email or username, example "(|(sAMAccountName=%s)(userPrincipalName=%s))"
      search_filter = "(uid=%s)"

      # An array of base dns to search through
      search_base_dns = ["ou=People,dc=support,dc=example,dc=org"]

      # group_search_filter = "(&(objectClass=posixGroup)(memberUid=%s))"
      # group_search_filter_user_attribute = "distinguishedName"
      # group_search_base_dns = ["ou=groups,dc=grafana,dc=org"]

      # Specify names of the ldap attributes your ldap uses
      [servers.attributes]
      name = "givenName"
      surname = "sn"
      username = "cn"
      member_of = "memberOf"
      email =  "email"
```

Create the ConfigMap into the cluster and deploy the Grafana Helm Chart using the existing ConfigMap and the following parameters:

```console
ldap.enabled=true
ldap.configMapName=ldap-config
ldap.allowSignUp=true
```

### Supporting HA (High Availability)

To support HA Grafana just need an external database where store dashboards, users and other persistent data.
To configure the external database provide a configuration file containing the [database section](https://grafana.com/docs/installation/configuration/#database)

More information about Grafana HA [here](https://grafana.com/docs/tutorials/ha_setup/)

### Setting Pod's affinity

This chart allows you to set your custom affinity using the `affinity` parameter. Find more information about Pod's affinity in the [kubernetes documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity).

As an alternative, you can use of the preset configurations for pod affinity, pod anti-affinity, and node affinity available at the [bitnami/common](https://github.com/bitnami/charts/tree/master/bitnami/common#affinities) chart. To do so, set the `podAffinityPreset`, `podAntiAffinityPreset`, or `nodeAffinityPreset` parameters.

## Persistence

The [Bitnami Grafana](https://github.com/bitnami/bitnami-docker-grafana) image stores the Grafana data and configurations at the `/opt/bitnami/grafana/data` path of the container.

Persistent Volume Claims are used to keep the data across deployments. This is known to work in GCE, AWS, and minikube.
See the [Parameters](#parameters) section to configure the PVC or to disable persistence.

## Troubleshooting

Find more information about how to deal with common errors related to Bitnami's Helm charts in [this troubleshooting guide](https://docs.bitnami.com/general/how-to/troubleshoot-helm-chart-issues).

## Upgrading

### To 7.0.0

This major release renames several values in this chart and adds missing features, in order to be inline with the rest of assets in the Bitnami charts repository.

Since the volume access mode when persistence is enabled is `ReadWriteOnce` in order to upgrade the deployment you will need to either use the `Recreate` strategy or delete the old deployment.

```console
kubectl delete deployment <deployment-name>
helm upgrade <release-name> bitnami/grafana
```

### To 4.1.0

This version also introduces `bitnami/common`, a [library chart](https://helm.sh/docs/topics/library_charts/#helm) as a dependency. More documentation about this new utility could be found [here](https://github.com/bitnami/charts/tree/master/bitnami/common#bitnami-common-library-chart). Please, make sure that you have updated the chart dependencies before executing any upgrade.

### To 4.0.0

[On November 13, 2020, Helm v2 support was formally finished](https://github.com/helm/charts#status-of-the-project), this major version is the result of the required changes applied to the Helm Chart to be able to incorporate the different features added in Helm v3 and to be consistent with the Helm project itself regarding the Helm v2 EOL.

**What changes were introduced in this major version?**

- Previous versions of this Helm Chart use `apiVersion: v1` (installable by both Helm 2 and 3), this Helm Chart was updated to `apiVersion: v2` (installable by Helm 3 only). [Here](https://helm.sh/docs/topics/charts/#the-apiversion-field) you can find more information about the `apiVersion` field.
- The different fields present in the *Chart.yaml* file has been ordered alphabetically in a homogeneous way for all the Bitnami Helm Charts

**Considerations when upgrading to this version**

- If you want to upgrade to this version from a previous one installed with Helm v3, you shouldn't face any issues
- If you want to upgrade to this version using Helm v2, this scenario is not supported as this version doesn't support Helm v2 anymore
- If you installed the previous version with Helm v2 and wants to upgrade to this version with Helm v3, please refer to the [official Helm documentation](https://helm.sh/docs/topics/v2_v3_migration/#migration-use-cases) about migrating from Helm v2 to v3

**Useful links**

- https://docs.bitnami.com/tutorials/resolve-helm2-helm3-post-migration-issues/
- https://helm.sh/docs/topics/v2_v3_migration/
- https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/

### To 3.0.0

Deployment label selector is immutable after it gets created, so you cannot "upgrade".

In https://github.com/bitnami/charts/pull/2773 the deployment label selectors of the resources were updated to add the component name. Resulting in compatibility breakage.

In order to "upgrade" from a previous version, you will need to [uninstall](#uninstalling-the-chart) the existing chart manually.

This major version signifies this change.

## License

Copyright &copy; 2022 Bitnami

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.