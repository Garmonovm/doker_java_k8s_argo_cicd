# ===========================================================================
# Java App — Production environment values
# Deployed to "prod" namespace via ArgoCD (main branch, tag trigger)
# ===========================================================================

fullnameOverride: java-app

image:
  repository: ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/java-app
  tag: "v1.0.0"    # Updated by CD pipeline on release tag
  pullPolicy: IfNotPresent

replicaCount: 2

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

ingress:
  enabled: true
  className: alb
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/healthcheck-path: /health
    alb.ingress.kubernetes.io/group.name: production
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}]'
    # alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:... # TODO: for prod  Add ACM cert for HTTPS
    # alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
    # alb.ingress.kubernetes.io/ssl-redirect: "443"
  hosts:
    - paths:
        - path: /java
          pathType: Prefix

resources:
  requests:
    cpu: 500m
    memory: 512Mi
  limits:
    cpu: "1"
    memory: 1Gi

# Java apps need more startup time (JVM warmup)
livenessProbe:
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 60
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 30
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 8
  targetCPUUtilizationPercentage: 70

env:
  - name: APP_NAME
    value: java-app
  - name: APP_VERSION
    value: "1.0.0"
  - name: JAVA_OPTS
    value: "-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC"
