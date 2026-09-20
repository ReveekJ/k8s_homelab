{{- define "hermes.fqdn" -}}
{{- include "cluster.fqdn" . -}}
{{- end }}

{{- define "hermes.privateImage" -}}
{{- include "cluster.privateImage" . -}}
{{- end }}
