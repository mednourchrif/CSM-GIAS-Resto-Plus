# Exigences Fonctionnelles
## CSM-GIAS Resto+
### Solution Intelligente de Gestion du Restaurant d'Entreprise

---

| Champ                  | Détail                                              |
|------------------------|-----------------------------------------------------|
| **Nom du projet**      | CSM-GIAS Resto+                                     |
| **Titre du document**  | Exigences Fonctionnelles                            |
| **Référence**          | CSM-GIAS-RESTO-EF-v1.0                              |
| **Version**            | 1.0                                                 |
| **Date**               | Juillet 2026                                        |
| **Statut**             | Approuvé pour développement                         |
| **Auteur**             | Stagiaire — Département Informatique                |
| **Encadrant**          | Responsable Technique / DSI                         |
| **Confidentialité**    | Usage interne — Document propriétaire               |

---

## Historique des Révisions

| Version | Date         | Auteur                     | Description                                   |
|---------|--------------|----------------------------|-----------------------------------------------|
| 0.1     | Juin 2026    | Stagiaire — Département IT | Ébauche initiale                              |
| 0.9     | Juillet 2026 | Stagiaire — Département IT | Révision suite à validation des Règles Métier |
| 1.0     | Juillet 2026 | Stagiaire — Département IT | Version approuvée pour développement          |

---

## Table des Matières

1. Introduction
2. Exigences Fonctionnelles
   - FR-100 — Gestion des Utilisateurs
   - FR-200 — Authentification
   - FR-300 — Reconnaissance Faciale
   - FR-400 — QR Codes
   - FR-500 — Gestion des Repas
   - FR-600 — Administration
   - FR-700 — Rapports
   - FR-800 — Statistiques
   - FR-900 — Notifications
   - FR-1000 — Audit
3. Matrice de Traçabilité
4. Glossaire
5. Conclusion

---

## 1. Introduction

### 1.1 Objet du Document

Le présent document constitue le **référentiel des Exigences Fonctionnelles** de l'application **CSM-GIAS Resto+**. Il a pour objectif de définir de manière exhaustive, précise et non ambiguë l'ensemble des fonctionnalités que le système doit fournir pour répondre aux besoins opérationnels de l'entreprise.

Ce document est produit conformément aux bonnes pratiques de l'ingénierie des exigences logicielles, en référence au standard **IEEE 29148** relatif aux spécifications d'exigences système et logiciel. Chaque exigence fonctionnelle répond exclusivement à la question : **« Que doit faire le système ? »** — sans jamais préjuger de la manière dont elle sera techniquement réalisée.

### 1.2 Périmètre

Ce document couvre l'intégralité des fonctionnalités de la **version 1.0** de CSM-GIAS Resto+, déployée sur une tablette Android installée à l'entrée du restaurant de l'entreprise. Les fonctionnalités prévues pour les versions ultérieures (tableau de bord web, multi-tablettes, intelligence artificielle) sont hors périmètre et ne font l'objet d'aucune exigence dans le présent document.

### 1.3 Relation avec le Document de Vision Projet

Le **Document de Vision Projet (01_Project_Vision.md)** établit le cadre stratégique et les objectifs généraux de la solution. Le présent document traduit ces objectifs en exigences fonctionnelles précises, mesurables et directement exploitables par les équipes de développement et de qualification. Toute exigence du présent document est en cohérence avec la vision définie et ne saurait la contredire.

### 1.4 Relation avec les Règles Métier

Le **Document des Règles Métier (02_Regles_Metier.md)** définit les contraintes et comportements attendus du système du point de vue de l'entreprise. Chaque règle métier se traduit en une ou plusieurs exigences fonctionnelles. La Matrice de Traçabilité (Section 3) établit le lien formel entre chaque règle métier (BR-XXX) et les exigences fonctionnelles correspondantes (FR-XXX), garantissant qu'aucune règle n'est orpheline de toute implémentation fonctionnelle.

### 1.5 Comment Lire ce Document

Les exigences fonctionnelles sont organisées par **modules fonctionnels**, identifiés par des préfixes numériques (FR-100, FR-200, etc.). Chaque exigence est présentée dans un tableau structuré comprenant les champs suivants :

| Champ                        | Description                                                                                                   |
|------------------------------|---------------------------------------------------------------------------------------------------------------|
| **ID**                       | Identifiant unique de l'exigence, de la forme FR-NNN.                                                        |
| **Module**                   | Module fonctionnel auquel appartient l'exigence.                                                             |
| **Exigence Fonctionnelle**   | Énoncé précis de ce que le système doit faire, rédigé à la forme « Le système doit... ».                    |
| **Priorité**                 | Niveau d'importance : **Critique**, **Haute**, **Moyenne** ou **Basse**.                                     |
| **Statut**                   | État d'avancement de l'exigence : **Approuvée** (exigence livrée en version 1.0), **Future** (prévue en version ultérieure) ou **Dépréciée** (retirée du périmètre). |
| **Règles Métier associées**  | Identifiants des règles métier (BR-XXX) dont découle cette exigence.                                        |

Les niveaux de priorité sont définis comme suit :

| Priorité     | Signification                                                                                            |
|--------------|----------------------------------------------------------------------------------------------------------|
| **Critique** | Exigence fondamentale. L'absence de cette fonctionnalité rend le système inutilisable en production.    |
| **Haute**    | Exigence essentielle à implémenter en version 1.0. Sa non-réalisation constitue un défaut fonctionnel. |
| **Moyenne**  | Exigence importante qui améliore significativement la qualité ou l'expérience utilisateur.              |
| **Basse**    | Exigence souhaitable pouvant être différée en cas de contrainte de développement.                       |

