# Kubernetes oauth2-proxy<!-- omit in toc -->

## `k8s-hello-oauth2` v99-99-99 <!-- omit in toc -->

## Helm charts: oauth2-proxy/oauth2-proxy v6.19.1 <!-- omit in toc -->


This namespace is intended to deploy an example of oauth2-proxy deployment protecting a simple Hello World application for modeling purposes.

To run this namespace, you must deploy before k8s-keycloakx to configure the example backend authentication client.

Configuration files are deployed from template {{ ._tpldescription }} version {{ ._tplversion }}.

- [TL;DR](#tldr)
- [Prerequisites](#prerequisites)
  - [Keycloak OpenID Connection to OAuth2 Proxy](#keycloak-openid-connection-to-oauth2-proxy)
    - [Create an OpenID Client in Keycloak](#create-an-openid-client-in-keycloak)
    - [Create a group and a test user in keycloak](#create-a-group-and-a-test-user-in-keycloak)
    - [Check realm OpenID endpoint configuration](#check-realm-openid-endpoint-configuration)
  - [Configure OIDC Client in oauth2-proxy](#configure-oidc-client-in-oauth2-proxy)
  - [Configure application ingress for oauth2-proxy](#configure-application-ingress-for-oauth2-proxy)
- [How-to guides](#how-to-guides)
  - [Install](#install)
  - [Update](#update)
  - [Uninstall](#uninstall)
  - [Remove](#remove)
  - [Display status](#display-status)
  - [Update Welcome Message](#update-welcome-message)
- [Reference](#reference)
  - [Application modules](#application-modules)
  - [Helm charts and values](#helm-charts-and-values)
  - [Scripts](#scripts)
    - [cs-deploy](#cs-deploy)
- [License](#license)

---

## TL;DR

- Complete procedures in prerequisites section.

```bash
# Install  
./csdeploy.sh -m install
# Check status
./csdeploy.sh -l
```

Run:

- Published at: `{{ .publishing.url }}`

## Prerequisites

- Administrative access to Kubernetes cluster.
- Helm v3.
- k8s-keycloakx namespace deployed

>**Note**: For OpenID authentication, Keycloack issuer URL must be published with a public trusted certificate (e.g., lets-encrypt).

### Keycloak OpenID Connection to OAuth2 Proxy

This procedure creates an OpenID client for OAuth2-Proxy in Keycloak. You can find documentation in: <https://www.talkingquickly.co.uk/webapp-authentication-keycloak-OAuth2-proxy-nginx-ingress-kubernetes>

#### Create an OpenID Client in Keycloak

Log in to Keycloak with a realm administrator.

Select the appropriate **realm** or create a new one (e.g., test-realm).

Go to **Clients** page and **Create** a new client with the following settings:

- Client type: OpenID Connect
- Client ID: {{ .namespace.name }}
- Go to **Next** page
- Client authentication: On (Confidential access type)
- **Save** settings
- Valid redirect URLs: https://oauth.{{ .publishing.url }}/oauth2/callback
- **Save** settings
- Go to **Credentials** tab
- Copy **Client secret** for later configuration.
- Go to **Client scopes** tab
- Select {{ .namespace.name }}-dedicated scope
- In **Mappers** tab, select **Configure a new mapper**
- Select **Group Membership**
- Name: Groups
- Token Claim Name: groups
- All other options "On"
- **Save** settings

#### Create a group and a test user in keycloak

Go to **Groups** page and **Create group** with the following settings:

- Name: {{ .namespace.name }} 

Go to **Users** page and **Create new user** with the following settings:

- Email: User's email
- Email verified: On
- First name: User's first name
- Last name: User's last name
- Join Groups: Select {{ .namespace.name }} group
- Go to **Credentials** tab
- **Set password**

#### Check realm OpenID endpoint configuration

Go to **Realm settings** page and select **General** tab

- Endpoints: Select **OpenID Endpoint Configuration**
- Copy **"issuer"** URL for later configuration.

### Configure OIDC Client in oauth2-proxy

Edit file `values-oauth2-proxy.yaml`:
- **clientSecret**: Set client secret from keycloak configuration
- **cookieSecret**: Generate new cookie secret executing the following command at your terminal:

```bash
# Create a new secret with the following command
openssl rand -base64 32 | head -c 32 | base64
```

- **oidc_issuer_url**: Set issuer URL from keycloak realm OpenID Endpoint Configuration.
- Verify all configuration values
- **Save** file.

### Configure application ingress for oauth2-proxy

Edit file `mod-hello-oauth2.yaml`:
- Verify ingress annotations for oauth2-proxy configuration values
- **Save** file.

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

### Update Welcome Message

You can change the welcome message by editing and changing the manifest file `mod-hello-oauth2.yaml`.

## Reference

### Application modules

| Module                  | Description                |
| ----------------------- | -------------------------- |
| `mod-hello-oauth2.yaml` | hello-kubernetes manifests |

### Helm charts and values

| Chart                     | Values                     |
| ------------------------- | -------------------------- |
| oauth2-proxy/oauth2-proxy | `values-oauth2-proxy.yaml` |


### Scripts

#### cs-deploy

```console
Purpose:
  Kubernetes Hello World app.

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
