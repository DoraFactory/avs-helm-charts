apiVersion: v1
kind: ConfigMap
metadata:
    name: nginx-config
    labels:
        {{- include "eigenda.labels" . | nindent 4 }}
        {{- with .Values.service.labels }}
        {{- toYaml . | nindent 4 }}
        {{- end}}
data:
    default.conf.template: |
        limit_req_zone $binary_remote_addr zone=ip:10m rate=${REQUEST_LIMIT};

        server {
            listen ${NODE_RETRIEVAL_PORT};

            client_max_body_size 1M;

            http2 on;

            location / {
                limit_req zone=ip burst=${BURST_LIMIT} nodelay;
                limit_req_status 429;

                grpc_set_header X-Real-IP $remote_addr;

                grpc_pass grpc://${NODE_HOST}:${NODE_INTERNAL_RETRIEVAL_PORT};
            }
        }