---

## 2. Exigences Fonctionnelles

---

### FR-100 — Gestion des Utilisateurs

Ce module couvre toutes les opérations de création, modification, désactivation et suppression des différents types d'utilisateurs du système.

| ID      | Module                    | Exigence Fonctionnelle                                                                                                                         | Priorité  | Statut     | Règles Métier associées |
|---------|---------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|-----------|------------|-------------------------|
| FR-101  | Gestion des Utilisateurs  | Le système doit permettre à un administrateur de créer un compte employé en saisissant au minimum son nom, son prénom et son statut.           | Critique  | Approuvée  | BR-011, BR-046          |
| FR-102  | Gestion des Utilisateurs  | Le système doit permettre à un administrateur de modifier les informations d'un compte employé existant.                                       | Haute     | Approuvée  | BR-046, BR-011          |
| FR-103  | Gestion des Utilisateurs  | Le système doit permettre à un administrateur de désactiver un compte employé sans le supprimer du système.                                    | Critique  | Approuvée  | BR-010, BR-046          |
| FR-104  | Gestion des Utilisateurs  | Le système doit permettre à un administrateur de réactiver un compte employé précédemment désactivé.                                           | Haute     | Approuvée  | BR-010, BR-046          |
| FR-105  | Gestion des Utilisateurs  | Le système doit permettre à un administrateur de supprimer définitivement un compte employé.                                                   | Haute     | Approuvée  | BR-012, BR-046          |
| FR-106  | Gestion des Utilisateurs  | Le système doit permettre de consulter la liste complète des employés enregistrés, avec leur statut actif ou inactif.                          | Haute     | Approuvée  | BR-046                  |
| FR-107  | Gestion des Utilisateurs  | Le système doit permettre à l'accueil ou à un administrateur de créer un compte stagiaire en saisissant au minimum son nom, son prénom, sa date de début et sa date de fin de stage. | Critique  | Approuvée  | BR-013, BR-018, BR-045  |
| FR-108  | Gestion des Utilisateurs  | Le système doit permettre à un administrateur de modifier les informations d'un compte stagiaire existant, y compris ses dates de stage.       | Haute     | Approuvée  | BR-018, BR-046          |
| FR-109  | Gestion des Utilisateurs  | Le système doit permettre à l'accueil ou à un administrateur de créer un compte visiteur en saisissant au minimum son nom, son prénom et la date de sa visite. | Critique  | Approuvée  | BR-024, BR-045          |
| FR-110  | Gestion des Utilisateurs  | Le système doit permettre de consulter la liste des stagiaires enregistrés, avec la validité de leur QR Code.                                  | Moyenne   | Approuvée  | BR-046                  |
| FR-111  | Gestion des Utilisateurs  | Le système doit permettre de consulter la liste des visiteurs enregistrés pour une journée donnée.                                             | Moyenne   | Approuvée  | BR-045                  |

---

### FR-200 — Authentification

Ce module couvre les mécanismes d'identification des utilisateurs finaux (employés, stagiaires, visiteurs) ainsi que l'authentification des administrateurs.

| ID      | Module            | Exigence Fonctionnelle                                                                                                                                           | Priorité  | Statut     | Règles Métier associées |
|---------|-------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|------------|-------------------------|
| FR-201  | Authentification  | Le système doit permettre l'identification d'un employé par reconnaissance faciale, sans saisie d'identifiant ou de mot de passe.                               | Critique  | Approuvée  | BR-001, BR-004, BR-007  |
| FR-202  | Authentification  | Le système doit permettre l'identification d'un stagiaire par présentation de son QR Code nominatif, sans saisie d'identifiant ou de mot de passe.             | Critique  | Approuvée  | BR-002, BR-004          |
| FR-203  | Authentification  | Le système doit permettre l'identification d'un visiteur par présentation de son QR Code temporaire, sans saisie d'identifiant ou de mot de passe.             | Critique  | Approuvée  | BR-003, BR-004          |
| FR-204  | Authentification  | Le système doit rejeter toute tentative d'identification par un QR Code dont la date d'expiration est dépassée.                                                 | Critique  | Approuvée  | BR-026, BR-027          |
| FR-205  | Authentification  | Le système doit rejeter toute tentative d'identification par un QR Code qui a été révoqué manuellement par l'administration.                                    | Critique  | Approuvée  | BR-029                  |
| FR-206  | Authentification  | Le système doit afficher un message d'erreur distinct selon que le QR Code est expiré ou révoqué.                                                               | Haute     | Approuvée  | BR-030                  |
| FR-207  | Authentification  | Le système doit interdire l'identification simultanée de plusieurs utilisateurs. Une seule session d'identification peut être traitée à la fois.                 | Critique  | Approuvée  | BR-006                  |
| FR-208  | Authentification  | Le système doit permettre à un administrateur de s'authentifier via un mécanisme d'authentification basé sur JWT.                                                 | Critique  | Approuvée  | BR-069                  |
| FR-209  | Authentification  | Le système doit invalider automatiquement la session d'un administrateur lorsque son jeton d'accès arrive à expiration.                                          | Critique  | Approuvée  | BR-070                  |
| FR-210  | Authentification  | Le système doit afficher un message d'erreur explicite lorsqu'une tentative d'identification échoue, quel qu'en soit le motif.                                  | Haute     | Approuvée  | BR-005                  |

