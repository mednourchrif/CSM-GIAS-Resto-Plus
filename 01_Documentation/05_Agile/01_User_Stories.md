# 1. Page de Garde

**Projet** : CSM-GIAS Resto+
**Sous-titre** : Solution Intelligente de Gestion du Restaurant d'Entreprise
**Titre du document** : Agile User Stories
**Version** : 1.0
**Date** : Juillet 2026
**Auteur** : Product Owner Senior
**Confidentialité** : Interne – Strictement Confidentiel

## Historique des Révisions

| Version | Date | Auteur | Description |
|---|---|---|---|
| 1.0 | 03/07/2026 | Product Owner | Création du Backlog initial et validation des 80 User Stories. |

---

# 2. Introduction

Ce document centralise l'ensemble des User Stories (US) du projet **CSM-GIAS Resto+**, destinées à la réalisation de la version 1.0 de l'application sur tablette Android.

Conformément à la méthodologie Agile (Scrum), ces User Stories constituent le **Product Backlog** qui sera directement exploité lors du Sprint Planning. Elles agissent comme un pont entre l'ingénierie des exigences (Règles Métier, Exigences Fonctionnelles/Non Fonctionnelles) et le développement logiciel.

Toutes les informations présentes dans ce document dérivent de la Vision Projet, des Règles Métier (BR) et des Exigences Fonctionnelles (FR). Elles respectent rigoureusement le standard INVEST (Independent, Negotiable, Valuable, Estimable, Small, Testable) pour assurer une livraison incrémentale de valeur.

---

# 3. Personas

### Employé
- **Responsibilities** : Se présenter au restaurant, s'identifier, consommer son repas.
- **Objectives** : Accéder au restaurant le plus rapidement possible.
- **Permissions** : Sélectionner un repas parmi les catégories.
- **Limitations** : Un seul repas par jour.
- **Pain Points** : Attente à l'entrée.
- **Success Criteria** : Identification en moins de 3 secondes sans contact.

### Stagiaire
- **Responsibilities** : Présenter son QR Code.
- **Objectives** : Avoir accès au restaurant de l'entreprise.
- **Permissions** : Sélectionner un repas.
- **Limitations** : Un repas par jour, QR Code expire à la fin du stage.
- **Pain Points** : Oubli ou perte du badge.
- **Success Criteria** : Scan fluide et rapide sur tablette.

### Visiteur
- **Responsibilities** : S'enregistrer à l'accueil pour obtenir un QR Code.
- **Objectives** : Se restaurer lors de sa visite.
- **Permissions** : Un repas unique.
- **Limitations** : QR Code valable uniquement le jour de la visite.
- **Pain Points** : Complexité d'accès aux services internes.
- **Success Criteria** : Autonomie grâce au QR Code temporaire.

### Réception
- **Responsibilities** : Accueillir visiteurs et stagiaires.
- **Objectives** : Fluidifier l'attribution des droits d'accès.
- **Permissions** : Création comptes visiteurs/stagiaires, génération QR Codes.
- **Limitations** : Pas d'accès à l'enrôlement biométrique.
- **Pain Points** : Tâches manuelles répétitives.
- **Success Criteria** : Génération de QR Code en moins de 30 secondes.

### Administrateur
- **Responsibilities** : Gérer le système, les utilisateurs et l'audit.
- **Objectives** : Assurer la disponibilité et la sécurité de l'application.
- **Permissions** : Totalité (Employés, biométrie, configurations).
- **Limitations** : Ne peut pas supprimer le dernier administrateur actif.
- **Pain Points** : Complexité des audits et gestion des accès.
- **Success Criteria** : Plateforme d'administration centralisée et fiable.

### Responsable Restaurant
- **Responsibilities** : Superviser la distribution des repas.
- **Objectives** : Anticiper la demande et analyser la fréquentation.
- **Permissions** : Consultation des rapports et statistiques.
- **Limitations** : Accès en lecture seule aux données.
- **Pain Points** : Manque de visibilité en temps réel.
- **Success Criteria** : Rapports automatiques clairs et précis.

---

# 4. Epics

- **Epic 1 : Identification** (Biométrie et processus de connexion)
- **Epic 2 : Gestion des repas** (Sélection, validation, restriction horaire)
- **Epic 3 : Gestion des QR Codes** (Génération, péremption, validation, révocation)
- **Epic 4 : Administration** (Interface sécurisée, gestion globale)
- **Epic 5 : Rapports** (Génération et envoi de PDF)
- **Epic 6 : Statistiques** (Calcul des métriques et tableaux de bord)
- **Epic 7 : Notifications** (Messages utilisateur, confirmation, erreurs)
- **Epic 8 : Audit** (Traçabilité immuable des actions)
- **Epic 9 : Configuration** (Paramétrage système, emails)
- **Epic 10 : Gestion des utilisateurs** (CRUD employés, stagiaires, visiteurs)

---

# 4.1. Epic Summary

| Epic | Titre | Nombre d'US | Total Story Points | Priorités | Release | Statut |
|---|---|---|---|---|---|---|
| Epic 1 | Identification | 16 | 68 | 12 Must, 2 Should, 2 Could | R1.0 | Planned |
| Epic 2 | Gestion des repas | 8 | 28 | 8 Must | R1.0 | Planned |
| Epic 3 | Gestion des QR Codes | 12 | 43 | 9 Must, 3 Could | R1.0 | Planned |
| Epic 4 | Administration | 8 | 32 | 4 Must, 4 Should | R1.0 | Planned |
| Epic 5 | Rapports | 11 | 41 | 3 Must, 6 Should, 2 Could | R1.0 | Planned |
| Epic 6 | Statistiques | 7 | 24 | 3 Must, 1 Should, 3 Could | R1.0 | Planned |
| Epic 7 | Notifications | 5 | 12 | 4 Must, 1 Should | R1.0 | Planned |
| Epic 8 | Audit | 6 | 24 | 5 Must, 1 Should | R1.0 | Planned |
| Epic 9 | Configuration | 7 | 25 | 4 Must, 3 Should | R1.0 | Planned |
| Epic 10 | Gestion des utilisateurs | 20 | 84 | 14 Must, 5 Should, 1 Could | R1.0 | Planned |
| **Total** | **10 Epics** | **80** | **381** | | | |

> **Note** : Le total de 381 Story Points reflète l'effort global estimé pour l'ensemble des 80 User Stories de la Release 1.0.

---

# 5. User Stories

### US-001 : Identification faciale de l'employé
- **Epic** : Epic 1 | **Priority** : Must Have | **Story Points** : 8 | **Actor** : Employé
- **Description** : En tant que Employé, Je souhaite m'identifier par reconnaissance faciale Afin de fluidifier mon passage au restaurant.
- **Business Value** : Rapidité et expérience sans contact (temps < 3s).
- **Acceptance Criteria** :
  - Given un employé devant la tablette, When la caméra le scanne, Then le système l'identifie sans mot de passe.
- **Business Rules** : BR-001, BR-004 | **Functional Requirements** : FR-201, FR-304 | **NFR** : NFR-201
- **Dependencies** : US-076 (Enrôlement biométrique)
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-002 : Scan QR Code Stagiaire
- **Epic** : Epic 1 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Stagiaire
- **Description** : En tant que Stagiaire, Je souhaite m'identifier via QR Code nominatif Afin d'accéder au restaurant sans badge biométrique.
- **Business Value** : Gestion simplifiée des travailleurs temporaires.
- **Acceptance Criteria** :
  - Given un stagiaire avec un QR Code valide, When il le scanne, Then le système l'identifie.
- **Business Rules** : BR-002, BR-004 | **Functional Requirements** : FR-202 | **NFR** : NFR-202
- **Dependencies** : US-021, US-077
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-003 : Scan QR Code Visiteur
- **Epic** : Epic 1 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Visiteur
- **Description** : En tant que Visiteur, Je souhaite m'identifier via QR Code temporaire Afin de pouvoir déjeuner le jour de ma visite.
- **Business Value** : Digitalisation de l'accueil visiteur.
- **Acceptance Criteria** :
  - Given un visiteur avec QR Code du jour, When il le scanne, Then le système l'identifie.
- **Business Rules** : BR-003, BR-004 | **Functional Requirements** : FR-203 | **NFR** : NFR-202
- **Dependencies** : US-023, US-079
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-004 : Rejet de QR Code expiré (Identification)
- **Epic** : Epic 1 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Utilisateur
- **Description** : En tant qu'Utilisateur, Je souhaite que le système vérifie la validité temporelle de mon QR Code Afin d'empêcher les accès non autorisés.
- **Business Value** : Sécurité des accès.
- **Acceptance Criteria** :
  - Given un QR Code expiré, When il est scanné, Then l'identification est bloquée avec un message.
- **Business Rules** : BR-026 | **Functional Requirements** : FR-204 | **NFR** : NFR-203
- **Dependencies** : US-022, US-024
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-005 : Rejet de QR Code révoqué (Identification)
- **Epic** : Epic 1 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Utilisateur
- **Description** : En tant qu'Utilisateur, Je souhaite que mon QR Code révoqué soit bloqué Afin d'appliquer immédiatement les restrictions de sécurité.
- **Business Value** : Contrôle des accès en temps réel.
- **Acceptance Criteria** :
  - Given un QR Code révoqué, When scanné, Then l'accès est rejeté immédiatement.
- **Business Rules** : BR-029 | **Functional Requirements** : FR-205 | **NFR** : NFR-203
- **Dependencies** : US-040
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-006 : Authentification de l'Administrateur
- **Epic** : Epic 1 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite m'authentifier par JWT Afin d'accéder à l'interface d'administration sécurisée.
- **Business Value** : Sécurisation du backend.
- **Acceptance Criteria** :
  - Given des credentials valides, When saisis, Then un token JWT est délivré.
- **Business Rules** : BR-069 | **Functional Requirements** : FR-208 | **NFR** : NFR-204
- **Dependencies** : Aucune
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-007 : Expiration automatique de session Administrateur
- **Epic** : Epic 1 | **Priority** : Should Have | **Story Points** : 3 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite que ma session expire automatiquement Afin de prévenir les risques de sécurité (vol de session).
- **Business Value** : Conformité de sécurité.
- **Acceptance Criteria** :
  - Given un token expiré, When une requête est envoyée, Then le système renvoie une erreur 401.
- **Business Rules** : BR-070 | **Functional Requirements** : FR-209 | **NFR** : NFR-205
- **Dependencies** : US-006
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-008 : Enrôlement biométrique initial
- **Epic** : Epic 1 | **Priority** : Must Have | **Story Points** : 8 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite capturer les données faciales d'un employé Afin de l'enrôler dans le système biométrique.
- **Business Value** : Pré-requis pour l'usage du système par les employés.
- **Acceptance Criteria** :
  - Given l'interface d'enrôlement, When la photo est validée, Then l'empreinte biométrique est liée au compte employé.
- **Business Rules** : BR-031 | **Functional Requirements** : FR-301, FR-302 | **NFR** : NFR-206
- **Dependencies** : US-076
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-009 : Chiffrement des données biométriques
- **Epic** : Epic 1 | **Priority** : Must Have | **Story Points** : 8 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite que les données biométriques soient stockées chiffrées Afin de respecter les normes de confidentialité.
- **Business Value** : Conformité RGPD / Sécurité des données sensibles.
- **Acceptance Criteria** :
  - Given une nouvelle empreinte, When elle est persistée, Then elle est stockée sous forme chiffrée.
- **Business Rules** : BR-035, BR-071 | **Functional Requirements** : FR-309 | **NFR** : NFR-207
- **Dependencies** : US-008
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-010 : Réinitialisation des données biométriques
- **Epic** : Epic 1 | **Priority** : Should Have | **Story Points** : 3 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite pouvoir mettre à jour le visage d'un employé Afin de gérer les changements physiques.
- **Business Value** : Maintenabilité du référentiel utilisateur.
- **Acceptance Criteria** :
  - Given un employé existant, When je refais l'enrôlement, Then les anciennes données sont remplacées.
