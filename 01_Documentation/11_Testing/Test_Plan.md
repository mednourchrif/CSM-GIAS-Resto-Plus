# Plan de Test — Test Plan

---

## 📋 Portée du Plan de Test
Ce document détaille les ressources, l'environnement de test, et le planning d'exécution de la campagne de tests pour le projet **CSM-GIAS Resto+** (v1.0).

---

## 🖥️ Environnement de Test (QA)

| Élément | Version / Modèle | Rôle |
|---|---|---|
| **Matériel Cible** | Tablette Android 10 pouces, Android 10+ | Support de déploiement de l'application mobile finale. |
| **Serveur Backend (Staging)** | Docker sur serveur local de l'entreprise | Hébergement de l'API FastAPI et traitement des visages. |
| **Base de Données (Staging)** | MySQL 8.0 | Stockage de test pour l'historique et les profils. |
| **Émulateur Android** | Android Virtual Device (AVD) | Tests de l'interface utilisateur et de la mise en page. |

---

## 📅 Calendrier d'Exécution des Tests (Sprint 4)

- **Phase 1 : Tests Unitaires et Intégration Continue** (17 Août - 19 Août 2026)
  - Exécution des suites de tests unitaires par les développeurs.
  - Validation de la couverture minimale de 80%.
- **Phase 2 : Campagne de Tests Système & Fonctionnels** (20 Août - 22 Août 2026)
  - Exécution manuelle et automatisée des cas de tests sur la tablette cible.
- **Phase 3 : Tests de Charge & Sécurité** (23 Août - 24 Août 2026)
  - Simulations de charge et tests de vulnérabilités (OWASP).
- **Phase 4 : Validation UAT & Signature** (25 Août - 26 Août 2026)
  - Test en conditions réelles avec un groupe pilote au restaurant.
