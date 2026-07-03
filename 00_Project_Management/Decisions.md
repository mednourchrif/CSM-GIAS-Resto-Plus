# Registre des Décisions Projet — Decisions

Ce registre consigne les décisions structurantes prises au cours du cycle de vie du projet.

---

## Décisions Prises

### DEC-001 : Choix des technologies de base
- **Date** : Juin 2026
- **Décision** : Utiliser **React Native** pour la partie mobile, **FastAPI** (Python) pour le backend, et **MySQL** pour la persistance des données.
- **Raison** : React Native permet un développement robuste pour tablette Android tout en offrant la possibilité de porter l'application vers iOS à l'avenir. FastAPI offre des performances optimales, une validation automatique via Pydantic et une documentation Swagger native. MySQL est le SGBDR standard de l'entreprise.
- **Statut** : Approuvé

### DEC-002 : Stockage chiffré des empreintes faciales vectorielles
- **Date** : Juin 2026
- **Décision** : Aucun stockage de photos en clair sur le serveur ou sur la tablette. Seuls les vecteurs numériques (Face Embeddings) sont stockés chiffrés en base de données.
- **Raison** : Respecter les réglementations de protection des données (RGPD) et assurer la sécurité des données biométriques des employés.
- **Statut** : Approuvé

### DEC-003 : Exclusion du tableau de bord web d'administration de la V1.0
- **Date** : Juillet 2026
- **Décision** : L'interface web d'administration est officiellement planifiée pour la version 2.0. En version 1.0, les actions de gestion (création d'employés, enrôlement) sont supportées par une section protégée au sein de l'application mobile.
- **Raison** : Focus technique sur le cœur du système (reconnaissance faciale, QR code et reporting) pour garantir un déploiement stable du MVP à la fin du stage.
- **Statut** : Approuvé
