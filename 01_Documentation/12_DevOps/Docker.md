# Conteneurisation de la Solution — Docker

Ce document décrit la configuration Docker requise pour exécuter l'API backend FastAPI de manière isolée et reproductible.

---

## 🐋 Structure du Fichier Dockerfile Backend (FastAPI)
L'image doit être construite en mode multi-stage pour minimiser la taille du conteneur final et exclure les dépendances de compilation de l'environnement de production.

```dockerfile
# Stage 1: Build dependencies
FROM python:3.11-slim AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Runtime image
FROM python:3.11-slim AS runner

WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY ./app ./app

ENV PATH=/root/.local/bin:$PATH
EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## 🎛️ Orchestration Locale avec Docker Compose
Pour exécuter la base de données MySQL et le serveur API en local, un fichier `docker-compose.yml` est fourni à la racine de la partie backend.

```yaml
version: '3.8'

services:
  database:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root_secure_password
      MYSQL_DATABASE: gias_resto_db
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql

  backend:
    build:
      context: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=mysql+pymysql://root:root_secure_password@database/gias_resto_db
    depends_on:
      - database

volumes:
  mysql_data:
```