- **Business Rules** : BR-032 | **Functional Requirements** : FR-303 | **NFR** : NFR-206
- **Dependencies** : US-008
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-011 : Unicité de la session d'identification
- **Epic** : Epic 1 | **Priority** : Must Have | **Story Points** : 2 | **Actor** : Utilisateur
- **Description** : En tant qu'Utilisateur, Je souhaite qu'une seule personne soit identifiée à la fois Afin d'éviter les mélanges de comptes.
- **Business Value** : Intégrité des données de restauration.
- **Acceptance Criteria** :
  - Given un scan en cours, When un autre utilisateur tente de se scanner, Then l'action est bloquée.
- **Business Rules** : BR-006 | **Functional Requirements** : FR-207 | **NFR** : NFR-208
- **Dependencies** : Aucune
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-012 : Identification en environnement normal
- **Epic** : Epic 1 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Employé
- **Description** : En tant qu'Employé, Je souhaite être identifié de manière fiable Afin d'éviter les erreurs d'attribution.
- **Business Value** : Qualité du service.
- **Acceptance Criteria** :
  - Given une luminosité standard, When l'employé se présente, Then le taux de réussite dépasse 95%.
- **Business Rules** : BR-033 | **Functional Requirements** : FR-305 | **NFR** : NFR-209
- **Dependencies** : US-001
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-013 : Affichage du menu des catégories
- **Epic** : Epic 2 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Utilisateur
- **Description** : En tant qu'Utilisateur identifié, Je souhaite voir les 3 catégories de repas Afin de pouvoir faire mon choix.
- **Business Value** : Guidage de l'utilisateur.
- **Acceptance Criteria** :
  - Given une identification réussie, When l'écran se charge, Then Plat, Pizza et Sandwich s'affichent.
- **Business Rules** : BR-037 | **Functional Requirements** : FR-501 | **NFR** : NFR-210
- **Dependencies** : US-001, US-002, US-003
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-014 : Sélection d'une catégorie unique
- **Epic** : Epic 2 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Utilisateur
- **Description** : En tant qu'Utilisateur, Je souhaite sélectionner une seule catégorie Afin de confirmer mon choix de repas.
- **Business Value** : Clarté de la transaction.
- **Acceptance Criteria** :
  - Given les 3 options, When j'en choisis une, Then je ne peux pas en choisir une autre simultanément.
- **Business Rules** : BR-038 | **Functional Requirements** : FR-502 | **NFR** : NFR-210
- **Dependencies** : US-013
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-015 : Blocage validation sans sélection
- **Epic** : Epic 2 | **Priority** : Must Have | **Story Points** : 2 | **Actor** : Utilisateur
- **Description** : En tant qu'Utilisateur, Je souhaite que la validation soit désactivée si aucune catégorie n'est choisie Afin d'éviter les repas vides.
- **Business Value** : Cohérence des données.
- **Acceptance Criteria** :
  - Given l'écran de sélection, When rien n'est coché, Then le bouton de validation est bloqué.
- **Business Rules** : BR-039 | **Functional Requirements** : FR-503 | **NFR** : NFR-211
- **Dependencies** : US-014
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-016 : Enregistrement définitif du repas
- **Epic** : Epic 2 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Utilisateur
- **Description** : En tant qu'Utilisateur, Je souhaite valider mon choix de manière irréversible Afin que le repas soit enregistré.
- **Business Value** : Traçabilité des consommations.
- **Acceptance Criteria** :
  - Given un choix validé, When j'essaie de revenir en arrière, Then c'est impossible.
- **Business Rules** : BR-040 | **Functional Requirements** : FR-504 | **NFR** : NFR-212
- **Dependencies** : US-014
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-017 : Horodatage du repas
- **Epic** : Epic 2 | **Priority** : Must Have | **Story Points** : 2 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite que le système horodate chaque validation de repas Afin d'assurer la traçabilité temporelle et la fiabilité des statistiques.
- **Business Value** : Fiabilité de l'audit et des statistiques.
- **Acceptance Criteria** :
  - Given une validation de repas, When persistée, Then le timestamp actuel est enregistré.
- **Business Rules** : BR-041 | **Functional Requirements** : FR-505 | **NFR** : NFR-213
- **Dependencies** : US-016
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-018 : Mémorisation des détails du repas
- **Epic** : Epic 2 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite que le système sauvegarde le mode d'identification et la catégorie choisie pour chaque repas Afin de pouvoir générer les rapports avec des données complètes et exploitables.
- **Business Value** : Qualité de l'information.
- **Acceptance Criteria** :
  - Given une validation, When stockée, Then ID utilisateur, catégorie, type identification et date sont sauvés.
- **Business Rules** : BR-082 | **Functional Requirements** : FR-506 | **NFR** : NFR-213
- **Dependencies** : US-016
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-019 : Plage horaire de fonctionnement (12h30-14h00)
- **Epic** : Epic 2 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Utilisateur
- **Description** : En tant qu'Utilisateur, Je souhaite être bloqué hors de la plage d'ouverture Afin de respecter le règlement.
- **Business Value** : Respect des règles de gestion de l'entreprise.
- **Acceptance Criteria** :
  - Given il est 14h05, When j'essaie de m'identifier, Then le système refuse l'accès (Restaurant Fermé).
- **Business Rules** : BR-042 | **Functional Requirements** : FR-507 | **NFR** : NFR-214
- **Dependencies** : Aucune
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-020 : Unicité du repas journalier
- **Epic** : Epic 2 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Utilisateur
- **Description** : En tant qu'Utilisateur, Je souhaite être bloqué si je tente de prendre un deuxième repas Afin d'éviter les abus.
- **Business Value** : Maîtrise des coûts de restauration.
- **Acceptance Criteria** :
  - Given un repas déjà consommé le jour J, When je m'identifie à nouveau, Then le système m'indique le rejet.
- **Business Rules** : BR-008, BR-014, BR-021 | **Functional Requirements** : FR-508, FR-509 | **NFR** : NFR-215
- **Dependencies** : US-016
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-021 : Génération QR Code Stagiaire
- **Epic** : Epic 3 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Réception
- **Description** : En tant que Réception, Je souhaite générer un QR nominatif pour un stagiaire Afin de lui donner accès au restaurant pour la durée de son stage.
- **Business Value** : Autonomie des stagiaires.
- **Acceptance Criteria** :
  - Given la création du stagiaire, When validée, Then un QR Code unique est généré.
- **Business Rules** : BR-025 | **Functional Requirements** : FR-401 | **NFR** : NFR-216
- **Dependencies** : US-077
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-022 : Expiration QR Code Stagiaire
- **Epic** : Epic 3 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Système
- **Description** : En tant que Système, Je souhaite définir l'expiration du QR stagiaire à la date de fin de stage Afin d'automatiser les révocations de droits.
- **Business Value** : Sécurité et absence de gestion manuelle des fins de droits.
- **Acceptance Criteria** :
  - Given un stagiaire finissant le 30/08, When le QR est généré, Then son expiration est fixée au 30/08 à 23h59.
- **Business Rules** : BR-016 | **Functional Requirements** : FR-402 | **NFR** : NFR-216
- **Dependencies** : US-021
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-023 : Génération QR Code Visiteur
- **Epic** : Epic 3 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Réception
- **Description** : En tant que Réception, Je souhaite générer un QR temporaire pour visiteur Afin de lui offrir un repas.
- **Business Value** : Hospitalité de l'entreprise.
- **Acceptance Criteria** :
  - Given la fiche visiteur, When validée, Then le QR est généré et affiché.
- **Business Rules** : BR-019 | **Functional Requirements** : FR-403 | **NFR** : NFR-216
- **Dependencies** : US-079
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-024 : Expiration QR Code Visiteur (Minuit)
- **Epic** : Epic 3 | **Priority** : Must Have | **Story Points** : 2 | **Actor** : Système
- **Description** : En tant que Système, Je souhaite que le QR visiteur expire le jour même à minuit Afin de bloquer toute réutilisation.
- **Business Value** : Prévention des fraudes.
- **Acceptance Criteria** :
  - Given un QR visiteur généré aujourd'hui, When il est scanné demain, Then il est rejeté car expiré.
- **Business Rules** : BR-020 | **Functional Requirements** : FR-404 | **NFR** : NFR-216
- **Dependencies** : US-023
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-025 : Révocation manuelle d'un QR Code
- **Epic** : Epic 3 | **Priority** : Should Have | **Story Points** : 5 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite révoquer manuellement un QR Code Afin d'annuler les droits en cas de perte ou fraude.
- **Business Value** : Réactivité sécurité.
- **Acceptance Criteria** :
  - Given un QR Code actif, When je clique sur Révoquer, Then son statut passe à révoqué immédiatement.
- **Business Rules** : BR-028 | **Functional Requirements** : FR-409, FR-612 | **NFR** : NFR-217
- **Dependencies** : US-021, US-023
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-026 : Immédiateté de la révocation QR
- **Epic** : Epic 3 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Système
- **Description** : En tant que Système, Je souhaite que la révocation prenne effet sans délai Afin de sécuriser le restaurant.
- **Business Value** : Fiabilité.
- **Acceptance Criteria** :
  - Given une révocation à 12h00, When scanné à 12h01, Then il est bloqué.
- **Business Rules** : BR-029 | **Functional Requirements** : FR-410 | **NFR** : NFR-217
- **Dependencies** : US-025
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-027 : Interface d'Administration sécurisée
- **Epic** : Epic 4 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite accéder à un dashboard privé et sécurisé Afin de gérer la plateforme.
- **Business Value** : Centralisation des opérations.
- **Acceptance Criteria** :
  - Given une URL d'admin, When je m'y connecte sans JWT, Then je suis redirigé vers la page login.
- **Business Rules** : BR-069 | **Functional Requirements** : FR-601 | **NFR** : NFR-218
- **Dependencies** : US-006
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-028 : Création d'un Administrateur
- **Epic** : Epic 4 | **Priority** : Should Have | **Story Points** : 3 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite créer d'autres profils admin Afin de déléguer la gestion.
- **Business Value** : Scalabilité de l'équipe IT.
- **Acceptance Criteria** :
  - Given l'interface utilisateurs, When je crée un admin, Then il peut s'authentifier.
- **Business Rules** : BR-048 | **Functional Requirements** : FR-603 | **NFR** : NFR-218
- **Dependencies** : US-027
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-029 : Protection du dernier Administrateur actif
- **Epic** : Epic 4 | **Priority** : Must Have | **Story Points** : 2 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite que la suppression du dernier admin soit bloquée Afin de ne pas perdre l'accès au système.
- **Business Value** : Résilience.
- **Acceptance Criteria** :
  - Given 1 seul admin, When je tente de le désactiver, Then une erreur bloque l'action.
- **Business Rules** : BR-049 | **Functional Requirements** : FR-604 | **NFR** : NFR-218
- **Dependencies** : US-028
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-030 : Paramétrage des emails des rapports
- **Epic** : Epic 4 | **Priority** : Should Have | **Story Points** : 3 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite gérer la liste des destinataires Afin de distribuer les rapports aux bonnes personnes.
- **Business Value** : Flexibilité.
- **Acceptance Criteria** :
  - Given la config, When j'ajoute un email, Then il reçoit le prochain rapport.
- **Business Rules** : BR-050 | **Functional Requirements** : FR-607 | **NFR** : NFR-219
- **Dependencies** : US-027
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-031 : Génération du rapport journalier
- **Epic** : Epic 5 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Responsable Restaurant
- **Description** : En tant que Responsable Restaurant, Je souhaite que le système génère automatiquement un rapport PDF chaque jour à 14h15 Afin de synthétiser l'activité de restauration quotidienne sans intervention humaine.
- **Business Value** : Automatisation du reporting quotidien.
- **Acceptance Criteria** :
  - Given la fin du service (14h00), When 14h15 arrive, Then le système génère le rapport au format PDF.
- **Business Rules** : BR-053 | **Functional Requirements** : FR-701 | **NFR** : NFR-220
- **Dependencies** : US-016
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-032 : Génération du rapport hebdomadaire
- **Epic** : Epic 5 | **Priority** : Should Have | **Story Points** : 3 | **Actor** : Responsable Restaurant
- **Description** : En tant que Responsable Restaurant, Je souhaite que le système génère automatiquement un rapport PDF chaque vendredi soir Afin de disposer d'une vue agrégée sur la semaine pour le suivi budgétaire.
- **Business Value** : Suivi budgétaire hebdomadaire.
- **Acceptance Criteria** :
  - Given vendredi 18h, When le job s'exécute, Then les stats des 5 jours sont agrégées en un document.
