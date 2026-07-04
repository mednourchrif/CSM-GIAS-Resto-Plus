# Product Backlog
## CSM-GIAS Resto+
### Solution Intelligente de Gestion du Restaurant d'Entreprise

---

## 1. Page de Garde

| Champ | Détail |
|---|---|
| **Nom du projet** | CSM-GIAS Resto+ |
| **Sous-titre** | Solution Intelligente de Gestion du Restaurant d'Entreprise |
| **Titre du document** | Product Backlog |
| **Référence** | CSM-GIAS-RESTO-PB-v1.0 |
| **Version** | 1.0 |
| **Date** | Juillet 2026 |
| **Auteur** | Product Owner Senior — Département Informatique |
| **Encadrant** | Responsable Technique / DSI |
| **Confidentialité** | Usage interne — Document propriétaire |
| **Statut** | Approuvé pour Sprint Planning |

### Historique des Révisions

| Version | Date | Auteur | Description |
|---|---|---|---|
| 0.1 | Juin 2026 | Stagiaire — Département IT | Ébauche initiale sur base des User Stories provisoires |
| 0.9 | Juillet 2026 | Stagiaire — Département IT | Révision suite à validation du document User Stories v1.0 |
| 1.0 | 04/07/2026 | Product Owner Senior | Version finale approuvée pour Sprint Planning |

---

## 2. Introduction

### 2.1 Qu'est-ce qu'un Product Backlog ?

Le Product Backlog est le référentiel central et ordonné de l'ensemble des fonctionnalités, améliorations et exigences d'un produit logiciel. Dans le cadre de la méthodologie Scrum, il constitue l'unique source de vérité pour l'équipe de développement, définissant de manière exhaustive ce qui doit être construit, dans quel ordre, et pourquoi.

Chaque élément du Product Backlog est appelé **Product Backlog Item (PBI)**. Un PBI représente une fonctionnalité métier livrable, identifiable et testable. Il ne décrit jamais une tâche technique ou une implémentation particulière : il exprime un besoin fonctionnel et la valeur qu'il génère pour l'entreprise.

Le Product Backlog est un artefact vivant. Il est continuellement affiné par le Product Owner à travers des sessions de **Backlog Refinement**, en collaboration avec l'équipe de développement et les parties prenantes. Son ordonnancement reflète à tout moment les priorités commerciales, les contraintes techniques et les risques identifiés.

### 2.2 Relation avec les User Stories

Le présent Product Backlog est directement dérivé du document **Agile User Stories CSM-GIAS Resto+ (v1.0)**, qui constitue sa source exclusive. Chaque PBI est lié à une ou plusieurs User Stories validées par le Product Owner. Cette traçabilité garantit qu'aucune exigence n'est perdue ou orpheline dans le processus de développement.

Certains PBIs regroupent plusieurs User Stories thématiquement proches afin de livrer une fonctionnalité cohérente en un seul sprint. D'autres PBIs correspondent à une User Story unique lorsque la complexité ou le risque le justifient.

### 2.3 Relation avec le Sprint Planning

Le Product Backlog est l'entrée principale du **Sprint Planning**. En début de chaque sprint, l'équipe Scrum (Product Owner, Scrum Master, équipe de développement) sélectionne les PBIs de priorité la plus haute dans la limite de sa vélocité. Ces PBIs forment le Sprint Backlog, qui définit l'objectif du sprint.

L'ordonnancement du Product Backlog garantit que les PBIs les plus critiques — en termes de valeur métier, de risque et de dépendances — sont traités en premier.

### 2.4 Relation avec les Releases

Le Product Backlog est structuré selon un plan de livraison en trois releases :

- **Release 1.0** : Déploiement en production de la solution minimale viable (MVP). Contient tous les PBIs indispensables au fonctionnement opérationnel du restaurant numérisé.
- **Release 1.1** : Enrichissements fonctionnels post-déploiement initial, incluant les fonctionnalités administratives avancées et les rapports complémentaires.
- **Release 2.0** : Fonctionnalités à haute valeur analytique et évolutions stratégiques, incluant les statistiques avancées et les préparations à la future version web.

### 2.5 Responsabilités du Product Owner

Le Product Owner est garant de la qualité, de l'exhaustivité et de la cohérence du Product Backlog. Ses responsabilités incluent :

- Définir et maintenir l'ordonnancement des PBIs en fonction de la valeur métier et des contraintes.
- Valider les critères d'acceptance de chaque PBI lors du Sprint Review.
- S'assurer que chaque PBI est suffisamment défini avant son entrée en sprint (Definition of Ready respectée).
- Communiquer la vision produit à l'équipe de développement et aux parties prenantes.
- Arbitrer les conflits de priorité entre parties prenantes.

---

## 3. Product Backlog Overview

Le tableau ci-dessous présente une vue synthétique de l'ensemble du Product Backlog, organisé par Epic.

| Epic | Titre de l'Epic | Nombre de PBIs | Story Points | Priorité dominante | Release principale |
|---|---|---|---|---|---|
| Epic 1 | Identification | 7 | 67 | Must Have | Release 1.0 |
| Epic 2 | Gestion des Repas | 4 | 26 | Must Have | Release 1.0 |
| Epic 3 | Gestion des QR Codes | 3 | 21 | Must Have | Release 1.0 |
| Epic 4 | Administration | 5 | 20 | Must Have / Should Have | Release 1.0 / 1.1 |
| Epic 5 | Rapports | 7 | 38 | Must Have / Should Have | Release 1.0 / 1.1 |
| Epic 6 | Statistiques | 5 | 20 | Should Have / Could Have | Release 1.1 / 2.0 |
| Epic 7 | Notifications | 4 | 13 | Must Have | Release 1.0 |
| Epic 8 | Audit et Traçabilité | 4 | 18 | Must Have / Should Have | Release 1.0 / 1.1 |
| Epic 9 | Configuration | 2 | 5 | Must Have | Release 1.0 |
| Epic 10 | Gestion des Utilisateurs | 4 | 29 | Must Have / Should Have | Release 1.0 / 1.1 |
| **Total** | **10 Epics** | **45 PBIs** | **257 SP** | | |

> Le total de 257 Story Points représente l'effort global estimé pour la réalisation de l'intégralité du périmètre fonctionnel de CSM-GIAS Resto+. La vélocité de référence de l'équipe de développement déterminera le nombre de sprints nécessaires.

---

## 4. Product Backlog

---

### Epic 1 — Identification

---

#### PBI-001 : Identification faciale des employés

- **Epic** : Epic 1 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 13

**Description**

Mettre en place le mécanisme complet d'identification des employés par reconnaissance faciale sur la tablette, depuis l'affichage de l'interface de scan jusqu'à la confirmation de l'identité reconnue. L'employé doit être reconnu sans saisie de mot de passe, en moins de trois secondes dans des conditions d'éclairage normales.

**User Stories liées** : US-001, US-012

**Acceptance Criteria**

- AC-001 : Lorsqu'un employé enrôlé se présente devant la caméra de la tablette, le système l'identifie et affiche son prénom avec un indicateur de succès visuel.
- AC-002 : Lorsqu'un employé dont le compte est désactivé est reconnu par la caméra, le système bloque l'accès et affiche un message d'indisponibilité.
- AC-003 : Lorsque la reconnaissance échoue après plusieurs tentatives, le système affiche un message invitant l'utilisateur à contacter l'administration.
- AC-004 : Le processus d'identification complet ne dépasse pas trois secondes dans des conditions d'éclairage standard.
- AC-005 : Aucune saisie de code, de mot de passe ou d'identifiant n'est requise de la part de l'employé.

**Business Value** : Fluidifie le flux d'entrée au restaurant. Élimine les files d'attente et les erreurs d'identification manuelle. Constitue le différenciateur technologique principal de la solution.

**Estimated Story Points** : 13

**Dependencies** : PBI-042 (Création des comptes employés), PBI-002 (Enrôlement biométrique)

**Risks** : Qualité variable de l'éclairage dans l'entrée du restaurant. Vieillissement du modèle biométrique en cas de changement physique notable de l'employé. Nécessite un calibrage de la caméra de la tablette.

**Notes** : Le taux de réussite cible en conditions normales doit dépasser 95 %. Une procédure de repli doit être documentée pour les cas d'échec répété.

**Business Rules** : BR-001, BR-004, BR-007, BR-033, BR-034
**Functional Requirements** : FR-201, FR-304, FR-305, FR-306, FR-307

---

#### PBI-002 : Enrôlement biométrique des employés

- **Epic** : Epic 1 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 13

**Description**

Fournir à l'administrateur une interface dédiée pour capturer et enregistrer les données faciales d'un employé via la caméra de la tablette. Cette fonctionnalité inclut l'enrôlement initial, la mise à jour des données biométriques en cas de nécessité, le chiffrement des données à la persistance, et leur suppression définitive lors de la suppression du compte.

**User Stories liées** : US-008, US-009, US-010

**Acceptance Criteria**

- AC-001 : Lorsqu'un administrateur sélectionne un employé et lance l'enrôlement, la caméra s'active et capture les données faciales. L'empreinte est ensuite liée au compte employé.
- AC-002 : Lorsque l'enrôlement est persisté, les données biométriques sont stockées sous forme chiffrée. Aucune donnée en clair n'est présente dans la base de données.
- AC-003 : Lorsqu'un administrateur procède à la mise à jour de l'enrôlement d'un employé déjà enrôlé, les anciennes données sont intégralement remplacées par les nouvelles.
- AC-004 : Lorsqu'un compte employé est supprimé, les données biométriques associées sont effacées de manière définitive et irréversible.
- AC-005 : L'interface d'enrôlement n'est accessible qu'aux administrateurs authentifiés. Toute tentative d'accès non authentifiée est bloquée.

**Business Value** : Constitue le prérequis absolu à l'identification faciale des employés. Sans enrôlement, aucun employé ne peut utiliser le restaurant numérisé.

**Estimated Story Points** : 13

