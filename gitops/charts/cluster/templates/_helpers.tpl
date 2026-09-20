{{- define "cluster.baseDomain" -}}
{{- required "global.baseDomain must be set" .Values.global.baseDomain -}}
{{- end }}

{{- define "cluster.fqdn" -}}
{{- printf "%s.%s" .prefix (include "cluster.baseDomain" .ctx) -}}
{{- end }}

{{- define "cluster.registry" -}}
{{- include "cluster.fqdn" (dict "ctx" . "prefix" "reg") -}}
{{- end }}

{{- define "cluster.privateImage" -}}
{{- printf "%s/%s:%s" (include "cluster.registry" .) .Values.image.repository .Values.image.tag -}}
{{- end }}