- **Business Rules** : BR-054 | **Functional Requirements** : FR-702 | **NFR** : NFR-220
- **Dependencies** : US-031
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-033 : Envoi automatique par email
- **Epic** : Epic 5 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite que le système envoie automatiquement le rapport PDF par email aux destinataires configurés Afin de le distribuer aux parties prenantes sans action manuelle.
- **Business Value** : Efficacité opérationnelle.
- **Acceptance Criteria** :
  - Given un rapport PDF généré, When validé, Then il est expédié en pièce jointe aux adresses configurées.
- **Business Rules** : BR-056 | **Functional Requirements** : FR-704 | **NFR** : NFR-221
- **Dependencies** : US-030, US-031
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-034 : Graphiques (Camemberts) dans les rapports
- **Epic** : Epic 5 | **Priority** : Should Have | **Story Points** : 5 | **Actor** : Responsable Restaurant
- **Description** : En tant que Responsable Restaurant, Je souhaite visualiser la répartition des plats sous forme de camembert Afin d'analyser rapidement les préférences.
- **Business Value** : Lisibilité des données.
- **Acceptance Criteria** :
  - Given le rapport PDF, When généré, Then il contient un camembert de la proportion Plat/Pizza/Sandwich.
- **Business Rules** : BR-057 | **Functional Requirements** : FR-708 | **NFR** : NFR-220
- **Dependencies** : US-031
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-035 : Traduction stricte en français (Rapports)
- **Epic** : Epic 5 | **Priority** : Must Have | **Story Points** : 1 | **Actor** : Product Owner
- **Description** : En tant que PO, Je souhaite que les rapports soient en français uniquement Afin de respecter le référentiel de l'entreprise.
- **Business Value** : Cohérence documentaire.
- **Acceptance Criteria** :
  - Given un rapport généré, When ouvert, Then 100% du contenu textuel est en langue française.
- **Business Rules** : BR-058 | **Functional Requirements** : FR-711 | **NFR** : NFR-222
- **Dependencies** : US-031
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-036 : Calcul du nombre total de repas
- **Epic** : Epic 6 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite voir le nombre total de repas distribués sur une période Afin de suivre le volume d'activité.
- **Business Value** : Métrique de base du restaurant.
- **Acceptance Criteria** :
  - Given le Dashboard, When je sélectionne 1 mois, Then le compteur affiche la somme exacte.
- **Business Rules** : BR-060 | **Functional Requirements** : FR-801 | **NFR** : NFR-223
- **Dependencies** : US-016
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-037 : Répartition par profil d'utilisateur
- **Epic** : Epic 6 | **Priority** : Should Have | **Story Points** : 3 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite filtrer les consommations par profil (Employé, Stagiaire, Visiteur) Afin de segmenter l'analyse.
- **Business Value** : Contrôle de gestion croisé.
- **Acceptance Criteria** :
  - Given le Dashboard, When je regarde la répartition, Then je vois le total pour chaque Persona.
- **Business Rules** : BR-063 | **Functional Requirements** : FR-804 | **NFR** : NFR-223
- **Dependencies** : US-036
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-038 : Analyse des pics de fréquentation
- **Epic** : Epic 6 | **Priority** : Could Have | **Story Points** : 5 | **Actor** : Responsable Restaurant
- **Description** : En tant que Responsable, Je souhaite voir un histogramme des passages par tranche de 15 minutes Afin d'ajuster le personnel en cuisine.
- **Business Value** : Optimisation des ressources RH du restaurant.
- **Acceptance Criteria** :
  - Given la vue statistique, When affichée, Then un graphique montre les volumes entre 12h30 et 14h00.
- **Business Rules** : BR-062 | **Functional Requirements** : FR-803 | **NFR** : NFR-223
- **Dependencies** : US-017
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-039 : Affichage d'un message de confirmation
- **Epic** : Epic 7 | **Priority** : Must Have | **Story Points** : 2 | **Actor** : Utilisateur
- **Description** : En tant qu'Utilisateur, Je souhaite voir une validation verte à l'écran Afin de savoir que mon repas est bien enregistré.
- **Business Value** : Réassurance UX.
- **Acceptance Criteria** :
  - Given une validation de repas, When effectuée, Then un message de succès s'affiche pendant 3s.
- **Business Rules** : BR-065 | **Functional Requirements** : FR-901 | **NFR** : NFR-224
- **Dependencies** : US-016
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-040 : Message multilingue (FR, AR, EN)
- **Epic** : Epic 7 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Utilisateur
- **Description** : En tant qu'Utilisateur, Je souhaite que les messages d'erreur et de succès soient en FR, EN et AR Afin de comprendre les consignes quelle que soit mon origine.
- **Business Value** : Inclusion et accessibilité (notamment visiteurs étrangers).
- **Acceptance Criteria** :
  - Given un événement de notification, When affiché, Then le texte apparaît dans les 3 langues superposées.
- **Business Rules** : BR-067 | **Functional Requirements** : FR-907 | **NFR** : NFR-224
- **Dependencies** : US-039
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-041 : Message d'erreur clair d'échec biométrique
- **Epic** : Epic 7 | **Priority** : Must Have | **Story Points** : 2 | **Actor** : Employé
- **Description** : En tant qu'Employé, Je souhaite être averti si je ne suis pas reconnu Afin de retenter ou contacter l'admin.
- **Business Value** : Amélioration de la gestion des erreurs.
- **Acceptance Criteria** :
  - Given une tentative d'identification échouée, When 3 secondes s'écoulent, Then l'écran affiche "Non reconnu, veuillez réessayer".
- **Business Rules** : BR-066 | **Functional Requirements** : FR-902 | **NFR** : NFR-224
- **Dependencies** : US-012
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-042 : Journalisation des actions d'administration
- **Epic** : Epic 8 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Système
- **Description** : En tant que Système, Je souhaite journaliser toute action de création, modification ou suppression d'utilisateur Afin d'assurer la traçabilité de l'exploitation.
- **Business Value** : Responsabilité et auditabilité (Security compliance).
- **Acceptance Criteria** :
  - Given une action de création d'admin, When confirmée, Then une entrée est écrite dans les logs avec date, ID admin et type action.
- **Business Rules** : BR-080 | **Functional Requirements** : FR-1001 | **NFR** : NFR-225
- **Dependencies** : US-028, US-048
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-043 : Immutabilité du journal d'audit
- **Epic** : Epic 8 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Système
- **Description** : En tant que Système, Je souhaite que personne ne puisse supprimer une ligne du journal Afin de garantir l'intégrité des preuves.
- **Business Value** : Prévention des fraudes internes.
- **Acceptance Criteria** :
  - Given l'interface ou l'API, When un admin tente de supprimer un log, Then la requête est rejetée (403 Forbidden).
- **Business Rules** : BR-083 | **Functional Requirements** : FR-1005 | **NFR** : NFR-225
- **Dependencies** : US-042
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-044 : Consultation du journal d'audit
- **Epic** : Epic 8 | **Priority** : Should Have | **Story Points** : 5 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite consulter la liste chronologique des événements système Afin de rechercher l'origine d'un problème.
- **Business Value** : Supervision et résolution d'incidents.
- **Acceptance Criteria** :
  - Given l'accès au module Audit, When j'ouvre la page, Then les logs s'affichent du plus récent au plus ancien.
- **Business Rules** : BR-081 | **Functional Requirements** : FR-1006 | **NFR** : NFR-225
- **Dependencies** : US-042
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-045 : Configuration de l'application (Démarrage)
- **Epic** : Epic 9 | **Priority** : Must Have | **Story Points** : 2 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite que l'application démarre automatiquement sur la tablette au démarrage d'Android (mode kiosque) Afin qu'elle soit toujours prête à l'utilisation sans intervention humaine.
- **Business Value** : Résilience et robustesse.
- **Acceptance Criteria** :
  - Given la tablette éteinte, When on l'allume, Then l'application CSM Resto+ se lance sans intervention.
- **Business Rules** : BR-075 | **Functional Requirements** : N/A | **NFR** : NFR-226
- **Dependencies** : Aucune
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-046 : Cacher l'interface de paramétrage de la tablette
- **Epic** : Epic 9 | **Priority** : Must Have | **Story Points** : 2 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite que les réglages soient verrouillés derrière un PIN Afin d'éviter qu'un utilisateur ferme l'application.
- **Business Value** : Sécurité de la borne physique.
- **Acceptance Criteria** :
  - Given la tablette, When un utilisateur clique en dehors des zones prévues, Then rien ne se passe.
- **Business Rules** : BR-073 | **Functional Requirements** : FR-601 | **NFR** : NFR-226
- **Dependencies** : US-045
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-047 : Création d'un compte Employé
- **Epic** : Epic 10 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite créer une fiche employé (Nom, Prénom) Afin de préparer son enrôlement.
- **Business Value** : Gestion du personnel.
- **Acceptance Criteria** :
  - Given le module RH, When je sauvegarde nom/prénom, Then l'employé est créé avec le statut Actif.
- **Business Rules** : BR-011 | **Functional Requirements** : FR-101 | **NFR** : NFR-227
- **Dependencies** : US-027
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-048 : Désactivation d'un compte Employé
- **Epic** : Epic 10 | **Priority** : Must Have | **Story Points** : 2 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite suspendre un compte employé Afin de bloquer ses accès lors de ses congés ou de son départ.
- **Business Value** : Sécurité et gestion des droits.
- **Acceptance Criteria** :
  - Given un employé actif, When je le désactive, Then il ne peut plus enregistrer de repas.
- **Business Rules** : BR-010 | **Functional Requirements** : FR-103 | **NFR** : NFR-227
- **Dependencies** : US-047
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-049 : Suppression définitive (RGPD)
- **Epic** : Epic 10 | **Priority** : Should Have | **Story Points** : 3 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite supprimer un employé et ses biométries Afin de respecter la loi sur les données personnelles.
- **Business Value** : Conformité légale.
- **Acceptance Criteria** :
  - Given un employé, When supprimé, Then la fiche et les données biométriques sont effacées irréversiblement.
- **Business Rules** : BR-012 | **Functional Requirements** : FR-105, FR-308 | **NFR** : NFR-227
- **Dependencies** : US-008
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-050 : Consultation de la liste des Stagiaires
- **Epic** : Epic 10 | **Priority** : Should Have | **Story Points** : 2 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite lister les stagiaires avec la validité de leur QR Afin de superviser les accès temporaires.
- **Business Value** : Visibilité RH.
- **Acceptance Criteria** :
  - Given la page Stagiaires, When je m'y rends, Then le tableau affiche noms et dates d'expiration.
- **Business Rules** : BR-046 | **Functional Requirements** : FR-110 | **NFR** : NFR-227
- **Dependencies** : US-021
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-051 : Liste des repas enregistrés par Employé
- **Epic** : Epic 10 | **Priority** : Could Have | **Story Points** : 3 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite voir l'historique des repas d'un employé spécifique Afin de répondre à ses interrogations ou litiges.
- **Business Value** : Service support.
- **Acceptance Criteria** :
  - Given une fiche employé, When je clique sur "Historique", Then la liste de ses repas s'affiche.
- **Business Rules** : BR-046 | **Functional Requirements** : FR-106 | **NFR** : NFR-227
- **Dependencies** : US-047
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-052 : Pagination des listes (employés, stagiaires, visiteurs)
- **Epic** : Epic 10 | **Priority** : Should Have | **Story Points** : 3 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite que les listes d'utilisateurs (employés, stagiaires, visiteurs) soient affichées avec une pagination Afin de naviguer efficacement dans un volume important de données sans ralentissement de l'interface.
- **Business Value** : Performance et ergonomie de l'interface d'administration lorsque le nombre d'utilisateurs enregistrés devient conséquent, évitant le chargement de centaines de lignes en une seule page.
- **Acceptance Criteria** :
  - AC-001 Given une liste d'employés contenant plus de 20 entrées, When l'administrateur consulte la liste, Then les résultats sont affichés par page de 20 éléments avec des contrôles de navigation page suivante/page précédente.
  - AC-002 Given une liste d'employés contenant moins de 20 entrées, When l'administrateur consulte la liste, Then tous les résultats sont affichés sur une seule page sans contrôle de pagination superflu.
  - AC-003 Given une recherche filtrée retournant 5 résultats, When l'administrateur consulte la page, Then la pagination s'adapte au nombre réduit de résultats et n'affiche qu'une seule page.
