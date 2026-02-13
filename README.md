# DevOps Assessment - Edison Chinlle

Este repositorio contiene el código desarrollado para el test de skills de TCS para el puesto DevOps Engineer de Edison Chinlle.

## Manual Completo

Ver archivo: `MANUAL.txt`

El manual incluye:

- Instrucciones paso a paso para todas las pruebas
- Requisitos previos y verificación de instalaciones
- Pruebas locales con Python
- Pruebas con Docker Compose
- Pruebas con Kubernetes (Minikube)
- Pruebas con Terraform
- Validación del Pipeline CI/CD
- Troubleshooting completo
- Resultados esperados para cada prueba
- Checklist de validación final

## Herramientas de Testing

- `test_endpoint.sh` — Script automatizado de testing
- `Makefile` — Comandos de automatización

### Uso del Script

```bash
chmod +x test_endpoint.sh
./test_endpoint.sh
```

### Uso del Makefile

```bash
make help        # Ver todos los comandos
make test        # Ejecutar tests
make docker-up   # Levantar Docker
make k8s-deploy  # Desplegar en K8s
```

## Validación Rápida

Para verificar que todo funciona correctamente:

### Tests Unitarios

```bash
make test
```

### Docker Compose

```bash
make docker-up
./test_endpoint.sh
make docker-down
```

### Kubernetes

```bash
make k8s-deploy
make k8s-status
```

## Créditos

**Autor:** Edison Chinlle

Email: chinllesteven8@gmail.com

GitHub: @Eschinlle
