# DevOps Microservice - Banco Pichincha Technical Assessment - Edison Chinlle

Microservicio REST desarrollado con FastAPI para el assessment técnico de DevOps.

## Requisitos

- Python 3.11+
- FastAPI
- Docker
- Kubernetes
- Terraform

## Objetivo

Crear un microservicio REST con:
- Endpoint `/DevOps` (POST)
- Autenticación con API Key y JWT
- Containerización con Docker
- Orquestación con Kubernetes
- CI/CD automatizado
- Infrastructure as Code

## Instalación

# Clonar repositorio
git clone https://github.com/Eschinlle/devops-assessment.git
cd devops-assessment

# Crear entorno virtual
python -m venv venv
source venv/bin/activate  # Linux/Mac

# Instalar dependencias
pip install -r requirements.txt

# Ejecutar aplicación
uvicorn app.main:app --reload

## Autor

**Eschinlle**
- GitHub: [@Eschinlle](https://github.com/Eschinlle)