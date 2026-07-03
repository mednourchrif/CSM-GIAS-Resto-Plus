# Document de Vision Projet

---

| Champ               | Détail                                     |
|---------------------|--------------------------------------------|
| **Nom du projet**   | CSM-GIAS Resto+                            |
| **Version**         | 1.0                                        |
| **Date**            | Juillet 2026                               |
| **Statut**          | En cours de développement                  |
| **Auteur**          | Stagiaire — Département Informatique       |
| **Encadrant**       | Responsable Technique / DSI                |
| **Confidentialité** | Usage interne                              |

---

## 1. Présentation du Projet

**CSM-GIAS Resto+** est une application mobile d'entreprise destinée à moderniser et à digitaliser le processus d'enregistrement des repas au sein du restaurant de la société. Déployée sur une tablette installée à l'entrée du restaurant, elle permet d'identifier automatiquement les bénéficiaires — employés, stagiaires et visiteurs — et d'enregistrer leurs consommations en temps réel, sans friction et sans support papier.

Le projet est développé dans le cadre d'un stage en ingénierie logicielle au sein de la société **CSM-GIAS**, et constitue une solution à part entière, scalable et évolutive, dont l'architecture est conçue pour accueillir un tableau de bord d'administration web dans une version future.

---

## 2. Contexte

Aujourd'hui, la gestion des repas au restaurant de l'entreprise repose sur des mécanismes manuels : registres papier, pointage verbal ou badges physiques. Ces pratiques engendrent plusieurs problèmes opérationnels :

- **Manque de traçabilité** : impossibilité de vérifier en temps réel si un employé a déjà consommé son repas du jour.
- **Risque d'abus** : absence de contrôle automatisé sur la règle d'un repas unique par personne et par jour.
- **Absence de statistiques fiables** : aucune donnée exploitable sur les habitudes de consommation, la fréquentation horaire ou la répartition par catégorie de repas.
- **Charge administrative** : génération manuelle et chronophage des rapports de fréquentation périodiques.
- **Expérience utilisateur dégradée** : files d'attente et processus d'identification lents aux heures de pointe.

Dans ce contexte, la direction informatique (DSI) a identifié le besoin d'une solution digitale robuste, sécurisée et ergonomique pour automatiser l'ensemble du cycle d'enregistrement des repas.

---

## 3. Vision

> *"Offrir à CSM-GIAS un système d'enregistrement des repas entièrement automatisé, sécurisé et sans contact, capable d'identifier chaque bénéficiaire en quelques secondes, d'appliquer les règles métier en temps réel, et de produire des données analytiques fiables pour soutenir la prise de décision administrative."*

CSM-GIAS Resto+ se positionne comme le pivot numérique du restaurant d'entreprise. À terme, la solution devra constituer le fondement d'un écosystème de gestion RH plus large, intégrant un tableau de bord web d'administration permettant la gestion centralisée des utilisateurs, des statistiques avancées et un suivi continu de l'activité restauratrice.

---

## 4. Objectifs

### 4.1 Objectifs Fonctionnels

| #  | Objectif                                                                                                         |
|----|------------------------------------------------------------------------------------------------------------------|
| F1 | Identifier les employés par **reconnaissance faciale** au moment de l'accès au restaurant.                       |
| F2 | Identifier les stagiaires par **QR Code nominatif** dont la validité est liée à la durée du stage.              |
| F3 | Identifier les visiteurs par **QR Code temporaire** généré à l'accueil et valide uniquement pour la journée.    |
| F4 | Permettre la sélection d'une **catégorie de repas** (Plat, Pizza, Sandwich) après identification.               |
| F5 | Appliquer la règle métier d'**un repas par personne et par jour**, avec rejet automatique des doublons.         |
| F6 | Restreindre l'accès au système aux **horaires d'ouverture** du restaurant (12h30 – 14h00).                      |
| F7 | Permettre l'**enrôlement biométrique** des employés par l'administration, via la caméra de la tablette.     |
| F8 | Générer des **rapports automatiques** (journaliers, hebdomadaires, mensuels) et les envoyer par email.          |

### 4.2 Objectifs Non Fonctionnels

