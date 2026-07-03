# Configuration des Environnements — Environment

Ce document décrit les variables d'environnement nécessaires pour configurer et exécuter le backend FastAPI et l'application mobile React Native de manière isolée.

---

## ⚙️ Variables d'Environnement Backend (Fichier `.env`)

### Configuration Générale du Serveur
- `PROJECT_NAME` : Nom du projet (ex: `CSM-GIAS Resto+`).
- `ENVIRONMENT` : Type d'environnement (`development`, `staging`, `production`).
- `DEBUG` : Activer ou désactiver les modes verbeux de log (`True` ou `False`).

### Base de Données
- `DB_HOST` : Adresse IP ou nom d'hôte du serveur MySQL.
- `DB_PORT` : Port de connexion MySQL (par défaut `3306`).
- `DB_USER` : Nom de l'utilisateur de la base de données.
- `DB_PASSWORD` : Mot de passe sécurisé associé à l'utilisateur de la BDD.
- `DB_NAME` : Nom de la base de données cible (ex: `gias_resto_db`).

### Sécurité & Authentification JWT
- `JWT_SECRET_KEY` : Clé secrète de signature des jetons d'accès JWT.
- `JWT_ALGORITHM` : Algorithme de signature (par défaut `HS256`).
- `ACCESS_TOKEN_EXPIRE_MINUTES` : Durée de validité des jetons d'administration en minutes (par défaut `60`).

### Serveur de Messagerie SMTP (Reporting)
- `SMTP_HOST` : Serveur d'envoi d'emails SMTP d'entreprise.
- `SMTP_PORT` : Port du serveur SMTP (ex: `587` ou `465`).
- `SMTP_USERNAME` : Identifiant de l'expéditeur de messagerie.
- `SMTP_PASSWORD` : Mot de passe d'accès au serveur de messagerie.
- `SMTP_SENDER_EMAIL` : Adresse email d'émission des rapports de restauration.
- `REPORT_RECIPIENTS` : Liste des adresses emails destinataires séparées par des virgules.
