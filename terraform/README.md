# Terraform Infrastructure as Code

Infrastructure as Code (IaC) for the DevOps Microservice using Terraform and Kubernetes.

## Prerequisites

- Terraform >= 1.0
- Kubernetes cluster (minikube, kind, or cloud provider)
- kubectl configured with cluster access
- Docker image built and available

## Quick Start

### 1. Initialize Terraform

```bash
cd terraform/
terraform init
```

### 2. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 3. Plan the Infrastructure

```bash
terraform plan
```

### 4. Apply the Infrastructure

```bash
terraform apply
```

### 5. Verify Deployment

```bash
terraform show

kubectl get all -n devops
kubectl get configmap -n devops
kubectl get secret -n devops
kubectl get ingress -n devops
kubectl get hpa -n devops
```

## Resources

This Terraform configuration creates:

- **Namespace**: `devops`
- **ConfigMap**: Application configuration
- **Secret**: JWT secret (sensitive data)
- **Deployment**: 2+ replicas with rolling updates
- **Service**: ClusterIP service on port 80
- **Ingress**: Nginx ingress for external access
- **HPA**: Auto-scaling

## Configuration

### Variables

All variables are defined in `variables.tf` with sensible defaults.

### Outputs

After applying, Terraform outputs useful information:

```bash
terraform output
```

## Update Infrastructure

To update the infrastructure:

```bash
terraform plan
terraform apply
```