---

### FR-300 — Reconnaissance Faciale

Ce module couvre le processus d'enrôlement biométrique des employés ainsi que les opérations de reconnaissance faciale lors de l'accès au restaurant.

| ID      | Module                   | Exigence Fonctionnelle                                                                                                                                            | Priorité  | Statut     | Règles Métier associées |
|---------|--------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|------------|-------------------------|
| FR-301  | Reconnaissance Faciale   | Le système doit permettre à un administrateur de procéder à l'enrôlement biométrique d'un employé à l'aide de la caméra de la tablette.                         | Critique  | Approuvée  | BR-031, BR-047          |
| FR-302  | Reconnaissance Faciale   | Le système doit associer les données biométriques enrôlées au compte employé correspondant dans la base de données.                                               | Critique  | Approuvée  | BR-031, BR-007          |
| FR-303  | Reconnaissance Faciale   | Le système doit permettre à un administrateur de mettre à jour les données biométriques d'un employé déjà enrôlé.                                                | Haute     | Approuvée  | BR-032                  |
| FR-304  | Reconnaissance Faciale   | Le système doit identifier un employé en comparant son visage capturé en temps réel avec les données biométriques enregistrées lors de son enrôlement.           | Critique  | Approuvée  | BR-001, BR-031          |
| FR-305  | Reconnaissance Faciale   | Le système doit compléter le processus d'identification par reconnaissance faciale dans des conditions d'éclairage normales.           | Haute     | Approuvée  | BR-033                  |
| FR-306  | Reconnaissance Faciale   | Le système doit afficher un message d'erreur clair et inviter l'utilisateur à contacter l'administration lorsque la reconnaissance faciale échoue de manière répétée. | Haute     | Approuvée  | BR-034                  |
| FR-307  | Reconnaissance Faciale   | Le système doit refuser l'accès au service de restauration à tout employé dont le compte est désactivé, même si ses données biométriques sont présentes.         | Critique  | Approuvée  | BR-010                  |
| FR-308  | Reconnaissance Faciale   | Le système doit supprimer les données biométriques d'un employé de manière définitive et irréversible lorsque son compte est supprimé.                           | Critique  | Approuvée  | BR-036, BR-012          |
| FR-309  | Reconnaissance Faciale   | Le système doit stocker les données biométriques des employés sous forme chiffrée et ne jamais les exposer en clair.                                              | Critique  | Approuvée  | BR-035, BR-071          |

---

### FR-400 — QR Codes

Ce module couvre la génération, la validation, la révocation et la gestion du cycle de vie des QR Codes utilisés par les stagiaires et les visiteurs.

| ID      | Module    | Exigence Fonctionnelle                                                                                                                                                    | Priorité  | Statut     | Règles Métier associées |
|---------|-----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|------------|-------------------------|
| FR-401  | QR Codes  | Le système doit générer un QR Code nominatif unique pour chaque stagiaire lors de sa création dans le système.                                                           | Critique  | Approuvée  | BR-025, BR-013          |
| FR-402  | QR Codes  | Le QR Code d'un stagiaire doit avoir une date d'expiration correspondant automatiquement à la date de fin de stage renseignée lors de la création du compte.            | Critique  | Approuvée  | BR-016                  |
| FR-403  | QR Codes  | Le système doit permettre à l'accueil ou à un administrateur de générer un QR Code temporaire pour un visiteur.                                                          | Critique  | Approuvée  | BR-019, BR-045          |
| FR-404  | QR Codes  | Le QR Code d'un visiteur doit expirer automatiquement à la fin de la journée calendaire de son émission.                                                                                  | Critique  | Approuvée  | BR-020                  |
| FR-405  | QR Codes  | Le système doit s'assurer qu'un seul QR Code actif existe pour un même visiteur au cours d'une même journée.                                                             | Haute     | Approuvée  | BR-022                  |
| FR-406  | QR Codes  | Le système doit valider la date d'expiration de tout QR Code présenté avant d'autoriser toute opération d'enregistrement de repas.                                      | Critique  | Approuvée  | BR-027                  |
| FR-407  | QR Codes  | Le système doit rejeter immédiatement tout QR Code dont la date d'expiration est atteinte ou dépassée.                                                                   | Critique  | Approuvée  | BR-026                  |
| FR-408  | QR Codes  | Le système doit rejeter immédiatement tout QR Code figurant sur la liste des codes révoqués, indépendamment de sa date d'expiration.                                    | Critique  | Approuvée  | BR-029                  |
| FR-409  | QR Codes  | Le système doit permettre à un administrateur de révoquer manuellement un QR Code actif, quel que soit son type (stagiaire ou visiteur).                                | Haute     | Approuvée  | BR-028                  |
| FR-410  | QR Codes  | La révocation d'un QR Code doit prendre effet immédiatement, sans délai de propagation.                                                                                  | Critique  | Approuvée  | BR-029                  |
| FR-411  | QR Codes  | Chaque QR Code généré par le système doit être unique et non réutilisable par un autre utilisateur.                                                                      | Critique  | Approuvée  | BR-025                  |

---

### FR-500 — Gestion des Repas

Ce module couvre le cycle complet d'enregistrement d'un repas, depuis l'affichage des catégories jusqu'à la confirmation et la persistance de la transaction.

