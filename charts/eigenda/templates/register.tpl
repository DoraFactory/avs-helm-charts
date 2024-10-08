{{- if .Values.register.enabled }}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "eigenda.fullname" . }}-register-job
  labels:
    {{- include "eigendaRegister.labels" . | nindent 4 }}
    {{- with .Values.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end}}
  annotations:
    "helm.sh/hook": "post-install"
  {{- with .Values.annotations }}
    {{- toYaml . | nindent 4 }}
  {{- end}}
spec:
  template:
    metadata:
      labels:
        {{- include "eigendaRegister.labels" . | nindent 8 }}
    spec:
      containers:
        - name: register
          image: "{{ .Values.register.image.repository }}:{{ .Values.register.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.register.image.pullPolicy }}
          args:
            {{- toYaml .Values.register.args | nindent 12 }}
          env:
            {{- toYaml .Values.register.env | nindent 12 }}
          volumeMounts:
            {{- toYaml .Values.register.volumeMounts | nindent 12 }}
            - name: config
              mountPath: /app/config/operator.yaml
              subPath: operator.yaml
      restartPolicy: Never
      volumes:
        {{- toYaml .Values.volumes | nindent 8 }}
        - name: config
          configMap:
            name: {{ include "eigenda.fullname" . }}-config
  backoffLimit: 2
{{- end }}