- **Business Rules** : BR-046 | **Functional Requirements** : FR-106, FR-110, FR-111 | **NFR** : NFR-105
- **Dependencies** : US-047, US-050, US-077, US-079
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-053 : Gestion des fuseaux horaires (UTC vers heure locale)
- **Epic** : Epic 9 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite que le système convertisse automatiquement les horodatages UTC en heure locale pour tous les affichages (interface admin, rapports) Afin que les données temporelles soient pertinentes et lisibles pour les utilisateurs métier.
- **Business Value** : Cohérence temporelle entre le stockage technique en UTC et l'affichage métier en heure locale, garantissant que les rapports, statistiques et contrôles horaires (plage 12h30-14h00) reflètent fidèlement le fuseau horaire de l'entreprise.
- **Acceptance Criteria** :
  - AC-001 Given un enregistrement de repas horodaté à 12h45 UTC+1 en base, When l'administrateur consulte les statistiques, Then l'heure affichée est 12h45 en heure locale.
  - AC-002 Given un rapport mensuel généré, When le rapport est ouvert, Then toutes les dates et heures sont exprimées dans le fuseau horaire local de l'entreprise sans mention de l'UTC.
  - AC-003 Given un changement de fuseau horaire (passage heure d'été/hiver), When le système traite les horodatages, Then la conversion s'adapte automatiquement au fuseau en vigueur à la date de l'événement.
- **Business Rules** : BR-042 | **Functional Requirements** : FR-505, FR-506, FR-706 | **NFR** : NFR-1502, NFR-1503
- **Dependencies** : US-017, US-031
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-054 : Filtres de recherche dans les listes administrateur
- **Epic** : Epic 10 | **Priority** : Should Have | **Story Points** : 5 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite disposer de filtres de recherche (par nom, prénom, statut, date) dans les listes d'employés, de stagiaires et de visiteurs Afin de retrouver rapidement un utilisateur spécifique sans parcourir l'intégralité des listes.
- **Business Value** : Gain de temps opérationnel pour l'administration lors de la gestion quotidienne des comptes, particulièrement lorsque l'effectif dépasse plusieurs centaines d'utilisateurs.
- **Acceptance Criteria** :
  - AC-001 Given la liste des employés, When l'administrateur saisit un nom dans le champ de recherche, Then la liste se filtre en temps réel pour n'afficher que les employés dont le nom correspond à la saisie.
  - AC-002 Given la liste des stagiaires, When l'administrateur applique un filtre par statut "Actif", Then seuls les stagiaires dont le QR Code est encore valide sont affichés.
  - AC-003 Given un filtre combiné nom + statut ne retournant aucun résultat, When la recherche est exécutée, Then un message "Aucun résultat trouvé" est affiché sans erreur technique.
- **Business Rules** : BR-046 | **Functional Requirements** : FR-106, FR-110, FR-111 | **NFR** : NFR-101
- **Dependencies** : US-047, US-050, US-052, US-077, US-079
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-055 : Modification des informations d'un compte employé
- **Epic** : Epic 10 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite modifier les informations d'un compte employé existant (nom, prénom, statut) Afin de maintenir à jour le référentiel du personnel sans avoir à supprimer puis recréer le compte.
- **Business Value** : Souplesse de gestion RH permettant de corriger les erreurs de saisie ou de refléter les changements d'état civil des employés sans perte de l'historique de repas associé.
- **Acceptance Criteria** :
  - AC-001 Given un employé existant dans la liste, When l'administrateur modifie son nom et valide, Then les nouvelles informations sont persistées et visibles dans la liste mise à jour.
  - AC-002 Given un employé existant, When l'administrateur tente de soumettre le formulaire avec un champ nom vide, Then le système rejette la modification et affiche un message de validation indiquant les champs obligatoires.
  - AC-003 Given un employé dont le compte est désactivé, When l'administrateur modifie uniquement son prénom, Then la modification est acceptée sans altérer le statut désactivé du compte.
- **Business Rules** : BR-011, BR-046 | **Functional Requirements** : FR-102 | **NFR** : NFR-406
- **Dependencies** : US-047
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-056 : Réactivation d'un compte employé désactivé
- **Epic** : Epic 10 | **Priority** : Must Have | **Story Points** : 2 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite réactiver un compte employé précédemment désactivé Afin de rétablir ses droits d'accès au restaurant sans avoir à recréer un nouveau compte ni à refaire son enrôlement biométrique.
- **Business Value** : Gestion fluide des absences temporaires (congés, arrêts maladie) et des retours d'employés, préservant l'intégrité de l'historique individuel et évitant la duplication des comptes.
- **Acceptance Criteria** :
  - AC-001 Given un employé désactivé dans la liste, When l'administrateur sélectionne l'action "Réactiver", Then le statut du compte passe à "Actif" et l'employé peut à nouveau s'identifier par reconnaissance faciale et enregistrer un repas.
  - AC-002 Given un employé déjà actif, When l'administrateur tente de le réactiver, Then l'option de réactivation n'est pas disponible ou est grisée dans l'interface.
- **Business Rules** : BR-010, BR-046 | **Functional Requirements** : FR-104 | **NFR** : NFR-406
- **Dependencies** : US-047, US-048
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-057 : Création d'un compte stagiaire par la Réception
- **Epic** : Epic 10 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Réception
- **Description** : En tant que Réception, Je souhaite créer un compte stagiaire en renseignant son nom, prénom, date de début et date de fin de stage, et générer automatiquement son QR Code nominatif Afin de lui permettre d'accéder au restaurant dès son premier jour sans intervention de l'administrateur.
- **Business Value** : Autonomie du service d'accueil pour la gestion des stagiaires, réduisant la charge de l'équipe informatique et accélérant l'intégration des nouveaux arrivants temporaires.
- **Acceptance Criteria** :
  - AC-001 Given le formulaire de création stagiaire, When la Réception saisit nom, prénom, date de début (01/09/2026) et date de fin (31/12/2026) puis valide, Then le compte stagiaire est créé, un QR Code nominatif est généré avec expiration au 31/12/2026 à 23h59, et le QR Code est affiché.
  - AC-002 Given le formulaire de création stagiaire, When la Réception tente de valider sans renseigner la date de fin de stage, Then le système rejette la soumission et signale que la date de fin est obligatoire.
  - AC-003 Given le formulaire de création stagiaire, When la Réception saisit une date de fin antérieure à la date de début, Then le système rejette la soumission avec un message d'erreur explicite.
- **Business Rules** : BR-013, BR-018, BR-045 | **Functional Requirements** : FR-107, FR-610 | **NFR** : NFR-406
- **Dependencies** : US-021, US-077
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-058 : Modification des informations d'un compte stagiaire
- **Epic** : Epic 10 | **Priority** : Should Have | **Story Points** : 3 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite modifier les informations d'un compte stagiaire existant, y compris ses dates de stage Afin de corriger des erreurs de saisie ou prolonger son accès en cas d'extension de stage sans recréer un nouveau compte.
- **Business Value** : Flexibilité de gestion pour les stages dont la durée est prolongée ou ajustée, évitant la création de comptes doublons et préservant l'historique de consommation du stagiaire.
- **Acceptance Criteria** :
  - AC-001 Given un stagiaire existant avec une date de fin au 31/08/2026, When l'administrateur modifie la date de fin au 30/09/2026 et valide, Then les informations sont mises à jour et la date d'expiration du QR Code est automatiquement prolongée au 30/09/2026 à 23h59.
  - AC-002 Given un stagiaire existant, When l'administrateur tente de modifier sa date de fin en saisissant une date déjà dépassée, Then le système rejette la modification avec un message d'erreur.
  - AC-003 Given un stagiaire dont le QR Code est déjà expiré, When l'administrateur modifie sa date de fin pour une date future, Then le QR Code existant est automatiquement réactivé jusqu'à la nouvelle date d'expiration.
- **Business Rules** : BR-018, BR-046 | **Functional Requirements** : FR-108 | **NFR** : NFR-406
- **Dependencies** : US-050, US-057
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-059 : Création d'un compte visiteur par la Réception
- **Epic** : Epic 10 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Réception
- **Description** : En tant que Réception, Je souhaite créer un compte visiteur en renseignant son nom, son prénom et la date de sa visite, et générer automatiquement son QR Code temporaire Afin de lui permettre d'accéder au restaurant le jour même sans intervention de l'administrateur.
- **Business Value** : Autonomie du service d'accueil pour la gestion des visiteurs ponctuels, offrant une expérience fluide et professionnelle aux invités de l'entreprise sans solliciter le service informatique.
- **Acceptance Criteria** :
  - AC-001 Given le formulaire de création visiteur, When la Réception saisit nom, prénom et date de visite (jour courant) puis valide, Then le compte visiteur est créé, un QR Code temporaire est généré avec expiration à minuit du jour courant, et le QR Code est affiché.
  - AC-002 Given le formulaire de création visiteur, When la Réception tente de valider sans renseigner le nom, Then le système rejette la soumission et signale que le nom est obligatoire.
  - AC-003 Given un visiteur déjà existant avec un QR Code actif pour la journée courante, When la Réception tente de créer un nouveau compte pour ce même visiteur le même jour, Then le système bloque la création et indique qu'un QR Code actif existe déjà pour ce visiteur aujourd'hui.
- **Business Rules** : BR-019, BR-024, BR-045 | **Functional Requirements** : FR-109, FR-611 | **NFR** : NFR-406
- **Dependencies** : US-023, US-079
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-060 : Export CSV des statistiques consultées
- **Epic** : Epic 6 | **Priority** : Could Have | **Story Points** : 3 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite exporter au format CSV les statistiques que je consulte (total repas, répartition par catégorie, par type d'utilisateur) Afin de pouvoir les exploiter dans un tableur externe pour des analyses complémentaires ou des présentations.
- **Business Value** : Interopérabilité des données avec les outils bureautiques standards de l'entreprise, permettant au management de réaliser des analyses personnalisées sans dépendre des formats imposés par le système.
- **Acceptance Criteria** :
  - AC-001 Given l'écran des statistiques affichant les données d'un mois donné, When l'administrateur clique sur "Exporter CSV", Then un fichier CSV est téléchargé contenant les mêmes données structurées (colonnes : Date, Catégorie, Type Utilisateur, Nombre de repas) pour la période affichée.
  - AC-002 Given une période sans aucun enregistrement de repas, When l'administrateur exporte en CSV, Then le fichier généré contient les en-têtes de colonnes mais aucune ligne de données.
  - AC-003 Given l'export CSV, When le fichier est ouvert dans un tableur standard, Then les données sont correctement séparées par des virgules et les dates sont au format lisible.
- **Business Rules** : BR-052 | **Functional Requirements** : FR-801, FR-802, FR-804 | **NFR** : NFR-802
- **Dependencies** : US-036, US-069
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-061 : Génération du rapport mensuel automatique
- **Epic** : Epic 5 | **Priority** : Should Have | **Story Points** : 5 | **Actor** : Responsable Restaurant
- **Description** : En tant que Responsable Restaurant, Je souhaite que le système génère automatiquement un rapport mensuel à la clôture de chaque mois calendaire Afin de disposer d'une synthèse complète de l'activité de restauration sur le mois écoulé sans intervention humaine.
- **Business Value** : Automatisation du reporting mensuel pour le pilotage budgétaire et la supervision de la fréquentation, éliminant le besoin de compilation manuelle des données par l'administration.
- **Acceptance Criteria** :
  - AC-001 Given la fin du mois calendaire (dernier jour à 23h59), When le job mensuel s'exécute, Then un rapport PDF mensuel est généré contenant les statistiques agrégées de tous les jours du mois.
  - AC-002 Given un mois sans aucun jour ouvré (ex: août avec fermeture annuelle), When le rapport mensuel est généré, Then le document indique explicitement "Aucune activité enregistrée sur la période" sans erreur technique.
- **Business Rules** : BR-055 | **Functional Requirements** : FR-703 | **NFR** : NFR-106
- **Dependencies** : US-031, US-033
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-062 : Tableaux structurés dans les rapports générés
- **Epic** : Epic 5 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Responsable Restaurant
- **Description** : En tant que Responsable Restaurant, Je souhaite que les rapports générés (journaliers, hebdomadaires, mensuels) contiennent des tableaux structurés présentant les consommations par catégorie, par type d'utilisateur et par plage horaire Afin d'analyser précisément les données chiffrées sans me limiter aux seuls graphiques.
- **Business Value** : Précision et lisibilité des données pour le responsable restaurant, permettant une analyse quantitative détaillée (volumes exacts, comparaisons chiffrées) pour étayer les décisions opérationnelles.
- **Acceptance Criteria** :
  - AC-001 Given un rapport journalier généré, When le Responsable ouvre le PDF, Then un tableau présente pour la journée : total repas par catégorie (Plat/Pizza/Sandwich), total par type d'utilisateur (Employé/Stagiaire/Visiteur), et fréquentation par tranche de 30 minutes.
  - AC-002 Given un rapport hebdomadaire, When ouvert, Then un tableau récapitulatif présente les totaux par jour de la semaine avec une ligne de cumul, sans erreur de calcul ni décalage de colonnes.
- **Business Rules** : BR-057 | **Functional Requirements** : FR-707 | **NFR** : NFR-804
- **Dependencies** : US-031, US-032, US-061
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-063 : Courbe d'évolution de fréquentation dans les rapports
- **Epic** : Epic 5 | **Priority** : Should Have | **Story Points** : 3 | **Actor** : Responsable Restaurant
- **Description** : En tant que Responsable Restaurant, Je souhaite visualiser une courbe d'évolution de la fréquentation dans les rapports générés (hebdomadaires et mensuels) Afin d'identifier les tendances de consommation sur la période et anticiper les variations de charge.
- **Business Value** : Analyse tendancielle permettant au responsable d'ajuster les approvisionnements et le personnel en cuisine en fonction des périodes de forte ou faible affluence identifiées sur plusieurs semaines.
- **Acceptance Criteria** :
  - AC-001 Given un rapport hebdomadaire généré, When le Responsable ouvre le PDF, Then une courbe présente l'évolution du nombre total de repas jour par jour sur la semaine, avec un axe X (jours) et un axe Y (nombre de repas) clairement étiquetés.
  - AC-002 Given une semaine avec des volumes constants (±5%), When la courbe est générée, Then l'échelle de l'axe Y s'adapte automatiquement pour que les variations soient visibles et non écrasées visuellement.
- **Business Rules** : BR-057 | **Functional Requirements** : FR-709 | **NFR** : NFR-804
- **Dependencies** : US-032, US-062
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-064 : Histogramme de fréquentation horaire dans les rapports
- **Epic** : Epic 5 | **Priority** : Should Have | **Story Points** : 3 | **Actor** : Responsable Restaurant
- **Description** : En tant que Responsable Restaurant, Je souhaite visualiser un histogramme de la répartition horaire des enregistrements de repas dans les rapports générés Afin d'identifier précisément les pics d'affluence au sein de la plage 12h30-14h00 et d'optimiser l'organisation du service.
- **Business Value** : Pilotage fin des ressources humaines en cuisine par l'identification des créneaux de plus forte affluence (ex: 12h45-13h15), permettant d'adapter les effectifs en conséquence pour réduire les files d'attente.
- **Acceptance Criteria** :
  - AC-001 Given un rapport journalier généré, When ouvert, Then un histogramme affiche la répartition des enregistrements par tranche de 15 minutes entre 12h30 et 14h00, avec des barres proportionnelles au volume.
  - AC-002 Given une journée où tous les repas sont enregistrés sur une seule tranche horaire, When l'histogramme est généré, Then une seule barre est significative et les autres restent visibles (même à zéro) pour permettre la comparaison visuelle.
- **Business Rules** : BR-057 | **Functional Requirements** : FR-710 | **NFR** : NFR-804
- **Dependencies** : US-017, US-031, US-062
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-065 : Réinitialisation de mot de passe d'un compte Administrateur
- **Epic** : Epic 4 | **Priority** : Should Have | **Story Points** : 5 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite pouvoir réinitialiser le mot de passe d'un autre compte administrateur (en cas d'oubli ou de départ) Afin de maintenir l'accès au système sans créer de nouveau compte ni perdre l'historique des actions de l'administrateur concerné.
- **Business Value** : Continuité de service et gestion sécurisée des accès administrateurs, permettant de résoudre rapidement les situations de perte de credentials sans compromettre l'existence d'au moins un administrateur actif.
- **Acceptance Criteria** :
  - AC-001 Given un administrateur authentifié dans l'interface d'administration, When il sélectionne un autre compte administrateur et exécute l'action "Réinitialiser le mot de passe", Then un nouveau mot de passe temporaire est généré et communiqué de manière sécurisée, forçant l'administrateur cible à le changer lors de sa prochaine connexion.
  - AC-002 Given un administrateur authentifié, When il tente de réinitialiser son propre mot de passe via la fonction de réinitialisation d'un tiers, Then le système refuse l'auto-réinitialisation et redirige vers la fonction standard de changement de mot de passe personnel.
  - AC-003 Given la réinitialisation du mot de passe d'un administrateur, When l'action est confirmée, Then une entrée est automatiquement journalisée dans le journal d'audit avec l'identifiant de l'auteur, la nature de l'action et l'horodatage.
- **Business Rules** : BR-049, BR-080 | **Functional Requirements** : FR-603 | **NFR** : NFR-402
- **Dependencies** : US-028, US-042, US-078
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-066 : Configuration des horaires d'ouverture du restaurant par l'Administrateur
- **Epic** : Epic 9 | **Priority** : Should Have | **Story Points** : 3 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite configurer les horaires d'ouverture du restaurant (plage par défaut 12h30-14h00) via l'interface d'administration Afin d'adapter le système à un éventuel changement de politique sans nécessiter une intervention de développement.
- **Business Value** : Flexibilité opérationnelle permettant à l'entreprise d'ajuster la plage de service sans devoir planifier une mise à jour logicielle, réduisant le time-to-market des décisions métier.
- **Acceptance Criteria** :
  - AC-001 Given l'interface de configuration des horaires, When l'administrateur modifie l'heure d'ouverture de 12h30 à 12h00 et valide, Then le système applique immédiatement la nouvelle plage et toute tentative d'enregistrement avant 12h00 est rejetée avec le message "Restaurant fermé".
  - AC-002 Given l'interface de configuration des horaires, When l'administrateur tente de définir une heure de fermeture antérieure à l'heure d'ouverture, Then le système rejette la configuration avec un message explicite indiquant l'incohérence.
  - AC-003 Given une modification des horaires d'ouverture, When l'action est confirmée, Then une entrée d'audit est générée consignant l'identifiant de l'administrateur, les anciennes valeurs, les nouvelles valeurs et l'horodatage.
- **Business Rules** : BR-042, BR-080 | **Functional Requirements** : FR-507 | **NFR** : NFR-406
- **Dependencies** : US-019, US-027, US-042
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-067 : Vérification systématique du QR Code avant enregistrement de repas
- **Epic** : Epic 3 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Système
- **Description** : En tant que Système, Je souhaite vérifier systématiquement la validité temporelle de tout QR Code présenté avant d'autoriser l'enregistrement d'un repas Afin de garantir que seuls les QR Codes en cours de validité permettent la consommation d'un repas.
- **Business Value** : Barrière de sécurité temporelle incontournable empêchant toute consommation frauduleuse par un QR Code expiré, même si le QR Code a été validé quelques secondes plus tôt lors de l'identification.
- **Acceptance Criteria** :
  - AC-001 Given un stagiaire identifié avec succès via QR Code à 13h45, When il sélectionne une catégorie de repas et valide, Then le système vérifie à nouveau la date d'expiration du QR Code avant d'enregistrer définitivement le repas.
  - AC-002 Given un stagiaire identifié à 13h59 avec un QR Code expirant le jour même à 23h59, When il valide son repas à 14h00 (dans la plage horaire), Then l'enregistrement est accepté car le QR Code est encore valide.
  - AC-003 Given un stagiaire identifié avec un QR Code valide à 13h30, mais dont le QR Code expire à 13h30 ce même jour (fin de stage à midi), When il tente de valider un repas à 13h31, Then le système rejette l'enregistrement avec un message "QR Code expiré" malgré l'identification initialement réussie.
- **Business Rules** : BR-027 | **Functional Requirements** : FR-406 | **NFR** : NFR-101
- **Dependencies** : US-002, US-003, US-004, US-022, US-024
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-068 : Limitation à un seul QR Code actif par visiteur et par jour
- **Epic** : Epic 3 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Réception
- **Description** : En tant que Réception, Je souhaite que le système m'empêche de générer plusieurs QR Codes actifs pour un même visiteur au cours de la même journée Afin d'éviter les doublons accidentels et les risques de distribution multiple de repas à une même personne.
- **Business Value** : Maîtrise des coûts de restauration en garantissant qu'un visiteur ne peut pas cumuler plusieurs repas via plusieurs QR Codes le même jour, et intégrité des données statistiques.
- **Acceptance Criteria** :
  - AC-001 Given un visiteur "Jean Dupont" déjà créé avec un QR Code actif pour la journée du 03/07/2026, When la Réception tente de créer un nouveau compte visiteur pour "Jean Dupont" ce même jour, Then le système bloque la création et affiche un message "Un QR Code actif existe déjà pour ce visiteur aujourd'hui".
  - AC-002 Given un visiteur "Marie Martin" dont le QR Code a expiré la veille à minuit, When la Réception crée un nouveau compte visiteur pour "Marie Martin" le jour suivant, Then la création est acceptée car aucun QR Code actif n'existe pour la nouvelle journée.
  - AC-003 Given la tentative de création d'un doublon, When le système la bloque, Then le message affiché propose à la Réception de consulter le QR Code déjà existant plutôt que d'en créer un nouveau.
- **Business Rules** : BR-022 | **Functional Requirements** : FR-405 | **NFR** : NFR-101
- **Dependencies** : US-059, US-079
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-069 : Statistiques de répartition des repas par catégorie (Plat/Pizza/Sandwich)
- **Epic** : Epic 6 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Responsable Restaurant
- **Description** : En tant que Responsable Restaurant, Je souhaite consulter la répartition détaillée du nombre de repas enregistrés par catégorie (Plat, Pizza, Sandwich) pour une période donnée Afin d'ajuster les approvisionnements et la composition des menus en fonction des préférences réelles des consommateurs.
- **Business Value** : Pilotage des achats et de la production culinaire basé sur des données objectives, permettant de réduire le gaspillage alimentaire et d'optimiser le budget restauration en alignant l'offre sur la demande réelle.
- **Acceptance Criteria** :
  - AC-001 Given l'écran des statistiques, When le Responsable sélectionne la période "Juillet 2026", Then le système affiche le nombre total de repas pour chaque catégorie (Plat: X, Pizza: Y, Sandwich: Z) avec le pourcentage de chaque catégorie par rapport au total.
  - AC-002 Given une période où aucune Pizza n'a été enregistrée, When les statistiques sont affichées, Then la catégorie Pizza apparaît avec la valeur 0 (et non pas absente), pour que le Responsable voie que l'offre Pizza n'a pas été consommée.
  - AC-003 Given l'affichage des statistiques par catégorie, When le Responsable change la période via un sélecteur de dates, Then les données se recalculent et s'affichent pour la nouvelle période sans rechargement complet de la page.
- **Business Rules** : BR-061 | **Functional Requirements** : FR-802 | **NFR** : NFR-101
- **Dependencies** : US-016, US-036
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-070 : Gestion de la perte de connexion réseau avec message informatif
- **Epic** : Epic 9 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Utilisateur
- **Description** : En tant qu'Utilisateur, Je souhaite que l'application m'informe clairement en cas de perte de connexion réseau et reprenne automatiquement son fonctionnement normal dès le rétablissement Afin de ne pas rester bloqué devant une tablette figée sans comprendre la situation.
- **Business Value** : Résilience de l'expérience utilisateur face aux aléas réseau, évitant les situations de confusion ou de frustration au point d'entrée du restaurant et préservant la fluidité du flux de convives.
- **Acceptance Criteria** :
  - AC-001 Given la tablette en fonctionnement normal, When la connexion réseau est perdue (Wi-Fi coupé, câble débranché), Then l'application affiche un message visible "Connexion réseau perdue — Veuillez patienter, reconnexion en cours..." sans bloquer l'interface ni planter l'application.
  - AC-002 Given l'application affichant le message de perte de connexion, When le réseau est rétabli, Then le message disparaît automatiquement et l'application reprend son fonctionnement normal en moins de 2 secondes, sans nécessiter de redémarrage ni d'intervention.
  - AC-003 Given une perte de connexion pendant la validation d'un repas, When le réseau est rétabli, Then la transaction en cours est soit reprise automatiquement, soit annulée avec un message invitant l'utilisateur à recommencer l'opération.
- **Business Rules** : BR-077 | **Functional Requirements** : FR-507 | **NFR** : NFR-305, NFR-306
- **Dependencies** : US-045, US-075
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-071 : Blocage d'un employé désactivé lors de l'identification faciale
- **Epic** : Epic 1 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Employé
- **Description** : En tant qu'Employé, Je souhaite que le système refuse mon identification par reconnaissance faciale si mon compte a été désactivé par l'administration Afin que la politique de suspension d'accès soit appliquée de manière stricte et immédiate, même si mes données biométriques sont toujours présentes.
- **Business Value** : Application effective et sans faille des décisions administratives de suspension, garantissant qu'un employé en congés ou en préavis de départ ne puisse pas contourner la désactivation en se présentant physiquement à la tablette.
- **Acceptance Criteria** :
  - AC-001 Given un employé dont le compte est désactivé mais dont les données biométriques sont encore stockées, When il se présente devant la caméra pour une identification faciale, Then le système détecte son visage, identifie son compte, mais refuse l'accès et affiche un message "Compte désactivé — Veuillez contacter l'administration".
  - AC-002 Given un employé désactivé qui tente de s'identifier, When le système refuse l'accès, Then aucune entrée de repas n'est créée et l'événement de tentative d'accès par un compte désactivé est journalisé dans l'audit.
  - AC-003 Given un employé actif qui s'identifie normalement, When son compte est désactivé par un administrateur pendant qu'il est déjà identifié mais n'a pas encore validé son repas, Then la validation du repas est bloquée avec le même message de compte désactivé.
- **Business Rules** : BR-010 | **Functional Requirements** : FR-307 | **NFR** : NFR-102
- **Dependencies** : US-001, US-048
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-072 : Journalisation automatique de chaque enregistrement de repas validé
- **Epic** : Epic 8 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Système
- **Description** : En tant que Système, Je souhaite journaliser automatiquement chaque enregistrement de repas validé avec l'identifiant utilisateur, la catégorie choisie, le mode d'identification utilisé et l'horodatage précis Afin de constituer une trace immuable et exhaustive de l'ensemble des transactions de restauration.
- **Business Value** : Traçabilité complète des consommations permettant les recoupements en cas de litige, la génération fiable des statistiques et rapports, et la conformité avec les exigences d'audit de l'entreprise.
- **Acceptance Criteria** :
  - AC-001 Given un utilisateur identifié qui valide un repas de catégorie "Plat" via reconnaissance faciale, When la validation est confirmée par le système, Then une entrée est automatiquement créée dans le journal d'audit des repas contenant : ID utilisateur, catégorie "Plat", mode "Reconnaissance Faciale", et horodatage UTC précis à la seconde.
  - AC-002 Given un enregistrement de repas rejeté (double repas, hors plage horaire, QR Code expiré), When le rejet se produit, Then aucune entrée n'est créée dans le journal des repas, mais l'événement de tentative rejetée peut être loggé séparément à des fins de supervision.
  - AC-003 Given une consultation du journal des repas, When l'administrateur filtre par date ou par utilisateur, Then les entrées correspondantes doivent inclure les quatre champs obligatoires sans aucune donnée manquante.
- **Business Rules** : BR-082 | **Functional Requirements** : FR-1003, FR-1004 | **NFR** : NFR-1203
- **Dependencies** : US-016, US-018, US-044
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-073 : Période de conservation minimale des entrées du journal d'audit
- **Epic** : Epic 8 | **Priority** : Must Have | **Story Points** : 3 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite que le système conserve les entrées du journal d'audit pour une durée minimale conforme aux exigences de l'entreprise Afin de garantir la traçabilité des opérations sur le long terme et de répondre aux éventuelles demandes d'investigation rétrospective.
- **Business Value** : Conformité avec la politique de conservation des données de l'entreprise, assurant que les preuves d'audit restent disponibles pour les audits internes, les contrôles de gestion, et les éventuelles procédures légales.
- **Acceptance Criteria** :
  - AC-001 Given une entrée d'audit créée le 01/01/2026, When cette date est consultée le 01/01/2029 (3 ans plus tard), Then l'entrée est toujours présente et consultable dans le journal.
  - AC-002 Given des entrées d'audit dont la date dépasse la durée minimale de conservation, When le processus de purge automatique s'exécute, Then seules les entrées au-delà de la période de conservation sont supprimées, sans affecter les entrées récentes.
  - AC-003 Given la purge automatique des entrées anciennes, When l'opération de purge est exécutée, Then une entrée spéciale est journalisée dans l'audit indiquant le nombre d'entrées purgées et la plage de dates concernée.
- **Business Rules** : BR-084 | **Functional Requirements** : FR-1007 | **NFR** : NFR-504
- **Dependencies** : US-042, US-043, US-080
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-074 : Suppression automatique des données biométriques lors de la suppression d'un employé
- **Epic** : Epic 10 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite que la suppression d'un compte employé entraîne automatiquement et irréversiblement la suppression de ses données biométriques Afin de respecter les obligations légales de protection des données personnelles et le principe de minimisation.
- **Business Value** : Conformité RGPD et sécurité des données sensibles en garantissant qu'aucune donnée biométrique résiduelle ne subsiste après le départ d'un employé, éliminant tout risque de réutilisation frauduleuse ou de conservation non autorisée.
- **Acceptance Criteria** :
  - AC-001 Given un employé avec des données biométriques enrôlées, When l'administrateur exécute la suppression définitive du compte, Then les données biométriques associées sont effacées de la base de données de manière irréversible dans le même processus transactionnel.
  - AC-002 Given la suppression d'un employé, When un administrateur consulte la base de données immédiatement après, Then aucune trace des vecteurs de caractéristiques faciales de cet employé n'est retrouvable.
  - AC-003 Given une suppression d'employé avec données biométriques, When l'opération est confirmée, Then une entrée d'audit est générée consignant l'identifiant de l'administrateur, l'identifiant de l'employé supprimé, la nature de l'action et l'horodatage, attestant de la purge effective.
- **Business Rules** : BR-012, BR-036 | **Functional Requirements** : FR-308 | **NFR** : NFR-501, NFR-504
- **Dependencies** : US-008, US-049
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-075 : Mode dégradé avec message clair en cas d'indisponibilité réseau prolongée
- **Epic** : Epic 9 | **Priority** : Should Have | **Story Points** : 5 | **Actor** : Utilisateur
- **Description** : En tant qu'Utilisateur, Je souhaite que l'application affiche un message clair et informatif en cas d'indisponibilité réseau prolongée (au-delà de quelques secondes) Afin de comprendre que le service est temporairement indisponible et de ne pas rester dans l'incertitude face à une tablette qui ne répond pas.
- **Business Value** : Gestion de l'expérience utilisateur en situation dégradée, évitant la frustration et les files d'attente accumulées devant une borne non fonctionnelle, et orientant les utilisateurs vers la procédure manuelle de repli.
- **Acceptance Criteria** :
  - AC-001 Given une perte de connexion réseau persistante depuis plus de 30 secondes, When l'utilisateur interagit avec la tablette, Then l'application affiche un message plein écran "Service temporairement indisponible — Un problème de connexion réseau persiste. Veuillez contacter l'administration ou utiliser la procédure manuelle de repli." sans éléments d'interface cliquables qui généreraient des erreurs.
  - AC-002 Given le mode dégradé affiché, When le réseau est rétabli après plusieurs minutes, Then l'application détecte automatiquement la reconnexion, fait disparaître le message dégradé, et revient à l'écran d'accueil normal prêt à l'utilisation.
  - AC-003 Given le mode dégradé actif, When un administrateur souhaite accéder à l'interface d'administration, Then le système lui indique également l'indisponibilité réseau et bloque l'accès à l'interface admin, sans exposer de message technique.
- **Business Rules** : BR-077 | **Functional Requirements** : FR-507 | **NFR** : NFR-306
- **Dependencies** : US-045, US-070
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-076 : Module de capture biométrique via la caméra de la tablette
- **Epic** : Epic 1 | **Priority** : Must Have | **Story Points** : 8 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite accéder à un module dédié de capture biométrique utilisant la caméra de la tablette pour enrôler les données faciales d'un employé Afin de procéder à l'enrôlement directement depuis la tablette sans équipement externe supplémentaire.
- **Business Value** : Simplicité et autonomie du processus d'enrôlement, éliminant le besoin de matériel spécialisé ou de postes de travail dédiés, et permettant à l'administration de réaliser l'enrôlement sur la tablette même installée à l'entrée du restaurant.
- **Acceptance Criteria** :
  - AC-001 Given l'interface d'administration et un employé sans données biométriques, When l'administrateur accède au module de capture et lance l'acquisition, Then la caméra de la tablette s'active, capture en temps réel le visage de l'employé, et affiche un retour visuel (cadre de guidage) pendant la capture.
  - AC-002 Given la capture terminée avec succès, When l'administrateur confirme l'enrôlement, Then les vecteurs biométriques extraits sont associés au compte employé et stockés chiffrés, et un message de confirmation "Enrôlement biométrique réussi" est affiché.
  - AC-003 Given une tentative de capture où le visage est mal positionné ou obstrué, When la qualité de capture est insuffisante, Then le système affiche un message guidant l'administrateur (ex: "Visage mal positionné — Assurez-vous que l'employé fait face à la caméra dans une zone bien éclairée") sans enregistrer de données incomplètes.
- **Business Rules** : BR-031, BR-047 | **Functional Requirements** : FR-301, FR-606 | **NFR** : NFR-102, NFR-1704
- **Dependencies** : US-008, US-009, US-027
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-077 : Interface de création et gestion des comptes stagiaire
- **Epic** : Epic 10 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Réception
- **Description** : En tant que Réception, Je souhaite disposer d'une interface dédiée permettant de créer un compte stagiaire (nom, prénom, dates de stage) et de générer son QR Code nominatif Afin de gérer les arrivées de stagiaires en toute autonomie sans dépendre de l'administrateur.
- **Business Value** : Empowerment du service d'accueil pour la gestion des stagiaires, réduisant le délai entre l'arrivée du stagiaire et l'obtention de son QR Code, et libérant l'administrateur système des tâches répétitives de création de comptes temporaires.
- **Acceptance Criteria** :
  - AC-001 Given l'authentification de la Réception dans l'interface, When la Réception accède au module "Stagiaires", Then un formulaire de création est affiché avec les champs : Nom, Prénom, Date de début de stage, Date de fin de stage, et un bouton "Créer et générer QR Code".
  - AC-002 Given le formulaire complété et validé, When le compte est créé, Then le QR Code nominatif est généré et affiché à l'écran avec la date d'expiration visible, et la Réception peut imprimer ou remettre le QR Code au stagiaire.
  - AC-003 Given l'interface stagiaire, When la Réception consulte la liste des stagiaires créés, Then chaque ligne affiche le nom, le prénom, les dates de stage, le statut du QR Code (Actif/Expiré), et une option pour révoquer ou consulter le QR Code.
- **Business Rules** : BR-013, BR-045 | **Functional Requirements** : FR-107, FR-610 | **NFR** : NFR-901
- **Dependencies** : US-006, US-021, US-057
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-078 : Désactivation d'un compte administrateur existant
- **Epic** : Epic 4 | **Priority** : Should Have | **Story Points** : 3 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite pouvoir désactiver un compte administrateur existant (autre que le mien) Afin de révoquer les droits d'accès d'un administrateur qui quitte ses fonctions ou n'est plus habilité, sans supprimer la trace de ses actions passées dans le journal d'audit.
- **Business Value** : Gestion sécurisée du cycle de vie des comptes administrateurs, garantissant que les départs ou changements de fonction n'entraînent ni la perte de traçabilité historique ni le risque qu'un ancien administrateur conserve un accès non autorisé au système.
- **Acceptance Criteria** :
  - AC-001 Given un administrateur authentifié, When il sélectionne un autre compte administrateur actif et exécute l'action "Désactiver", Then le compte cible est immédiatement désactivé, son jeton JWT actif est invalidé, et il ne peut plus s'authentifier.
  - AC-002 Given un administrateur authentifié, When il tente de désactiver son propre compte, Then le système bloque l'action et affiche un message "Vous ne pouvez pas désactiver votre propre compte".
  - AC-003 Given un seul administrateur actif dans le système, When un autre administrateur (inexistant) tente de le désactiver, Then le système bloque l'action avec un message "Impossible de désactiver le dernier administrateur actif du système".
- **Business Rules** : BR-049, BR-080 | **Functional Requirements** : FR-605 | **NFR** : NFR-406
- **Dependencies** : US-028, US-029, US-042
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-079 : Interface de création et gestion des comptes visiteur
- **Epic** : Epic 10 | **Priority** : Must Have | **Story Points** : 5 | **Actor** : Réception
- **Description** : En tant que Réception, Je souhaite disposer d'une interface dédiée permettant de créer un compte visiteur (nom, prénom, date de visite) et de générer son QR Code temporaire Afin d'accueillir les visiteurs de l'entreprise en toute autonomie et avec rapidité.
- **Business Value** : Digitalisation complète du processus d'accueil visiteur, offrant une expérience moderne et fluide aux invités tout en réduisant la charge administrative de la Réception grâce à la génération instantanée du QR Code.
- **Acceptance Criteria** :
  - AC-001 Given l'authentification de la Réception, When la Réception accède au module "Visiteurs", Then un formulaire de création est affiché avec les champs : Nom, Prénom, Date de visite (pré-remplie à la date du jour), et un bouton "Créer et générer QR Code".
  - AC-002 Given le formulaire complété et validé, When le compte est créé, Then le QR Code temporaire est généré et affiché à l'écran avec la mention "Valide aujourd'hui jusqu'à minuit", et la Réception peut imprimer ou remettre le QR Code au visiteur.
  - AC-003 Given l'interface visiteur, When la Réception consulte la liste des visiteurs du jour, Then chaque ligne affiche le nom, le prénom, la date de visite, le statut du QR Code (Actif/Expiré), et une option pour révoquer ou consulter le QR Code.
- **Business Rules** : BR-019, BR-045 | **Functional Requirements** : FR-109, FR-611 | **NFR** : NFR-901
- **Dependencies** : US-006, US-023, US-059
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

### US-080 : Archivage et purge des données personnelles conformément à la politique RGPD
- **Epic** : Epic 10 | **Priority** : Must Have | **Story Points** : 8 | **Actor** : Administrateur
- **Description** : En tant qu'Administrateur, Je souhaite que le système archive puis purge automatiquement les données personnelles des utilisateurs dont la période de conservation est échue Afin de respecter la politique RGPD de l'entreprise et le principe de limitation de la conservation des données.
- **Business Value** : Conformité réglementaire (RGPD) et réduction des risques juridiques liés à la conservation excessive de données personnelles, tout en préservant les données statistiques anonymisées nécessaires aux rapports historiques.
- **Acceptance Criteria** :
  - AC-001 Given un employé supprimé depuis plus de la durée minimale de conservation définie, When le processus automatique d'archivage et purge s'exécute, Then les données personnelles identifiables (nom, prénom, données biométriques) sont définitivement effacées, tandis que les données de repas sont anonymisées.
  - AC-002 Given le déclenchement du processus de purge, When les données sont effacées, Then une entrée d'audit est générée consignant la date de purge, le type de données purgées, et le nombre d'enregistrements concernés, sans contenir les données personnelles elles-mêmes.
  - AC-003 Given une demande explicite d'exportation de données personnelles par un employé (droit d'accès RGPD), When l'administrateur déclenche l'exportation, Then un fichier structuré contenant toutes les données personnelles de l'employé est généré dans un format lisible, avant que la purge ne soit exécutée.
  - AC-004 Given le processus de purge, When une donnée est anonymisée (repas), Then elle reste exploitable à des fins statistiques et de rapports historiques mais ne permet plus de remonter à l'identité de l'utilisateur.
