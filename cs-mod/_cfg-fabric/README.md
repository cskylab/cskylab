# Configuration Fabric

This folder contains runbooks used to create application configuration directories in your repository from cSkyLab template libraries. You should have at least one `_cfg-fabric` folder for each zone of your installation (cs-mod, cs-pro... etc.)

You can get runbook models from cSkyLab templates and copy them to create and save your own runbooks with the overriding values for the applications you deploy.

## Get Runbook models from cSkyLab templates

To get all existing configuration runbook models from cSkyLab template directory, customize ENV variables & run the following snippet:

- **Set ENV variables**: Customize values for your environment variables:
  
  - `RB_REPO_DIR`: Your repository root directory
  - `RB_REPO_CFG_FABRIC_DIR`: Configuration Runbooks directory
  - `RB_REPO_TPL_DIR`: Templates directory

- After updating with your values, copy and run the following command:

```bash
echo \
&& export RB_REPO_DIR="$HOME/YourRepo"  \
&& export RB_REPO_CFG_FABRIC_DIR="${RB_REPO_DIR}/cs-mod/_cfg-fabric" \
&& export RB_REPO_TPL_DIR="${RB_REPO_DIR}/tpl-cskylab" \
&& echo
```

- **Run Snippet**: After setting the ENV variables, copy and run the snippet:

>**Note:** All existing runbook models (files named **_rb-*.md**) will be updated.

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
&& echo \
&& echo "******** Files in ${RB_REPO_CFG_FABRIC_DIR} directory:" \
&& echo \
&& ls -lah ${RB_REPO_CFG_FABRIC_DIR} \
&& echo \
&& echo "******** END of snippet execution ********" \
&& echo
```