| ID      | Module              | Exigence Fonctionnelle                                                                                                                                                   | Priorité  | Statut     | Règles Métier associées |
|---------|---------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|------------|-------------------------|
| FR-501  | Gestion des Repas   | Le système doit afficher les trois catégories de repas disponibles (Plat, Pizza, Sandwich) immédiatement après l'identification réussie d'un utilisateur.               | Critique  | Approuvée  | BR-037, BR-038          |
| FR-502  | Gestion des Repas   | Le système doit permettre à l'utilisateur de sélectionner une et une seule catégorie de repas parmi les trois proposées.                                                | Critique  | Approuvée  | BR-038                  |
| FR-503  | Gestion des Repas   | Le système doit interdire la validation d'un enregistrement sans qu'une catégorie de repas ait été préalablement sélectionnée.                                          | Critique  | Approuvée  | BR-039                  |
| FR-504  | Gestion des Repas   | Le système doit enregistrer la consommation du repas de manière définitive et irréversible dès que l'utilisateur confirme sa sélection.                                 | Critique  | Approuvée  | BR-040                  |
| FR-505  | Gestion des Repas   | Le système doit horodater automatiquement chaque enregistrement de repas au moment de sa confirmation.                                                                   | Critique  | Approuvée  | BR-041                  |
| FR-506  | Gestion des Repas   | Le système doit enregistrer, pour chaque repas validé, l'identifiant de l'utilisateur, la catégorie choisie, le mode d'identification utilisé et l'horodatage.         | Critique  | Approuvée  | BR-041, BR-082          |
| FR-507  | Gestion des Repas   | Le système doit refuser tout enregistrement de repas effectué en dehors de la plage horaire 12h30–14h00.                                                                | Critique  | Approuvée  | BR-042                  |
| FR-508  | Gestion des Repas   | Le système doit refuser l'enregistrement d'un second repas pour un utilisateur ayant déjà consommé un repas au cours de la même journée calendaire.                    | Critique  | Approuvée  | BR-008, BR-014, BR-021  |
| FR-509  | Gestion des Repas   | Le système doit vérifier l'unicité du repas par utilisateur et par jour avant toute validation, quel que soit le type d'utilisateur (employé, stagiaire ou visiteur).  | Critique  | Approuvée  | BR-008, BR-014, BR-021  |
| FR-510  | Gestion des Repas   | Les intitulés des catégories de repas affichés dans l'interface (Plat, Pizza, Sandwich) sont fixes et ne peuvent pas être modifiés par les utilisateurs ou les administrateurs. | Critique  | Approuvée  | BR-037, BR-044 |

---

### FR-600 — Administration

Ce module couvre toutes les fonctionnalités accessibles aux administrateurs et au personnel d'accueil via l'interface d'administration.

| ID      | Module          | Exigence Fonctionnelle                                                                                                                                               | Priorité  | Statut     | Règles Métier associées |
|---------|-----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|------------|-------------------------|
| FR-601  | Administration  | Le système doit présenter une interface d'administration sécurisée, distincte de l'interface utilisateur de la tablette, accessible uniquement après authentification. | Critique  | Approuvée  | BR-069, BR-073          |
| FR-602  | Administration  | L'interface d'administration doit être disponible exclusivement en langue française.                                                                                 | Haute     | Approuvée  | BR-051                  |
| FR-603  | Administration  | Le système doit permettre à un administrateur de créer un nouveau compte administrateur en lui attribuant des identifiants de connexion.                             | Haute     | Approuvée  | BR-048                  |
| FR-604  | Administration  | Le système doit garantir en permanence l'existence d'au moins un compte administrateur actif. La suppression du dernier administrateur actif doit être bloquée.     | Critique  | Approuvée  | BR-049                  |
| FR-605  | Administration  | Le système doit permettre à un administrateur de désactiver un compte administrateur existant, à l'exception de son propre compte.                                  | Haute     | Approuvée  | BR-049                  |
| FR-606  | Administration  | Le système doit permettre à un administrateur d'accéder à l'interface d'enrôlement biométrique pour capturer les données faciales d'un employé via la caméra de la tablette. | Critique  | Approuvée  | BR-047, BR-031        |
| FR-607  | Administration  | Le système doit permettre à un administrateur de configurer la liste des adresses email destinataires des rapports automatiques.                                     | Haute     | Approuvée  | BR-050                  |
| FR-608  | Administration  | Le système doit permettre à un administrateur d'ajouter ou de supprimer des adresses email de la liste des destinataires de rapports.                               | Haute     | Approuvée  | BR-050                  |
| FR-609  | Administration  | Le système doit permettre à un administrateur de consulter le journal d'audit des actions administratives.                                                           | Critique  | Approuvée  | BR-081                  |
| FR-610  | Administration  | Le système doit permettre à l'accueil de créer un compte stagiaire et de générer son QR Code nominatif.                                                             | Critique  | Approuvée  | BR-045                  |
| FR-611  | Administration  | Le système doit permettre à l'accueil de créer un compte visiteur et de générer son QR Code temporaire.                                                             | Critique  | Approuvée  | BR-045                  |
| FR-612  | Administration  | Le système doit permettre à un administrateur de révoquer manuellement tout QR Code actif depuis l'interface d'administration.                                      | Haute     | Approuvée  | BR-028, BR-409          |
| FR-613  | Administration  | Le système doit permettre à un administrateur de consulter les rapports générés antérieurement.                                                                     | Haute     | Approuvée  | BR-052, BR-059          |
| FR-614  | Administration  | Le système doit permettre à un administrateur de consulter les statistiques d'utilisation du restaurant.                                                            | Haute     | Approuvée  | BR-052                  |

