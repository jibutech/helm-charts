{{/*
Return the proper image name
*/}}
{{- define "controllerManager.kubeRbacProxy.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.controllerManager.kubeRbacProxy.image "global" .Values.global) }}
{{- end -}}

{{- define "controllerManager.kubeeyeApiserver.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.controllerManager.kubeeyeApiserver.image "global" .Values.global) }}
{{- end -}}

{{- define "controllerManager.manager.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.controllerManager.manager.image "global" .Values.global) }}
{{- end -}}

{{- define "config.job.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.config.job.image "global" .Values.global) }}
{{- end -}}

{{- define "common.images.image" -}}
{{- $registryName := .global.imageRegistry -}}
{{- $repositoryName := .imageRoot.repository -}}
{{- $separator := ":" -}}
{{- $termination := .global.tag | toString -}}
{{- if .imageRoot.registry }}
    {{- $registryName = .imageRoot.registry -}}
{{- end -}}
{{- if .imageRoot.tag }}
    {{- $termination = .imageRoot.tag | toString -}}
{{- end -}}
{{- if .imageRoot.digest }}
    {{- $separator = "@" -}}
    {{- $termination = .imageRoot.digest | toString -}}
{{- end -}}
{{- printf "%s/%s%s%s" $registryName $repositoryName $separator $termination -}}
{{- end -}}


{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "backend.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "pullSecrets" .Values.imagePullSecrets "global" .Values.global) -}}
{{- end -}}

{{- define "common.images.pullSecrets" -}}
  {{- $pullSecrets := list }}

  {{- if .global }}
    {{- range .global.imagePullSecrets -}}
      {{- $pullSecrets = append $pullSecrets . -}}
    {{- end -}}
  {{- end -}}

  {{- range .pullSecrets -}}
    {{- $pullSecrets = append $pullSecrets . -}}
  {{- end -}}

  {{- if (not (empty $pullSecrets)) }}
imagePullSecrets:
    {{- range $pullSecrets }}
  - name: {{ . }}
    {{- end }}
  {{- end }}
{{- end -}}
