# Configuration Fabric

This folder contains runbook models used to create application configuration directories in your repository from cSkyLab template libraries.

Runbook models are pre-configured with values according to the deployment model provided by cSkyLab project. You can directly run these runbooks to configure applications and services in **cs-mod** zone.

You can also copy these models and create your own runbooks with customized overriding values for all the applications you want to deploy in your staging and production environments.

## Get/Update Runbook models

To get all existing configuration runbook models from cSkyLab templates directory:

**Set ENV variables**:

Customize values for your environment variables:

- `RB_REPO_DIR`: Your repository root directory
- `RB_REPO_CFG_FABRIC_DIR`: Configuration fabric directory
- `RB_REPO_TPL_DIR`: Templates directory

Update env variables with your own values, copy and run the following command:

```bash
echo \
&& export RB_REPO_DIR="Your_Repository_Root_Directory"  \
&& export RB_REPO_CFG_FABRIC_DIR="${RB_REPO_DIR}/_cfg-fabric" \
&& export RB_REPO_TPL_DIR="${RB_REPO_DIR}/tpl-cskylab" \
&& echo
```

**Run Snippet**:

After setting ENV variables, copy and run the following snippet:

>**Note:** All existing runbook models (files named **_rb-*.md**) will be replaced. After running the snippet, if you're using your own private CA in a cert-manager clusterissuer, you should change the value for `ca-test-internal` in all runbooks with the value of your private clusterissuer.

```bash
echo \
&& echo "******** START of snippet execution ********" \
&& echo \
&& echo "******** Environment variables declared:" \
&& echo \
&& printenv | grep -e "RB_*" \
&& echo \
&& read -r -s -p $'Press Enter to continue or Ctrl+C to abort...' \
&& echo \
&& echo \
&& echo "******** Getting runbook models:" \
&& echo \
&& find ${RB_REPO_TPL_DIR} -name "_rb-*.md" | \
        xargs -n 1 cp -v --target-directory=${RB_REPO_CFG_FABRIC_DIR} \
&& find ${RB_REPO_CFG_FABRIC_DIR} -name "_rb-*.md" | \
        xargs -n 1 sed -i "s#Your_Repository_Root_Directory#${RB_REPO_DIR}#g" \
&& echo \
&& echo "******** Files in ${RB_REPO_CFG_FABRIC_DIR} directory:" \
&& echo \
&& ls -lah ${RB_REPO_CFG_FABRIC_DIR} \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```