---

### FR-700 — Rapports

Ce module couvre la génération automatique et la diffusion par email des rapports périodiques d'activité du restaurant.

| ID      | Module    | Exigence Fonctionnelle                                                                                                                                              | Priorité  | Statut     | Règles Métier associées |
|---------|-----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|------------|-------------------------|
| FR-701  | Rapports  | Le système doit générer automatiquement un rapport journalier à l'issue de chaque journée de restauration, sans intervention humaine.                              | Critique  | Approuvée  | BR-053                  |
| FR-702  | Rapports  | Le système doit générer automatiquement un rapport hebdomadaire à l'issue de chaque semaine calendaire.                                                            | Haute     | Approuvée  | BR-054                  |
| FR-703  | Rapports  | Le système doit générer automatiquement un rapport mensuel à l'issue de chaque mois calendaire.                                                                    | Haute     | Approuvée  | BR-055                  |
| FR-704  | Rapports  | Le système doit transmettre automatiquement chaque rapport généré par email à l'ensemble des destinataires configurés, sans intervention humaine.                  | Critique  | Approuvée  | BR-056                  |
| FR-705  | Rapports  | Le système doit prendre en charge l'envoi simultané des rapports à plusieurs adresses email destinataires.                                                          | Haute     | Approuvée  | BR-056                  |
| FR-706  | Rapports  | Chaque rapport généré doit contenir des statistiques synthétiques relatives à la période couverte.                                                                  | Haute     | Approuvée  | BR-057                  |
| FR-707  | Rapports  | Chaque rapport généré doit contenir des tableaux structurés présentant les données de consommation par catégorie, par type d'utilisateur et par plage horaire.    | Haute     | Approuvée  | BR-057                  |
| FR-708  | Rapports  | Chaque rapport généré doit contenir des représentations graphiques de type camembert illustrant la répartition des consommations.                                  | Haute     | Approuvée  | BR-057                  |
| FR-709  | Rapports  | Chaque rapport généré doit contenir des représentations graphiques de type courbe illustrant l'évolution de la fréquentation sur la période.                       | Haute     | Approuvée  | BR-057                  |
| FR-710  | Rapports  | Chaque rapport généré doit contenir des représentations graphiques de type histogramme illustrant la répartition horaire des enregistrements.                      | Haute     | Approuvée  | BR-057                  |
| FR-711  | Rapports  | Tous les rapports doivent être rédigés exclusivement en langue française.                                                                                           | Haute     | Approuvée  | BR-058                  |
| FR-712  | Rapports  | Le système doit conserver un historique de tous les rapports générés, accessible en consultation par les administrateurs.                                          | Moyenne   | Approuvée  | BR-059                  |

---

### FR-800 — Statistiques

Ce module couvre le calcul et la restitution des indicateurs d'activité du restaurant, accessibles depuis l'interface d'administration.

| ID      | Module        | Exigence Fonctionnelle                                                                                                                                          | Priorité  | Statut     | Règles Métier associées |
|---------|---------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|------------|-------------------------|
| FR-801  | Statistiques  | Le système doit calculer et restituer le nombre total de repas enregistrés pour toute période définie par l'administrateur.                                    | Haute     | Approuvée  | BR-060                  |
| FR-802  | Statistiques  | Le système doit calculer et restituer la répartition du nombre de repas enregistrés par catégorie (Plat, Pizza, Sandwich).                                     | Haute     | Approuvée  | BR-061                  |
| FR-803  | Statistiques  | Le système doit calculer et restituer la fréquentation horaire du restaurant, en agrégeant les enregistrements par tranche horaire au sein de la plage d'ouverture. | Haute     | Approuvée  | BR-062                  |
| FR-804  | Statistiques  | Le système doit calculer et restituer la répartition du nombre de repas enregistrés par type d'utilisateur : Employés, Stagiaires et Visiteurs.               | Haute     | Approuvée  | BR-063                  |
| FR-805  | Statistiques  | Le système doit calculer et restituer la répartition des identifications effectuées selon le mode utilisé : Reconnaissance Faciale et QR Code.                 | Moyenne   | Approuvée  | BR-064                  |
| FR-806  | Statistiques  | Le système doit présenter l'ensemble des indicateurs statistiques sous une forme lisible et structurée dans l'interface d'administration.                       | Haute     | Approuvée  | BR-052                  |

---

### FR-900 — Notifications

Ce module couvre l'ensemble des messages affichés à l'écran de la tablette à destination des utilisateurs finaux en réponse à leurs actions.