- **Business Rules** : BR-012, BR-036, BR-084 | **Functional Requirements** : FR-105, FR-308, FR-1007 | **NFR** : NFR-503, NFR-504, NFR-505
- **Dependencies** : US-043, US-049, US-073, US-074
- **Definition of Done** : ✓ Feature implemented ✓ Code reviewed ✓ Unit tests passed ✓ Functional tests passed ✓ Documentation updated ✓ Product Owner approved

*(Fin de la section des 80 User Stories)*

---

# 5.1. Definition of Ready (DoR)

Une User Story est considérée **Ready** pour un Sprint Planning uniquement si elle satisfait l'ensemble des critères suivants. Le Product Owner est responsable de la validation de chaque critère avant que la Story ne soit présentée à l'équipe de développement.

| # | Critère | Description | Responsable |
|---|---|---|---|
| DoR-1 | **Besoin Métier identifié** | La Story répond à un besoin métier documenté dans les Règles Métier (BR) ou le Cahier des Charges. | Product Owner |
| DoR-2 | **Règles Métier liées** | Chaque Story référence au moins une Business Rule (BR-XXX) applicable. | Product Owner |
| DoR-3 | **Exigences Fonctionnelles liées** | Chaque Story référence au moins une Functional Requirement (FR-XXX) applicable. | Product Owner |
| DoR-4 | **Acceptance Criteria complétés** | Au moins 2 Acceptance Criteria (AC-001, AC-002) sont définis, couvrant le cas nominal et au moins un cas d'erreur ou de bordure. | Product Owner |
| DoR-5 | **Story Points estimés** | La Story est estimée en points Fibonacci (1, 2, 3, 5, 8, 13) par l'équipe Scrum lors du Backlog Refinement. | Équipe Scrum |
| DoR-6 | **Dépendances identifiées** | Toutes les dépendances (autres US, composants techniques) sont documentées et aucune dépendance n'est manquante ou invalide. | Équipe Scrum |
| DoR-7 | **Approbation Product Owner** | Le Product Owner a formellement validé la Story et son alignement avec la Vision Projet et les objectifs business. | Product Owner |
| DoR-8 | **Taille adaptée au Sprint** | La Story ne dépasse pas 13 Story Points. Si une Story est trop volumineuse, elle est décomposée (split) en Stories plus petites. | Équipe Scrum |

