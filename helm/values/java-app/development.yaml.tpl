# Java App — Development environment values
# Deployed to "development" namespace via ArgoCD (develop branch)
# tmpl to hide the sensetive parameters for public repo.

fullnameOverride: java-app

image:
  repository: "${ECR_REPOSITORY}/java-app"
  tag: "sha-latest"    # Updated automatically by CI pipeline
  pullPolicy: Always

replicaCount: 1

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
    alb.ingress.kubernetes.io/group.name: ingress-shared-alb
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}]'
  hosts:
    - paths:
        - path: /java-dev
          pathType: Prefix

resources:
  requests:
    cpu: 200m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi

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
  enabled: false

env:
  - name: APP_NAME
    value: java-app
  - name: APP_VERSION
    value: "1.0.0"
  - name: JAVA_OPTS
    value: "-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC"