| #   | Objectif                                                                                                                |
|-----|-------------------------------------------------------------------------------------------------------------------------|
| NF1 | **Performance** : le temps d'identification (face ou QR) ne doit pas excéder 3 secondes dans des conditions normales. |
| NF2 | **Disponibilité** : le système doit être opérationnel pendant toute la plage d'ouverture du restaurant.               |
| NF3 | **Sécurité** : toutes les communications sont sécurisées par JWT ; les données biométriques sont stockées de façon chiffrée. |
| NF4 | **Ergonomie** : l'interface doit être utilisable sans formation préalable, avec un parcours utilisateur en moins de 30 secondes. |
| NF5 | **Évolutivité** : l'architecture doit permettre l'ajout futur d'un tableau de bord web sans refonte majeure du backend. |
| NF6 | **Maintenabilité** : le code doit être modulaire, documenté et conforme aux bonnes pratiques de développement.        |

---

## 5. Parties Prenantes

| Partie prenante              | Rôle                                                                                     | Intérêt principal                                          |
|------------------------------|------------------------------------------------------------------------------------------|------------------------------------------------------------|
| **Direction Générale**       | Commanditaire du projet                                                                  | Modernisation des processus internes, image de l'entreprise |
| **DSI / Responsable IT**     | Encadrant technique, responsable de la validation et du déploiement                     | Qualité technique, sécurité, conformité                    |
| **Service RH**               | Gestionnaire des données des employés et des stagiaires                                 | Exactitude des données, gestion des accès                  |
| **Responsable du Restaurant**| Utilisateur de l'outil de reporting ; superviseur de l'accès au restaurant              | Fluidité du service, fiabilité des rapports                |
| **Stagiaire Développeur**    | Concepteur et développeur de la solution                                                 | Réalisation d'un projet complet et fonctionnel             |
| **Accueil / Sécurité**       | Génération des QR Codes visiteurs à l'accueil                                           | Simplicité du processus d'émission des codes               |

---

## 6. Utilisateurs Cibles

### 6.1 Employés Permanents
- **Profil** : personnel de l'entreprise, toutes fonctions confondues.
- **Mode d'identification** : reconnaissance faciale.
- **Contraintes** : enrôlement biométrique préalable obligatoire, effectué une seule fois par l'administration.
- **Attentes** : rapidité et fluidité de l'enregistrement du repas, sans manipulation d'aucun objet physique.

### 6.2 Stagiaires
- **Profil** : étudiants en stage au sein de l'entreprise, pour une durée limitée.
- **Mode d'identification** : QR Code nominatif.
- **Contraintes** : le QR Code est valide uniquement pendant la durée officielle du stage ; il expire automatiquement à la date de fin.
- **Attentes** : obtention rapide du QR Code à l'entrée du stage et utilisation simple au quotidien.

### 6.3 Visiteurs
- **Profil** : personnes extérieures à l'entreprise, présentes pour une visite ponctuelle.
- **Mode d'identification** : QR Code temporaire généré à l'accueil.
- **Contraintes** : le QR Code est valide uniquement pour la journée courante ; il expire automatiquement à minuit.
- **Attentes** : accès rapide et sans friction au restaurant lors de leur visite.

### 6.4 Administrateurs (Utilisateurs Indirects)
- **Profil** : DSI, responsable RH, responsable du restaurant.
- **Interaction** : gestion des inscriptions faciales, consultation des rapports et des statistiques.
- **Attentes** : données fiables, rapports automatiques, interface d'administration claire (prévue dans la version future).

---

## 7. Périmètre du Projet

### 7.1 Dans le Périmètre (In Scope — Version 1.0)

- Application mobile **React Native** déployée sur tablette (Android).
- Module d'**identification par reconnaissance faciale** pour les employés.
- Module d'**identification par QR Code** pour les stagiaires et visiteurs.
- Module de **sélection de catégorie de repas** (Plat, Pizza, Sandwich).
- **Moteur de règles métier** : unicité du repas par jour, plage horaire d'ouverture, expiration des QR Codes.
- **Interface d'enrôlement biométrique** (administration) via la caméra de la tablette.
- **Backend API REST** : API sécurisée reposant sur une architecture modulaire et une base de données relationnelle, conçue pour accompagner l'évolution future de la solution.
- **Authentification et sécurisation** des échanges via **JWT**.
- **Génération et envoi automatique** de rapports par email (journalier, hebdomadaire, mensuel).
- **Statistiques embarquées** : total des repas, répartition par catégorie, fréquentation horaire, segmentation par type d'utilisateur et par mode d'identification.

