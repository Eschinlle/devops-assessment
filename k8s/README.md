# Kubernetes Manifests

Manifiestos de Kubernetes para el despliegue del microservicio DevOps - Edison Chinlle.

## Recursos

- **namespace.yaml**: Namespace `devops`
- **configmap.yaml**: ConfigMap y Secrets
- **deployment.yaml**: Deployment con 2 réplicas + Service
- **ingress.yaml**: Ingress para load balancing
- **hpa.yaml**: HorizontalPodAutoscaler (escalado dinámico)

## Deployment

### Aplicar todos los manifiestos

```bash
kubectl apply -f k8s/
```

### Aplicar uno por uno

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/ingress.yaml
kubectl apply -f k8s/hpa.yaml
```

## Verificación

```bash
kubectl get all -n devops

kubectl get pods -n devops

kubectl get svc -n devops

kubectl get ingress -n devops

kubectl get hpa -n devops

kubectl logs -f deployment/devops-microservice -n devops
```