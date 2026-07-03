# Supervision et Alerting — Monitoring

Ce document décrit l'architecture de supervision mise en place pour surveiller en temps réel la santé technique et fonctionnelle du projet.

---

## 📊 Métriques à Surveiller (KPIs Techniques)

### 1. Métriques Système (Serveur Hôte)
- **Taux d'utilisation CPU** : Alerte si > 85% pendant plus de 5 minutes.
- **Utilisation RAM** : Alerte si > 90%.
- **Espace Disque Restant** : Alerte si < 15% d'espace libre (risque lié aux bases de données et aux fichiers de logs).

### 2. Métriques API Backend (FastAPI)
- **Temps de Réponse Moyen** : Alerte si le temps de réponse moyen de l'authentification passe au-dessus de 1,5 seconde.
- **Taux d'erreurs (HTTP 5xx)** : Alerte immédiate si le taux d'erreur dépasse 1% sur une période glissante de 10 minutes.
- **Requêtes par Seconde (RPS)** : Analyse de la courbe de fréquentation.

---

## 🛠️ Outils & Intégrations de Supervision
- **Collecte de logs** : Les logs de FastAPI et de MySQL sont centralisés et collectés de manière structurée via un agent de logs d'entreprise.
- **Visualisation** : Un tableau de bord technique est configuré pour visualiser les métriques de base de données, l'utilisation mémoire et les requêtes HTTP.
- **Alerte en temps réel** : Les pannes ou dépassements de seuils critiques (ex: base MySQL injoignable, API inactive à 12h30) déclenchent automatiquement un email d'alerte prioritaire envoyé à l'équipe technique de la DSI.