### 7.2 Hors Périmètre (Out of Scope — Version 1.0)

- Tableau de bord web d'administration *(prévu en Version 2.0)*.
- Intégration avec un système de paie ou ERP existant.
- Gestion des allergies et préférences alimentaires.
- Module de paiement ou de facturation des repas.
- Application disponible sur les smartphones personnels des utilisateurs.
- **Support multilingue partiel** : l'application est principalement en français ; les messages essentiels (accueil, erreurs, confirmation, succès) sont également disponibles en arabe et en anglais afin de garantir une meilleure accessibilité.

---

## 8. Valeur Ajoutée

### 8.1 Pour l'Entreprise

| Bénéfice                      | Description                                                                                                          |
|-------------------------------|----------------------------------------------------------------------------------------------------------------------|
| **Digitalisation complète**   | Élimination des registres papier et des processus manuels d'enregistrement des repas.                               |
| **Contrôle renforcé**         | Application automatique et infaillible de la règle d'un repas par jour par bénéficiaire.                           |
| **Gain de temps**             | Réduction significative du temps d'enregistrement à l'entrée du restaurant, réduisant les files d'attente.          |
| **Données décisionnelles**    | Production de statistiques fiables et exploitables pour optimiser la gestion du restaurant (stocks, personnels).     |
| **Conformité et auditabilité**| Traçabilité complète de toutes les consommations, consultable à tout moment via les rapports générés.               |

### 8.2 Pour les Utilisateurs

| Bénéfice                    | Description                                                                                                 |
|-----------------------------|-------------------------------------------------------------------------------------------------------------|
| **Expérience sans friction**| Identification instantanée (face ou QR), sans manipulation d'objets physiques ni saisie manuelle.          |
| **Rapidité**                | Parcours d'enregistrement complet en moins de 30 secondes.                                                  |
| **Inclusivité**             | Trois modes d'identification adaptés aux différents profils (permanents, stagiaires, visiteurs).            |

### 8.3 Valeur Technologique

- Mise en œuvre de techniques avancées de **computer vision** (reconnaissance faciale) dans un contexte métier concret.
- Architecture backend **scalable et documentée** (API REST FastAPI), prête pour l'extension web.
- Solution reproductible et déployable dans d'autres sites ou filiales du groupe.

---

## 9. Critères de Réussite

Les critères ci-dessous constituent les indicateurs clés permettant d'évaluer le succès du projet à la fin du développement et lors de la mise en production.

| # | Critère                                        | Indicateur Mesurable                                                                 |
|---|------------------------------------------------|--------------------------------------------------------------------------------------|
| 1 | **Taux de reconnaissance faciale**             | ≥ 95 % d'identifications correctes dans des conditions d'éclairage normales.        |
| 2 | **Temps d'identification**                     | ≤ 3 secondes, face ou QR Code, du déclenchement à la confirmation.                  |
| 3 | **Respect de la règle métier**                 | 0 % de doublons acceptés (un repas par personne et par jour).                       |
| 4 | **Fiabilité de la plage horaire**              | Blocage systématique des accès en dehors de la plage 12h30–14h00.                   |
| 5 | **Expiration des QR Codes**                    | 100 % des QR Codes visiteurs expirés à minuit ; stagiaires à la date de fin de stage.|
| 6 | **Génération des rapports**                    | Rapports envoyés automatiquement par email sans intervention humaine.                |
| 7 | **Disponibilité du système**                   | ≥ 99 % de disponibilité pendant les plages d'ouverture du restaurant.               |
| 8 | **Satisfaction utilisateur**                   | Retours positifs de la part des utilisateurs pilotes lors de la phase de test.       |
| 9 | **Couverture fonctionnelle**                   | 100 % des fonctionnalités définies dans le périmètre V1.0 implémentées et testées.  |
| 10| **Qualité du code**                            | Code documenté, structuré en modules, et conforme aux conventions du projet.         |
| 11| **Temps moyen d'enregistrement**              | Parcours complet (identification + validation) en moins de 10 secondes.              |
| 12| **Temps de démarrage de l'application**       | Lancement de l'application en moins de 2 secondes sur la tablette cible.             |
| 13| **Taux d'erreurs critiques**                  | 0 erreur bloquante en production.                                                    |
| 14| **Disponibilité aux heures d'ouverture**      | ≥ 99 % de disponibilité pendant la plage 12h30–14h00.                               |
| 15| **Exactitude des rapports**                   | 100 % de concordance entre les enregistrements et les données des rapports générés.  |

