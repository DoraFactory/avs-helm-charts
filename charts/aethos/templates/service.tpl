apiVersion: v1
kind: Service
metadata:
  name: {{ include "aethos.fullname" . }}
  {{- with .Values.service.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "aethos.labels" . | nindent 4 }}
    {{- with .Values.service.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end}}
spec:
  type: {{ .Values.service.type }}
  loadBalancerIP: {{ .Values.service.loadBalancerIP }}
  ports:
  {{- range .Values.service.ports }}
  - name: {{ .name }}
    port: {{ .port }}
    protocol: {{ .protocol }}
    targetPort: {{ .targetPort }}
  {{- end }}
  selector:
    {{- with .Values.labels }}
      {{- toYaml . | nindent 4 }}
    {{- end}}
    app: {{ include "aethos.fullname" . }}