**Dependencies** : PBI-015 (Interface d'administration sécurisée), PBI-042 (Comptes employés)

**Risks** : Qualité insuffisante des données capturées. Gestion du consentement et de la conformité RGPD. Complexité du chiffrement et impact sur les performances de reconnaissance.

**Notes** : L'enrôlement est une opération rare (à la création et en cas de nécessité). L'interface doit être guidée pas-à-pas pour minimiser les erreurs opérateur.

**Business Rules** : BR-031, BR-032, BR-035, BR-036, BR-071
**Functional Requirements** : FR-301, FR-302, FR-303, FR-308, FR-309

---

#### PBI-003 : Identification des stagiaires par QR Code

- **Epic** : Epic 1 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 5

**Description**

Permettre à un stagiaire de s'identifier à l'entrée du restaurant en présentant son QR Code nominatif sur le lecteur de la tablette. L'identification est sans saisie de mot de passe. Le système valide instantanément la validité temporelle du QR Code avant d'autoriser l'accès.

**User Stories liées** : US-002

**Acceptance Criteria**

- AC-001 : Lorsqu'un stagiaire présente un QR Code nominatif valide et non expiré, le système l'identifie et l'autorise à accéder à la sélection de repas.
- AC-002 : Lorsqu'un stagiaire présente un QR Code dont la date de fin de stage est dépassée, l'accès est refusé et un message d'expiration est affiché.
- AC-003 : Aucune saisie de code ou de mot de passe n'est requise du stagiaire.
- AC-004 : Lorsqu'un stagiaire présente un QR Code révoqué, l'accès est refusé avec un message distinct du cas d'expiration.

**Business Value** : Intègre les travailleurs temporaires dans le système de restauration numérique sans nécessiter de dispositif biométrique.

**Estimated Story Points** : 5

**Dependencies** : PBI-030 (Génération QR Code Stagiaire — PBI-012)

**Risks** : QR Code illisible (écran abîmé, mauvaise luminosité). Perte du QR Code par le stagiaire.

**Notes** : Le QR Code peut être affiché sur un smartphone ou imprimé. La tablette doit gérer les deux cas de présentation.

**Business Rules** : BR-002, BR-004, BR-016, BR-026, BR-027
**Functional Requirements** : FR-202, FR-204, FR-205, FR-406, FR-407

---

#### PBI-004 : Identification des visiteurs par QR Code temporaire

- **Epic** : Epic 1 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 5

**Description**

Permettre à un visiteur de s'identifier à l'entrée du restaurant en présentant son QR Code temporaire généré par l'accueil le jour même. Le système vérifie que le QR Code est valide pour la journée courante avant d'autoriser l'accès.

**User Stories liées** : US-003

**Acceptance Criteria**

- AC-001 : Lorsqu'un visiteur présente un QR Code temporaire émis le jour même, le système l'identifie et l'autorise à accéder à la sélection de repas.
- AC-002 : Lorsqu'un visiteur présente un QR Code émis un jour précédent, l'accès est refusé avec un message indiquant que le code est expiré.
- AC-003 : Aucune saisie de code ou de mot de passe n'est requise du visiteur.
- AC-004 : Lorsqu'un visiteur présente un QR Code révoqué, l'accès est refusé avec un message distinct du cas d'expiration.

**Business Value** : Offre aux visiteurs externes une expérience d'accueil professionnelle et autonome, sans intervention humaine à l'entrée du restaurant.

**Estimated Story Points** : 5

**Dependencies** : PBI-013 (Génération QR Code Visiteur)

**Risks** : QR Code mal imprimé ou écran de smartphone illisible. Tentative de réutilisation d'un QR Code d'une visite précédente.

**Notes** : La vérification d'expiration doit se faire à la seconde près par rapport au fuseau horaire local de la tablette.

**Business Rules** : BR-003, BR-004, BR-020, BR-026, BR-027
**Functional Requirements** : FR-203, FR-204, FR-405, FR-406, FR-407

---

#### PBI-005 : Contrôle de validité des QR Codes à l'identification

- **Epic** : Epic 1 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 5

**Description**

Implémenter le moteur de validation des QR Codes au moment de leur présentation. Ce moteur vérifie systématiquement : la validité temporelle du code, son statut de révocation, et son unicité. Les messages d'erreur distinguent clairement les cas d'expiration et de révocation pour orienter correctement l'utilisateur.

**User Stories liées** : US-004, US-005

**Acceptance Criteria**

- AC-001 : Tout QR Code dont la date d'expiration est atteinte ou dépassée est rejeté avant tout enregistrement de repas.
- AC-002 : Tout QR Code figurant dans la liste des codes révoqués est rejeté immédiatement, quelle que soit sa date d'expiration.
- AC-003 : Le message affiché en cas d'expiration est distinct du message affiché en cas de révocation.
- AC-004 : Les messages d'erreur sont affichés en français, en arabe et en anglais.
- AC-005 : Le rejet d'un QR Code ne génère aucun enregistrement de repas dans le système.

**Business Value** : Garantit l'intégrité du contrôle d'accès. Empêche les usurpations d'accès par réutilisation ou partage de QR Codes.

**Estimated Story Points** : 5

**Dependencies** : PBI-003, PBI-004, PBI-014 (Révocation QR)

**Risks** : Latence de propagation de la révocation en cas d'architecture distribuée (non applicable en version 1.0, tablette unique).

**Notes** : En version 1.0, la vérification est synchrone et locale. Aucun délai de propagation n'est admis.

**Business Rules** : BR-026, BR-027, BR-029, BR-030
**Functional Requirements** : FR-204, FR-205, FR-206, FR-406, FR-407, FR-408

---

#### PBI-006 : Authentification sécurisée des administrateurs

- **Epic** : Epic 1 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 8

**Description**

Mettre en place le mécanisme d'authentification des administrateurs par jeton d'accès sécurisé (JWT), incluant la délivrance du jeton, sa vérification à chaque requête, et l'invalidation automatique à l'expiration. Tout accès à l'interface d'administration sans jeton valide est refusé et redirigé vers la page de connexion.

**User Stories liées** : US-006, US-007

**Acceptance Criteria**

- AC-001 : Lorsqu'un administrateur saisit des identifiants valides, un jeton JWT lui est délivré et lui donne accès à l'interface d'administration.
- AC-002 : Lorsqu'un administrateur saisit un mot de passe incorrect, l'accès est refusé et un message d'erreur est affiché. Aucun jeton n'est délivré.
- AC-003 : Lorsqu'un administrateur tente d'accéder à une page protégée sans jeton valide, il est redirigé vers la page de connexion.
- AC-004 : Lorsque le jeton d'un administrateur expire, toute requête suivante est rejetée avec un code d'erreur 401 et l'administrateur est invité à se reconnecter.
- AC-005 : Aucune ressource d'administration n'est accessible sans authentification préalable.

**Business Value** : Sécurise l'accès à l'ensemble des fonctions d'administration. Protège les données personnelles et les configurations système contre tout accès non autorisé.

**Estimated Story Points** : 8

**Dependencies** : Aucune

**Risks** : Vol de session par interception du jeton. Expiration trop courte perturbant le travail de l'administrateur. Expiration trop longue augmentant la surface d'exposition.

**Notes** : La durée de validité du jeton sera définie lors du Sprint Planning en accord avec le Responsable Sécurité. Elle doit équilibrer confort d'utilisation et sécurité.

**Business Rules** : BR-069, BR-070, BR-073
**Functional Requirements** : FR-208, FR-209, FR-601

---

#### PBI-007 : Unicité et séquentialité des sessions d'identification

- **Epic** : Epic 1 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 2

**Description**

Garantir qu'une seule session d'identification est traitée à la fois par la tablette. Toute tentative d'identification simultanée de deux utilisateurs est bloquée. La tablette ne traite le prochain utilisateur qu'après clôture complète de la transaction en cours.

**User Stories liées** : US-011

**Acceptance Criteria**

- AC-001 : Lorsqu'une session d'identification est en cours, toute tentative d'initiation d'une nouvelle session est ignorée jusqu'à la fermeture de la session active.
- AC-002 : Après confirmation ou rejet d'un enregistrement de repas, la tablette revient automatiquement à l'écran d'accueil et est prête pour le prochain utilisateur.
- AC-003 : Le délai de retour à l'écran d'accueil après une transaction n'excède pas cinq secondes.

**Business Value** : Prévient les erreurs d'attribution de repas entre deux utilisateurs se présentant simultanément à la borne.

**Estimated Story Points** : 2

**Dependencies** : PBI-001, PBI-003, PBI-004

**Risks** : Blocage de la tablette si une session reste ouverte sans action utilisateur (timeout à prévoir).

**Notes** : Un mécanisme de timeout de session doit être intégré pour les cas où l'utilisateur abandonne en cours d'identification.

**Business Rules** : BR-006
**Functional Requirements** : FR-207

---

### Epic 2 — Gestion des Repas

---

#### PBI-008 : Affichage et sélection du menu

- **Epic** : Epic 2 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 8

**Description**

Après identification réussie, afficher à l'utilisateur les trois catégories de repas disponibles (Plat, Pizza, Sandwich). Permettre la sélection exclusive d'une seule catégorie. Bloquer la validation si aucune sélection n'a été effectuée. Les intitulés des catégories sont fixes et non configurables.

**User Stories liées** : US-013, US-014, US-015

**Acceptance Criteria**

- AC-001 : Immédiatement après une identification réussie, l'écran affiche les trois catégories : Plat, Pizza, Sandwich.
- AC-002 : Lorsque l'utilisateur sélectionne une catégorie, les deux autres sont visuellement désélectionnées. Une seule sélection est possible à la fois.
- AC-003 : Lorsqu'aucune catégorie n'est sélectionnée, le bouton de validation est désactivé et ne peut pas être déclenché.
- AC-004 : Les intitulés des catégories (Plat, Pizza, Sandwich) sont identiques quelle que soit la langue d'interface.
- AC-005 : L'écran de sélection est accessible et lisible sur la tablette dans les conditions d'utilisation standard du restaurant.

**Business Value** : Constitue l'étape centrale de l'expérience utilisateur. La sélection doit être intuitive, rapide et sans ambiguïté pour ne pas ralentir le flux d'entrée.

**Estimated Story Points** : 8

**Dependencies** : PBI-001, PBI-003, PBI-004

**Risks** : Interface confuse ou lente pouvant générer des erreurs de sélection, notamment pour les visiteurs peu familiers avec la tablette.

**Notes** : L'interface doit être conçue pour une utilisation avec des doigts (grandes zones tactiles). Elle doit être accessible aux utilisateurs de toutes origines culturelles.

**Business Rules** : BR-037, BR-038, BR-039, BR-044
**Functional Requirements** : FR-501, FR-502, FR-503, FR-510

---

#### PBI-009 : Enregistrement définitif et traçabilité du repas

- **Epic** : Epic 2 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 8

**Description**

Enregistrer de manière définitive et irréversible le repas choisi par l'utilisateur dès confirmation. Horodater automatiquement l'enregistrement. Persister l'ensemble des données de la transaction : identifiant utilisateur, catégorie choisie, mode d'identification et horodatage précis.

**User Stories liées** : US-016, US-017, US-018

**Acceptance Criteria**

- AC-001 : Lorsque l'utilisateur confirme sa sélection, le repas est enregistré immédiatement avec un horodatage automatique correspondant à l'heure locale de la tablette.
- AC-002 : Une fois confirmé, l'enregistrement est définitif. Aucune option d'annulation ou de modification n'est proposée à l'utilisateur.
- AC-003 : Chaque enregistrement contient au minimum : l'identifiant de l'utilisateur, la catégorie de repas choisie, le mode d'identification utilisé (reconnaissance faciale ou QR Code), et l'horodatage précis.
- AC-004 : En cas d'échec de la persistance (indisponibilité momentanée), le système doit notifier l'erreur sans créer d'enregistrement partiel.
- AC-005 : L'identité de l'utilisateur n'est pas affichée à l'écran après validation de l'enregistrement.

**Business Value** : Constitue la transaction métier fondamentale du système. Sa fiabilité et son intégrité sont non négociables pour les besoins de reporting et d'audit.

**Estimated Story Points** : 8

**Dependencies** : PBI-008

**Risks** : Perte de données en cas de coupure réseau au moment de la validation. Horodatage incorrect si l'horloge de la tablette est désynchronisée.

**Notes** : La synchronisation de l'heure de la tablette avec un serveur de temps NTP doit être vérifiée lors de la configuration initiale.

**Business Rules** : BR-040, BR-041, BR-072, BR-082
**Functional Requirements** : FR-504, FR-505, FR-506

---

#### PBI-010 : Contrôle de la plage horaire d'ouverture

- **Epic** : Epic 2 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 5

**Description**

Empêcher tout enregistrement de repas en dehors de la plage horaire définie (12h30–14h00). Afficher un message explicite informant l'utilisateur que le restaurant est fermé lorsqu'une tentative d'identification est effectuée hors de cette plage. Ce contrôle est appliqué avant toute autre vérification.

**User Stories liées** : US-019

**Acceptance Criteria**

- AC-001 : Lorsqu'un utilisateur tente de s'identifier avant 12h30, le système affiche un message indiquant que le restaurant n'est pas encore ouvert.
- AC-002 : Lorsqu'un utilisateur tente de s'identifier après 14h00, le système affiche un message indiquant que le restaurant est fermé.
- AC-003 : Entre 12h30 et 14h00 inclus, le système accepte les tentatives d'identification et poursuit le processus normalement.
- AC-004 : Le message "Restaurant Fermé" est affiché en français, en arabe et en anglais.
- AC-005 : Aucun enregistrement de repas n'est créé lorsque la tentative est effectuée hors plage horaire.

**Business Value** : Applique la règle métier fondamentale de gestion du restaurant. Protège l'intégrité des données statistiques en ne comptabilisant que les repas effectivement pris durant le service.

**Estimated Story Points** : 5

**Dependencies** : Aucune

**Risks** : Dérive de l'horloge de la tablette au fil du temps. Gestion du changement d'heure saisonnier (heure d'été / heure d'hiver).

**Notes** : La plage horaire doit être paramétrable dans une version future. En version 1.0, elle est fixée à 12h30–14h00 de manière non configurable par les utilisateurs.

**Business Rules** : BR-042, BR-043, BR-067, BR-078
**Functional Requirements** : FR-507, FR-904

---

#### PBI-011 : Unicité du repas journalier par utilisateur

- **Epic** : Epic 2 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 5

**Description**

Empêcher qu'un même utilisateur — employé, stagiaire ou visiteur — enregistre plus d'un repas par jour calendaire. Le contrôle est effectué à l'issue de l'identification, avant l'affichage du menu. Un message explicite est affiché en cas de tentative de double enregistrement.

**User Stories liées** : US-020

**Acceptance Criteria**

- AC-001 : Lorsqu'un employé ayant déjà enregistré un repas le jour J tente de s'identifier à nouveau, le système refuse et affiche un message indiquant qu'un repas a déjà été enregistré.
- AC-002 : La règle d'unicité journalière s'applique identiquement aux stagiaires et aux visiteurs.
- AC-003 : Le message de rejet indique clairement à l'utilisateur qu'il a déjà consommé son repas pour la journée.
- AC-004 : Le rejet de double enregistrement est affiché en français, en arabe et en anglais.
- AC-005 : Le contrôle d'unicité est effectué en base de données et ne peut pas être contourné par une manipulation côté tablette.

**Business Value** : Maîtrise des coûts de restauration de l'entreprise. Garantit l'équité entre les utilisateurs. Fiabilise les statistiques de fréquentation.

**Estimated Story Points** : 5

**Dependencies** : PBI-009

**Risks** : Faux positif en cas de synchronisation incorrecte des dates (fuseau horaire). Tentative de fraude par utilisation de QR Codes différents.

**Notes** : La vérification d'unicité doit être atomique et protégée contre les conditions de concurrence.

**Business Rules** : BR-008, BR-009, BR-014, BR-015, BR-021, BR-068
**Functional Requirements** : FR-508, FR-509, FR-905

---

### Epic 3 — Gestion des QR Codes

---

#### PBI-012 : Génération et cycle de vie du QR Code Stagiaire

- **Epic** : Epic 3 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 8

**Description**

Générer automatiquement un QR Code nominatif unique pour chaque stagiaire au moment de la création de son compte. Définir automatiquement la date d'expiration du QR Code à la date de fin de stage saisie. Garantir l'unicité globale du QR Code dans le système.

**User Stories liées** : US-021, US-022

**Acceptance Criteria**

- AC-001 : Lors de la création d'un compte stagiaire, un QR Code nominatif unique est généré automatiquement sans action supplémentaire de l'opérateur.
- AC-002 : La date d'expiration du QR Code correspond exactement à la date de fin de stage saisie lors de la création du compte, à 23h59 du jour concerné.
- AC-003 : Deux stagiaires différents ne peuvent pas posséder un QR Code identique.
- AC-004 : Le QR Code généré est lisible sur la tablette dans des conditions d'utilisation standard (distance de 20 à 40 cm).
- AC-005 : Après expiration, le QR Code est automatiquement rejeté lors de sa présentation, sans intervention administrative.

**Business Value** : Automatise la gestion des droits d'accès des stagiaires. Supprime le suivi manuel des dates de fin de stage pour la gestion des accès au restaurant.

**Estimated Story Points** : 8

**Dependencies** : PBI-038 (Gestion des comptes stagiaires — inclus dans PBI-040)

**Risks** : Collision de codes générés (à mitiger par un algorithme de génération unique garanti). Renouvellement nécessaire en cas de prolongation de stage.

**Notes** : En cas de prolongation de stage, l'administrateur doit pouvoir modifier la date de fin, ce qui régénère ou prolonge le QR Code.

**Business Rules** : BR-013, BR-016, BR-025, BR-017
**Functional Requirements** : FR-401, FR-402, FR-411

---

#### PBI-013 : Génération et cycle de vie du QR Code Visiteur

- **Epic** : Epic 3 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 8

**Description**

Permettre à l'accueil de générer un QR Code temporaire pour un visiteur. Ce QR Code est valide uniquement le jour de sa génération et expire automatiquement à minuit. Un seul QR Code actif peut exister pour un même visiteur par journée. La génération se fait en quelques secondes depuis l'interface de l'accueil.

**User Stories liées** : US-023, US-024

**Acceptance Criteria**

- AC-001 : Lorsque l'accueil valide la création d'un visiteur, un QR Code temporaire est généré instantanément et affiché à l'écran.
- AC-002 : La date d'expiration du QR Code visiteur est automatiquement fixée à 23h59:59 du jour de génération.
- AC-003 : Si l'accueil tente de générer un second QR Code pour un visiteur existant ayant déjà un QR Code actif pour la journée, le système bloque la génération et affiche un avertissement.
- AC-004 : Le QR Code peut être affiché à l'écran pour présentation sur smartphone ou transmis pour impression.
- AC-005 : Un QR Code visiteur présenté le lendemain ou après est rejeté avec un message d'expiration.

**Business Value** : Permet l'accueil numérique des visiteurs sans recours à des badges physiques réutilisables. La validité limitée à la journée protège l'entreprise contre les accès non autorisés.

**Estimated Story Points** : 8

**Dependencies** : PBI-044 (Création de comptes visiteurs)

**Risks** : Partage du QR Code visiteur avec un tiers. Génération de QR Codes en masse pour une même journée.

**Notes** : La temporalité de l'expiration doit tenir compte du fuseau horaire local et du changement d'heure saisonnier.

**Business Rules** : BR-019, BR-020, BR-022, BR-023, BR-025
**Functional Requirements** : FR-403, FR-404, FR-405, FR-411

---

#### PBI-014 : Révocation manuelle d'un QR Code

- **Epic** : Epic 3 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 5

**Description**

Permettre à un administrateur de révoquer manuellement tout QR Code actif, qu'il soit nominatif (stagiaire) ou temporaire (visiteur), depuis l'interface d'administration. La révocation prend effet immédiatement. Tout QR Code révoqué présenté à la tablette est rejeté sans délai.

**User Stories liées** : US-025, US-026

**Acceptance Criteria**

- AC-001 : Depuis l'interface d'administration, l'administrateur peut sélectionner un QR Code actif et le révoquer en une action.
- AC-002 : La révocation est immédiatement effective. Un QR Code révoqué à 12h00 est rejeté à 12h00 et 30 secondes.
- AC-003 : Le message affiché lors d'une tentative d'utilisation d'un QR Code révoqué est distinct du message d'expiration.
- AC-004 : La révocation est consignée dans le journal d'audit avec l'identifiant de l'administrateur et l'horodatage.
- AC-005 : Un QR Code révoqué ne peut pas être réactivé sans génération d'un nouveau QR Code.

**Business Value** : Offre une réponse immédiate aux situations de sécurité (perte de QR Code, départ anticipé d'un stagiaire, visiteur indésirable).

**Estimated Story Points** : 5

**Dependencies** : PBI-006 (Authentification admin), PBI-012, PBI-013

**Risks** : Révocation accidentelle d'un QR Code valide sans possibilité de retour arrière.

**Notes** : Une confirmation de révocation (pop-up de confirmation) doit être implémentée pour prévenir les erreurs de manipulation.

**Business Rules** : BR-028, BR-029, BR-030
**Functional Requirements** : FR-408, FR-409, FR-410, FR-612

---

### Epic 4 — Administration

---

#### PBI-015 : Interface d'administration sécurisée

- **Epic** : Epic 4 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 5

**Description**

Fournir une interface d'administration distincte de l'interface utilisateur de la tablette. Cette interface est protégée par authentification JWT, disponible exclusivement en langue française, et accessible aux profils Administrateur et Réception selon leurs droits respectifs.

**User Stories liées** : US-027

**Acceptance Criteria**

- AC-001 : L'interface d'administration est accessible sur une URL ou section distincte de l'interface tablette.
- AC-002 : Tout accès sans jeton JWT valide est bloqué et redirigé vers la page de connexion.
- AC-003 : L'interface est intégralement rédigée en langue française.
- AC-004 : La navigation dans l'interface est fluide et sans délai perceptible pour les opérations courantes.
- AC-005 : Les sections accessibles varient selon le profil connecté (Administrateur ou Réception).

**Business Value** : Centralise la gestion opérationnelle du système dans un espace sécurisé et contrôlé, distinct de la borne de restaurant.

**Estimated Story Points** : 5

**Dependencies** : PBI-006

**Risks** : Interface accessible depuis des postes non sécurisés du réseau de l'entreprise.

**Notes** : En version 1.0, l'interface d'administration peut être accédée depuis le navigateur d'un poste du réseau interne. L'accès depuis l'extérieur est hors périmètre.

**Business Rules** : BR-051, BR-069, BR-073
**Functional Requirements** : FR-601, FR-602

---

#### PBI-016 : Gestion des comptes administrateurs

- **Epic** : Epic 4 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 5

**Description**

Permettre à un administrateur de créer de nouveaux comptes administrateurs, de désactiver des comptes existants, et de garantir en permanence l'existence d'au moins un compte administrateur actif dans le système.

**User Stories liées** : US-028, US-029

**Acceptance Criteria**

- AC-001 : Un administrateur peut créer un nouveau compte administrateur en saisissant les identifiants de connexion.
- AC-002 : Le nouveau compte administrateur peut s'authentifier immédiatement après sa création.
- AC-003 : Un administrateur peut désactiver le compte d'un autre administrateur.
- AC-004 : La désactivation du seul compte administrateur actif est bloquée par le système avec un message d'erreur explicite.
- AC-005 : Un administrateur ne peut pas désactiver son propre compte depuis l'interface.

**Business Value** : Assure la gouvernance et la continuité opérationnelle du système. Prévient toute situation de blocage total due à l'absence d'administrateur actif.

**Estimated Story Points** : 5

**Dependencies** : PBI-015

**Risks** : Prolifération non contrôlée de comptes administrateurs. Partage de comptes entre plusieurs personnes.

**Notes** : Il est recommandé de limiter le nombre d'administrateurs actifs et de documenter leur identité dans une procédure de gouvernance interne.

**Business Rules** : BR-048, BR-049
**Functional Requirements** : FR-603, FR-604, FR-605

---

#### PBI-017 : Configuration des destinataires des rapports automatiques

- **Epic** : Epic 4 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 3

**Description**

Permettre à un administrateur de configurer, ajouter et supprimer des adresses email dans la liste des destinataires des rapports automatiques. Cette configuration est persistante et prend effet dès le prochain envoi de rapport.

**User Stories liées** : US-030

**Acceptance Criteria**

- AC-001 : Un administrateur peut ajouter une adresse email valide à la liste des destinataires.
- AC-002 : Un administrateur peut supprimer une adresse email de la liste des destinataires.
- AC-003 : La liste des destinataires actuelle est affichée à l'administrateur lors de la consultation de la page de configuration.
- AC-004 : Les modifications de la liste prennent effet dès le prochain envoi de rapport planifié.
- AC-005 : La saisie d'une adresse email invalide (format incorrect) est rejetée avec un message d'erreur.

**Business Value** : Assure que les rapports automatiques parviennent aux bonnes personnes, sans intervention technique à chaque changement d'organisation.

**Estimated Story Points** : 3

**Dependencies** : PBI-015, PBI-020

**Risks** : Liste de destinataires vide entraînant une perte silencieuse des rapports.

**Notes** : Le système doit alerter l'administrateur si la liste de destinataires est vide lors d'une génération de rapport.

**Business Rules** : BR-050
**Functional Requirements** : FR-607, FR-608

---

#### PBI-018 : Réinitialisation du mot de passe administrateur

- **Epic** : Epic 4 | **Priority** : Should Have | **Status** : Planned | **Release** : 1.1
- **Story Points** : 3

**Description**

Fournir un mécanisme permettant à un administrateur de réinitialiser le mot de passe d'un autre compte administrateur, ou de récupérer l'accès en cas de perte de credentials, sans compromettre la sécurité du système.

**User Stories liées** : US-067

**Acceptance Criteria**

- AC-001 : Un administrateur peut déclencher la réinitialisation du mot de passe d'un autre administrateur depuis l'interface de gestion.
- AC-002 : Un email de réinitialisation est envoyé à l'adresse associée au compte concerné.
- AC-003 : Le lien de réinitialisation est temporaire et expire après utilisation ou après un délai défini.
- AC-004 : L'action de réinitialisation est consignée dans le journal d'audit.

**Business Value** : Prévient les situations de blocage opérationnel causées par la perte de credentials administrateur.

**Estimated Story Points** : 3

**Dependencies** : PBI-016

**Risks** : Interception de l'email de réinitialisation. Utilisation abusive de la procédure de réinitialisation.

**Notes** : La procédure de réinitialisation doit être documentée dans le guide d'administration.

**Business Rules** : BR-069
**Functional Requirements** : FR-603

---

#### PBI-019 : Consultation et révocation depuis l'interface d'administration

- **Epic** : Epic 4 | **Priority** : Should Have | **Status** : Planned | **Release** : 1.1
- **Story Points** : 5

**Description**

Permettre à l'administrateur de consulter la liste complète des QR Codes actifs (stagiaires et visiteurs), leur statut, leur date d'expiration, et d'effectuer une révocation directement depuis cette vue.

**User Stories liées** : US-059 (désactivation admin), US-025 (révocation QR — couverture interface)

**Acceptance Criteria**

- AC-001 : L'administrateur dispose d'une vue listant tous les QR Codes actifs avec leur propriétaire, leur type et leur date d'expiration.
- AC-002 : L'administrateur peut filtrer la liste par type (Stagiaire / Visiteur) ou par statut.
- AC-003 : Un bouton de révocation est disponible sur chaque ligne de la liste.
- AC-004 : La révocation déclenche une confirmation avant exécution.

**Business Value** : Offre une supervision centralisée des accès actifs au restaurant, facilitant la gestion des incidents de sécurité.

**Estimated Story Points** : 5

**Dependencies** : PBI-014, PBI-015

**Risks** : Volume de QR Codes important sur une même journée réduisant la lisibilité de la liste.

**Notes** : La pagination et le filtrage sont essentiels pour les jours à forte affluence de visiteurs.

**Business Rules** : BR-028, BR-049
**Functional Requirements** : FR-409, FR-605, FR-612

---

### Epic 5 — Rapports

---

#### PBI-020 : Génération automatique du rapport journalier

- **Epic** : Epic 5 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 5

**Description**

Générer automatiquement un rapport journalier en fin de service de restauration, sans intervention humaine. Le rapport couvre l'activité du jour et contient des statistiques synthétiques sur les repas enregistrés.

**User Stories liées** : US-031

**Acceptance Criteria**

- AC-001 : Le rapport journalier est généré automatiquement chaque jour de service, à l'issue de la plage horaire de restauration.
- AC-002 : Le rapport contient le nombre total de repas enregistrés, la répartition par catégorie, et la répartition par type d'utilisateur pour la journée.
- AC-003 : Le rapport est rédigé exclusivement en langue française.
- AC-004 : En cas d'absence de repas enregistrés pour la journée, un rapport vide est tout de même généré, indiquant zéro consommation.
- AC-005 : Chaque rapport généré est conservé dans le système et consultable ultérieurement.

**Business Value** : Fournit quotidiennement au Responsable Restaurant et à la direction une synthèse de l'activité. Remplace les registres papier manuels.

**Estimated Story Points** : 5

**Dependencies** : PBI-009, PBI-017

**Risks** : Génération échouée sans alerte si le service de reporting est indisponible. Rapport généré à une heure incorrecte si l'horloge de la tablette dérive.

**Notes** : Un mécanisme de reprise doit permettre de régénérer un rapport journalier en cas d'échec.

**Business Rules** : BR-053, BR-057, BR-058, BR-059
**Functional Requirements** : FR-701, FR-706, FR-711, FR-712

---

#### PBI-021 : Diffusion automatique des rapports par email

- **Epic** : Epic 5 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 8

**Description**

Transmettre automatiquement chaque rapport généré (journalier, hebdomadaire, mensuel) par email à l'ensemble des destinataires configurés. L'envoi se fait sans intervention humaine, immédiatement après la génération du rapport. Le rapport est joint en pièce jointe au format PDF.

**User Stories liées** : US-033, US-064

**Acceptance Criteria**

- AC-001 : Chaque rapport généré est automatiquement envoyé par email à tous les destinataires de la liste de configuration.
- AC-002 : L'email contient le rapport en pièce jointe au format PDF.
- AC-003 : L'envoi simultané à plusieurs destinataires est supporté.
- AC-004 : En cas d'échec d'envoi (adresse invalide, serveur SMTP indisponible), une erreur est consignée dans les logs système.
- AC-005 : Aucune intervention manuelle n'est requise pour déclencher l'envoi.

**Business Value** : Distribue l'information à toutes les parties prenantes sans qu'aucun d'entre eux n'ait besoin d'accéder activement au système.

**Estimated Story Points** : 8

**Dependencies** : PBI-017, PBI-020

**Risks** : Serveur SMTP indisponible ou mal configuré. Rapports bloqués par les filtres anti-spam des destinataires.

**Notes** : La configuration du serveur SMTP (adresse, port, authentification) doit être définie lors de l'installation de la solution.

**Business Rules** : BR-056
**Functional Requirements** : FR-704, FR-705

---

#### PBI-022 : Contenu graphique des rapports

- **Epic** : Epic 5 | **Priority** : Should Have | **Status** : Planned | **Release** : 1.1
- **Story Points** : 13

**Description**

Enrichir les rapports avec des représentations graphiques : camemberts de répartition des catégories, courbes d'évolution de la fréquentation sur la période, et histogrammes de la répartition horaire des enregistrements. Ces graphiques sont inclus dans le PDF généré.

**User Stories liées** : US-034, US-065, US-066

**Acceptance Criteria**

- AC-001 : Le rapport PDF contient un graphique de type camembert illustrant la répartition des repas par catégorie (Plat, Pizza, Sandwich).
- AC-002 : Le rapport contient une courbe d'évolution du nombre de repas jour par jour sur la période couverte.
- AC-003 : Le rapport contient un histogramme montrant la répartition des enregistrements par tranche horaire au sein de la plage 12h30–14h00.
- AC-004 : Tous les graphiques sont lisibles dans le PDF et correctement légendés en français.
- AC-005 : Les graphiques sont générés automatiquement sans intervention manuelle.

**Business Value** : Transforme les données brutes en information visuelle immédiatement exploitable par le Responsable Restaurant et la direction.

**Estimated Story Points** : 13

**Dependencies** : PBI-020

**Risks** : Complexité de la génération PDF avec graphiques intégrés. Lisibilité des graphiques sur email en pièce jointe.

**Notes** : La bibliothèque de génération graphique sera choisie lors du Sprint Planning technique.

**Business Rules** : BR-057
**Functional Requirements** : FR-708, FR-709, FR-710

---

#### PBI-023 : Tableaux de données dans les rapports

- **Epic** : Epic 5 | **Priority** : Should Have | **Status** : Planned | **Release** : 1.1
- **Story Points** : 3

**Description**

Inclure dans chaque rapport des tableaux structurés présentant les données de consommation par catégorie, par type d'utilisateur, et par tranche horaire, afin de compléter les graphiques par des données précises.

**User Stories liées** : US-062

**Acceptance Criteria**

- AC-001 : Le rapport contient un tableau récapitulatif des repas par catégorie avec les volumes et pourcentages.
- AC-002 : Le rapport contient un tableau de répartition par type d'utilisateur (Employé, Stagiaire, Visiteur).
- AC-003 : Le rapport contient un tableau de fréquentation par tranche horaire.
- AC-004 : Les tableaux sont correctement formatés et lisibles dans le PDF.

**Business Value** : Permet une lecture précise des données pour les analyses de contrôle de gestion.

**Estimated Story Points** : 3

**Dependencies** : PBI-020

**Risks** : Tableaux trop volumineux rendant le rapport difficile à lire.

**Notes** : Les tableaux complètent les graphiques sans les remplacer. Les deux types de représentation doivent coexister dans le rapport.

**Business Rules** : BR-057
**Functional Requirements** : FR-707

---

#### PBI-024 : Génération des rapports périodiques (hebdomadaire et mensuel)

- **Epic** : Epic 5 | **Priority** : Should Have | **Status** : Planned | **Release** : 1.1
- **Story Points** : 5

**Description**

Générer automatiquement un rapport hebdomadaire en fin de semaine et un rapport mensuel en fin de mois, selon le même modèle que le rapport journalier, mais en agrégeant les données sur la période correspondante.

**User Stories liées** : US-032, US-063

**Acceptance Criteria**

- AC-001 : Un rapport hebdomadaire est généré automatiquement chaque vendredi soir, agrégant les données des cinq jours de service de la semaine.
- AC-002 : Un rapport mensuel est généré automatiquement le dernier jour calendaire de chaque mois.
- AC-003 : Les rapports hebdomadaires et mensuels contiennent les mêmes éléments que le rapport journalier (statistiques, tableaux, graphiques), adaptés à leur période.
- AC-004 : Les rapports générés sont envoyés par email selon la même liste de destinataires que les rapports journaliers.

**Business Value** : Permet au management un suivi de l'activité à différentes granularités temporelles pour faciliter les décisions budgétaires.

**Estimated Story Points** : 5

**Dependencies** : PBI-020, PBI-021

**Risks** : Semaines à cheval sur deux mois. Gestion des mois incomplets (début de déploiement, jours fériés).

**Notes** : La logique de calcul des semaines doit respecter la norme ISO 8601 (semaine débutant le lundi).

**Business Rules** : BR-054, BR-055, BR-056, BR-058
**Functional Requirements** : FR-702, FR-703

---

#### PBI-025 : Consultation de l'historique des rapports

- **Epic** : Epic 5 | **Priority** : Should Have | **Status** : Planned | **Release** : 1.1
- **Story Points** : 3

**Description**

Permettre à un administrateur ou au Responsable Restaurant de consulter et télécharger les rapports générés antérieurement depuis l'interface d'administration.

**User Stories liées** : US-061, US-068

**Acceptance Criteria**

- AC-001 : L'interface d'administration présente une liste des rapports générés, triés par date décroissante.
- AC-002 : L'administrateur peut filtrer les rapports par type (journalier, hebdomadaire, mensuel) et par période.
- AC-003 : Chaque rapport est téléchargeable au format PDF depuis l'interface.
- AC-004 : Les rapports sont conservés dans le système pour une durée minimale définie par la politique de rétention de l'entreprise.

**Business Value** : Permet la recherche et l'analyse historique de l'activité du restaurant pour les besoins de contrôle de gestion ou d'audit interne.

**Estimated Story Points** : 3

**Dependencies** : PBI-020, PBI-015

**Risks** : Volume de stockage important en cas de conservation longue durée.

**Notes** : La politique de rétention des rapports doit être définie avec la DSI avant le déploiement.

**Business Rules** : BR-059
**Functional Requirements** : FR-712, FR-613

---

#### PBI-026 : Conformité linguistique et intégrité des rapports

- **Epic** : Epic 5 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 2

**Description**

Garantir que l'intégralité du contenu des rapports générés est rédigé exclusivement en langue française. Ce critère s'applique aux textes, aux labels de graphiques, aux en-têtes de tableaux et aux métadonnées du document PDF.

**User Stories liées** : US-035

**Acceptance Criteria**

- AC-001 : Tous les textes du rapport PDF sont en langue française, sans exception.
- AC-002 : Les labels des graphiques (légendes, axes, titres) sont en français.
- AC-003 : Les en-têtes de colonnes de tableaux sont en français.
- AC-004 : Le titre et les métadonnées du document PDF sont en français.

**Business Value** : Assure la cohérence documentaire et la lisibilité pour l'ensemble des parties prenantes de l'entreprise.

**Estimated Story Points** : 2

**Dependencies** : PBI-020

**Risks** : Bibliothèques tierces générant des libellés par défaut en anglais.

**Notes** : La vérification de la conformité linguistique doit être intégrée aux tests de recette de chaque rapport.

**Business Rules** : BR-058
**Functional Requirements** : FR-711

---

### Epic 6 — Statistiques

---

#### PBI-027 : Tableau de bord des indicateurs d'activité

- **Epic** : Epic 6 | **Priority** : Should Have | **Status** : Planned | **Release** : 1.1
- **Story Points** : 8

**Description**

Fournir à l'administrateur et au Responsable Restaurant une interface de tableau de bord permettant de consulter en temps réel les indicateurs d'activité du restaurant : nombre total de repas, répartition par catégorie, répartition par type d'utilisateur et répartition par mode d'identification.

**User Stories liées** : US-036, US-037, US-069, US-070, US-071

**Acceptance Criteria**

- AC-001 : Le tableau de bord affiche le nombre total de repas enregistrés pour une période sélectionnable.
- AC-002 : La répartition par catégorie (Plat, Pizza, Sandwich) est visible sous forme de graphique et de données chiffrées.
- AC-003 : La répartition par type d'utilisateur (Employé, Stagiaire, Visiteur) est affichée.
- AC-004 : La répartition par mode d'identification (Reconnaissance Faciale / QR Code) est affichée.
- AC-005 : Les données du tableau de bord sont cohérentes avec les données des rapports générés.

**Business Value** : Donne au Responsable Restaurant et à la direction une visibilité immédiate sur l'utilisation du restaurant, sans attendre les rapports automatiques.

**Estimated Story Points** : 8

**Dependencies** : PBI-009, PBI-015

**Risks** : Performances dégradées si les requêtes d'agrégation ne sont pas optimisées.

**Notes** : Le tableau de bord doit permettre la sélection de plages de dates (jour, semaine, mois).

**Business Rules** : BR-060, BR-061, BR-063, BR-064
**Functional Requirements** : FR-801, FR-802, FR-804, FR-805, FR-806

---

#### PBI-028 : Analyse des pics de fréquentation horaire

- **Epic** : Epic 6 | **Priority** : Could Have | **Status** : Planned | **Release** : 2.0
- **Story Points** : 5

**Description**

Fournir une vue analytique de la fréquentation horaire du restaurant, permettant d'identifier les pics d'affluence par tranches de quinze minutes au sein de la plage 12h30–14h00.

**User Stories liées** : US-038

**Acceptance Criteria**

- AC-001 : Le tableau de bord inclut un histogramme de la fréquentation par tranche horaire (tranches de 15 minutes).
- AC-002 : L'histogramme couvre la plage horaire complète 12h30–14h00.
- AC-003 : Les données sont filtrables par période (jour, semaine, mois).

**Business Value** : Permet l'optimisation des ressources humaines en cuisine et en service en anticipant les pics d'affluence.

**Estimated Story Points** : 5

**Dependencies** : PBI-027

**Risks** : Données insuffisantes pour des analyses significatives en début de déploiement.

**Notes** : Cette fonctionnalité est prioritairement destinée au Responsable Restaurant.

**Business Rules** : BR-062
**Functional Requirements** : FR-803

---

#### PBI-029 : Export des données statistiques

- **Epic** : Epic 6 | **Priority** : Could Have | **Status** : Planned | **Release** : 2.0
- **Story Points** : 3

**Description**

Permettre à un administrateur ou au Responsable Restaurant d'exporter les données statistiques affichées dans le tableau de bord au format CSV pour une exploitation ultérieure dans un outil bureautique.

**User Stories liées** : US-060

**Acceptance Criteria**

- AC-001 : Un bouton d'export est disponible sur le tableau de bord.
- AC-002 : L'export génère un fichier CSV contenant les données de la période sélectionnée.
- AC-003 : Le fichier CSV est téléchargeable immédiatement depuis le navigateur.
- AC-004 : Les colonnes du CSV sont labellisées en français.

**Business Value** : Offre aux managers la flexibilité de réaliser leurs propres analyses dans des outils comme Excel ou Google Sheets.

**Estimated Story Points** : 3

**Dependencies** : PBI-027

**Risks** : Exportation de données personnelles dans un fichier non sécurisé.

**Notes** : L'export ne doit pas contenir de données nominatives d'identification (conformité RGPD).

**Business Rules** : BR-060, BR-061
**Functional Requirements** : FR-801, FR-802

---

### Epic 7 — Notifications

---

#### PBI-030 : Confirmation d'enregistrement de repas

- **Epic** : Epic 7 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 3

**Description**

Afficher immédiatement après un enregistrement réussi un message de confirmation visuel à l'écran de la tablette, en français, en arabe et en anglais. Le message disparaît automatiquement après quelques secondes et la tablette retourne à l'écran d'accueil.

**User Stories liées** : US-039, US-040

**Acceptance Criteria**

- AC-001 : Après validation d'un repas, un message de confirmation s'affiche immédiatement à l'écran.
- AC-002 : Le message est affiché simultanément en français, en arabe et en anglais.
- AC-003 : Le message disparaît automatiquement après cinq secondes et la tablette retourne à l'écran d'accueil.
- AC-004 : Aucune information nominative de l'utilisateur n'est affichée dans le message de confirmation.

**Business Value** : Réassure l'utilisateur que son repas a bien été enregistré. Réduit les tentatives de double enregistrement par incompréhension.

**Estimated Story Points** : 3

**Dependencies** : PBI-009

**Risks** : Délai de retour à l'écran d'accueil trop long créant une file d'attente inutile.

**Notes** : Le délai de cinq secondes peut être ajusté lors de la phase d'utilisation réelle selon le retour des utilisateurs.

**Business Rules** : BR-065, BR-067, BR-072
**Functional Requirements** : FR-901, FR-907

---

#### PBI-031 : Messages d'erreur d'identification

- **Epic** : Epic 7 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 3

**Description**

Afficher des messages d'erreur clairs et compréhensibles lorsqu'une identification échoue, que ce soit par reconnaissance faciale ou par QR Code. Les messages orientent l'utilisateur vers la bonne action corrective.

**User Stories liées** : US-041, US-074

**Acceptance Criteria**

- AC-001 : En cas d'échec de reconnaissance faciale, un message invite l'utilisateur à se repositionner devant la caméra.
- AC-002 : En cas d'échecs répétés de reconnaissance faciale, le message invite l'utilisateur à contacter l'administration.
- AC-003 : En cas de QR Code illisible ou invalide, un message d'erreur est affiché.
- AC-004 : Tous les messages d'erreur sont disponibles en français, en arabe et en anglais.

**Business Value** : Réduit la frustration des utilisateurs et limite les appels au support en cas d'incident d'identification.

**Estimated Story Points** : 3

**Dependencies** : PBI-001, PBI-003, PBI-004

**Risks** : Messages trop techniques ou incompréhensibles pour des utilisateurs non francophones.

**Notes** : Les messages doivent être validés par le Product Owner avant implémentation.

**Business Rules** : BR-005, BR-066
**Functional Requirements** : FR-902, FR-903

---

#### PBI-032 : Messages contextuels métier

- **Epic** : Epic 7 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 5

**Description**

Afficher des messages spécifiques selon le contexte métier : message "Restaurant Fermé" hors plage horaire, message "Repas déjà enregistré" en cas de double tentative, et messages distinguant un QR Code expiré d'un QR Code révoqué. Tous ces messages sont trilingues.

**User Stories liées** : US-072, US-073, US-058

**Acceptance Criteria**

- AC-001 : Lorsqu'une tentative d'identification est effectuée hors de la plage 12h30–14h00, le message "Restaurant Fermé" s'affiche en trois langues.
- AC-002 : Lorsqu'un utilisateur ayant déjà consommé un repas tente de s'identifier, le message "Repas déjà enregistré pour aujourd'hui" s'affiche.
- AC-003 : Le message d'expiration de QR Code est distinct du message de révocation. L'utilisateur comprend la différence et sait quoi faire.
- AC-004 : Tous les messages contextuels sont disponibles en français, en arabe et en anglais.

**Business Value** : Oriente précisément les utilisateurs selon leur situation, réduisant la confusion et les appels inutiles à l'administration.

**Estimated Story Points** : 5

**Dependencies** : PBI-010, PBI-011, PBI-005

**Risks** : Ambiguïté des messages pouvant induire des comportements incorrects.

**Notes** : Les textes des messages doivent être revus par un traducteur pour la version arabe.

**Business Rules** : BR-030, BR-043, BR-067, BR-068
**Functional Requirements** : FR-206, FR-904, FR-905, FR-906, FR-907

---

#### PBI-033 : Retour visuel après identification réussie

- **Epic** : Epic 7 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 2

**Description**

Afficher un retour visuel positif immédiatement après l'identification réussie d'un utilisateur (avant la sélection du repas), indiquant que la reconnaissance a abouti et que l'utilisateur peut procéder à son choix.

**User Stories liées** : US-039 (complément)

**Acceptance Criteria**

- AC-001 : Après identification réussie, un indicateur visuel positif s'affiche brièvement avant la transition vers l'écran de sélection.
- AC-002 : La transition vers l'écran de sélection est fluide et sans temps d'attente perceptible.
- AC-003 : Aucune donnée personnelle nominative n'est affichée lors de cette transition.

**Business Value** : Améliore l'expérience utilisateur et réduit l'incertitude entre l'identification et la sélection du repas.

**Estimated Story Points** : 2

**Dependencies** : PBI-001, PBI-003, PBI-004

**Risks** : Affichage de données personnelles par inadvertance.

**Notes** : Seul le prénom peut éventuellement être affiché si le Product Owner le valide explicitement.

**Business Rules** : BR-072
**Functional Requirements** : FR-901

---

### Epic 8 — Audit et Traçabilité

---

#### PBI-034 : Journalisation des actions administratives

- **Epic** : Epic 8 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 5

**Description**

Enregistrer automatiquement et de manière immuable toutes les actions effectuées par les administrateurs dans l'interface d'administration : créations, modifications, suppressions et révocations. Chaque entrée du journal contient l'identifiant de l'auteur, la nature de l'action et l'horodatage précis.

**User Stories liées** : US-042, US-075

**Acceptance Criteria**

- AC-001 : Chaque action d'un administrateur (création, modification, suppression d'utilisateur, révocation de QR Code) génère automatiquement une entrée dans le journal d'audit.
- AC-002 : Chaque entrée contient au minimum : l'identifiant de l'administrateur, la nature de l'action, l'objet concerné et l'horodatage.
- AC-003 : Le journal d'audit enregistre également chaque enregistrement de repas validé avec l'identifiant de l'utilisateur, la catégorie, le mode d'identification et l'horodatage.
- AC-004 : Les entrées du journal sont persistées de manière sécurisée et ne sont jamais exposées à des utilisateurs non autorisés.

**Business Value** : Assure la traçabilité complète des opérations pour les besoins d'audit interne, de conformité réglementaire et de résolution d'incidents.

**Estimated Story Points** : 5

**Dependencies** : PBI-015, PBI-009

**Risks** : Volume important d'entrées en cas de forte activité. Performances dégradées si la journalisation est synchrone et bloquante.

**Notes** : La journalisation doit être asynchrone pour ne pas impacter les performances de l'interface utilisateur.

**Business Rules** : BR-080, BR-082
**Functional Requirements** : FR-1001, FR-1002, FR-1003, FR-1004

---

#### PBI-035 : Immutabilité et intégrité du journal d'audit

- **Epic** : Epic 8 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 5

**Description**

Garantir que le journal d'audit est immuable. Aucun utilisateur, y compris les administrateurs, ne doit pouvoir modifier ou supprimer une entrée existante. L'accès en lecture est restreint aux administrateurs disposant des droits appropriés.

**User Stories liées** : US-043, US-044

**Acceptance Criteria**

- AC-001 : Toute tentative de modification ou de suppression d'une entrée du journal d'audit est bloquée et retourne une erreur.
- AC-002 : L'interface d'administration ne propose aucun bouton de modification ou de suppression d'entrées du journal.
- AC-003 : Seuls les administrateurs disposant des droits appropriés peuvent accéder en lecture au journal d'audit.
- AC-004 : Les entrées du journal sont affichées en ordre chronologique inverse (du plus récent au plus ancien).
- AC-005 : L'administrateur peut rechercher des entrées par date, par type d'action ou par auteur.

**Business Value** : Garantit l'intégrité des preuves d'audit. Protège l'entreprise en cas de litige ou d'inspection réglementaire.

**Estimated Story Points** : 5

**Dependencies** : PBI-034

**Risks** : Contournement de l'immutabilité par un accès direct à la base de données.

**Notes** : L'immutabilité doit être garantie au niveau applicatif ET au niveau de la base de données (droits d'accès restreints).

