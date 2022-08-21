{{/*
  Include using:
  {{ include "gitlab.scripts.configure" (
            dict
                "required" "your required secrets dirs" // optional, default "shell gitaly registry rails-secrets gitlab-workhorse"
                "optional" "your optional secrets dirs" // optional, default "redis minio objectstorage postgres ldap omniauth smtp kas mailroom gitlab-exporter"
    ) }}
*/}}
{{- define "gitlab.scripts.configure.secrets" -}}
set -e
config_dir="/init-config"
secret_dir="/init-secrets"

for secret in {{ default "shell gitaly registry rails-secrets gitlab-workhorse" $.required }} ; do
  mkdir -p "${secret_dir}/${secret}"
  cp -v -r -L "${config_dir}/${secret}/." "${secret_dir}/${secret}/"
done
for secret in {{ default "redis minio objectstorage postgres ldap omniauth smtp kas pages oauth-secrets mailroom" $.optional }} ; do
  if [ -e "${config_dir}/${secret}" ]; then
    mkdir -p "${secret_dir}/${secret}"
    cp -v -r -L "${config_dir}/${secret}/." "${secret_dir}/${secret}/"
  fi
done
{{ end -}}
