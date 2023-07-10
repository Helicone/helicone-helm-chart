{{/*
Expand the name of the chart.
*/}}
{{- define "helicone.web.name" -}}
{{- default (print .Chart.Name "-helicone-web") .Values.helicone.web.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "helicone.web.fullname" -}}
{{- if .Values.helicone.web.fullnameOverride }}
{{- .Values.helicone.web.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default (print .Chart.Name "-helicone-web") .Values.helicone.web.nameOverride }}
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
{{- define "helicone.web.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helicone.web.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}