**Business Rules** : BR-081, BR-083
**Functional Requirements** : FR-1005, FR-1006

---

#### PBI-036 : Rétention et durabilité du journal d'audit

- **Epic** : Epic 8 | **Priority** : Should Have | **Status** : Planned | **Release** : 1.1
- **Story Points** : 3

**Description**

Définir et implémenter la politique de rétention du journal d'audit, garantissant la conservation des entrées pour une durée minimale conforme aux exigences de traçabilité de l'entreprise.

**User Stories liées** : US-076

**Acceptance Criteria**

- AC-001 : Les entrées du journal d'audit sont conservées pour une durée minimale de trois ans (sauf politique interne plus restrictive).
- AC-002 : Aucune suppression automatique d'entrées n'est effectuée avant l'expiration de la durée de rétention.
- AC-003 : La politique de rétention est configurable par la DSI sans développement.

**Business Value** : Assure la conformité réglementaire et la disponibilité des preuves d'audit sur la durée définie par l'entreprise.

**Estimated Story Points** : 3

**Dependencies** : PBI-034

**Risks** : Volume de stockage croissant sur plusieurs années.

**Notes** : La politique de rétention exacte doit être validée par le Responsable Juridique de l'entreprise avant le déploiement.

**Business Rules** : BR-084
**Functional Requirements** : FR-1007

