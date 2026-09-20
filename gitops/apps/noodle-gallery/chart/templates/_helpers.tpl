{{- define "noodle-gallery.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "noodle-gallery.fullname" -}}
{{- default (include "noodle-gallery.name" .) .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "noodle-gallery.labels" -}}
app.kubernetes.io/name: {{ include "noodle-gallery.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "noodle-gallery.serverImage" -}}
{{- printf "%s:%s" .Values.image.server.repository .Values.image.server.tag -}}
{{- end }}

{{- define "noodle-gallery.mlImage" -}}
{{- printf "%s:%s" .Values.image.machineLearning.repository .Values.image.machineLearning.tag -}}
{{- end }}

{{- define "noodle-gallery.databaseImage" -}}
{{- printf "%s@%s" .Values.image.database.repository .Values.image.database.digest -}}
{{- end }}