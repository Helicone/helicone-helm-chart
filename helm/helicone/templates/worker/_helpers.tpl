{{/*
Expand the name of the chart.
*/}}
{{- define "helicone.worker.name" -}}
{{- default (print .Chart.Name "-helicone-worker") .Values.helicone.worker.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "helicone.worker.fullname" -}}
{{- if .Values.helicone.worker.fullnameOverride }}
{{- .Values.helicone.worker.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default (print .Chart.Name "-helicone-worker") .Values.helicone.worker.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helicone.worker.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helicone.worker.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