---

#### PBI-037 : Journalisation des enregistrements de repas (Audit)

- **Epic** : Epic 8 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 5

**Description**

Consigner dans le journal d'audit chaque transaction de repas validée, avec tous les éléments nécessaires à la reconstitution de l'historique : identifiant utilisateur, catégorie de repas, mode d'identification, horodatage.

**User Stories liées** : US-075

**Acceptance Criteria**

- AC-001 : Chaque repas validé génère une entrée dans le journal d'audit.
- AC-002 : L'entrée contient : l'identifiant de l'utilisateur, la catégorie de repas choisie, le mode d'identification (Faciale ou QR Code), et l'horodatage précis.
- AC-003 : Les entrées de repas sont distinctes des entrées d'actions administratives dans le journal.
- AC-004 : Les entrées de repas sont consultables par les administrateurs disposant des droits appropriés.

**Business Value** : Permet la reconstitution de l'historique exact des consommations en cas de litige, d'erreur de facturation ou d'audit interne.

**Estimated Story Points** : 5

**Dependencies** : PBI-009, PBI-034

**Risks** : Redondance entre les données de repas (base principale) et le journal d'audit. Désynchronisation en cas de défaillance partielle.

**Notes** : Le journal d'audit des repas complète la base de données principale et ne la remplace pas.

