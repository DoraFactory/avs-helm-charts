apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ include "eigenda.fullname" . }}
  labels:
    {{- include "eigenda.labels" . | nindent 4 }}
    {{- with .Values.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end}}
  annotations:
    {{- with .Values.annotations }}
    {{- toYaml . | nindent 4 }}
    {{- end}}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "eigenda.selectorLabels" . | nindent 6 }}
        {{- with .Values.labels }}
        {{- toYaml . | nindent 6 }}
        {{- end}}
  template:
    metadata:
      annotations:
      {{- with .Values.podAnnotations }}
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.annotations }}
        {{- toYaml . | nindent 8 }}
      {{- end}}
      labels:
        app: {{ include "eigenda.fullname" . }}
        {{- include "eigenda.selectorLabels" . | nindent 8 }}
        {{- with .Values.labels }}
        {{- toYaml . | nindent 8 }}
        {{- end}}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ .Values.serviceAccount.name | default (include "eigenda.fullname" .) }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
      - name: reverse-proxy
        image: nginx:latest
        ports:
        - name: retrieval
          containerPort: {{ .Values.reverseProxy.nodeRetrievalPort }}
          protocol: TCP
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/templates/default.conf.template
          subPath: default.conf.template
        envFrom:
        - configMapRef:
            name: {{ include "eigenda.fullname" . }}-config

      - name: node
        {{- with .Values.node.command }}
        command:
        {{- toYaml . | nindent 12 }}
        {{- end }}
        {{- with .Values.node.args }}
        args:
        {{- toYaml . | nindent 12 }}
        {{- end }}
        securityContext:
          {{- toYaml .Values.securityContext | nindent 12 }}
        image: "{{ .Values.node.image.repository }}:{{ .Values.node.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ .Values.node.image.pullPolicy }}
        ports:
        - name: in-retrieval
          containerPort: {{ .Values.node.internalRetrievalPort }}
          protocol: TCP
        - name: api
          containerPort: {{ .Values.node.nodeApiPort }}
          protocol: TCP
        - name: dispersal
          containerPort: {{ .Values.node.dispersalPort }}
          protocol: TCP
        - name: metrics
          containerPort: {{ .Values.node.metricsPort }}
          protocol: TCP
        {{- if .Values.lifecycleHooks }}
        lifecycle:
        {{- toYaml .Values.node.lifecycleHooks | nindent 12 }}
        {{- end }}
        {{- if .Values.node.livenessProbe }}
        livenessProbe:
          {{- toYaml .Values.node.livenessProbe | nindent 12 }}
        {{- end }}
        {{- if .Values.node.readinessProbe }}
        readinessProbe:
          {{- toYaml .Values.node.readinessProbe | nindent 12 }}
        {{- end }}
        resources:
          {{- toYaml .Values.node.resources | nindent 12 }}
        volumeMounts:
        {{- with .Values.node.volumeMounts }}
        {{- toYaml . | nindent 12 }}
        {{- end }}
        env:
          {{- toYaml .Values.node.env | nindent 12 }}
        envFrom:
        - configMapRef:
            name: {{ include "eigenda.fullname" . }}-config

      volumes:
          {{- with .Values.volumes }}
          {{- toYaml . | nindent 8 }}
          {{- end }}
        - name: nginx-config
          configMap:
            name: nginx-config
            items:
            - key: default.conf.template
              path: default.conf.template

      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