| ID      | Module         | Exigence Fonctionnelle                                                                                                                                                   | Priorité  | Statut     | Règles Métier associées |
|---------|----------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|------------|-------------------------|
| FR-901  | Notifications  | Le système doit afficher un message de confirmation visuel immédiatement après l'enregistrement réussi d'un repas.                                                      | Haute     | Approuvée  | BR-065                  |
| FR-902  | Notifications  | Le système doit afficher un message d'erreur explicite lorsqu'une identification par reconnaissance faciale échoue.                                                     | Haute     | Approuvée  | BR-066                  |
| FR-903  | Notifications  | Le système doit afficher un message d'erreur explicite lorsqu'un QR Code présenté est invalide.                                                                          | Haute     | Approuvée  | BR-066                  |
| FR-904  | Notifications  | Le système doit afficher un message informant l'utilisateur que le restaurant est fermé lorsqu'une tentative d'enregistrement est effectuée en dehors de la plage 12h30–14h00. | Haute     | Approuvée  | BR-043, BR-078         |
| FR-905  | Notifications  | Le système doit afficher un message indiquant à l'utilisateur qu'il a déjà enregistré son repas pour la journée lorsqu'une tentative de double enregistrement est détectée. | Critique  | Approuvée  | BR-068                 |
| FR-906  | Notifications  | Le système doit afficher un message distinct selon que le QR Code est expiré ou révoqué, afin d'orienter correctement l'utilisateur.                                    | Haute     | Approuvée  | BR-030                  |
| FR-907  | Notifications  | L'ensemble des messages affichés aux utilisateurs finaux sur la tablette (confirmation, erreur, restaurant fermé, déjà enregistré) doit être disponible en français, en arabe et en anglais. | Haute     | Approuvée  | BR-067, BR-078      |

---

### FR-1000 — Audit

Ce module couvre la journalisation automatique et sécurisée des actions administratives et des transactions d'enregistrement de repas.

| ID       | Module  | Exigence Fonctionnelle                                                                                                                                                                   | Priorité  | Statut     | Règles Métier associées |
|----------|---------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|------------|-------------------------|
| FR-1001  | Audit   | Le système doit enregistrer automatiquement une entrée dans le journal d'audit pour chaque action effectuée par un administrateur.                                                      | Critique  | Approuvée  | BR-080                  |
| FR-1002  | Audit   | Chaque entrée du journal d'audit relatif aux actions administratives doit contenir au minimum : l'identifiant de l'administrateur auteur de l'action, la nature de l'action et l'horodatage précis. | Critique  | Approuvée  | BR-080               |
| FR-1003  | Audit   | Le système doit enregistrer automatiquement une entrée dans le journal d'audit pour chaque enregistrement de repas validé.                                                              | Critique  | Approuvée  | BR-082                  |
| FR-1004  | Audit   | Chaque entrée du journal d'audit relatif aux enregistrements de repas doit contenir au minimum : l'identifiant de l'utilisateur, la catégorie de repas, le mode d'identification et l'horodatage. | Critique  | Approuvée  | BR-082              |
| FR-1005  | Audit   | Le système doit garantir l'immutabilité du journal d'audit. Aucun utilisateur, y compris les administrateurs, ne doit pouvoir modifier ou supprimer une entrée existante.               | Critique  | Approuvée  | BR-083                  |
| FR-1006  | Audit   | Le système doit restreindre l'accès en lecture au journal d'audit aux seuls administrateurs disposant des droits appropriés.                                                            | Critique  | Approuvée  | BR-081                  |
| FR-1007  | Audit   | Le système doit conserver les entrées du journal d'audit pour une durée minimale garantissant la traçabilité des opérations conformément aux exigences de l'entreprise.                | Haute     | Approuvée  | BR-084                  |

---

## 3. Matrice de Traçabilité

La matrice ci-dessous établit la correspondance formelle entre chaque Règle Métier (BR-XXX) définie dans le document des Règles Métier et les Exigences Fonctionnelles (FR-XXX) qui en découlent. Cette matrice garantit qu'aucune règle métier n'est orpheline de toute implémentation fonctionnelle, et que l'intégralité du périmètre métier est couvert.