**Business Rules** : BR-082
**Functional Requirements** : FR-1003, FR-1004

---

### Epic 9 — Configuration

---

#### PBI-038 : Mode kiosque et démarrage automatique

- **Epic** : Epic 9 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 3

**Description**

Configurer la tablette Android en mode kiosque : l'application CSM-GIAS Resto+ démarre automatiquement au démarrage de la tablette et s'affiche en plein écran. L'accès aux paramètres système Android est verrouillé pour les utilisateurs non authentifiés.

**User Stories liées** : US-045, US-046, US-078

**Acceptance Criteria**

- AC-001 : L'application se lance automatiquement au démarrage de la tablette, sans intervention de l'opérateur.
- AC-002 : L'application est opérationnelle en moins de deux secondes après activation de la tablette.
- AC-003 : Les boutons de navigation Android (retour, accueil, applications récentes) sont désactivés ou masqués pendant l'utilisation de l'application.
- AC-004 : L'accès aux paramètres Android est protégé par un code PIN connu uniquement des administrateurs.
- AC-005 : L'interface d'administration est accessible uniquement depuis un navigateur autorisé, et non depuis la tablette elle-même en utilisation normale.

**Business Value** : Garantit la disponibilité permanente de la borne pendant les heures de service. Prévient toute manipulation accidentelle ou intentionnelle de la tablette par les utilisateurs.

**Estimated Story Points** : 3

**Dependencies** : Aucune

**Risks** : Mise à jour système Android désactivant le mode kiosque. Blocage de la tablette nécessitant un redémarrage forcé.

**Notes** : Une procédure de sortie du mode kiosque pour maintenance doit être documentée et réservée aux administrateurs.

**Business Rules** : BR-073, BR-074, BR-075, BR-077
**Functional Requirements** : FR-601

---

#### PBI-039 : Interface d'administration en langue française

- **Epic** : Epic 9 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 2

**Description**

Garantir que l'intégralité de l'interface d'administration est rédigée et affichée exclusivement en langue française, pour tous les écrans, menus, messages d'erreur et labels de formulaires.

**User Stories liées** : US-078

**Acceptance Criteria**

- AC-001 : Tous les éléments textuels de l'interface d'administration sont en français, sans exception.
- AC-002 : Les messages d'erreur système affichés à l'administrateur sont en français.
- AC-003 : Les notifications et confirmations affichées dans l'interface d'administration sont en français.

**Business Value** : Assure la conformité linguistique de l'outil aux exigences de l'entreprise. Facilite l'adoption par les équipes administratives.

**Estimated Story Points** : 2

**Dependencies** : PBI-015

