{{- define "gitlab.checkConfig.gitlabExporter.tls" -}}
{{- $tls := (index .Values "gitlab" "gitlab-exporter").tls -}}
{{/*
We ensure that if TLS is enabled, a TLS certificate is specified.
TODO: Remove this check when we start automatically generating these certificates.
*/}}
{{- if and $tls.enabled (empty $tls.secretName) }}
gitlab-exporter:
  gitlab.gitlab-exporter.tls.enabled is set to true, but no secret is specified in gitlab.gitlab-exporter.tls.secretName.
{{- end -}}
{{- end -}}
{{/* END "gitlab.checkConfig.gitlabExporter.tls" */}}