---

## 10. Vision Future

La version 1.0 de **CSM-GIAS Resto+** constitue la brique fondatrice d'un écosystème digital plus large autour de la gestion du restaurant d'entreprise. La feuille de route prévisionnelle s'articule comme suit :

### Version 2.0 — Tableau de Bord Web d'Administration

> Développement d'une interface web dédiée aux administrateurs, accessible depuis n'importe quel poste interne, offrant :

- **Gestion des utilisateurs** : création, modification et suppression des comptes employés et stagiaires ; gestion des enregistrements faciaux à distance.
- **Gestion des QR Codes** : génération et révocation manuelle des QR Codes visiteurs et stagiaires.
- **Tableau de bord analytique en temps réel** : visualisation graphique des statistiques de fréquentation, par jour, semaine et mois.
- **Centre de rapports** : consultation et téléchargement des rapports historiques ; configuration des destinataires des emails automatiques.
- **Gestion des paramètres** : configuration des horaires d'ouverture, des catégories de repas et des règles métier.

### Évolutions Fonctionnelles Envisagées

| Évolution                                 | Description                                                                                      |
|-------------------------------------------|--------------------------------------------------------------------------------------------------|
| **Multi-sites**                           | Extension de la solution à plusieurs restaurants ou sites de l'entreprise depuis une plateforme centralisée. |
| **Multi-tablettes**                      | Synchronisation de plusieurs tablettes afin de permettre l'utilisation simultanée du système sur plusieurs points d'accès au restaurant. |
| **Intégration RH / ERP**                  | Synchronisation automatique des données employés et stagiaires avec le système d'information RH existant. |
| **Notifications Push**                    | Alertes en temps réel pour les administrateurs (anomalie, quota, pic de fréquentation).          |
| **Module de préférences alimentaires**    | Enregistrement des préférences et restrictions alimentaires par bénéficiaire.                    |
| **Intelligence artificielle prédictive** | Prédiction de la fréquentation pour optimiser la gestion des stocks et du personnel de cuisine.  |
| **Audit et conformité**                   | Journalisation avancée des accès pour répondre aux exigences de conformité réglementaire.        |

---

## 11. Contraintes du Projet

| ID | Contrainte | Description |
|----|------------|-------------|
| C1 | Plateforme | L'application sera déployée sur une tablette Android installée à l'entrée du restaurant. |
| C2 | Identification des employés | Les employés sont identifiés uniquement par reconnaissance faciale. |
| C3 | Identification des stagiaires | Les stagiaires utilisent exclusivement un QR Code nominatif. |
| C4 | Identification des visiteurs | Les visiteurs utilisent un QR Code temporaire valable uniquement pour la journée. |
| C5 | Catégories de repas | Les catégories de repas sont fixes : Plat, Pizza et Sandwich. |
| C6 | Horaires | Les repas peuvent être enregistrés uniquement entre 12h30 et 14h00. |
| C7 | Règle métier | Une seule prise de repas est autorisée par utilisateur et par jour. |
| C8 | Langue | L'application est principalement en français ; les messages essentiels sont également disponibles en arabe et en anglais. |
| C9 | Rapports | Les rapports sont générés automatiquement et envoyés par email. |
| C10 | Évolutivité | L'architecture doit permettre l'ajout futur d'une application web d'administration. |

---

> **Note de développement** : Ce document constitue le point de départ de toute la documentation technique et fonctionnelle du projet. Il est destiné à évoluer au fur et à mesure de l'avancement du développement, en cohérence avec les documents complémentaires (cahier des charges, spécifications techniques, plan de tests).

---

*Document rédigé dans le cadre d'un stage en ingénierie logicielle — CSM-GIAS, Été 2026.*
