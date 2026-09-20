{{- define "presenton.name" -}}
presenton
{{- end }}

{{- define "presenton.fqdn" -}}
{{- if .Values.ingress.host -}}
{{- .Values.ingress.host -}}
{{- else -}}
{{- include "cluster.fqdn" (dict "ctx" . "prefix" (include "presenton.name" .)) -}}
{{- end -}}
{{- end }}