**Risks** : Bibliothèques tierces ou composants UI affichant des libellés en anglais par défaut.

**Notes** : Toutes les chaînes de caractères de l'interface d'administration doivent être externalisées dans un fichier de traduction pour faciliter une future internationalisation.

**Business Rules** : BR-051, BR-078
**Functional Requirements** : FR-602

---

### Epic 10 — Gestion des Utilisateurs

---

#### PBI-040 : Gestion complète des comptes Employés

- **Epic** : Epic 10 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 13

**Description**

Fournir à l'administrateur un module complet de gestion des employés : création de fiche avec les informations minimales requises, modification des informations, désactivation temporaire, réactivation, et suppression définitive avec effacement des données biométriques associées.

**User Stories liées** : US-047, US-048, US-052, US-053, US-049

**Acceptance Criteria**

- AC-001 : L'administrateur peut créer un compte employé en saisissant au minimum le nom, le prénom et le statut. Le compte est créé avec le statut Actif par défaut.
- AC-002 : L'administrateur peut modifier les informations d'un employé existant.
- AC-003 : L'administrateur peut désactiver un compte employé. Un employé désactivé ne peut plus enregistrer de repas.
- AC-004 : L'administrateur peut réactiver un compte employé précédemment désactivé.
- AC-005 : L'administrateur peut supprimer définitivement un compte employé. La suppression entraîne l'effacement irréversible des données biométriques associées.
- AC-006 : Toutes les actions effectuées sur les comptes employés sont consignées dans le journal d'audit.

**Business Value** : Permet à l'entreprise de maintenir à jour le référentiel des employés autorisés à utiliser le restaurant, avec une réactivité immédiate en cas de départ ou de suspension.

**Estimated Story Points** : 13

**Dependencies** : PBI-015

**Risks** : Suppression accidentelle d'un compte employé entraînant la perte définitive de ses données biométriques.

**Notes** : Une confirmation en deux étapes est recommandée pour la suppression définitive. Une désactivation préalable est conseillée avant toute suppression.

**Business Rules** : BR-010, BR-011, BR-012, BR-046
**Functional Requirements** : FR-101, FR-102, FR-103, FR-104, FR-105, FR-106

---

#### PBI-041 : Gestion des comptes Stagiaires

- **Epic** : Epic 10 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 8

**Description**

Permettre à l'accueil et à l'administrateur de créer des comptes stagiaires avec les informations minimales requises (nom, prénom, date de début, date de fin de stage), de modifier ces informations, et de consulter la liste des stagiaires avec la validité de leur QR Code.

**User Stories liées** : US-077, US-056, US-050

**Acceptance Criteria**

- AC-001 : L'accueil ou l'administrateur peut créer un compte stagiaire en saisissant le nom, le prénom, la date de début et la date de fin de stage. Ces quatre champs sont obligatoires.
- AC-002 : Après création, un QR Code nominatif est automatiquement généré (voir PBI-012).
- AC-003 : L'administrateur peut modifier les informations d'un stagiaire existant, y compris la date de fin de stage.
- AC-004 : La liste des stagiaires est consultable avec, pour chaque stagiaire, son nom, sa date de fin de stage et le statut de son QR Code (Actif / Expiré / Révoqué).
- AC-005 : Toutes les actions sur les comptes stagiaires sont consignées dans le journal d'audit.

**Business Value** : Intègre les stagiaires dans le système de restauration de manière autonome et contrôlée, avec une gestion automatisée de la durée d'accès.

**Estimated Story Points** : 8

**Dependencies** : PBI-015, PBI-012

**Risks** : Erreur de saisie de la date de fin de stage générant un QR Code à durée de vie incorrecte.

**Notes** : Le système doit valider que la date de fin de stage est postérieure à la date de début lors de la création.

**Business Rules** : BR-013, BR-018, BR-045
**Functional Requirements** : FR-107, FR-108, FR-110, FR-610

---

#### PBI-042 : Gestion des comptes Visiteurs

- **Epic** : Epic 10 | **Priority** : Must Have | **Status** : Planned | **Release** : 1.0
- **Story Points** : 5

**Description**

Permettre à l'accueil de créer rapidement un compte visiteur avec les informations minimales (nom, prénom, date de visite) et de lui générer immédiatement un QR Code temporaire valable pour la journée.

**User Stories liées** : US-079

**Acceptance Criteria**

- AC-001 : L'accueil peut créer un compte visiteur en saisissant le nom, le prénom et la date de visite.
- AC-002 : Un QR Code temporaire est généré immédiatement après la validation de la création.
- AC-003 : Le QR Code généré est affiché à l'écran et peut être imprimé ou transmis au visiteur.
- AC-004 : La liste des visiteurs enregistrés pour la journée est consultable par l'accueil et l'administrateur.
- AC-005 : Toutes les créations de comptes visiteurs sont consignées dans le journal d'audit.

**Business Value** : Permet un accueil rapide et professionnel des visiteurs avec une gestion entièrement numérique des droits d'accès au restaurant.

**Estimated Story Points** : 5

**Dependencies** : PBI-015, PBI-013

**Risks** : Visiteur perdant son QR Code avant d'accéder au restaurant.

**Notes** : La procédure en cas de perte du QR Code visiteur doit être documentée (révocation et regénération).

**Business Rules** : BR-019, BR-024, BR-045
**Functional Requirements** : FR-109, FR-111, FR-611

---

#### PBI-043 : Consultation et recherche des listes d'utilisateurs

- **Epic** : Epic 10 | **Priority** : Should Have | **Status** : Planned | **Release** : 1.1
- **Story Points** : 5

**Description**

Fournir à l'administrateur des vues de liste paginées et filtrables pour chaque type d'utilisateur (Employés, Stagiaires, Visiteurs), avec des fonctionnalités de recherche par nom et de filtrage par statut.

**User Stories liées** : US-051, US-054, US-055, US-080

**Acceptance Criteria**

- AC-001 : La liste des employés est affichée avec leur statut (Actif / Inactif) et un indicateur d'enrôlement biométrique.
- AC-002 : La liste des stagiaires affiche leur date de fin de stage et le statut de leur QR Code.
- AC-003 : La liste des visiteurs est filtrable par date de visite.
- AC-004 : Des champs de recherche permettent de trouver rapidement un utilisateur par son nom ou prénom.
- AC-005 : Les listes sont paginées pour gérer un grand nombre d'entrées sans dégradation des performances.

**Business Value** : Facilite la supervision et la gestion quotidienne du référentiel utilisateurs par l'administrateur.

**Estimated Story Points** : 5

**Dependencies** : PBI-040, PBI-041, PBI-042

**Risks** : Performances dégradées sans pagination correcte sur une base d'employés importante.

**Notes** : La pagination par défaut est de 25 éléments par page. La recherche doit être insensible à la casse et aux accents.

**Business Rules** : BR-046
**Functional Requirements** : FR-106, FR-110, FR-111

---

## 5. Backlog Prioritization

### 5.1 Méthode MoSCoW

La priorisation de l'ensemble des Product Backlog Items a été effectuée selon la méthode **MoSCoW**, en croisant la valeur métier, la criticité des règles métier associées, les dépendances techniques et le risque de déploiement.

### Must Have — Production immédiatement compromise sans ces PBIs

| PBI | Titre | Story Points | Justification |
|---|---|---|---|
| PBI-001 | Identification faciale des employés | 13 | Mécanisme central du système. BR-001 Critique. |
| PBI-002 | Enrôlement biométrique des employés | 13 | Prérequis absolu à PBI-001. BR-031 Critique. |
| PBI-003 | Identification des stagiaires par QR Code | 5 | BR-002 Critique. |
| PBI-004 | Identification des visiteurs par QR Code | 5 | BR-003 Critique. |
| PBI-005 | Contrôle de validité des QR Codes | 5 | BR-026, BR-027 Critiques. |
| PBI-006 | Authentification des administrateurs | 8 | BR-069 Critique. Sécurité de l'ensemble. |
| PBI-007 | Unicité des sessions d'identification | 2 | BR-006 Critique. |
| PBI-008 | Affichage et sélection du menu | 8 | Fonctionnalité centrale utilisateur. |
| PBI-009 | Enregistrement définitif du repas | 8 | Transaction métier principale. BR-040, BR-041 Critiques. |
| PBI-010 | Contrôle de la plage horaire | 5 | BR-042 Critique. |
| PBI-011 | Unicité du repas journalier | 5 | BR-008, BR-009 Critiques. |
| PBI-012 | QR Code Stagiaire | 8 | BR-016, BR-025 Critiques. |
| PBI-013 | QR Code Visiteur | 8 | BR-020, BR-025 Critiques. |
| PBI-014 | Révocation manuelle QR | 5 | BR-029 Critique. |
| PBI-015 | Interface d'administration sécurisée | 5 | BR-069, BR-073 Critiques. |
| PBI-016 | Gestion des comptes administrateurs | 5 | BR-049 Critique. |
| PBI-017 | Configuration des emails de rapports | 3 | Prérequis à PBI-021. |
| PBI-020 | Rapport journalier automatique | 5 | BR-053 Critique. |
| PBI-021 | Diffusion des rapports par email | 8 | BR-056 Critique. |
| PBI-026 | Conformité linguistique des rapports | 2 | BR-058 Haute. |
| PBI-030 | Confirmation d'enregistrement | 3 | BR-065 Haute. UX critique. |
| PBI-031 | Messages d'erreur d'identification | 3 | BR-005, BR-066 Hautes. |
| PBI-032 | Messages contextuels métier | 5 | BR-067, BR-068 Hautes. |
| PBI-033 | Retour visuel après identification | 2 | UX indispensable. |
| PBI-034 | Journalisation des actions administratives | 5 | BR-080 Critique. |
| PBI-035 | Immutabilité du journal d'audit | 5 | BR-083 Critique. |
| PBI-037 | Journalisation des enregistrements de repas | 5 | BR-082 Critique. |
| PBI-038 | Mode kiosque et démarrage automatique | 3 | BR-074, BR-075 Hautes. |
| PBI-039 | Interface admin en français | 2 | BR-051 Haute. |
| PBI-040 | Gestion des comptes Employés | 13 | FR-101 à FR-105 Critiques. |
| PBI-041 | Gestion des comptes Stagiaires | 8 | FR-107 Critique. |
| PBI-042 | Gestion des comptes Visiteurs | 5 | FR-109 Critique. |

**Total Must Have : 32 PBIs — 193 Story Points**

---

### Should Have — Valeur significative, déploiement post-MVP acceptable

| PBI | Titre | Story Points | Justification |
|---|---|---|---|
| PBI-018 | Réinitialisation mot de passe admin | 3 | Maintenance opérationnelle. |
| PBI-019 | Vue de révocation depuis l'administration | 5 | Supervision des accès. |
| PBI-022 | Contenu graphique des rapports | 13 | BR-057 Haute. Valeur analytique. |
| PBI-023 | Tableaux de données dans les rapports | 3 | BR-057 Haute. |
| PBI-024 | Rapports hebdomadaires et mensuels | 5 | BR-054, BR-055 Hautes. |
| PBI-025 | Consultation de l'historique des rapports | 3 | BR-059 Moyenne. |
| PBI-027 | Tableau de bord statistiques | 8 | BR-060 à BR-064 Hautes. |
| PBI-036 | Rétention du journal d'audit | 3 | BR-084 Haute. |
| PBI-043 | Consultation et recherche des listes | 5 | Confort opérationnel. |

**Total Should Have : 9 PBIs — 48 Story Points**

---

### Could Have — Valeur ajoutée, différé à Release 2.0

| PBI | Titre | Story Points | Justification |
|---|---|---|---|
| PBI-028 | Analyse des pics de fréquentation | 5 | BR-062 Haute. Valeur analytique avancée. |
| PBI-029 | Export CSV des statistiques | 3 | Confort utilisateur avancé. |

**Total Could Have : 2 PBIs — 8 Story Points**

---

### Won't Have (Version 1.x)

| Fonctionnalité | Justification |
|---|---|
| Tableau de bord web externe | Prévu en Release 2.0 selon la Vision Projet. |
| Synchronisation multi-tablettes | Hors périmètre Version 1.0 (tablette unique). |
| Intelligence artificielle / Prédictions | Version future identifiée dans la Vision Projet. |
| Réservation de repas à l'avance | Non prévue dans les exigences validées. |
| Application mobile employé | Non dans le périmètre de la Version 1.0. |

---

## 6. Définition du MVP — Version 1.0

Le MVP (Minimum Viable Product) de CSM-GIAS Resto+ est constitué de l'ensemble des PBIs classés **Must Have**. Ces 32 PBIs représentent les fonctionnalités strictement nécessaires au déploiement en production de la solution sur la tablette Android du restaurant de l'entreprise.

### Périmètre du MVP

Le MVP permet :

- L'identification biométrique des employés par reconnaissance faciale.
- L'identification des stagiaires et des visiteurs par QR Code.
- La sélection et l'enregistrement définitif d'un repas parmi trois catégories.
- Le contrôle de la plage horaire d'ouverture et de l'unicité journalière.
- La génération et la gestion du cycle de vie des QR Codes.
- La révocation manuelle immédiate des QR Codes.
- L'interface d'administration sécurisée pour la gestion des utilisateurs.
- La génération automatique des rapports journaliers et leur diffusion par email.
- La journalisation immuable de toutes les actions et transactions.
- Le mode kiosque de la tablette pour une disponibilité permanente.

