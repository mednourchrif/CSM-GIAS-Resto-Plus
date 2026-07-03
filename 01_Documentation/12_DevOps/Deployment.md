# Guide de Déploiement — Deployment

Ce guide détaille les étapes d'installation et de mise en production de la solution **CSM-GIAS Resto+**.

---

## 🏗️ Architecture du Déploiement Local

```text
               +----------------------------------------+
               |            Réseau Local                |
               |                                        |
+----------+   |    +---------------+  Secured (JWT)    |
| Tablette |   |    |    Reverse    | +------------+    |
|  Android |=======>|     Proxy     | | API        |    |
| (Client) |   |    |    (NGINX)    | | (FastAPI)  |    |
+----------+   |    +---------------+ +------------+    |
               |                            ||          |
               |                            \/          |
               |                      +------------+    |
               |                      | Base BDD   |    |
               |                      | (MySQL 8)  |    |
               |                      +------------+    |
               +----------------------------------------+
```

---

## 🛠️ Instructions pour le Déploiement du Backend

### 1. Prérequis sur le Serveur Hôte
- Système d'exploitation Linux (Ubuntu Server 20.04 LTS ou supérieur).
- Docker et Docker Compose installés et configurés.
- Accès réseau configuré pour le port 80/443 (Reverse Proxy).

### 2. Étapes de Déploiement
1. Cloner la branche de production du dépôt Git sur le serveur.
2. Configurer le fichier `.env` avec les secrets de production (mots de passe BDD, clés de signature JWT).
3. Lancer le déploiement via Docker Compose :
   ```bash
   docker-compose -f docker-compose.prod.yml up -d --build
   ```
4. Vérifier que l'API répond correctement sur l'endpoint `/health`.
