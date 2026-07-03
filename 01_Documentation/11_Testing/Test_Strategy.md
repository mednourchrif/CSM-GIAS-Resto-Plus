# Stratégie de Tests — Test Strategy

---

## 🎯 Objectifs de la Stratégie de Tests
La présente stratégie de tests vise à garantir que la solution **CSM-GIAS Resto+** est conforme à l'intégralité des spécifications fonctionnelles (FR) et non fonctionnelles (NFR). Elle structure l'approche de validation pour l'équipe d'assurance qualité (QA).

---

## 🔬 Types de Tests Planifiés

### 1. Tests Unitaires (TU)
- **Objectif** : Valider de manière isolée le comportement des fonctions logiques de l'API (FastAPI) et des composants de l'application mobile (React Native).
- **Responsables** : Développeurs.
- **Outils** : `pytest` pour le backend Python, `Jest` pour le frontend mobile.
- **Objectif de couverture** : Minimum 80% du code métier backend.

### 2. Tests d'Intégration (TI)
- **Objectif** : Vérifier la bonne communication entre l'application mobile, le serveur API et la base de données MySQL.
- **Responsables** : Développeurs & Testeurs.
- **Outils** : `pytest-mock` et environnements de staging.

### 3. Tests de Charge & Performance
- **Objectif** : Valider que le système peut absorber le flux d'identification à l'heure d'ouverture du restaurant (12h30).
- **Responsables** : Testeurs & DevOps.
- **Outils** : `Locust` ou `JMeter`.
- **Cible** : Traitement de 100 requêtes d'identification par seconde avec un temps de réponse inférieur à 500 ms.

### 4. Tests d'Acceptation Utilisateur (UAT)
- **Objectif** : Valider le parcours utilisateur complet d'identification et de sélection des repas avec les utilisateurs pilotes (Employés, Stagiaires, Visiteurs).
- **Responsables** : Chef de projet et représentants métier de l'entreprise.

---

## 🛑 Critères d'Arrêt et de Suspension
- **Suspension** : Si une anomalie de niveau bloqueur (ex: plantage systématique au démarrage) empêche l'exécution de plus de 30% des cas de tests prévus.
- **Reprise** : Livraison d'un correctif fonctionnel validé par les développeurs.
