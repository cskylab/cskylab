<!-- markdownlint-disable MD024 -->

# k8s-minio-operator <!-- omit in toc -->

## Update Guides <!-- omit in toc -->

- [v23-11-24](#v23-11-24)
  - [Background](#background)
  - [How-to guides](#how-to-guides)
    - [1.- Update minio-tenant manifest and documentation](#1--update-minio-tenant-manifest-and-documentation)
    - [2.- Update minio-operator chart](#2--update-minio-operator-chart)
    - [3.- Update minio-operator namespace](#3--update-minio-operator-namespace)
    - [4.- Update minio-tenant namespace](#4--update-minio-tenant-namespace)
  - [Reference](#reference)
- [v23-04-27](#v23-04-27)
  - [Background](#background-1)
  - [How-to guides](#how-to-guides-1)
    - [1.- Update minio-tenant manifest and documentation](#1--update-minio-tenant-manifest-and-documentation-1)
    - [2.- Update minio-tenant script cs-bucket.sh](#2--update-minio-tenant-script-cs-bucketsh)
    - [3.- Update minio-operator chart](#3--update-minio-operator-chart)
    - [4.- Update minio-operator namespace](#4--update-minio-operator-namespace)
    - [5.- Update minio-tenant namespace](#5--update-minio-tenant-namespace)
  - [Reference](#reference-1)
- [v22-12-19](#v22-12-19)
  - [Background](#background-2)
  - [How-to guides](#how-to-guides-2)
    - [1.- Update minio-tenant manifest](#1--update-minio-tenant-manifest)
    - [2.- Update minio-operator chart](#2--update-minio-operator-chart-1)
    - [3.- Update minio-operator namespace](#3--update-minio-operator-namespace-1)
    - [4.- Update minio-tenant namespace](#4--update-minio-tenant-namespace-1)
  - [Reference](#reference-2)
- [v22-08-21](#v22-08-21)
  - [Background](#background-3)
  - [How-to guides](#how-to-guides-3)
    - [1.- Uninstall minio-tenant  namespace](#1--uninstall-minio-tenant--namespace)
    - [2.- Uninstall minio-operator  namespace](#2--uninstall-minio-operator--namespace)
    - [3.- Update minio-tenant manifest](#3--update-minio-tenant-manifest)
    - [4.- Update minio-operator chart](#4--update-minio-operator-chart)
    - [5.- Remove old tenant CRD's](#5--remove-old-tenant-crds)
    - [5.- Install minio-operator namespace](#5--install-minio-operator-namespace)
    - [6.- Install minio-tenant namespace](#6--install-minio-tenant-namespace)
  - [Reference](#reference-3)

---

## v23-11-24

### Background

This procedure upgrades minio-operator to version `5.0.11` and minio-tenant to version `RELEASE.2023-11-15T20-43-25Z`.

This procedure updates the installation in k8s-mod cluster.

### How-to guides

#### 1.- Update minio-tenant manifest and documentation

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/minio-t1` repository directory.

- Edit file  `mod-tenant.yaml` and replace the whole content as follows:

>**Note**: You should change the string `minio-t1` in all the content, in case you want to deploy it in another namespace.

```yaml
##
## Release v5.0.11
## Modified from https://github.com/minio/operator/blob/master/examples/kustomization/base/tenant.yaml
##

apiVersion: minio.min.io/v2
kind: Tenant
metadata:
  name: minio-t1
  namespace: minio-t1
  ## Optionally pass labels to be applied to the statefulset pods
  labels:
    app: minio
  ## Optionally pass annotations to be applied to the statefulset pods
  annotations:
    prometheus.io/path: /minio/v2/metrics/cluster
    prometheus.io/port: "9000"
    prometheus.io/scrape: "true"

## If a scheduler is specified here, Tenant pods will be dispatched by specified scheduler.
## If not specified, the Tenant pods will be dispatched by default scheduler.
# scheduler:
#  name: my-custom-scheduler

spec:
  features:
    ## Enable S3 specific features such as Bucket DNS which would allow `buckets` to be
    ## accessible as DNS entries of form `<bucketname>.minio.namespace.svc.cluster.local`
    ## This feature is turned off by default
    bucketDNS: false
    ## Specify a list of domains used to access MinIO and Console
    domains: { }
  ## Create users in the Tenant using this field. Make sure to create secrets per user added here.
  ## Secret should follow the format used in `minio-creds-secret`.
  users: [ ]
    # - name: storage-user
  ## Create buckets using the console user
  # buckets:
  #   - name: "test-bucket1"
  #     region: "us-east-1"
  #     objectLock: true
  #   - name: "test-bucket2"
  #     region: "us-east-1"
  #     objectLock: true
  ## This field is used only when "requestAutoCert" is set to true. Use this field to set CommonName
  ## for the auto-generated certificate. Internal DNS name for the pod will be used if CommonName is
  ## not provided. DNS name format is *.minio.default.svc.cluster.local
  certConfig: { }
  ## PodManagement policy for MinIO Tenant Pods. Can be "OrderedReady" or "Parallel"
  ## Refer https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/#pod-management-policy
  ## for details.
  podManagementPolicy: Parallel
  ## Secret with credentials and configurations to be used by MinIO Tenant.
  configuration:
    name: tenant-config
  ## Add environment variables to be set in MinIO container (https://github.com/minio/minio/tree/master/docs/config)
  env: [ ]
  #   - name: MINIO_SERVER_URL
  #     value: "https://minio-t2.cskylab.net:443" 
  #   - name: MINIO_EXTERNAL_SERVER
  #     value: "https://minio-t2.cskylab.net:443" 
  #   - name: MINIO_STORAGE_CLASS_STANDARD
  #     value: "EC:4"
  # # serviceMetadata allows passing additional labels and annotations to MinIO and Console specific
  ## services created by the operator.
  serviceMetadata:
    minioServiceLabels: { }
    minioServiceAnnotations: { }
    consoleServiceLabels: { }
    consoleServiceAnnotations: { }
  ## PriorityClassName indicates the Pod priority and hence importance of a Pod relative to other Pods.
  ## This is applied to MinIO pods only.
  ## Refer Kubernetes documentation for details https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/#priorityclass/
  priorityClassName: ""
  ## Use this field to provide one or more external CA certificates. This is used by MinIO
  ## to verify TLS connections with other applications.
  ## Certificate secret files will be mounted under /tmp/certs/CAs folder, supported types:
  ## Opaque | kubernetes.io/tls | cert-manager.io/v1alpha2 | cert-manager.io/v1
  ##
  ## ie:
  ##
  ##  externalCaCertSecret:
  ##    - name: ca-certificate-1
  ##      type: Opaque
  ##    - name: ca-certificate-2
  ##      type: Opaque
  ##    - name: ca-certificate-3
  ##      type: Opaque
  ##
  ## Create secrets as explained here:
  ## https://github.com/minio/minio/tree/master/docs/tls/kubernetes#2-create-kubernetes-secret
  externalCaCertSecret:
    - name: external-ca-certificate
      type: Opaque

  ## Use this field to provide one or more Secrets with external certificates. This can be used to configure
  ## TLS for MinIO Tenant pods.
  ## Certificate secret files will be mounted under /tmp/certs folder, supported types:
  ## Opaque | kubernetes.io/tls | cert-manager.io/v1alpha2 | cert-manager.io/v1
  ##
  ## ie:
  ##
  ##  externalCertSecret:
  ##    - name: domain-certificate-1
  ##      type: kubernetes.io/tls
  ##    - name: domain-certificate-2
  ##      type: kubernetes.io/tls
  ##    - name:domain-certificate-3
  ##      type: kubernetes.io/tls
  ##
  ## Create secrets as explained here:
  ## https://github.com/minio/minio/tree/master/docs/tls/kubernetes#2-create-kubernetes-secret
  externalCertSecret:
    - name: minio-t1-tenant-tls
      type: kubernetes.io/tls

  ## Use this field to provide client certificates for MinIO & KES. This can be used to configure
  ## mTLS for MinIO and your KES server. Files will be mounted under /tmp/certs folder, supported types:
  ## Opaque | kubernetes.io/tls | cert-manager.io/v1alpha2 | cert-manager.io/v1
  ## ie:
  ##
  ##  externalClientCertSecret:
  ##    name: mtls-certificates-for-tenant
  ##    type: Opaque
  ##
  ## Create secrets as explained here:
  ## https://github.com/minio/minio/tree/master/docs/tls/kubernetes#2-create-kubernetes-secret
  # externalClientCertSecret: {}
  ##
  
  ## Use this field to provide additional client certificate for the MinIO Tenant
  ## Certificate secret files will be mounted under /tmp/certs folder, supported types:
  ## Opaque | kubernetes.io/tls | cert-manager.io/v1alpha2 | cert-manager.io/v1
  ##
  ## mount path inside container:
  ##
  ## ie:
  ##
  ##    externalClientCertSecrets:
  ##      - name: client-certificate-1
  ##        type: kubernetes.io/tls
  ##      - name: client-certificate-2
  ##        type: kubernetes.io/tls
  ##      - name:client-certificate-3
  ##        type: kubernetes.io/tls
  ##
  ## Create secrets as explained here:
  ## https://github.com/minio/minio/tree/master/docs/tls/kubernetes#2-create-kubernetes-secret
  externalClientCertSecrets: [ ]

  ## Registry location and Tag to download MinIO Server image
  image: quay.io/minio/minio:RELEASE.2023-11-15T20-43-25Z
  imagePullSecret: { }
  ## Mount path where PV will be mounted inside container(s).
  mountPath: /export
  ## Sub path inside Mount path where MinIO stores data.
  subPath: /data
  ## Service account to be used for all the MinIO Pods
  serviceAccountName: ""
  ## Specification for MinIO Pool(s) in this Tenant.
  pools:
    ## Servers specifies the number of MinIO Tenant Pods / Servers in this pool.
    ## For standalone mode, supply 1. For distributed mode, supply 4 or more.
    ## Note that the operator does not support upgrading from standalone to distributed mode.
    - servers: 4
      ## custom name for the pool
      name: ss-0
      ## volumesPerServer specifies the number of volumes attached per MinIO Tenant Pod / Server.
      volumesPerServer: 4
      ## nodeSelector parameters for MinIO Pods. It specifies a map of key-value pairs. For the pod to be
      ## eligible to run on a node, the node must have each of the
      ## indicated key-value pairs as labels.
      ## Read more here: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
      nodeSelector: { }
      ## Used to specify a toleration for a pod
      tolerations: [ ]
      ## Affinity settings for MinIO pods. Read more about affinity
      ## here: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity.
      affinity:
        nodeAffinity: { }
        podAffinity: { }
        podAntiAffinity: { }
      ## Configure resource requests and limits for MinIO containers
      resources: { }
      ## This VolumeClaimTemplate is used across all the volumes provisioned for MinIO Tenant in this
      ## Pool.
      volumeClaimTemplate:
        apiVersion: v1
        kind: persistentvolumeclaims
        metadata: { }
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 10Gi
          storageClassName: minio-t1-storage
        status: { }
      ## Configure security context
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        runAsNonRoot: true
        fsGroup: 1000
        fsGroupChangePolicy: "OnRootMismatch"
      ## Configure container security context
      containerSecurityContext:
        runAsUser: 1000
        runAsGroup: 1000
        runAsNonRoot: true
  ## Enable automatic Kubernetes based certificate generation and signing as explained in
  ## https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster
  requestAutoCert: false
  ## Prometheus setup for MinIO Tenant.
  #  prometheus:
  #    image: "" # defaults to quay.io/prometheus/prometheus:latest
  #    env: [ ]
  #    sidecarimage: "" # defaults to alpine
  #    initimage: "" # defaults to busybox:1.33.1
  #    diskCapacityGB: 1
  #    storageClassName: standard
  #    annotations: { }
  #    labels: { }
  #    nodeSelector: { }
  #    affinity:
  #      nodeAffinity: { }
  #      podAffinity: { }
  #      podAntiAffinity: { }
  #    resources: { }
  #    serviceAccountName: ""
  #    securityContext:
  #      runAsUser: 1000
  #      runAsGroup: 1000
  #      runAsNonRoot: true
  #      fsGroup: 1000
  ## Prometheus Operator's Service Monitor for MinIO Tenant Pods.
  # prometheusOperator:
  #   labels:
  #     app: minio-sm
  ## Audit Logs will be deprecated soon, commenting out for now!.
  ## LogSearch API setup for MinIO Tenant.
  # log:
  #   image: "" # defaults to minio/operator:v5.0.4
  #   env: [ ]
  #   resources: { }
  #   nodeSelector: { }
  #   affinity:
  #     nodeAffinity: { }
  #     podAffinity: { }
  #     podAntiAffinity: { }
  #   tolerations: [ ]
  #   annotations: { }
  #   labels: { }
  #   audit:
  #     diskCapacityGB: 1
  #   ## Postgres setup for LogSearch API
  #   db:
  #     image: "" # defaults to library/postgres
  #     env: [ ]
  #     initimage: "" # defaults to busybox:1.33.1
  #     volumeClaimTemplate:
  #       metadata: { }
  #       spec:
  #         storageClassName: standard
  #         accessModes:
  #           - ReadWriteOnce
  #         resources:
  #           requests:
  #             storage: 1Gi
  #     resources: { }
  #     nodeSelector: { }
  #     affinity:
  #       nodeAffinity: { }
  #       podAffinity: { }
  #       podAntiAffinity: { }
  #     tolerations: [ ]
  #     annotations: { }
  #     labels: { }
  #     serviceAccountName: ""
  #     securityContext:
  #       runAsUser: 999
  #       runAsGroup: 999
  #       runAsNonRoot: true
  #       fsGroup: 999
  #   serviceAccountName: ""
  #   securityContext:
  #     runAsUser: 1000
  #     runAsGroup: 1000
  #     runAsNonRoot: true
  #     fsGroup: 1000
```

- Edit `README.md` documentation file, and change header as follows:

``` bash
## v23-11-24 <!-- omit in toc -->

## Image: quay.io/minio/minio:RELEASE.2023-11-15T20-43-25Z <!-- omit in toc -->
```

- Edit `README.md` documentation file, and change yaml section at **Install** as follows:

```yaml
  ## Registry location and Tag to download MinIO Server image
  image: quay.io/minio/minio:RELEASE.2023-11-15T20-43-25Z
```

#### 2.- Update minio-operator chart

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/minio-op` repository directory.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

## Repositories
helm repo add minio https://operator.min.io/
helm repo update

## Charts
helm pull minio/operator --version 5.0.11 --untar

EOF
)"
```

- Edit `README.md` documentation file, and change header as follows:

``` bash
## 23-11-24 <!-- omit in toc -->

## Helm charts: minio/operator v5.0.11 <!-- omit in toc -->
```

#### 3.- Update minio-operator namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/minio-op` repository directory.

Update namespace by running:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Install chart and namespace.  
./csdeploy.sh -m update
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```
#### 4.- Update minio-tenant namespace

Update namespace by running:

```bash
# Update namespace.  
./csdeploy.sh -m update
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```

- Connect to minio-tenant console and check the application is running.

### Reference

- <https://github.com/bitnami/charts/tree/master/bitnami/minio>

---

## v23-04-27

### Background

This procedure upgrades minio-operator to version `5.0.4` and minio-tenant to version `RELEASE.2023-04-20T17-56-55Z`.

This procedure updates the installation in k8s-mod cluster.

### How-to guides

#### 1.- Update minio-tenant manifest and documentation

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/minio-t1` repository directory.

- Edit file  `mod-tenant.yaml` and replace the whole content as follows:

>**Note**: You should change the string `minio-t1` in all the content, in case you want to deploy it in another namespace.

```bash
##
## Modified from https://github.com/minio/operator/blob/master/examples/kustomization/base/tenant.yaml
##

apiVersion: minio.min.io/v2
kind: Tenant
metadata:
  name: minio-t1
  namespace: minio-t1
  ## Optionally pass labels to be applied to the statefulset pods
  labels:
    app: minio
  ## Optionally pass annotations to be applied to the statefulset pods
  annotations:
    prometheus.io/path: /minio/v2/metrics/cluster
    prometheus.io/port: "9000"
    prometheus.io/scrape: "true"

## If a scheduler is specified here, Tenant pods will be dispatched by specified scheduler.
## If not specified, the Tenant pods will be dispatched by default scheduler.
# scheduler:
#  name: my-custom-scheduler

spec:
  features:
    ## Enable S3 specific features such as Bucket DNS which would allow `buckets` to be
    ## accessible as DNS entries of form `<bucketname>.minio.namespace.svc.cluster.local`
    ## This feature is turned off by default
    bucketDNS: false
    ## Specify a list of domains used to access MinIO and Console
    domains: { }
  ## Create users in the Tenant using this field. Make sure to create secrets per user added here.
  ## Secret should follow the format used in `minio-creds-secret`.
  users: [ ]
    # - name: storage-user
  ## Create buckets using the console user
  # buckets:
  #   - name: "test-bucket1"
  #     region: "us-east-1"
  #     objectLock: true
  #   - name: "test-bucket2"
  #     region: "us-east-1"
  #     objectLock: true
  ## This field is used only when "requestAutoCert" is set to true. Use this field to set CommonName
  ## for the auto-generated certificate. Internal DNS name for the pod will be used if CommonName is
  ## not provided. DNS name format is *.minio.default.svc.cluster.local
  certConfig: { }
  ## PodManagement policy for MinIO Tenant Pods. Can be "OrderedReady" or "Parallel"
  ## Refer https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/#pod-management-policy
  ## for details.
  podManagementPolicy: Parallel
  ## Secret with credentials and configurations to be used by MinIO Tenant.
  configuration:
    name: tenant-config
  ## Add environment variables to be set in MinIO container (https://github.com/minio/minio/tree/master/docs/config)
  env: [ ]
  #   - name: MINIO_SERVER_URL
  #     value: "https://minio-t2.cskylab.net:443" 
  #   - name: MINIO_EXTERNAL_SERVER
  #     value: "https://minio-t2.cskylab.net:443" 
  #   - name: MINIO_STORAGE_CLASS_STANDARD
  #     value: "EC:4"
  # # serviceMetadata allows passing additional labels and annotations to MinIO and Console specific
  ## services created by the operator.
  serviceMetadata:
    minioServiceLabels: { }
    minioServiceAnnotations: { }
    consoleServiceLabels: { }
    consoleServiceAnnotations: { }
  ## PriorityClassName indicates the Pod priority and hence importance of a Pod relative to other Pods.
  ## This is applied to MinIO pods only.
  ## Refer Kubernetes documentation for details https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/#priorityclass/
  priorityClassName: ""
  ## Use this field to provide one or more external CA certificates. This is used by MinIO
  ## to verify TLS connections with other applications.
  ## Certificate secret files will be mounted under /tmp/certs/CAs folder, supported types:
  ## Opaque | kubernetes.io/tls | cert-manager.io/v1alpha2 | cert-manager.io/v1
  ##
  ## ie:
  ##
  ##  externalCaCertSecret:
  ##    - name: ca-certificate-1
  ##      type: Opaque
  ##    - name: ca-certificate-2
  ##      type: Opaque
  ##    - name: ca-certificate-3
  ##      type: Opaque
  ##
  ## Create secrets as explained here:
  ## https://github.com/minio/minio/tree/master/docs/tls/kubernetes#2-create-kubernetes-secret
  externalCaCertSecret:
    - name: external-ca-certificate
      type: Opaque

  ## Use this field to provide one or more Secrets with external certificates. This can be used to configure
  ## TLS for MinIO Tenant pods.
  ## Certificate secret files will be mounted under /tmp/certs folder, supported types:
  ## Opaque | kubernetes.io/tls | cert-manager.io/v1alpha2 | cert-manager.io/v1
  ##
  ## ie:
  ##
  ##  externalCertSecret:
  ##    - name: domain-certificate-1
  ##      type: kubernetes.io/tls
  ##    - name: domain-certificate-2
  ##      type: kubernetes.io/tls
  ##    - name:domain-certificate-3
  ##      type: kubernetes.io/tls
  ##
  ## Create secrets as explained here:
  ## https://github.com/minio/minio/tree/master/docs/tls/kubernetes#2-create-kubernetes-secret
  externalCertSecret:
    - name: minio-t1-tenant-tls
      type: kubernetes.io/tls

  ## Use this field to provide client certificates for MinIO & KES. This can be used to configure
  ## mTLS for MinIO and your KES server. Files will be mounted under /tmp/certs folder, supported types:
  ## Opaque | kubernetes.io/tls | cert-manager.io/v1alpha2 | cert-manager.io/v1
  ## ie:
  ##
  ##  externalClientCertSecret:
  ##    name: mtls-certificates-for-tenant
  ##    type: Opaque
  ##
  ## Create secrets as explained here:
  ## https://github.com/minio/minio/tree/master/docs/tls/kubernetes#2-create-kubernetes-secret
  # externalClientCertSecret: {}
  ##
  
  ## Use this field to provide additional client certificate for the MinIO Tenant
  ## Certificate secret files will be mounted under /tmp/certs folder, supported types:
  ## Opaque | kubernetes.io/tls | cert-manager.io/v1alpha2 | cert-manager.io/v1
  ##
  ## mount path inside container:
  ##
  ## ie:
  ##
  ##    externalClientCertSecrets:
  ##      - name: client-certificate-1
  ##        type: kubernetes.io/tls
  ##      - name: client-certificate-2
  ##        type: kubernetes.io/tls
  ##      - name:client-certificate-3
  ##        type: kubernetes.io/tls
  ##
  ## Create secrets as explained here:
  ## https://github.com/minio/minio/tree/master/docs/tls/kubernetes#2-create-kubernetes-secret
  externalClientCertSecrets: [ ]

  ## Registry location and Tag to download MinIO Server image
  image: quay.io/minio/minio:RELEASE.2023-04-20T17-56-55Z
  imagePullSecret: { }
  ## Mount path where PV will be mounted inside container(s).
  mountPath: /export
  ## Sub path inside Mount path where MinIO stores data.
  subPath: /data
  ## Service account to be used for all the MinIO Pods
  serviceAccountName: ""
  ## Specification for MinIO Pool(s) in this Tenant.
  pools:
    ## Servers specifies the number of MinIO Tenant Pods / Servers in this pool.
    ## For standalone mode, supply 1. For distributed mode, supply 4 or more.
    ## Note that the operator does not support upgrading from standalone to distributed mode.
    - servers: 4
      ## custom name for the pool
      name: ss-0
      ## volumesPerServer specifies the number of volumes attached per MinIO Tenant Pod / Server.
      volumesPerServer: 4
      ## nodeSelector parameters for MinIO Pods. It specifies a map of key-value pairs. For the pod to be
      ## eligible to run on a node, the node must have each of the
      ## indicated key-value pairs as labels.
      ## Read more here: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
      nodeSelector: { }
      ## Used to specify a toleration for a pod
      tolerations: [ ]
      ## Affinity settings for MinIO pods. Read more about affinity
      ## here: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity.
      affinity:
        nodeAffinity: { }
        podAffinity: { }
        podAntiAffinity: { }
      ## Configure resource requests and limits for MinIO containers
      resources: { }
      ## This VolumeClaimTemplate is used across all the volumes provisioned for MinIO Tenant in this
      ## Pool.
      volumeClaimTemplate:
        apiVersion: v1
        kind: persistentvolumeclaims
        metadata: { }
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 10Gi
          storageClassName: minio-t1-storage
        status: { }
      ## Configure security context
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        runAsNonRoot: true
        fsGroup: 1000
      ## Configure container security context
      containerSecurityContext:
        runAsUser: 1000
        runAsGroup: 1000
        runAsNonRoot: true
  ## Enable automatic Kubernetes based certificate generation and signing as explained in
  ## https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster
  requestAutoCert: false
  ## Prometheus setup for MinIO Tenant.
  #  prometheus:
  #    image: "" # defaults to quay.io/prometheus/prometheus:latest
  #    env: [ ]
  #    sidecarimage: "" # defaults to alpine
  #    initimage: "" # defaults to busybox:1.33.1
  #    diskCapacityGB: 1
  #    storageClassName: standard
  #    annotations: { }
  #    labels: { }
  #    nodeSelector: { }
  #    affinity:
  #      nodeAffinity: { }
  #      podAffinity: { }
  #      podAntiAffinity: { }
  #    resources: { }
  #    serviceAccountName: ""
  #    securityContext:
  #      runAsUser: 1000
  #      runAsGroup: 1000
  #      runAsNonRoot: true
  #      fsGroup: 1000
  ## Prometheus Operator's Service Monitor for MinIO Tenant Pods.
  # prometheusOperator:
  #   labels:
  #     app: minio-sm
  ## Audit Logs will be deprecated soon, commenting out for now!.
  ## LogSearch API setup for MinIO Tenant.
  # log:
  #   image: "" # defaults to minio/operator:v5.0.4
  #   env: [ ]
  #   resources: { }
  #   nodeSelector: { }
  #   affinity:
  #     nodeAffinity: { }
  #     podAffinity: { }
  #     podAntiAffinity: { }
  #   tolerations: [ ]
  #   annotations: { }
  #   labels: { }
  #   audit:
  #     diskCapacityGB: 1
  #   ## Postgres setup for LogSearch API
  #   db:
  #     image: "" # defaults to library/postgres
  #     env: [ ]
  #     initimage: "" # defaults to busybox:1.33.1
  #     volumeClaimTemplate:
  #       metadata: { }
  #       spec:
  #         storageClassName: standard
  #         accessModes:
  #           - ReadWriteOnce
  #         resources:
  #           requests:
  #             storage: 1Gi
  #     resources: { }
  #     nodeSelector: { }
  #     affinity:
  #       nodeAffinity: { }
  #       podAffinity: { }
  #       podAntiAffinity: { }
  #     tolerations: [ ]
  #     annotations: { }
  #     labels: { }
  #     serviceAccountName: ""
  #     securityContext:
  #       runAsUser: 999
  #       runAsGroup: 999
  #       runAsNonRoot: true
  #       fsGroup: 999
  #   serviceAccountName: ""
  #   securityContext:
  #     runAsUser: 1000
  #     runAsGroup: 1000
  #     runAsNonRoot: true
  #     fsGroup: 1000
  
  ```

- Edit `README.md` documentation file, and change header as follows:

``` bash
## v23-04-27 <!-- omit in toc -->

## Image: quay.io/minio/minio:RELEASE.2023-04-20T17-56-55Z <!-- omit in toc -->
```

- Edit `README.md` documentation file, and change yaml section at **Install** as follows:

```yaml
  ## Registry location and Tag to download MinIO Server image
  image: quay.io/minio/minio:RELEASE.2023-04-20T17-56-55Z
```

#### 2.- Update minio-tenant script cs-bucket.sh

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/minio-t1` repository directory.

Open script `csbucket.sh` and change the code section **"Create Bucket & User & Policy"** with the following code:

```bash
################################################################################
# Create Bucket & User & Policy
################################################################################

if [[ "${execution_mode}" == "create-bucket" ]]; then

  # Create bucket configuration file
  echo
  echo "${msg_info} Create bucket configuration file ./buckets/${bucket_name}.config"
  echo
  touch ./buckets/"${bucket_name}".config
  {
    echo "minio_host=${minio_host}"
    echo "bucket_name=${bucket_name}"
    echo "---"
    echo "bucket_rw_user=${bucket_rw_user}"
    echo "bucket_rw_secret=${bucket_rw_secret}"
    echo "bucket_rw_policy=${bucket_rw_policy}"
    echo "bucket_rw_policy_content=${bucket_rw_policy_content}"
    echo "---"
    echo "bucket_ro_user=${bucket_ro_user}"
    echo "bucket_ro_secret=${bucket_ro_secret}"
    echo "bucket_ro_policy=${bucket_ro_policy}"
    echo "bucket_ro_policy_content=${bucket_ro_policy_content}"
    echo "---"
    echo "bucket_wo_user=${bucket_wo_user}"
    echo "bucket_wo_secret=${bucket_wo_secret}"
    echo "bucket_wo_policy=${bucket_wo_policy}"
    echo "bucket_wo_policy_content=${bucket_wo_policy_content}"

  } >>./buckets/"${bucket_name}".config

  # Create bucket environment source file
  echo
  echo "${msg_info} Create bucket environment source file ./buckets/source-${bucket_name}.sh"
  echo
  touch ./buckets/source-"${bucket_name}".sh

  cat >>./buckets/source-"${bucket_name}".sh <<EOF
#
#   Source environment file for MinIO bucket "${bucket_name}"
#

# This script is designed to be sourced
# No shebang intentionally
# shellcheck disable=SC2148

## minio bucket environment
export MINIO_ACCESS_KEY="${bucket_rw_user}"
export MINIO_SECRET_KEY="${bucket_rw_secret}"
export MINIO_URL="${minio_host}"
export MINIO_BUCKET="${bucket_name}"
export MC_HOST_minio="https://${bucket_rw_user}:${bucket_rw_secret}@${minio_host}"

## restic-environment
export AWS_ACCESS_KEY_ID="restic-test_rw"
export AWS_SECRET_ACCESS_KEY="iZ6Qpx1WlmXXoXKxBmiCMKWCsYOrgZKr"
export RESTIC_REPOSITORY="s3:https://minio-standalone.cskylab.com/restic-test/"
export RESTIC_PASSWORD="sGKvPNSRzQ1YlAxv"

## Restic backup job schedule (UTC)
## At every 15th minute.
export RESTIC_BACKUP_JOB_SCHEDULE="*/15 * * * *"
export RESTIC_FORGET_POLICY="--keep-last 6 --keep-hourly 12 --keep-daily 31 --keep-weekly 5 --keep-monthly 13 --keep-yearly 10"

## Restic repo maintenance job schedule (UTC)
## At 02:00.
export RESTIC_REPO_MAINTENANCE_JOB_SCHEDULE="0 2 * * *"
# Percentage of pack files to check in repo maintenance
export RESTIC_REPO_MAINTENANCE_CHECK_DATA_SUBSET="10%"

EOF

  # Create bucket
  echo
  echo "${msg_info} Create bucket minio/${bucket_name}"
  echo
  mc mb minio/"${bucket_name}"

  # ReadWrite
  echo
  echo "${msg_info} Create ReadWrite user ${bucket_rw_user} access secret and policy"
  echo
  # user
  mc admin user add minio/ "${bucket_rw_user}" "${bucket_rw_secret}"
  # policy
  echo "${bucket_rw_policy_content}" >"/tmp/${bucket_rw_policy}.json"
  mc admin policy create minio/ "${bucket_rw_policy}" "/tmp/${bucket_rw_policy}.json"
  # Set policy to user
  mc admin policy attach minio/ "${bucket_rw_policy}" --user "${bucket_rw_user}"

  # ReadOnly
  echo
  echo "${msg_info} Create ReadOnly user ${bucket_ro_user} access secret and policy"
  echo
  # user
  mc admin user add minio/ "${bucket_ro_user}" "${bucket_ro_secret}"
  # policy
  echo "${bucket_ro_policy_content}" >"/tmp/${bucket_ro_policy}.json"
  mc admin policy create minio/ "${bucket_ro_policy}" "/tmp/${bucket_ro_policy}.json"
  # Set policy to user
  mc admin policy attach minio/ "${bucket_ro_policy}" --user "${bucket_ro_user}"

  # WriteOnly
  echo
  echo "${msg_info} Create WriteOnly user ${bucket_wo_user} access secret and policy"
  echo
  # user
  mc admin user add minio/ "${bucket_wo_user}" "${bucket_wo_secret}"
  # policy
  echo "${bucket_wo_policy_content}" >"/tmp/${bucket_wo_policy}.json"
  mc admin policy create minio/ "${bucket_wo_policy}" "/tmp/${bucket_wo_policy}.json"
  # Set policy to user
  mc admin policy attach minio/ "${bucket_wo_policy}" --user "${bucket_wo_user}"

fi
```

#### 3.- Update minio-operator chart

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/minio-op` repository directory.

- Edit `values-operator.yaml` file
- Comment image proxy sections to retrieve the images directly from quay.io repository:

```yaml
# Default values for minio-operator.

# operator:
#   image:
#     repository: harbor.cskylab.net/dockerhub/minio/operator

console:
  # image:
  #   repository: harbor.cskylab.net/dockerhub/minio/console
  ingress:
    enabled: true
    annotations:
  ...
  ...
  ...
  ...
  ...
```

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

## Repositories
helm repo add minio https://operator.min.io/
helm repo update

## Charts
helm pull minio/operator --version 5.0.4 --untar

EOF
)"
```

- Edit `README.md` documentation file, and change header as follows:

``` bash
## v23-04-27 <!-- omit in toc -->

## Helm charts: minio/operator v5.0.4 <!-- omit in toc -->
```

#### 4.- Update minio-operator namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/minio-op` repository directory.

Update namespace by running:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Install chart and namespace.  
./csdeploy.sh -m update
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```
#### 5.- Update minio-tenant namespace

Update namespace by running:

```bash
# Update namespace.  
./csdeploy.sh -m update
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```

- Connect to minio-tenant console and check the application is running.

### Reference

- <https://github.com/bitnami/charts/tree/master/bitnami/minio>

---

## v22-12-19

### Background

This procedure upgrades minio-operator to version `4.5.5` and minio-tenant to version `RELEASE.2022-12-12T19-27-27Z`.

This procedure updates the installation in k8s-mod cluster.

### How-to guides

#### 1.- Update minio-tenant manifest

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/minio-t1` repository directory.

- Edit file  `mod-tenant.yaml` and update the minio server line as follows:

```bash
## Registry location and Tag to download MinIO Server image
image: quay.io/minio/minio:RELEASE.2022-12-12T19-27-27Z
```

#### 2.- Update minio-operator chart

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/minio-op` repository directory.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

## Repositories
helm repo add minio https://operator.min.io/
helm repo update

## Charts
helm pull minio/operator --version 4.5.5 --untar

EOF
)"
```

- Edit `README.md` documentation file, and change header as follows:

``` bash
## v22-12-19 <!-- omit in toc -->

## Helm charts: minio/operator v4.5.5 <!-- omit in toc -->
```

#### 3.- Update minio-operator namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/minio-op` repository directory.

Update namespace by running:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Install chart and namespace.  
./csdeploy.sh -m update
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```
#### 4.- Update minio-tenant namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/minio-t1` repository directory.

Update namespace by running:

```bash

# Update namespace.  
./csdeploy.sh -m update
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```

- Connect to minio-tenant console and check the application is running.

### Reference

- <https://github.com/bitnami/charts/tree/master/bitnami/minio>

---

## v22-08-21

### Background

This procedure upgrades minio-operator to version `4.4.28` and minio-tenant to version `RELEASE.2022-08-13T21-54-44Z`.

When migrating from version 4.8.8 it is neccesary to uninstall the namespaces and remove manually CRD's `tenants.minio.min.io`.

This procedure updates the installation in k8s-mod cluster.

### How-to guides
#### 1.- Uninstall minio-tenant  namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/minio-t1` repository directory.

- Remove gitlab namespace by running:

```bash
# Uninstall chart and namespace.  
./csdeploy.sh -m uninstall
```

#### 2.- Uninstall minio-operator  namespace

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/minio-op` repository directory.

- Remove gitlab namespace by running:

```bash
# Uninstall chart and namespace.  
./csdeploy.sh -m uninstall
```

#### 3.- Update minio-tenant manifest

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/minio-t1` repository directory.

- Edit file  `mod-tenant.yaml` and update the minio server line as follows:

```bash
## Registry location and Tag to download MinIO Server image
image: quay.io/minio/minio:RELEASE.2022-08-13T21-54-44Z
```

#### 4.- Update minio-operator chart

From VS Code Remote connected to `mcc`, open  terminal at `cs-mod/k8s-mod/minio-op` repository directory.

- Edit `csdeploy.sh` file
- Change `source_charts` variable to the following values:

```bash
# Source script to pull charts
source_charts="$(
  cat <<EOF

## Pull helm charts from repositories

## Repositories
helm repo add minio https://operator.min.io/
helm repo update

## Charts
helm pull minio/operator --version 4.4.28 --untar

EOF
)"
```

- Edit `README.md` documentation file, and change header as follows:

``` bash
## v22-08-21 <!-- omit in toc -->

## Helm charts: minio/operator v4.4.28 <!-- omit in toc -->
```

#### 5.- Remove old tenant CRD's

- Check existings CRD's by running:

```bash
# Get CRD's
kubectl get customresourcedefinitions.apiextensions.k8s.io
```

- Remove tenant CRD's by running:

```bash
# Remove tenant CRD's
kubectl delete customresourcedefinitions.apiextensions.k8s.io tenants.minio.min.io
```

#### 5.- Install minio-operator namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/minio-op` repository directory.

Install namespace by running:

```bash
# Pull charts to './charts/' directory
./csdeploy.sh -m pull-charts

# Install chart and namespace.  
./csdeploy.sh -m install
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```
#### 6.- Install minio-tenant namespace

From VS Code Remote connected to `mcc`, open  terminal at new `cs-mod/k8s-mod/minio-t1` repository directory.

Install namespace by running:

```bash

# Install chart and namespace.  
./csdeploy.sh -m install
```

- Check deployment status:

```bash
# Check namespace status.  
./csdeploy.sh -l
```

- Connect to minio-tenant console and check the application is running.

### Reference

- <https://github.com/bitnami/charts/tree/master/bitnami/minio>

---