### Justification du MVP

Chaque PBI du MVP est justifié par au moins une règle métier de priorité **Critique** ou **Haute** extraite du document des Règles Métier validé. Les PBIs Should Have et Could Have ont été délibérément exclus du MVP car leur absence ne compromet pas le fonctionnement opérationnel du restaurant numérisé en version 1.0.

**MVP Total : 32 PBIs — 193 Story Points**

---

## 7. Release Roadmap

### Release 1.0 — Production (MVP)

**Objectif** : Mettre en production la solution minimale viable permettant la numérisation complète de l'entrée du restaurant d'entreprise.

**Contenu** : 32 PBIs Must Have — 193 Story Points

| PBI | Titre | Epic | SP |
|---|---|---|---|
| PBI-001 | Identification faciale des employés | Epic 1 | 13 |
| PBI-002 | Enrôlement biométrique | Epic 1 | 13 |
| PBI-003 | Identification stagiaires QR Code | Epic 1 | 5 |
| PBI-004 | Identification visiteurs QR Code | Epic 1 | 5 |
| PBI-005 | Contrôle validité QR Codes | Epic 1 | 5 |
| PBI-006 | Authentification administrateurs | Epic 1 | 8 |
| PBI-007 | Unicité des sessions | Epic 1 | 2 |
| PBI-008 | Affichage et sélection du menu | Epic 2 | 8 |
| PBI-009 | Enregistrement définitif du repas | Epic 2 | 8 |
| PBI-010 | Contrôle plage horaire | Epic 2 | 5 |
| PBI-011 | Unicité du repas journalier | Epic 2 | 5 |
| PBI-012 | QR Code Stagiaire | Epic 3 | 8 |
| PBI-013 | QR Code Visiteur | Epic 3 | 8 |
| PBI-014 | Révocation manuelle QR | Epic 3 | 5 |
| PBI-015 | Interface d'administration | Epic 4 | 5 |
| PBI-016 | Gestion comptes administrateurs | Epic 4 | 5 |
| PBI-017 | Configuration emails rapports | Epic 4 | 3 |
| PBI-020 | Rapport journalier automatique | Epic 5 | 5 |
| PBI-021 | Diffusion rapports par email | Epic 5 | 8 |
| PBI-026 | Conformité linguistique rapports | Epic 5 | 2 |
| PBI-030 | Confirmation enregistrement | Epic 7 | 3 |
| PBI-031 | Messages d'erreur identification | Epic 7 | 3 |
| PBI-032 | Messages contextuels métier | Epic 7 | 5 |
| PBI-033 | Retour visuel identification | Epic 7 | 2 |
| PBI-034 | Journalisation actions admin | Epic 8 | 5 |
| PBI-035 | Immutabilité journal d'audit | Epic 8 | 5 |
| PBI-037 | Journalisation repas (Audit) | Epic 8 | 5 |
| PBI-038 | Mode kiosque tablette | Epic 9 | 3 |
| PBI-039 | Interface admin en français | Epic 9 | 2 |
| PBI-040 | Gestion comptes Employés | Epic 10 | 13 |
| PBI-041 | Gestion comptes Stagiaires | Epic 10 | 8 |
| PBI-042 | Gestion comptes Visiteurs | Epic 10 | 5 |

**Justification de Release 1.0** : Ces PBIs couvrent l'intégralité du flux opérationnel quotidien du restaurant, depuis l'identification de l'utilisateur jusqu'à la génération et la distribution automatique des rapports. Leur déploiement conjoint permet une mise en production immédiatement utilisable et conforme aux règles métier critiques.

---

### Release 1.1 — Enrichissements fonctionnels

**Objectif** : Renforcer les capacités d'administration, enrichir les rapports et améliorer la supervision des données.

**Contenu** : 9 PBIs Should Have — 48 Story Points

| PBI | Titre | Epic | SP |
|---|---|---|---|
| PBI-018 | Réinitialisation mot de passe admin | Epic 4 | 3 |
| PBI-019 | Vue révocation depuis interface admin | Epic 4 | 5 |
| PBI-022 | Contenu graphique des rapports | Epic 5 | 13 |
| PBI-023 | Tableaux de données dans les rapports | Epic 5 | 3 |
| PBI-024 | Rapports hebdomadaires et mensuels | Epic 5 | 5 |
| PBI-025 | Consultation historique des rapports | Epic 5 | 3 |
| PBI-027 | Tableau de bord statistiques | Epic 6 | 8 |
| PBI-036 | Rétention du journal d'audit | Epic 8 | 3 |
| PBI-043 | Consultation et recherche listes | Epic 10 | 5 |

**Justification de Release 1.1** : Ces PBIs s'appuient sur la base fonctionnelle déployée en Release 1.0. Ils enrichissent l'expérience des administrateurs et du Responsable Restaurant sans être bloquants pour la production initiale.

---

### Release 2.0 — Fonctionnalités avancées

**Objectif** : Apporter des capacités analytiques avancées et préparer les fondations de l'évolution vers un tableau de bord web multi-tablettes.

**Contenu** : 2 PBIs Could Have — 8 Story Points + évolutions hors périmètre

| PBI | Titre | Epic | SP |
|---|---|---|---|
| PBI-028 | Analyse des pics de fréquentation | Epic 6 | 5 |
| PBI-029 | Export CSV des statistiques | Epic 6 | 3 |

