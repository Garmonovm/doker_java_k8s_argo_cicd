# Docker Java K8s Argo CI/CD

This repository is created for lab purposes to demonstrate how ArgoCD can automatically deploy and test Docker images.

## How It Works
ArgoCD monitors the repository for changes and automatically refreshes the Docker image by rebuilding and deploying it to the Kubernetes cluster.

## Helm Chart Integration
This lab uses Helm charts to define and manage the Kubernetes applications. Helm simplifies the deployment process by packaging all the Kubernetes manifests into a single chart. The chart is responsible for:
- Creating the necessary Kubernetes resources (e.g., Deployments, Services, HPA etc).
- Managing application configurations.
- Ensuring consistency across environments (development production).

## Image Renewal Process
When a new Docker image is pushed to the repository:
1. ArgoCD detects the change and triggers a sync process.
2. The Helm chart is updated with the new image tag.
3. Kubernetes resources are refreshed, and the application is redeployed with the updated image.

## NOTE Troubleshooting / Development
- Health checks are still under development.
