{{/*
Expand the name of the chart.
*/}}
{{- define "clickhouse.name" -}}
{{- default (print .Chart.Name "-clickhouse") .Values.clickhouse.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "clickhouse.fullname" -}}
{{- if .Values.clickhouse.fullnameOverride }}
{{- .Values.clickhouse.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default (print .Chart.Name "-clickhouse") .Values.clickhouse.nameOverride }}
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
{{- define "clickhouse.selectorLabels" -}}
app.kubernetes.io/name: {{ include "clickhouse.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}