**Fonctionnalités futures identifiées (Won't Have v1.x)** :
- Tableau de bord web d'administration multi-tablettes.
- Synchronisation en temps réel entre plusieurs bornes.
- Module d'intelligence artificielle pour la prédiction de la demande.
- Application mobile dédiée.

**Justification de Release 2.0** : Ces fonctionnalités apportent une valeur analytique significative mais ne sont accessibles qu'une fois une base de données suffisamment constituée par la Release 1.0. Elles nécessitent également une réflexion architecturale sur l'évolution vers le web dashboard.

---

## 8. Dependency Matrix

Le tableau ci-dessous identifie les dépendances critiques entre les PBIs et met en évidence le chemin critique de développement.

| PBI | Dépend de | Type de dépendance | Impact sur chemin critique |
|---|---|---|---|
| PBI-001 | PBI-002, PBI-040 | Fonctionnelle | Critique |
| PBI-002 | PBI-015, PBI-040 | Fonctionnelle | Critique |
| PBI-003 | PBI-012 | Fonctionnelle | Critique |
| PBI-004 | PBI-013 | Fonctionnelle | Critique |
| PBI-005 | PBI-003, PBI-004, PBI-014 | Fonctionnelle | Critique |
| PBI-006 | Aucune | — | Point de départ |
| PBI-007 | PBI-001, PBI-003, PBI-004 | Fonctionnelle | Haute |
| PBI-008 | PBI-001, PBI-003, PBI-004 | Fonctionnelle | Critique |
| PBI-009 | PBI-008 | Fonctionnelle | Critique |
| PBI-010 | Aucune | — | Indépendant |
| PBI-011 | PBI-009 | Fonctionnelle | Critique |
| PBI-012 | PBI-041 | Fonctionnelle | Critique |
| PBI-013 | PBI-042 | Fonctionnelle | Critique |
| PBI-014 | PBI-006, PBI-012, PBI-013 | Fonctionnelle | Haute |
| PBI-015 | PBI-006 | Fonctionnelle | Critique |
| PBI-016 | PBI-015 | Fonctionnelle | Haute |
| PBI-017 | PBI-015, PBI-020 | Fonctionnelle | Haute |
| PBI-018 | PBI-016 | Fonctionnelle | Moyenne |
| PBI-019 | PBI-014, PBI-015 | Fonctionnelle | Moyenne |
| PBI-020 | PBI-009, PBI-017 | Fonctionnelle | Critique |
| PBI-021 | PBI-017, PBI-020 | Fonctionnelle | Critique |
| PBI-022 | PBI-020 | Fonctionnelle | Haute |
| PBI-023 | PBI-020 | Fonctionnelle | Haute |
| PBI-024 | PBI-020, PBI-021 | Fonctionnelle | Haute |
| PBI-025 | PBI-020, PBI-015 | Fonctionnelle | Moyenne |
| PBI-026 | PBI-020 | Fonctionnelle | Critique |
| PBI-027 | PBI-009, PBI-015 | Fonctionnelle | Haute |
| PBI-028 | PBI-027 | Fonctionnelle | Basse |
| PBI-029 | PBI-027 | Fonctionnelle | Basse |
| PBI-030 | PBI-009 | Fonctionnelle | Critique |
| PBI-031 | PBI-001, PBI-003, PBI-004 | Fonctionnelle | Critique |
| PBI-032 | PBI-010, PBI-011, PBI-005 | Fonctionnelle | Critique |
| PBI-033 | PBI-001, PBI-003, PBI-004 | Fonctionnelle | Haute |
| PBI-034 | PBI-015, PBI-009 | Fonctionnelle | Critique |
| PBI-035 | PBI-034 | Fonctionnelle | Critique |
| PBI-036 | PBI-034 | Fonctionnelle | Moyenne |
| PBI-037 | PBI-009, PBI-034 | Fonctionnelle | Critique |
| PBI-038 | Aucune | — | Point de départ |
| PBI-039 | PBI-015 | Fonctionnelle | Critique |
| PBI-040 | PBI-015 | Fonctionnelle | Critique |
| PBI-041 | PBI-015, PBI-012 | Fonctionnelle | Critique |
| PBI-042 | PBI-015, PBI-013 | Fonctionnelle | Critique |
| PBI-043 | PBI-040, PBI-041, PBI-042 | Fonctionnelle | Moyenne |

### Chemin Critique

Le chemin critique de développement pour la Release 1.0 est le suivant :

PBI-006 (Auth Admin) → PBI-015 (Interface Admin) → PBI-040 (Employés) → PBI-002 (Enrôlement) → PBI-001 (Identification faciale) → PBI-008 (Menu) → PBI-009 (Enregistrement repas) → PBI-020 (Rapport) → PBI-021 (Email)

Ce chemin critique doit être traité en priorité absolue lors du Sprint Planning. Tout retard sur l'un de ces PBIs impacte directement la date de livraison de la Release 1.0.

---

## 9. Product Backlog Metrics

### 9.1 Métriques Globales

| Métrique | Valeur |
|---|---|
| Nombre total de PBIs | 43 |
| Story Points totaux | 257 |
| PBIs Must Have | 32 (74,4 %) |
| PBIs Should Have | 9 (20,9 %) |
| PBIs Could Have | 2 (4,7 %) |
| PBIs Won't Have (v1.x) | 5 (hors périmètre) |
| Story Points MVP (Release 1.0) | 193 |
| Story Points Release 1.1 | 48 |
| Story Points Release 2.0 | 8 |
| Nombre d'Epics | 10 |

### 9.2 Story Points par Epic

| Epic | Titre | Story Points | % du Total |
|---|---|---|---|
| Epic 1 | Identification | 51 | 19,8 % |
| Epic 2 | Gestion des Repas | 26 | 10,1 % |
| Epic 3 | Gestion des QR Codes | 21 | 8,2 % |
| Epic 4 | Administration | 21 | 8,2 % |
| Epic 5 | Rapports | 46 | 17,9 % |
| Epic 6 | Statistiques | 16 | 6,2 % |
| Epic 7 | Notifications | 13 | 5,1 % |
| Epic 8 | Audit | 18 | 7,0 % |
| Epic 9 | Configuration | 5 | 1,9 % |
| Epic 10 | Gestion des Utilisateurs | 26 | 10,1 % |
| Hors Epic (non groupés) | — | 14 | 5,4 % |
| **Total** | | **257** | **100 %** |

### 9.3 Distribution des Priorités

| Priorité | Nombre de PBIs | Story Points | Pourcentage (SP) |
|---|---|---|---|
| Must Have | 32 | 193 | 75,1 % |
| Should Have | 9 | 48 | 18,7 % |
| Could Have | 2 | 8 | 3,1 % |
| Won't Have | 0 | 0 | 0 % |
| **Total** | **43** | **249** | **100 %** |

---

## 10. Traceability Matrix

La matrice ci-dessous établit la correspondance complète entre les Règles Métier (BR), les Exigences Fonctionnelles (FR), les User Stories (US) et les Product Backlog Items (PBI).

| Règle Métier | Exigence Fonctionnelle | User Story | Product Backlog Item |
|---|---|---|---|
| BR-001 | FR-201, FR-304 | US-001 | PBI-001 |
| BR-002 | FR-202 | US-002 | PBI-003 |
| BR-003 | FR-203 | US-003 | PBI-004 |
| BR-004 | FR-201, FR-202, FR-203 | US-001, US-002, US-003 | PBI-001, PBI-003, PBI-004 |
| BR-005 | FR-210 | US-041 | PBI-031 |
| BR-006 | FR-207 | US-011 | PBI-007 |
| BR-007 | FR-201, FR-302 | US-001 | PBI-001, PBI-002 |
| BR-008 | FR-508, FR-509 | US-020 | PBI-011 |
| BR-009 | FR-508 | US-020 | PBI-011 |
| BR-010 | FR-103, FR-307 | US-048 | PBI-040 |
| BR-011 | FR-101, FR-102 | US-047 | PBI-040 |
| BR-012 | FR-105, FR-308 | US-049 | PBI-040 |
| BR-013 | FR-107, FR-401 | US-077 | PBI-041 |
| BR-014 | FR-508, FR-509 | US-020 | PBI-011 |
| BR-015 | FR-508 | US-020 | PBI-011 |
| BR-016 | FR-402 | US-022 | PBI-012 |
| BR-017 | FR-204, FR-407 | US-004 | PBI-005 |
| BR-018 | FR-107, FR-108 | US-077, US-056 | PBI-041 |
| BR-019 | FR-403 | US-023 | PBI-013 |
| BR-020 | FR-404 | US-024 | PBI-013 |
| BR-021 | FR-508, FR-509 | US-020 | PBI-011 |
| BR-022 | FR-405 | US-057 | PBI-013 |
| BR-023 | FR-404, FR-407 | US-024 | PBI-013 |
| BR-024 | FR-109 | US-079 | PBI-042 |
| BR-025 | FR-401, FR-411 | US-021 | PBI-012 |
| BR-026 | FR-204, FR-407 | US-004 | PBI-005 |
| BR-027 | FR-406 | US-004 | PBI-005 |
| BR-028 | FR-409, FR-612 | US-025 | PBI-014 |
| BR-029 | FR-205, FR-408, FR-410 | US-005, US-026 | PBI-005, PBI-014 |
| BR-030 | FR-206, FR-906 | US-058 | PBI-032 |
| BR-031 | FR-301, FR-302, FR-606 | US-008 | PBI-002 |
| BR-032 | FR-303 | US-010 | PBI-002 |
| BR-033 | FR-305 | US-012 | PBI-001 |
| BR-034 | FR-306 | US-041 | PBI-031 |
| BR-035 | FR-309 | US-009 | PBI-002 |
| BR-036 | FR-308 | US-049 | PBI-002, PBI-040 |
| BR-037 | FR-501, FR-510 | US-013 | PBI-008 |
| BR-038 | FR-501, FR-502 | US-013, US-014 | PBI-008 |
| BR-039 | FR-503 | US-015 | PBI-008 |
| BR-040 | FR-504 | US-016 | PBI-009 |
| BR-041 | FR-505, FR-506 | US-017, US-018 | PBI-009 |
| BR-042 | FR-507 | US-019 | PBI-010 |
| BR-043 | FR-904 | US-072 | PBI-032 |
| BR-044 | FR-510 | US-013 | PBI-008 |
| BR-045 | FR-610, FR-611 | US-077, US-079 | PBI-041, PBI-042 |
| BR-046 | FR-101 à FR-105 | US-047 à US-051 | PBI-040, PBI-043 |
| BR-047 | FR-301, FR-606 | US-008 | PBI-002 |
| BR-048 | FR-603 | US-028 | PBI-016 |
| BR-049 | FR-604, FR-605 | US-029 | PBI-016 |
| BR-050 | FR-607, FR-608 | US-030 | PBI-017 |
| BR-051 | FR-602 | US-078 | PBI-039 |
| BR-052 | FR-613, FR-614 | US-061, US-062 | PBI-025, PBI-027 |
| BR-053 | FR-701 | US-031 | PBI-020 |
| BR-054 | FR-702 | US-032 | PBI-024 |
| BR-055 | FR-703 | US-063 | PBI-024 |
| BR-056 | FR-704, FR-705 | US-033, US-064 | PBI-021 |
| BR-057 | FR-706 à FR-710 | US-034, US-062, US-065, US-066 | PBI-022, PBI-023 |
| BR-058 | FR-711 | US-035 | PBI-026 |
| BR-059 | FR-712, FR-613 | US-061, US-068 | PBI-025 |
| BR-060 | FR-801 | US-036 | PBI-027 |
| BR-061 | FR-802 | US-069 | PBI-027 |
| BR-062 | FR-803 | US-038 | PBI-028 |
| BR-063 | FR-804 | US-037 | PBI-027 |
| BR-064 | FR-805 | US-070 | PBI-027 |
| BR-065 | FR-901 | US-039 | PBI-030 |
| BR-066 | FR-902, FR-903 | US-041, US-074 | PBI-031 |
| BR-067 | FR-907 | US-040 | PBI-030, PBI-031, PBI-032 |
| BR-068 | FR-905 | US-073 | PBI-032 |
| BR-069 | FR-208, FR-601 | US-006, US-027 | PBI-006, PBI-015 |
| BR-070 | FR-209 | US-007 | PBI-006 |
| BR-071 | FR-309 | US-009 | PBI-002 |
| BR-072 | FR-506 | US-018 | PBI-009 |
| BR-073 | FR-601 | US-046 | PBI-038 |
| BR-074 | N/A | US-045 | PBI-038 |
| BR-075 | N/A | US-045 | PBI-038 |
| BR-076 | FR-507 | US-019 | PBI-010 |
| BR-077 | N/A | US-045 | PBI-038 |
| BR-078 | FR-904 | US-072 | PBI-032 |
| BR-079 | N/A | Évolution future | Release 2.0 |
| BR-080 | FR-1001, FR-1002 | US-042 | PBI-034 |
| BR-081 | FR-1006 | US-044 | PBI-035 |
| BR-082 | FR-1003, FR-1004 | US-075 | PBI-037 |
| BR-083 | FR-1005 | US-043 | PBI-035 |
| BR-084 | FR-1007 | US-076 | PBI-036 |

> Aucune règle métier n'est orpheline. L'ensemble des 84 règles métier validées est couvert par au moins un Product Backlog Item.

---

## 11. Product Owner Review Checklist

La présente checklist certifie la qualité et la complétude du Product Backlog avant sa présentation à l'équipe Scrum.

| Critère de vérification | Statut | Commentaire |
|---|---|---|
| Toutes les User Stories (US-001 à US-080) sont représentées dans le Backlog | Conforme | Chaque US est liée à au moins un PBI. |
| Aucun PBI dupliqué n'est présent | Conforme | 43 PBIs distincts, aucune redondance identifiée. |
| Les priorités MoSCoW sont cohérentes avec les règles métier | Conforme | Toutes les BR Critiques sont Must Have. |
| Le MVP (Release 1.0) est complet et déployable | Conforme | 32 PBIs couvrant le flux opérationnel complet. |
| Les rapports automatiques critiques (BR-053, BR-056) sont inclus dans le MVP | Conforme | PBI-020, PBI-021 en Must Have Release 1.0. |
| Toutes les dépendances entre PBIs sont valides et réalistes | Conforme | Chemin critique identifié et documenté. |
| La Traceability Matrix couvre l'ensemble des 84 Règles Métier | Conforme | Aucune règle orpheline. |
| La Traceability Matrix couvre l'ensemble des Exigences Fonctionnelles | Conforme | Couverture FR-101 à FR-1007. |
| Chaque PBI est estimé en Story Points (valeurs Fibonacci) | Conforme | Valeurs : 2, 3, 5, 8, 13 utilisées. |
| Chaque PBI a une valeur métier explicitement formulée | Conforme | Section Business Value présente pour chaque PBI. |
| Le journal d'audit (BR-080 à BR-084) est inclus dans le MVP | Conforme | PBI-034, PBI-035, PBI-037 en Must Have. |
| La conformité RGPD (suppression des données biométriques) est couverte | Conforme | PBI-002, PBI-040 couvrent BR-012, BR-036. |
| Le mode kiosque de la tablette est inclus dans le MVP | Conforme | PBI-038 en Must Have. |
| La résistance à la fraude (révocation, expiration, unicité) est couverte | Conforme | PBI-005, PBI-011, PBI-014 en Must Have. |

**Verdict Product Owner** : Le Product Backlog est certifié conforme et prêt pour le Sprint Planning de la Release 1.0.

---

## 12. Glossaire

**Acceptance Criteria (Critères d'Acceptation)**
Conditions précises et vérifiables que doit satisfaire un Product Backlog Item pour être considéré comme "Done" lors du Sprint Review.

**Backlog Refinement**
Activité récurrente au cours de laquelle le Product Owner et l'équipe de développement affinent, décomposent et estiment les PBIs du Product Backlog en préparation des futurs sprints.

**Chemin Critique**
Séquence de PBIs dont le retard de l'un entraîne mécaniquement un retard de la livraison finale. Le chemin critique doit être traité en priorité absolue.

**Definition of Done (DoD)**
Ensemble des critères qui doivent être satisfaits pour qu'un PBI soit considéré comme terminé : implémenté, testé, révisé, documenté et approuvé par le Product Owner.

**Epic**
Regroupement thématique de User Stories et de PBIs partageant un objectif fonctionnel commun. Les Epics structurent le Product Backlog à un niveau de granularité plus élevé que les PBIs.

**MoSCoW**
Méthode de priorisation des exigences en quatre catégories : Must Have (indispensable), Should Have (important), Could Have (souhaitable), Won't Have (hors périmètre actuel).

**MVP (Minimum Viable Product)**
Version minimale du produit contenant uniquement les fonctionnalités indispensables à un déploiement en production. Permet de livrer de la valeur rapidement et de collecter des retours réels des utilisateurs.

**PBI (Product Backlog Item)**
Élément unitaire du Product Backlog représentant une fonctionnalité métier livrable. Chaque PBI est lié à des User Stories, estimé en Story Points et priorisé selon MoSCoW.

**Product Backlog**
Liste ordonnée et exhaustive de l'ensemble des fonctionnalités à réaliser pour un produit logiciel. Géré et maintenu par le Product Owner, il constitue l'unique source de vérité pour les développements.

**Product Owner**
Rôle Scrum responsable de maximiser la valeur du produit et de gérer le Product Backlog. Il est le représentant des parties prenantes auprès de l'équipe de développement.

**QR Code Nominatif**
QR Code attribué à un stagiaire lors de son intégration. Lié à son identité et valide jusqu'à la fin de son stage.

**QR Code Temporaire**
QR Code généré par l'accueil pour un visiteur. Valide uniquement le jour de son émission.

**Release**
Livraison d'un ensemble cohérent de fonctionnalités en production. Chaque Release correspond à un palier de valeur métier livré aux utilisateurs finaux.

**Sprint**
Itération de développement d'une durée fixe (généralement deux semaines) au cours de laquelle l'équipe réalise un ensemble de PBIs sélectionnés depuis le Product Backlog.

**Sprint Backlog**
Sous-ensemble du Product Backlog sélectionné par l'équipe pour un sprint donné, lors du Sprint Planning.

**Sprint Planning**
Cérémonie Scrum au cours de laquelle l'équipe sélectionne les PBIs du prochain sprint et définit l'objectif de sprint.

**Story Points**
Unité d'estimation relative de l'effort requis pour réaliser un PBI. Exprimée en valeurs de la suite de Fibonacci (1, 2, 3, 5, 8, 13...).

**Vélocité**
Mesure de la quantité de travail que l'équipe de développement est capable de réaliser en un sprint, exprimée en Story Points. Elle permet de prédire le nombre de sprints nécessaires pour livrer une Release.

---

## 13. Conclusion

Le présent Product Backlog constitue le référentiel opérationnel complet du projet **CSM-GIAS Resto+**, structurant 43 Product Backlog Items répartis sur 10 Epics et représentant un total estimé de 257 Story Points.

Ce backlog traduit fidèlement les 80 User Stories validées, elles-mêmes issues des Règles Métier et des Exigences Fonctionnelles approuvées. La traçabilité est complète et vérifiée : chacune des 84 règles métier est couverte par au moins un PBI, garantissant qu'aucune exigence n'est perdue dans la transition vers le développement.

### Le Product Backlog comme fondation du Sprint Planning

Le Sprint Planning peut désormais s'appuyer sur ce Product Backlog pour construire les premiers sprints de la Release 1.0. L'équipe Scrum sélectionnera les PBIs dans l'ordre de priorité établi, en respectant le chemin critique identifié. La vélocité de l'équipe permettra de calculer précisément le nombre de sprints nécessaires à la livraison du MVP (193 Story Points).

### Le Product Backlog comme contrat de livraison

Ce document constitue le contrat fonctionnel entre le Product Owner, l'équipe de développement et les parties prenantes. Les PBIs Must Have de la Release 1.0 représentent un engagement ferme de livraison. Les PBIs Should Have et Could Have font l'objet d'une négociation continue en fonction de la vélocité réelle de l'équipe.

### Évolutions attendues

Le Product Backlog est un artefact vivant. Il sera continuellement affiné au fil des sprints, en intégrant les retours des utilisateurs réels après le déploiement de la Release 1.0. Les PBIs des Releases 1.1 et 2.0 seront progressivement détaillés et estimés à l'approche de leur planification.

Ce Product Backlog est approuvé par le Product Owner et prêt pour son utilisation immédiate par l'équipe Scrum dans le cadre du Sprint Planning de CSM-GIAS Resto+.

---

*Document rédigé dans le cadre d'un projet de développement logiciel — CSM-GIAS, Été 2026.*
*Usage interne — Strictement confidentiel.*