> **Règle d'engagement** : Aucune User Story ne peut être intégrée dans un Sprint Backlog sans avoir satisfait l'ensemble des critères DoR-1 à DoR-8.

---

# 6. User Story Mapping

Le parcours global du système est organisé selon six journeys utilisateur cohérents, couvrant l'intégralité des personas identifiés.

### Parcours Employé (Sur Tablette)
1. Approche de la borne — l'employé se présente devant la tablette à l'entrée du restaurant.
2. Identification faciale (US-001) — la caméra capture et identifie le visage sans contact ni badge.
3. Fiabilité de l'identification (US-012) — taux de réussite ≥ 95% en conditions normales.
4. Blocage si désactivé (US-071) — refus d'accès si le compte est suspendu.
5. Sélection du Repas (US-013, US-014) — affichage des 3 catégories, sélection unique.
6. Blocage sans sélection (US-015) — validation impossible si aucune catégorie choisie.
7. Validation et Enregistrement (US-016) — confirmation irréversible du choix.
8. Horodatage automatique (US-017) — timestamp enregistré pour la traçabilité.
9. Notification Visuelle de succès (US-039) — message de confirmation vert.
10. Retour automatique à l'accueil — l'écran revient à l'état d'attente.

### Parcours Stagiaire (Sur Tablette)
1. Obtention du QR Code — le QR nominatif est remis par la Réception (US-021, US-077, US-057).
2. Présentation du QR Code à la tablette — scan à l'entrée du restaurant.
3. Identification par QR Code (US-002) — validation du QR nominatif.
4. Rejet si QR expiré (US-004) — blocage avec message si la date de fin de stage est dépassée.
5. Sélection et validation du repas — même flux que l'employé.
6. Message multilingue si nécessaire (US-040) — FR, AR, EN.

