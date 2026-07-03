# Spécification des Exigences Logicielles — Software Requirements Specification (SRS)

---

## 1. Introduction
Ce document constitue la **Spécification des Exigences Logicielles (SRS)** pour la solution **CSM-GIAS Resto+**, rédigé en conformité avec la norme **IEEE 29148**. Il sert de référence contractuelle pour la validation technique et fonctionnelle du produit final.

---

## 2. Description Générale du Système

### 2.1 Perspective du Produit
CSM-GIAS Resto+ est un système indépendant composé d'une application mobile Android (tablette) faisant office de terminal de saisie et d'identification des visages/QR Codes, communiquant via HTTPS avec un serveur backend FastAPI hébergeant la logique métier, le moteur de reconnaissance faciale local et la base de données relationnelle MySQL.

### 2.2 Contraintes du Système
- Exécution de l'application sur tablette Android uniquement.
- Pas de dépendances Cloud externes pour la reconnaissance faciale (traitement Edge/On-Premise local).
- Restriction horaire rigoureuse (12h30 - 14h00).

---

## 3. Exigences Détaillées
L'ensemble des exigences détaillées est structuré et traçable à travers les documents associés :
- Les **Exigences Fonctionnelles (FR)** sont spécifiées dans le fichier [03_Exigences_Fonctionnelles.md](file:///C:/Users/Administrator/Desktop/CSM-GIAS-Resto-Plus/01_Documentation/03_Exigences_Fonctionnelles.md).
- Les **Exigences Non Fonctionnelles (NFR)** sont spécifiées dans le fichier [04_Exigences_Non_Fonctionnelles.md](file:///C:/Users/Administrator/Desktop/CSM-GIAS-Resto-Plus/01_Documentation/04_Exigences_Non_Fonctionnelles.md).
- Les **Règles Métier (BR)** sont spécifiées dans le fichier [02_Regles_Metier.md](file:///C:/Users/Administrator/Desktop/CSM-GIAS-Resto-Plus/01_Documentation/02_Regles_Metier.md).
