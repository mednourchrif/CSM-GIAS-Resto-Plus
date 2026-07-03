# Cahier des Charges Fonctionnel — CSM-GIAS Resto+

---

## 1. Contexte et Objectifs du Projet
Le présent document formalise le besoin de digitalisation de l'enregistrement des repas au sein du restaurant de la société **CSM-GIAS**. L'objectif est de supprimer les registres papier et de mettre en place un système d'identification rapide (reconnaissance faciale et QR Codes) sur tablette Android à l'entrée du restaurant.

---

## 2. Description Fonctionnelle du Besoin

### 2.1 Les Profils Utilisateurs
- **Employés** : Identification sans contact via reconnaissance faciale uniquement.
- **Stagiaires** : QR Code nominatif lié aux dates réelles du stage.
- **Visiteurs** : QR Code temporaire généré le jour de la visite à l'accueil de l'entreprise.

### 2.2 Règle d'Unicité et Catégories de Repas
- Un seul repas autorisé par personne et par jour.
- Catégories de repas fixes : Plat, Pizza, Sandwich.
- Enregistrement restreint à la plage horaire stricte de 12h30 à 14h00.

### 2.3 Reporting & Statistiques
- Génération automatique de rapports (journaliers, hebdomadaires, mensuels) envoyés par email aux responsables de l'administration et des ressources humaines.

---

## 3. Périmètre du Projet (Version 1.0)
- **Dans le périmètre** : L'application mobile Android (tablette), l'API backend FastAPI, la base de données MySQL et le module d'envoi automatique de rapports par email.
- **Hors périmètre** : Le tableau de bord d'administration sur navigateur web (prévu en V2.0), le paiement des repas et l'intégration avec d'autres systèmes RH.