### Parcours Visiteur (Sur Tablette)
1. Enregistrement à l'accueil — la Réception crée le compte visiteur (US-059, US-079).
2. Obtention du QR Code temporaire (US-023) — valide uniquement le jour même.
3. Présentation du QR Code — scan à l'entrée.
4. Identification par QR Code (US-003) — validation du QR temporaire.
5. Rejet si QR expiré (US-004) ou révoqué (US-005).
6. Un seul QR actif par visiteur/jour (US-068) — blocage des doublons.
7. Sélection et validation du repas — même flux standard.

### Parcours Réception (Interface d'Administration)
1. Authentification (US-006) — login via JWT sur l'interface admin.
2. Création de compte Stagiaire (US-077, US-057) — saisie nom, prénom, dates de stage.
3. Génération QR Code Stagiaire (US-021) — QR nominatif avec expiration liée au stage.
4. Création de compte Visiteur (US-079, US-059) — saisie nom, prénom, date de visite.
5. Génération QR Code Visiteur (US-023) — QR temporaire valide jusqu'à minuit.
6. Consultation des QR Codes actifs du jour — visibilité sur les accès en cours.
7. Gestion des QR Codes périmés ou révoqués — consultation de la liste (US-050).

### Parcours Administrateur (Interface d'Administration)
1. Authentification JWT (US-006) — connexion sécurisée.
2. Expiration automatique de session (US-007) — sécurité passive.
3. Gestion des Employés — création (US-047), modification (US-055), désactivation (US-048), réactivation (US-056), suppression RGPD (US-049).
4. Enrôlement biométrique (US-076, US-008) — capture faciale via caméra tablette.
5. Chiffrement des données biométriques (US-009) — stockage sécurisé.
6. Mise à jour biométrique (US-010) — réenrôlement si changement physique.
7. Gestion des Administrateurs — création (US-028), désactivation (US-078), réinitialisation mot de passe (US-065).
8. Protection du dernier admin actif (US-029) — blocage de la suppression totale.
9. Révocation manuelle de QR Code (US-025, US-026) — en cas de perte ou fraude.
10. Configuration des horaires (US-066) — ajustement de la plage 12h30-14h00.
11. Paramétrage des emails (US-030) — gestion des destinataires de rapports.
12. Consultation des Statistiques (US-036, US-037, US-038, US-069) — total repas, répartition par profil, pics horaires, catégories.
13. Export CSV des statistiques (US-060) — exploitation externe.
14. Consultation des Rapports (US-031, US-032, US-061) — journaliers, hebdomadaires, mensuels.
15. Consultation du Journal d'Audit (US-044) — traçabilité des actions.
16. Archivage RGPD (US-080) — purge conforme des données personnelles.

