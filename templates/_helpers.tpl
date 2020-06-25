{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "rctf.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rctf.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rctf.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "rctf.labels" -}}
app.kubernetes.io/name: {{ include "rctf.name" . }}
helm.sh/chart: {{ include "rctf.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Token key
*/}}
{{- define "rctf.tokenKey" -}}
{{- if .Values.tokenKey -}}
    {{- .Values.tokenKey -}}
{{- else -}}
    {{- randAlphaNum 43 -}}=
{{- end -}}
{{- end -}}

{{/*
rCTF shared environment variables
*/}}
{{- define "rctf.envVars" -}}
- name: RCTF_TOKEN_KEY
  valueFrom:
    secretKeyRef:
      name: {{ template "rctf.fullname" . }}-token-key
      key: token-key
- name: RCTF_REDIS_HOST
  value: {{ required "redis.host is required" .Values.redis.host | quote }}
- name: RCTF_REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
    {{- if .Values.redis.passwordSecret }}
      name: {{ .Values.redis.passwordSecret | quote }}
      key: {{ required "redis.passwordSecretKey is required" .Values.redis.passwordSecretKey | quote }}
    {{- else }}
      name: {{ template "rctf.fullname" . }}-redis
      key: redis-password
    {{- end }}
- name: RCTF_DATABASE_HOST
  value: {{ required "postgres.host is required" .Values.postgres.host | quote }}
{{- with .Values.postgres.port }}
- name: RCTF_DATABASE_PORT
  value: {{ . | quote }}
{{- end }}
- name: RCTF_DATABASE_USERNAME
  value: {{ required "postgres.user is required" .Values.postgres.user | quote }}
- name: RCTF_DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
    {{- if .Values.postgres.passwordSecret }}
      name: {{ .Values.postgres.passwordSecret | quote }}
      key: {{ required "postgres.passwordSecretKey is required" .Values.postgres.passwordSecretKey | quote }}
    {{- else }}
      name: {{ template "rctf.fullname" . }}-postgres
      key: postgresql-postgres-password
    {{- end }}
- name: RCTF_DATABASE_DATABASE
  value: {{ required "postgres.database is required" .Values.postgres.database | quote }}
{{- with .Values.email }}
{{- with .smtpProvider }}
- name: RCTF_SMTP_URL
  valueFrom:
    secretKeyRef:
    {{- if .urlSecret }}
      name: {{ .urlSecret | quote }}
      key: {{ required "email.smtpProvider.urlSecretKey is required" .urlSecretKey | quote }}
    {{- else }}
      name: {{ template "rctf.fullname" $ }}-smtp
      key: url
    {{- end }}
{{- end }}{{/* with .smtpProvider */}}
{{- with .sesProvider }}
- name: RCTF_SES_KEY_SECRET
  valueFrom:
    secretKeyRef:
    {{- if .credentialsSecret }}
      name: {{ .credentialsSecret | quote }}
      key: {{ required "email.sesProvider.secretAwsKeySecretKey is required" .secretAwsKeySecretKey | quote }}
    {{- else }}
      name: {{ template "rctf.fullname" $ }}-ses
      key: aws-key-secret
    {{- end }}
- name: RCTF_SES_KEY_ID
{{- if and .credentialsSecret (not .secretAwsKeyIdKey) }}
  value: {{ required "email.sesProvider.awsKeyId is required" .awsKeyId | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
    {{- if .credentialsSecret }}
      name: {{ .credentialsSecret | quote }}
      key: {{ .secretAwsKeyIdKey | quote }}
    {{- else }}
      name: {{ template "rctf.fullname" $ }}-ses
      key: aws-key-id
    {{- end }}
{{- end }}{{/* if */}}
- name: RCTF_SES_REGION
{{- if and .credentialsSecret (not .secretAwsRegionKey) }}
  value: {{ required "email.sesProvider.awsRegion is required" .awsRegion | quote }}
{{- else }}
  valueFrom:
    secretKeyRef:
    {{- if .credentialsSecret }}
      name: {{ .credentialsSecret | quote }}
      key: {{ .secretAwsRegionKey | quote }}
    {{- else }}
      name: {{ template "rctf.fullname" $ }}-ses
      key: aws-region
    {{- end }}
{{- end }}{{/* if */}}
{{- end }}{{/* with .sesProvider */}}
{{- end }}{{/* with .Values.email */}}
{{- if .Values.ctftime.clientId }}
- name: RCTF_CTFTIME_CLIENT_ID
  value: {{ .Values.ctftime.clientId | quote }}
- name: RCTF_CTFTIME_CLIENT_SECRET
  value: {{ required "ctftime.clientSecret is required" .Values.ctftime.clientSecret | quote }}
{{- end }}
{{- if .Values.gcs }}
- name: RCTF_GCS_CREDENTIALS
  {{- if .Values.gcs.credentials }}
  valueFrom:
    secretKeyRef:
      name: {{ template "rctf.fullname" . }}-gcs-credentials
      key: credentials-json
  {{- else }}
  value: "{}"
  {{- end }}
- name: RCTF_GCS_BUCKET
  value: {{ required "gcs.bucket is required" .Values.gcs.bucket | quote }}
{{- end }}
{{- end -}}