| Règle Métier | Intitulé synthétique                              | Exigences Fonctionnelles associées           |
|--------------|---------------------------------------------------|----------------------------------------------|
| BR-001       | Identification des employés par face uniquement   | FR-201, FR-304                               |
| BR-002       | Identification des stagiaires par QR Code         | FR-202                                       |
| BR-003       | Identification des visiteurs par QR Code temp.    | FR-203                                       |
| BR-004       | Aucune saisie de mot de passe pour les utilisateurs finaux | FR-201, FR-202, FR-203                |
| BR-005       | Message d'erreur en cas d'échec d'identification  | FR-210, FR-902, FR-903                       |
| BR-006       | Une seule session d'identification à la fois      | FR-207                                       |
| BR-007       | Enrôlement biométrique préalable obligatoire      | FR-201, FR-302                               |
| BR-008       | Un repas par employé par jour                     | FR-508, FR-509                               |
| BR-009       | Rejet du double enregistrement pour un employé    | FR-508, FR-905                               |
| BR-010       | Employé désactivé ne peut pas s'enregistrer       | FR-103, FR-307                               |
| BR-011       | Fiche employé minimale                            | FR-101, FR-102                               |
| BR-012       | Suppression employé entraîne suppression biom.    | FR-105, FR-308                               |
| BR-013       | Création stagiaire avec dates obligatoires        | FR-107, FR-401                               |
| BR-014       | Un repas par stagiaire par jour                   | FR-508, FR-509                               |
| BR-015       | Rejet du double enregistrement pour un stagiaire  | FR-508, FR-905                               |
| BR-016       | QR Code stagiaire expire à la fin du stage        | FR-402                                       |
| BR-017       | Stagiaire bloqué après expiration QR Code         | FR-204, FR-407                               |
| BR-018       | Fiche stagiaire minimale                          | FR-107, FR-108                               |
| BR-019       | Visiteur reçoit un QR Code temporaire             | FR-403, FR-611                               |
| BR-020       | QR Code visiteur expire à minuit                  | FR-404                                       |
| BR-021       | Un repas par visiteur par jour                    | FR-508, FR-509                               |
| BR-022       | Un seul QR Code actif par visiteur par jour       | FR-405                                       |
| BR-023       | QR Code visiteur non réutilisable le lendemain    | FR-404, FR-407                               |
| BR-024       | Fiche visiteur minimale                           | FR-109                                       |
| BR-025       | QR Code unique par utilisateur                    | FR-401, FR-411                               |
| BR-026       | QR Code expiré est rejeté                         | FR-204, FR-407                               |
| BR-027       | Validation temporelle avant enregistrement        | FR-406                                       |
| BR-028       | Révocation manuelle possible                      | FR-409, FR-612                               |
| BR-029       | QR Code révoqué est rejeté immédiatement          | FR-205, FR-408, FR-410                       |
| BR-030       | Message distinct expiré vs révoqué                | FR-206, FR-906                               |
| BR-031       | Enrôlement biométrique via caméra tablette        | FR-301, FR-302, FR-606                       |
| BR-032       | Mise à jour données biométriques possible         | FR-303                                       |
| BR-033       | Identification faciale en moins de 3 secondes     | FR-305                                       |
| BR-034       | Message et redirection en cas d'échec répété      | FR-306                                       |
| BR-035       | Données biométriques stockées chiffrées           | FR-309                                       |
| BR-036       | Suppression biom. lors de suppression employé     | FR-308                                       |
| BR-037       | Trois catégories immuables                        | FR-501, FR-510                               |
| BR-038       | Sélection d'une seule catégorie                   | FR-501, FR-502                               |
| BR-039       | Enregistrement impossible sans sélection          | FR-503                                       |
| BR-040       | Enregistrement définitif et irréversible          | FR-504                                       |
| BR-041       | Horodatage automatique                            | FR-505, FR-506                               |
| BR-042       | Restriction horaire 12h30–14h00                   | FR-507                                       |
| BR-043       | Message restaurant fermé                          | FR-904                                       |
| BR-044       | Noms catégories non modifiables                   | FR-510                                       |
| BR-045       | Droits de l'accueil                               | FR-610, FR-611                               |
| BR-046       | Droits de l'administrateur sur les employés       | FR-101, FR-102, FR-103, FR-104, FR-105       |
| BR-047       | Admin procède à l'enrôlement biométrique          | FR-606, FR-301                               |
| BR-048       | Admin peut créer d'autres admins                  | FR-603                                       |
| BR-049       | Au moins un admin actif en permanence             | FR-604, FR-605                               |
| BR-050       | Configuration des destinataires email             | FR-607, FR-608                               |
| BR-051       | Interface admin en français uniquement            | FR-602                                       |
| BR-052       | Admin consulte statistiques et rapports           | FR-613, FR-614                               |
| BR-053       | Rapport journalier automatique                    | FR-701                                       |
| BR-054       | Rapport hebdomadaire automatique                  | FR-702                                       |
| BR-055       | Rapport mensuel automatique                       | FR-703                                       |
| BR-056       | Envoi automatique par email                       | FR-704, FR-705                               |
| BR-057       | Rapports avec stats, tableaux et graphiques       | FR-706, FR-707, FR-708, FR-709, FR-710       |
| BR-058       | Rapports en français                              | FR-711                                       |
| BR-059       | Historique des rapports conservé                  | FR-712, FR-613                               |
| BR-060       | Total repas par période                           | FR-801                                       |
| BR-061       | Répartition par catégorie                         | FR-802                                       |
| BR-062       | Fréquentation horaire                             | FR-803                                       |
| BR-063       | Répartition par type d'utilisateur                | FR-804                                       |
| BR-064       | Répartition par mode d'identification             | FR-805                                       |
| BR-065       | Message de confirmation après enregistrement      | FR-901                                       |
| BR-066       | Message d'erreur en cas d'échec                   | FR-902, FR-903                               |
| BR-067       | Messages en FR / AR / EN                          | FR-907                                       |
| BR-068       | Message double enregistrement explicite           | FR-905                                       |
| BR-069       | Authentification admin par jeton sécurisé         | FR-208, FR-601                               |
| BR-070       | Jeton expiré rejeté automatiquement               | FR-209                                       |
| BR-071       | Données biométriques jamais en clair              | FR-309                                       |
| BR-072       | Aucune donnée personnelle affichée après validation | FR-506                                     |
| BR-073       | Interface sans accès sans authentification        | FR-601                                       |
| BR-074       | Déploiement sur tablette Android unique           | FR-507 *(contrainte d'environnement)*        |
| BR-075       | Démarrage en moins de 2 secondes                  | *(Exigence non fonctionnelle — hors périmètre EF)* |
| BR-076       | Enregistrement complet en moins de 30 secondes    | *(Exigence non fonctionnelle — hors périmètre EF)* |
| BR-077       | Disponibilité pendant la plage d'ouverture        | *(Exigence non fonctionnelle — hors périmètre EF)* |
| BR-078       | Messages en FR / AR / EN                          | FR-907                                       |
| BR-079       | Architecture évolutive pour version web           | *(Exigence non fonctionnelle — hors périmètre EF)* |
| BR-080       | Journal d'audit des actions admin                 | FR-1001, FR-1002                             |
| BR-081       | Accès audit réservé aux admins autorisés          | FR-1006, FR-609                              |
| BR-082       | Journal des enregistrements de repas              | FR-1003, FR-1004, FR-506                     |
| BR-083       | Immutabilité du journal d'audit                   | FR-1005                                      |
| BR-084       | Conservation du journal pendant durée minimale    | FR-1007                                      |

> **Note** : Les règles métier BR-075, BR-076, BR-077 et BR-079 sont des exigences non fonctionnelles de performance, de disponibilité et d'architecture. Elles ne génèrent pas d'exigences fonctionnelles mais seront traitées dans le document des Exigences Non Fonctionnelles.

---

## 4. Glossaire

Le présent glossaire reprend les termes métier essentiels utilisés dans ce document. Pour la définition complète de chaque terme, se référer au **Glossaire du Document des Règles Métier (02_Regles_Metier.md)**.

---

**Administrateur** : Utilisateur habilité disposant de droits d'accès étendus permettant la gestion des comptes, des paramètres système, des rapports et du journal d'audit.

**Accueil** : Service chargé de l'accueil des visiteurs et de la création des comptes stagiaires, disposant de droits d'accès restreints à ces seules fonctions.

**Audit** : Mécanisme de journalisation automatique, immuable et sécurisée, enregistrant l'ensemble des actions administratives et des transactions d'enregistrement de repas.

**Catégorie de repas** : Classification fixe et non modifiable des types de repas proposés au restaurant. Les trois catégories disponibles en version 1.0 sont : Plat, Pizza et Sandwich.

**Employé** : Membre du personnel permanent de l'entreprise, identifié exclusivement par reconnaissance faciale.

**Enrôlement biométrique** : Opération unique d'enregistrement des données faciales d'un employé dans le système, réalisée par un administrateur via la caméra de la tablette.

**Enregistrement de repas** : Transaction par laquelle un utilisateur identifié sélectionne et confirme la consommation d'une catégorie de repas. L'enregistrement est horodaté et définitif.

**Horodatage** : Marquage temporel automatique appliqué par le système à chaque événement significatif.

**Plage d'ouverture** : Période journalière fixée de 12h30 à 14h00 pendant laquelle l'enregistrement des repas est autorisé.

**QR Code nominatif** : Code graphique unique attribué à un stagiaire, valide pendant toute la durée de son stage.

**QR Code temporaire** : Code graphique unique généré pour un visiteur, valide uniquement pour la journée calendaire de son émission.

**Rapport** : Document synthétique généré automatiquement par le système à intervalles réguliers, transmis par email aux destinataires configurés, contenant statistiques, tableaux et graphiques.

**Reconnaissance faciale** : Technologie biométrique permettant d'identifier un employé en comparant son visage capturé en temps réel avec ses données enregistrées lors de l'enrôlement.

**Révocation** : Invalidation manuelle anticipée d'un QR Code par un administrateur, prenant effet immédiatement.

**Stagiaire** : Personne en stage au sein de l'entreprise pour une durée déterminée, identifiée par QR Code nominatif.

**Visiteur** : Personne extérieure à l'entreprise présente pour une visite ponctuelle, identifiée par QR Code temporaire.

---

## 5. Conclusion

Le présent document recense et formalise **88 exigences fonctionnelles** réparties en **10 modules fonctionnels**, couvrant l'intégralité du périmètre applicatif de la version 1.0 de **CSM-GIAS Resto+**. Chaque exigence est formulée de manière atomique, claire, testable et traçable, conformément aux bonnes pratiques de l'ingénierie des exigences logicielles issues du standard IEEE 29148.

La production de ce référentiel d'exigences fonctionnelles avant toute phase de conception architecturale ou de développement répond à plusieurs impératifs fondamentaux du génie logiciel d'entreprise.

**Fondement de l'architecture** : les architectes logiciels ne peuvent concevoir une architecture technique solide et pertinente qu'à partir d'exigences fonctionnelles formalisées. Chaque décision d'architecture doit pouvoir être justifiée par une ou plusieurs exigences du présent document.

**Contrat de développement** : ce document constitue le contrat fonctionnel liant les équipes de développement aux commanditaires du projet. Toute fonctionnalité développée doit correspondre à au moins une exigence identifiée ; toute exigence doit trouver une implémentation dans le système livré.

**Base de qualification** : chaque exigence fonctionnelle est directement transformable en un ou plusieurs cas de test. L'équipe d'assurance qualité s'appuiera sur ce document pour élaborer le plan de qualification et vérifier la conformité du système développé aux spécifications.

**Maîtrise du périmètre** : en délimitant explicitement l'ensemble des fonctions attendues du système, ce document protège le projet contre toute dérive fonctionnelle non maîtrisée et constitue la référence en cas de litige sur le périmètre.

**Traçabilité bidirectionnelle** : la Matrice de Traçabilité établit un lien formel et vérifiable entre les Règles Métier, les Exigences Fonctionnelles et, par extension, les futurs composants techniques et cas de test. Cette traçabilité est indispensable pour la gestion des changements et la maintenance évolutive du système.

Ce document constitue désormais l'entrée principale du processus de conception technique et sera tenu à jour tout au long du cycle de vie du projet, en cohérence avec l'ensemble de la documentation fonctionnelle et technique de CSM-GIAS Resto+.

---

> **Note documentaire** : Ce document est à maintenir en cohérence avec le Document de Vision Projet et le Document des Règles Métier. Toute modification d'une exigence doit faire l'objet d'une mise à jour de l'historique des révisions, d'une vérification de la cohérence avec les règles métier associées, et d'une communication aux équipes concernées.

---

*Document rédigé dans le cadre d'un stage en ingénierie logicielle — CSM-GIAS, Été 2026.*
