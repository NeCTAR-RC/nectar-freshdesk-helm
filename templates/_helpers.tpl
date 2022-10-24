{{/*
Expand the name of the chart.
*/}}
{{- define "nectar-freshdesk.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nectar-freshdesk.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "nectar-freshdesk.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nectar-freshdesk.labels" -}}
helm.sh/chart: {{ include "nectar-freshdesk.chart" . }}
{{ include "nectar-freshdesk.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nectar-freshdesk.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nectar-freshdesk.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "nectar-freshdesk.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nectar-freshdesk.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Vault annotations
*/}}
{{- define "nectar-freshdesk.vaultAnnotations" -}}
vault.hashicorp.com/role: "{{ .Values.vault.role }}"
vault.hashicorp.com/agent-inject: "true"
vault.hashicorp.com/agent-pre-populate-only: "true"
vault.hashicorp.com/agent-inject-status: "update"
vault.hashicorp.com/secret-volume-path-secrets.conf: /etc/nectar-freshdesk/nectar-freshdesk.conf.d
vault.hashicorp.com/agent-inject-secret-secrets.conf: "{{ .Values.vault.settings_secret }}"
vault.hashicorp.com/agent-inject-template-secrets.conf: |
  {{ print "{{- with secret \"" .Values.vault.settings_secret "\" -}}" }}
  {{ print "[DEFAULT]" }}
  {{ print "transport_url={{ .Data.data.transport_url }}" }}
  {{ print "[database]" }}
  {{ print "connection={{ .Data.data.database_connection }}" }}
  {{ print "[nectar-freshdesk]" }}
  {{ print "bot_password={{ .Data.data.bot_password }}" }}
  {{ print "[flask]" }}
  {{ print "secret_key={{ .Data.data.secret_key }}" }}
  {{ print "[service_auth]" }}
  {{ print "password={{ .Data.data.keystone_password }}" }}
  {{ print "[keystone_authtoken]" }}
  {{ print "password={{ .Data.data.keystone_password }}" }}
  {{ print "[oslo_limit]" }}
  {{ print "password={{ .Data.data.keystone_password }}" }}
  {{ print "[freshdesk]" }}
  {{ print "key={{ .Data.data.freshdesk_key }}" }}
  {{ print "{{- end -}}" }}
{{- end }}
