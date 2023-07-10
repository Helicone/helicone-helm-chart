{{/*
Expand the name of the chart.
*/}}
{{- define "helicone.clickhouse.name" -}}
{{- default (print .Chart.Name "-helicone-clickhouse") .Values.helicone.clickhouse.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "helicone.clickhouse.fullname" -}}
{{- if .Values.helicone.clickhouse.fullnameOverride }}
{{- .Values.helicone.clickhouse.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default (print .Chart.Name "-helicone-clickhouse") .Values.helicone.clickhouse.nameOverride }}
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
{{- define "helicone.clickhouse.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helicone.clickhouse.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}