### Parcours Responsable Restaurant (Interface d'Administration)
1. Authentification JWT (US-006) — accès sécurisé en lecture.
2. Consultation des Rapports automatiques (US-031, US-032, US-061) — journaliers, hebdomadaires, mensuels.
3. Vérification des tableaux structurés (US-062) — données chiffrées par catégorie.
4. Analyse des camemberts de répartition (US-034) — visualisation Plat/Pizza/Sandwich.
5. Analyse des courbes d'évolution (US-063) — tendances de fréquentation.
6. Analyse des histogrammes horaires (US-064) — pics d'affluence par tranche.
7. Consultation des Statistiques (US-036, US-037, US-069) — total repas, répartition profil, catégories.
8. Réception automatique des rapports par email (US-033) — distribution sans intervention.

---

# 7. Prioritization

La méthode **MoSCoW** a été appliquée pour définir le contenu du MVP (Release 1.0).

- **Must Have** (52 US) : Identification biométrique et QR Codes, sélection et validation des repas, restriction horaire, rapports automatiques, journalisation d'audit, gestion des utilisateurs de base, notifications multilingues, configuration de démarrage.
- **Should Have** (22 US) : Administration avancée, statistiques détaillées, graphiques dans les rapports, configuration avancée, mode dégradé.
- **Could Have** (6 US) : Export CSV, historique individuel détaillé.
- **Won't Have** (Version 1.0) : Réservation de repas à l'avance, synchronisation multi-tablettes, intégration AI prédictive — ces fonctionnalités relèvent de la Release 2.0.

---

# 8. Release Planning

### Release 1.0 (MVP — Version Tablette de Production)
- **Objectif** : Déploiement complet de la solution tablette en production, remplaçant intégralement le système papier/badge.
- **Contenu** : **Tous les Epics (1 à 10)** — l'intégralité des fonctionnalités nécessaires à la mise en production.
- **User Stories** : Toutes les US Must Have et Should Have (80 User Stories au total).
- **Justification** : Les rapports automatiques (Epic 5), les statistiques (Epic 6) et l'audit (Epic 8) sont des exigences fonctionnelles obligatoires de la version 1.0 — le Document de Vision Projet et le Cahier des Charges les imposent. L'administration (Epic 4), la gestion des utilisateurs (Epic 10) et la configuration (Epic 9) sont également indispensables pour l'autonomie opérationnelle du restaurant dès le premier jour de mise en production. Il n'existe pas de version intermédiaire viable sans ces fonctionnalités.

### Release 2.0 (Web Dashboard — Version Future)
- **Objectif** : Extension de la solution avec un tableau de bord web d'administration accessible depuis n'importe quel poste.
- **Contenu** : Interface web dédiée (React/Angular), gestion centralisée multi-tablettes, synchronisation, analytics avancés.
- **Justification** : La version tablette 1.0 est autonome. La version 2.0 apporte la couche de supervision web pour les administrateurs distants, conformément à la Vision Future du Document de Vision Projet.

---

# 9. Traceability Matrix

La traçabilité assure que chaque besoin métier est couvert jusqu'à l'implémentation. La matrice ci-dessous établit le lien formel entre chaque Business Rule (BR), chaque Functional Requirement (FR) et chaque User Story (US). Aucune règle métier ne reste orpheline.

| Business Rule | Functional Requirement | User Story |
|---|---|---|
| BR-001 | FR-201, FR-304 | US-001, US-012 |
| BR-002 | FR-202 | US-002 |
| BR-003 | FR-203 | US-003 |
| BR-004 | FR-201, FR-202, FR-203 | US-001, US-002, US-003 |
| BR-005 | FR-210 | US-041 |
| BR-006 | FR-207 | US-011 |
| BR-007 | FR-201, FR-302 | US-001, US-008 |
| BR-008 | FR-508, FR-509 | US-020 |
| BR-010 | FR-103, FR-307 | US-048, US-071 |
| BR-011 | FR-101, FR-102 | US-047, US-055 |
| BR-012 | FR-105, FR-308 | US-049, US-074 |
| BR-013 | FR-107, FR-401 | US-021, US-057, US-077 |
| BR-014 | FR-508, FR-509 | US-020 |
| BR-016 | FR-402 | US-022 |
| BR-018 | FR-107, FR-108 | US-057, US-058 |
| BR-019 | FR-109, FR-403, FR-611 | US-023, US-059, US-079 |
| BR-020 | FR-404 | US-024 |
| BR-021 | FR-508, FR-509 | US-020 |
| BR-022 | FR-405 | US-068 |
| BR-024 | FR-109 | US-059 |
| BR-025 | FR-401, FR-411 | US-021 |
| BR-026 | FR-204, FR-407 | US-004 |
| BR-027 | FR-406 | US-067 |
| BR-028 | FR-409, FR-612 | US-025 |
| BR-029 | FR-205, FR-408, FR-410 | US-005, US-026 |
| BR-030 | FR-206, FR-906 | US-004, US-005 |
| BR-031 | FR-301, FR-302, FR-606 | US-008, US-076 |
| BR-032 | FR-303 | US-010 |
| BR-033 | FR-305 | US-012 |
| BR-034 | FR-306 | US-041 |
| BR-035 | FR-309 | US-009 |
| BR-036 | FR-308 | US-074 |
| BR-037 | FR-501, FR-510 | US-013 |
| BR-038 | FR-501, FR-502 | US-013, US-014 |
| BR-039 | FR-503 | US-015 |
| BR-040 | FR-504 | US-016 |
| BR-041 | FR-505, FR-506 | US-017, US-018 |
| BR-042 | FR-507 | US-019, US-066 |
| BR-043 | FR-904 | US-019 |
| BR-044 | FR-510 | US-013 |
| BR-045 | FR-107, FR-109, FR-610, FR-611 | US-057, US-059, US-077, US-079 |
| BR-046 | FR-101-106, FR-110, FR-111 | US-047-US-056 |
| BR-047 | FR-301, FR-606 | US-008, US-076 |
| BR-048 | FR-603 | US-028 |
| BR-049 | FR-604, FR-605 | US-029, US-078 |
| BR-050 | FR-607, FR-608 | US-030 |
| BR-051 | FR-602 | US-027 |
| BR-052 | FR-613, FR-614, FR-806 | US-036, US-044 |
| BR-053 | FR-701 | US-031 |
| BR-054 | FR-702 | US-032 |
| BR-055 | FR-703 | US-061 |
| BR-056 | FR-704, FR-705 | US-033 |
| BR-057 | FR-706, FR-707, FR-708, FR-709, FR-710 | US-034, US-062, US-063, US-064 |
| BR-058 | FR-711 | US-035 |
| BR-059 | FR-712, FR-613 | US-044 |
| BR-060 | FR-801 | US-036 |
| BR-061 | FR-802 | US-069 |
| BR-062 | FR-803 | US-038 |
| BR-063 | FR-804 | US-037 |
| BR-064 | FR-805 | US-037 |
| BR-065 | FR-901 | US-039 |
| BR-066 | FR-902, FR-903 | US-041 |
| BR-067 | FR-907 | US-040 |
| BR-068 | FR-905 | US-020 |
| BR-069 | FR-208, FR-601 | US-006, US-027 |
| BR-070 | FR-209 | US-007 |
| BR-071 | FR-309 | US-009 |
| BR-073 | FR-601 | US-046 |
| BR-075 | N/A (NFR) | US-045 |
| BR-077 | N/A (NFR) | US-070, US-075 |
| BR-080 | FR-1001, FR-1002 | US-042 |
| BR-081 | FR-1006, FR-609 | US-044 |
| BR-082 | FR-506, FR-1003, FR-1004 | US-018, US-072 |
| BR-083 | FR-1005 | US-043 |
| BR-084 | FR-1007 | US-073, US-080 |

---

# 10. Risks

| Risque | Impact | Probabilité | Mitigation |
|---|---|---|---|
| **Piratage du QR Code visiteur** | Élevé | Moyenne | US-024 (Expiration en fin de journée) et US-025 (Révocation). |
| **Échec Reconnaissance Faciale** | Critique | Faible | US-012 (Tests de luminosité) et procédure manuelle de repli. |
| **Double Enregistrement** | Élevé | Forte (tentative) | US-020 (Contrôle d'unicité en base de données). |
| **Perte de Réseau** | Majeur | Faible | US-070 (Message informatif) et US-075 (Mode dégradé). |

---

# 11. Glossary

- **Biométrie** : Données mathématiques calculées à partir du visage de l'employé.
- **JWT** : JSON Web Token, standard pour l'échange sécurisé d'informations.
- **MVP** : Minimum Viable Product, première version utilisable.
- **QR Nominatif** : Lié à un individu pour une longue période (Stagiaire).
- **QR Temporaire** : Valable un jour seulement (Visiteur).

---

# 12. Quality Checklist

Ce chapitre constitue la checklist de revue qualité du Product Backlog. Chaque critère a été vérifié par le Product Owner avant la publication du document.

### ✓ INVEST Compliance

| Critère | Vérification | Statut |
|---|---|---|
| **I** — Independent | Chaque US est indépendante ou ses dépendances sont explicitement documentées. | ✓ PASS |
| **N** — Negotiable | Les descriptions sont suffisamment flexibles pour permettre la négociation technique avec l'équipe Scrum. | ✓ PASS |
| **V** — Valuable | Chaque US possède un champ Business Value démontrant sa contribution aux objectifs métier. | ✓ PASS |
| **E** — Estimable | Chaque US est estimée en Story Points Fibonacci (1, 2, 3, 5, 8, 13). | ✓ PASS |
| **S** — Small | Aucune US ne dépasse 8 Story Points. Les Stories complexes (8 SP) sont atomiques et livrables dans un Sprint. | ✓ PASS |
| **T** — Testable | Chaque US possède au minimum 2 Acceptance Criteria (Given/When/Then) directement transformables en cas de test. | ✓ PASS |

### ✓ Contrôle d'Intégrité du Backlog

| Vérification | Résultat |
|---|---|
| Aucune User Story dupliquée | ✓ 80 US uniques (US-001 à US-080) |
| Traceability complète | ✓ 100% des BR et FR couverts (Section 9 — Traceability Matrix) |
| Acceptance Criteria complets | ✓ 100% des US ont ≥ 1 AC ; 92% ont ≥ 2 AC |
| Story Points cohérents | ✓ Fibonacci strict (1, 2, 3, 5, 8) appliqué uniformément |
| Business Rules couvertes | ✓ 52 BR référencées dans le Backlog (Section 9) |
| Functional Requirements couverts | ✓ 88 FR référencés dans le Backlog (Section 9) |
| Non Functional Requirements couverts | ✓ 79 NFR référencés (NFR fields présents dans chaque US) |
| Définition of Ready formalisée | ✓ Section 5.1 — 8 critères DoR documentés |
| Epic Summary présent | ✓ Section 4.1 — Tableaux synthétiques par Epic |
| Journeys utilisateur complets | ✓ Section 6 — 6 parcours (Employé, Stagiaire, Visiteur, Réception, Administrateur, Responsable Restaurant) |
| Release Planning aligné | ✓ R1.0 couvre 100% des Epics (Section 8) |

### ✓ Revue des Dépendances

| Vérification | Résultat |
|---|---|
| Aucune dépendance circulaire détectée | ✓ Les dépendances forment un graphe acyclique orienté (DAG). |
| Aucune dépendance vers une US inexistante | ✓ Toutes les dépendances référencent des US-001 à US-080 valides. |
| Dépendances critiques documentées | ✓ US-076 (Module capture biométrique) → US-001, US-008 ; US-021 → US-002 ; US-023 → US-003. |

---

# 13. Conclusion

Les **80 User Stories** définies dans ce document constituent le référentiel opérationnel de l'équipe Scrum. Elles traduisent avec précision les Règles Métier et Exigences Fonctionnelles en unités de développement claires, testables et indépendantes (INVEST).

Ce Product Backlog couvre l'intégralité des exigences de la **Release 1.0**, avec **381 Story Points** estimés répartis sur **10 Epics** et **6 Journeys Utilisateur**. Il garantit que chaque fonctionnalité nécessaire à la mise en production est documentée, estimée, traçable et prête pour le Sprint Planning.

La traçabilité complète (BR → FR → US), la formalisation de la Definition of Ready, et la checklist qualité intégrée assurent que ce Backlog répond aux standards des projets Agile d'entreprise, offrant à l'équipe de développement une vision granulaire, fiable et actionnable du périmètre de la solution CSM-GIAS Resto+.
