{{- if .Values.vmPodScrape.enabled -}}
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMPodScrape
metadata:
  name: {{ include "eigenda.fullname" . }}
spec:
  selector:
    matchLabels:
      {{- include "eigenda.selectorLabels" . | nindent 6 }}
        {{- with .Values.labels }}
        {{- toYaml . | nindent 6 }}
        {{- end}}
  podMetricsEndpoints:
    - port: metrics
      scheme: http
{{- end }}
