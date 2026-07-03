# Règles Métier
## CSM-GIAS Resto+
### Solution Intelligente de Gestion du Restaurant d'Entreprise

---

| Champ                  | Détail                                              |
|------------------------|-----------------------------------------------------|
| **Nom du projet**      | CSM-GIAS Resto+                                     |
| **Titre du document**  | Règles Métier                                       |
| **Version**            | 1.0                                                 |
| **Date**               | Juillet 2026                                        |
| **Statut**             | Approuvé pour développement                         |
| **Auteur**             | Stagiaire — Département Informatique                |
| **Encadrant**          | Responsable Technique / DSI                         |
| **Confidentialité**    | Usage interne — Document propriétaire               |

---

## Historique des Révisions

| Version | Date         | Auteur                          | Description                         |
|---------|--------------|---------------------------------|-------------------------------------|
| 0.1     | Juin 2026    | Stagiaire — Département IT      | Première ébauche                    |
| 1.0     | Juillet 2026 | Stagiaire — Département IT      | Version initiale approuvée          |

---

## Table des Matières

1. Introduction
2. Règles Métier
   - 2.1 Authentification
   - 2.2 Employés
   - 2.3 Stagiaires
   - 2.4 Visiteurs
   - 2.5 QR Codes
   - 2.6 Reconnaissance Faciale
   - 2.7 Repas
   - 2.8 Administration
   - 2.9 Rapports
   - 2.10 Statistiques
   - 2.11 Notifications
   - 2.12 Sécurité
   - 2.13 Contraintes Opérationnelles
   - 2.14 Audit
3. Glossaire
4. Conclusion

---

## 1. Introduction

### 1.1 Objet du Document

Le présent document définit l'ensemble des règles métier régissant le fonctionnement de l'application **CSM-GIAS Resto+**. Il constitue le référentiel fonctionnel de référence pour toutes les équipes impliquées dans le cycle de développement du projet : architectes logiciels, développeurs backend et mobile, équipes de test, chefs de projet, ainsi que les encadrants universitaires et industriels.

Une règle métier est une contrainte, une condition ou un comportement attendu du système qui découle directement des exigences fonctionnelles ou des politiques de l'entreprise. Elle est indépendante de toute considération technique et ne fait référence à aucune implémentation particulière.

### 1.2 Relation avec le Document de Vision Projet

Le présent document est directement dérivé du **Document de Vision Projet — CSM-GIAS Resto+ (Version 1.0)**. Les règles métier formalisent et précisent les objectifs fonctionnels, les contraintes et les comportements attendus qui ont été décrits de manière synthétique dans la vision. En cas de contradiction entre les deux documents, la version la plus récente du présent document fait foi, sous réserve de validation par l'encadrant technique.

### 1.3 Importance des Règles Métier

La définition préalable et exhaustive des règles métier est une étape critique dans tout projet de développement logiciel d'entreprise. Elle remplit plusieurs fonctions essentielles :

- **Alignement fonctionnel** : garantir que toutes les parties prenantes partagent une compréhension commune et non ambiguë du comportement attendu du système.
- **Cadrage du développement** : fournir aux développeurs des spécifications précises, atomiques et testables, limitant ainsi le risque d'interprétation incorrecte.
- **Base de test** : chaque règle métier constitue un cas de test potentiel, facilitant l'élaboration du plan de qualification.
- **Gestion du périmètre** : identifier clairement ce qui est dans le périmètre du projet, prévenant toute dérive fonctionnelle non maîtrisée.
- **Traçabilité** : assurer une traçabilité complète entre les exigences métier, les spécifications techniques et les développements réalisés.

### 1.4 Conventions de Lecture

Chaque règle métier est identifiée par un identifiant unique de la forme **BR-XXX** (Business Rule), une catégorie fonctionnelle, un énoncé précis et un niveau de priorité défini comme suit :

| Priorité     | Définition                                                                                         |
|--------------|----------------------------------------------------------------------------------------------------|
| **Critique** | La règle est non négociable. Sa violation entraîne un dysfonctionnement majeur ou un risque métier grave. |
| **Haute**    | La règle est essentielle au bon fonctionnement du système. Elle doit être implémentée en version 1.0. |
| **Moyenne**  | La règle améliore significativement l'expérience utilisateur ou la qualité des données.            |
| **Basse**    | La règle est souhaitable mais peut être différée si les contraintes de développement l'imposent.   |

---

## 2. Règles Métier

### 2.1 Authentification

| ID      | Catégorie        | Règle Métier                                                                                                                                                 | Priorité  |
|---------|------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| BR-001  | Authentification | Les employés s'identifient exclusivement par reconnaissance faciale. Aucun autre mode d'identification n'est admis pour cette catégorie d'utilisateurs.       | Critique  |
| BR-002  | Authentification | Les stagiaires s'identifient exclusivement par QR Code nominatif. La reconnaissance faciale ne leur est pas accessible.                                       | Critique  |
| BR-003  | Authentification | Les visiteurs s'identifient exclusivement par QR Code temporaire. La reconnaissance faciale ne leur est pas accessible.                                       | Critique  |
| BR-004  | Authentification | Les employés, stagiaires et visiteurs ne saisissent aucun identifiant ou mot de passe pour accéder au service de restauration.                               | Haute     |
| BR-005  | Authentification | En cas d'échec d'identification, le système affiche un message d'erreur explicite et invite l'utilisateur à recommencer l'opération.                         | Haute     |
| BR-006  | Authentification | Le système ne peut pas identifier simultanément deux utilisateurs. Une seule session d'identification est traitée à la fois.                                  | Critique  |

---

### 2.2 Employés

| ID      | Catégorie  | Règle Métier                                                                                                                                                      | Priorité  |
|---------|------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| BR-007  | Employés   | Un employé doit avoir préalablement fait l'objet d'un enrôlement biométrique par l'administration pour pouvoir utiliser le système.                               | Critique  |
| BR-008  | Employés   | Un employé ne peut enregistrer qu'un seul repas par jour calendaire, quelle que soit la catégorie choisie.                                                       | Critique  |
| BR-009  | Employés   | Si un employé tente d'enregistrer un second repas le même jour, le système refuse la demande et affiche un message indiquant que le repas a déjà été enregistré. | Critique  |
| BR-010  | Employés   | Un employé désactivé par l'administration ne peut pas enregistrer de repas, même si ses données biométriques sont présentes dans le système.                     | Critique  |
| BR-011  | Employés   | La fiche d'un employé comprend au minimum son nom, son prénom et son statut actif ou inactif.                                                                    | Haute     |
| BR-012  | Employés   | La suppression d'un employé du système entraîne la suppression de ses données biométriques associées.                                                            | Haute     |

---

### 2.3 Stagiaires

| ID      | Catégorie   | Règle Métier                                                                                                                                                  | Priorité  |
|---------|-------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| BR-013  | Stagiaires  | Un stagiaire est créé dans le système par l'accueil ou l'administration, avec une date de début et une date de fin de stage obligatoires.                     | Critique  |
| BR-014  | Stagiaires  | Un stagiaire ne peut enregistrer qu'un seul repas par jour calendaire.                                                                                        | Critique  |
| BR-015  | Stagiaires  | Si un stagiaire tente d'enregistrer un second repas le même jour, le système refuse la demande et l'en informe explicitement.                                  | Critique  |
| BR-016  | Stagiaires  | Le QR Code d'un stagiaire expire automatiquement à la date de fin de stage définie lors de sa création.                                                       | Critique  |
| BR-017  | Stagiaires  | Après expiration du QR Code, le stagiaire ne peut plus accéder au service de restauration, sauf renouvellement explicite par l'administration.               | Haute     |
| BR-018  | Stagiaires  | La fiche d'un stagiaire comprend au minimum son nom, son prénom, la date de début et la date de fin de son stage.                                            | Haute     |

---

### 2.4 Visiteurs

| ID      | Catégorie  | Règle Métier                                                                                                                                                   | Priorité  |
|---------|------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| BR-019  | Visiteurs  | Un visiteur reçoit un QR Code temporaire généré par l'accueil au moment de sa visite.                                                                        | Critique  |
| BR-020  | Visiteurs  | Le QR Code d'un visiteur est valide uniquement pour la journée courante. Il expire automatiquement à minuit du jour d'émission.                               | Critique  |
| BR-021  | Visiteurs  | Un visiteur est autorisé à enregistrer un seul repas par jour. Une tentative de double enregistrement est rejetée par le système.                             | Critique  |
| BR-022  | Visiteurs  | Il n'est pas possible de générer plusieurs QR Codes actifs pour un même visiteur au cours de la même journée.                                                 | Haute     |
| BR-023  | Visiteurs  | Le QR Code d'un visiteur ne peut pas être utilisé le lendemain ou lors d'une visite ultérieure. Un nouveau QR Code doit être généré pour chaque nouvelle visite. | Critique  |
| BR-024  | Visiteurs  | La fiche d'un visiteur comprend au minimum son nom, son prénom et la date de sa visite.                                                                       | Moyenne   |

---

### 2.5 QR Codes

| ID      | Catégorie | Règle Métier                                                                                                                                       | Priorité  |
|---------|-----------|----------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| BR-025  | QR Codes  | Chaque QR Code généré par le système est unique et non réutilisable par un autre utilisateur.                                                     | Critique  |
| BR-026  | QR Codes  | Un QR Code expiré est rejeté par le système, quel que soit le profil de l'utilisateur qui le présente.                                            | Critique  |
| BR-027  | QR Codes  | Le système vérifie systématiquement la validité temporelle du QR Code au moment de sa présentation, avant tout enregistrement de repas.           | Critique  |
| BR-028  | QR Codes  | Un QR Code peut être révoqué manuellement par l'administration avant sa date d'expiration naturelle.                                              | Haute     |
| BR-029  | QR Codes  | Un QR Code révoqué est immédiatement rejeté par le système lors de sa présentation.                                                               | Critique  |
| BR-030  | QR Codes  | Le système affiche un message explicite lorsqu'un QR Code est expiré ou révoqué, en distinguant les deux cas.                                     | Moyenne   |

---

### 2.6 Reconnaissance Faciale

| ID      | Catégorie               | Règle Métier                                                                                                                                                          | Priorité  |
|---------|-------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| BR-031  | Reconnaissance Faciale  | L'enrôlement biométrique d'un employé est réalisé une seule fois par l'administration, à l'aide de la caméra de la tablette dédiée à l'application.                  | Critique  |
| BR-032  | Reconnaissance Faciale  | L'enrôlement biométrique d'un même employé peut être réinitialisé ou mis à jour par un administrateur en cas de nécessité (changement physique notable, erreur initiale). | Haute  |
| BR-033  | Reconnaissance Faciale  | Le système doit être en mesure d'identifier un employé en moins de trois secondes dans des conditions d'éclairage normales.                                            | Haute     |
| BR-034  | Reconnaissance Faciale  | En cas d'impossibilité d'identification par reconnaissance faciale après plusieurs tentatives, l'utilisateur est invité à contacter l'administration.                  | Haute     |
| BR-035  | Reconnaissance Faciale  | Les données biométriques des employés sont stockées de manière sécurisée et ne sont utilisées qu'aux fins d'identification dans le cadre de cette application.        | Critique  |
| BR-036  | Reconnaissance Faciale  | La suppression d'un employé du système entraîne l'effacement définitif de ses données biométriques associées.                                                         | Critique  |

---

### 2.7 Repas

| ID      | Catégorie | Règle Métier                                                                                                                                                | Priorité  |
|---------|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| BR-037  | Repas     | Les catégories de repas disponibles dans le système sont au nombre de trois et immuables : Plat, Pizza et Sandwich.                                        | Critique  |
| BR-038  | Repas     | L'utilisateur sélectionne une et une seule catégorie de repas après avoir été identifié avec succès.                                                       | Critique  |
| BR-039  | Repas     | Il n'est pas possible d'enregistrer un repas sans avoir sélectionné une catégorie.                                                                         | Critique  |
| BR-040  | Repas     | L'enregistrement d'un repas est définitif. L'utilisateur final ne peut ni annuler ni modifier son choix après confirmation.                                 | Haute     |
| BR-041  | Repas     | L'enregistrement d'un repas est horodaté automatiquement par le système au moment de la confirmation.                                                      | Critique  |
| BR-042  | Repas     | L'enregistrement d'un repas n'est possible qu'entre 12h30 et 14h00, heure locale. Toute tentative en dehors de cette plage est automatiquement rejetée.    | Critique  |
| BR-043  | Repas     | Le système informe l'utilisateur que le restaurant est fermé lorsqu'une tentative d'enregistrement est effectuée hors des horaires d'ouverture.             | Haute     |
| BR-044  | Repas     | Les noms des catégories de repas ne sont pas configurables par les utilisateurs ou les administrateurs. Toute modification nécessite une intervention de développement. | Critique |

---

### 2.8 Administration

| ID      | Catégorie      | Règle Métier                                                                                                                                                   | Priorité  |
|---------|----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| BR-045  | Administration | L'accueil dispose des droits nécessaires pour créer des comptes stagiaires et des comptes visiteurs, ainsi que pour générer leurs QR Codes respectifs.         | Haute     |
| BR-046  | Administration | Un administrateur dispose des droits permettant de créer, modifier, désactiver et supprimer les comptes employés.                                             | Critique  |
| BR-047  | Administration | Un administrateur est habilité à procéder à l'enrôlement biométrique des employés via la caméra de la tablette.                                              | Critique  |
| BR-048  | Administration | Un administrateur peut créer d'autres comptes administrateurs et définir leurs droits d'accès.                                                               | Haute     |
| BR-049  | Administration | Plusieurs administrateurs peuvent coexister dans le système. Il ne peut y avoir de situation où aucun administrateur actif n'existe.                         | Haute     |
| BR-050  | Administration | Un administrateur peut configurer les adresses email destinataires des rapports automatiques.                                                                 | Haute     |
| BR-051  | Administration | L'interface d'administration est accessible exclusivement en langue française.                                                                                | Haute     |
| BR-052  | Administration | L'administration peut consulter les statistiques et les rapports générés par le système.                                                                     | Haute     |

---

### 2.9 Rapports

| ID      | Catégorie | Règle Métier                                                                                                                                                 | Priorité  |
|---------|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| BR-053  | Rapports  | Le système génère automatiquement un rapport journalier à la clôture de chaque journée de restauration.                                                     | Critique  |
| BR-054  | Rapports  | Le système génère automatiquement un rapport hebdomadaire à la fin de chaque semaine.                                                                        | Haute     |
| BR-055  | Rapports  | Le système génère automatiquement un rapport mensuel à la fin de chaque mois calendaire.                                                                     | Haute     |
| BR-056  | Rapports  | Chaque rapport généré est transmis automatiquement par email à l'ensemble des destinataires configurés, sans intervention humaine.                           | Critique  |
| BR-057  | Rapports  | Les rapports contiennent obligatoirement des statistiques synthétiques, des tableaux de données, ainsi que des représentations graphiques (camemberts, courbes, histogrammes). | Haute |
| BR-058  | Rapports  | Tous les rapports sont rédigés exclusivement en langue française.                                                                                            | Haute     |
| BR-059  | Rapports  | Le système conserve un historique de tous les rapports générés.                                                                                              | Moyenne   |

---

### 2.10 Statistiques

| ID      | Catégorie    | Règle Métier                                                                                                                                                | Priorité  |
|---------|--------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| BR-060  | Statistiques | Le système calcule et restitue le nombre total de repas enregistrés pour une période donnée.                                                               | Haute     |
| BR-061  | Statistiques | Le système calcule et restitue la répartition des repas enregistrés par catégorie (Plat, Pizza, Sandwich).                                                 | Haute     |
| BR-062  | Statistiques | Le système calcule et restitue la fréquentation horaire du restaurant, permettant d'identifier les pics d'affluence.                                       | Haute     |
| BR-063  | Statistiques | Le système calcule et restitue la répartition des repas enregistrés par type d'utilisateur : Employés, Stagiaires et Visiteurs.                            | Haute     |
| BR-064  | Statistiques | Le système calcule et restitue la répartition des identifications par mode : Reconnaissance Faciale et QR Code.                                            | Moyenne   |

---

### 2.11 Notifications

| ID      | Catégorie     | Règle Métier                                                                                                                                                   | Priorité  |
|---------|---------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| BR-065  | Notifications | Le système affiche un message de confirmation visuel à l'utilisateur immédiatement après l'enregistrement réussi de son repas.                               | Haute     |
| BR-066  | Notifications | Le système affiche un message d'erreur clair et compréhensible lorsqu'une identification échoue.                                                             | Haute     |
| BR-067  | Notifications | Les messages destinés aux utilisateurs finaux (confirmation, erreur, restaurant fermé) sont affichés en français, en arabe et en anglais.                     | Haute     |
| BR-068  | Notifications | Le message de rejet pour double enregistrement indique explicitement à l'utilisateur qu'il a déjà enregistré son repas pour la journée.                       | Haute     |

---

### 2.12 Sécurité

| ID      | Catégorie | Règle Métier                                                                                                                                                    | Priorité  |
|---------|-----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| BR-069  | Sécurité  | L'accès à toutes les fonctionnalités d'administration est protégé par une authentification préalable au moyen d'un jeton d'accès sécurisé.                     | Critique  |
| BR-070  | Sécurité  | Les jetons d'accès administrateur ont une durée de validité limitée. Un jeton expiré est automatiquement rejeté par le système.                                | Critique  |
| BR-071  | Sécurité  | Les données biométriques des employés sont stockées sous forme chiffrée. Elles ne sont jamais transmises en clair sur le réseau.                               | Critique  |
| BR-072  | Sécurité  | Aucune donnée d'identification personnelle n'est affichée à l'écran de la tablette après validation de l'enregistrement d'un repas.                           | Haute     |
| BR-073  | Sécurité  | L'application de la tablette n'expose aucune interface de configuration accessible sans authentification préalable.                                            | Critique  |

---

### 2.13 Contraintes Opérationnelles

| ID      | Catégorie              | Règle Métier                                                                                                                                                   | Priorité  |
|---------|------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| BR-074  | Contraintes            | L'application est déployée sur une tablette Android unique installée à l'entrée du restaurant. Elle n'est pas accessible sur d'autres terminaux en version 1.0. | Haute    |
| BR-075  | Contraintes            | L'application doit démarrer et être opérationnelle en moins de deux secondes après activation de la tablette.                                                  | Haute     |
| BR-076  | Contraintes            | L'interface utilisateur doit permettre l'enregistrement complet d'un repas — identification incluse — en moins de trente secondes dans des conditions normales. | Haute    |
| BR-077  | Contraintes            | Le système doit rester fonctionnel et disponible pendant toute la plage d'ouverture du restaurant (12h30–14h00), sans interruption planifiée.                  | Critique  |
| BR-078  | Contraintes            | L'interface utilisateur principale est rédigée en français. Les messages essentiels sont également disponibles en arabe et en anglais.                          | Haute     |
| BR-079  | Contraintes            | L'architecture technique de la solution doit permettre, sans refonte majeure, l'ajout d'un tableau de bord web d'administration dans une version ultérieure.   | Haute     |

---

### 2.14 Audit

| ID      | Catégorie | Règle Métier                                                                                                                                                    | Priorité  |
|---------|-----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| BR-080  | Audit     | Le système enregistre automatiquement un journal de toutes les actions effectuées par les administrateurs, comprenant l'identifiant de l'auteur, la nature de l'action et l'horodatage précis. | Critique |
| BR-081  | Audit     | Le journal d'audit est accessible uniquement aux administrateurs disposant des droits appropriés.                                                               | Critique  |
| BR-082  | Audit     | Chaque enregistrement de repas est consigné dans le système avec l'identifiant de l'utilisateur, la catégorie de repas choisie, le mode d'identification utilisé et l'horodatage. | Critique |
| BR-083  | Audit     | Les entrées du journal d'audit sont immuables. Aucun utilisateur, y compris les administrateurs, ne peut modifier ou supprimer une entrée existante.            | Critique  |
| BR-084  | Audit     | Le système conserve le journal d'audit pour une durée minimale permettant de répondre aux exigences de traçabilité de l'entreprise.                            | Haute     |

---

## 3. Glossaire

Le présent glossaire définit les termes métier utilisés dans ce document. Ces définitions font autorité dans l'ensemble de la documentation fonctionnelle et technique du projet CSM-GIAS Resto+.

---

**Administrateur**
Personne habilitée à gérer le système CSM-GIAS Resto+ dans sa totalité. L'administrateur dispose de droits étendus incluant la gestion des comptes utilisateurs, l'enrôlement biométrique, la configuration des paramètres système et la consultation des rapports. Plusieurs administrateurs peuvent coexister. L'accès aux fonctionnalités d'administration est protégé par authentification.

---

**Accueil**
Service de l'entreprise chargé de l'accueil des visiteurs et de la gestion administrative des stagiaires. L'accueil dispose de droits restreints permettant la création de comptes visiteurs et stagiaires, ainsi que la génération des QR Codes correspondants.

---

**Audit**
Mécanisme de traçabilité permettant d'enregistrer automatiquement et de manière immuable l'ensemble des actions effectuées par les utilisateurs administrateurs du système. Le journal d'audit constitue la preuve formelle des opérations réalisées et ne peut être modifié.

---

**Catégorie de Repas**
Classification fixe et immuable des types de repas proposés au restaurant de l'entreprise. En version 1.0, trois catégories existent : Plat, Pizza et Sandwich. Ces catégories ne sont pas configurables par les administrateurs.

---

**Employé**
Personne faisant partie du personnel permanent de l'entreprise CSM-GIAS. L'employé s'identifie exclusivement par reconnaissance faciale. Il bénéficie d'un enrôlement biométrique réalisé une seule fois par l'administration.

---

**Enrôlement Biométrique**
Opération consistant à capturer et à enregistrer les données faciales d'un employé dans le système, afin de permettre son identification ultérieure par reconnaissance faciale. L'enrôlement est réalisé par un administrateur à l'aide de la caméra de la tablette dédiée.

---

**Enregistrement de Repas**
Action par laquelle un utilisateur identifié par le système sélectionne une catégorie de repas et valide sa consommation. L'enregistrement est horodaté et consigné de manière définitive dans la base de données.

---

**Horodatage**
Marquage temporel automatique appliqué par le système à chaque événement significatif : enregistrement de repas, génération de QR Code, action administrative. L'horodatage est une donnée non modifiable.

---

**Plage d'Ouverture**
Période journalière pendant laquelle le restaurant de l'entreprise est ouvert et pendant laquelle l'enregistrement des repas est autorisé. En version 1.0, cette plage est fixée de 12h30 à 14h00.

---

**QR Code**
Code graphique bidimensionnel servant de support d'identification pour les stagiaires et les visiteurs. Chaque QR Code est unique, nominatif ou temporaire selon le profil de l'utilisateur, et soumis à une date d'expiration.

---

**QR Code Nominatif**
QR Code attribué à un stagiaire lors de son intégration dans l'entreprise. Il est lié à l'identité du stagiaire et expire automatiquement à la date de fin de stage définie dans le système.

---

**QR Code Temporaire**
QR Code généré par l'accueil pour un visiteur au moment de sa venue. Sa validité est strictement limitée à la journée calendaire de son émission.

---

**Rapport**
Document synthétique généré automatiquement par le système à intervalles réguliers (journalier, hebdomadaire, mensuel). Un rapport contient des données statistiques, des tableaux et des représentations graphiques relatifs à l'activité du restaurant. Il est transmis automatiquement par email aux destinataires configurés.

---

**Reconnaissance Faciale**
Technologie biométrique permettant d'identifier un individu en comparant les caractéristiques de son visage capturées en temps réel avec les données enregistrées lors de son enrôlement. Dans CSM-GIAS Resto+, la reconnaissance faciale est le mode d'identification exclusif des employés.

---

**Révocation**
Action administrative consistant à invalider manuellement un QR Code avant sa date d'expiration naturelle. Un QR Code révoqué est immédiatement rejeté par le système lors de sa présentation.

---

**Stagiaire**
Personne effectuant un stage au sein de l'entreprise CSM-GIAS pour une durée déterminée. Le stagiaire s'identifie exclusivement par QR Code nominatif. Son accès au restaurant est conditionné par la validité de ce QR Code.

---

**Statistiques**
Indicateurs quantitatifs calculés par le système à partir des données d'enregistrement des repas. Les statistiques permettent de suivre la fréquentation du restaurant, la répartition des consommations et l'utilisation des modes d'identification.

---

**Visiteur**
Personne extérieure à l'entreprise, présente pour une visite ponctuelle. Le visiteur s'identifie par un QR Code temporaire émis par l'accueil le jour de sa visite. Il est autorisé à enregistrer un seul repas par journée de visite.

---

## 4. Conclusion

Le présent document recense et formalise soixante-quatre règles métier couvrant l'intégralité du périmètre fonctionnel de l'application **CSM-GIAS Resto+** dans sa version 1.0. Ces règles ont été élaborées à partir du Document de Vision Projet et des exigences fonctionnelles validées par les parties prenantes.

La définition rigoureuse et exhaustive de ces règles avant toute phase de développement répond à plusieurs impératifs fondamentaux de l'ingénierie logicielle d'entreprise :

**Réduction du risque** : l'ambiguïté fonctionnelle est la première source de défauts dans un projet logiciel. En énonçant chaque règle de manière atomique et non équivoque, ce document réduit considérablement le risque d'interprétation erronée par les équipes de développement.

**Efficacité du développement** : les développeurs disposent d'un référentiel clair et structuré leur permettant de prendre des décisions techniques fondées sur des exigences précises, sans recourir systématiquement aux parties prenantes métier.

**Qualité et testabilité** : chaque règle métier constitue un critère d'acceptance directement transformable en cas de test. L'équipe de qualification peut s'appuyer sur ce document pour élaborer un plan de test complet et vérifier la conformité du système développé.

**Traçabilité et maintenabilité** : l'attribution d'un identifiant unique à chaque règle permet d'établir une matrice de traçabilité entre les exigences métier, les spécifications techniques, les développements et les tests. Cette traçabilité est indispensable pour la maintenance et l'évolution du système.

**Cadrage contractuel** : en définissant explicitement ce qui est dans le périmètre du projet et ce qui en est exclu, ce document protège l'ensemble des parties prenantes contre toute dérive non maîtrisée du périmètre fonctionnel.

Ces règles métier constituent désormais le contrat fonctionnel entre les commanditaires du projet et l'équipe de développement. Elles devront être maintenues à jour tout au long du cycle de vie du projet et serviront de référence lors de toute évolution fonctionnelle, y compris dans les versions ultérieures de la solution.

---

> **Note documentaire** : Ce document est destiné à évoluer en cohérence avec les documents complémentaires du projet (Cahier des Charges, Spécifications Fonctionnelles Détaillées, Plan de Tests). En cas de modification d'une règle métier, l'historique des révisions doit être mis à jour et la modification doit être communiquée à l'ensemble des équipes concernées.

---

*Document rédigé dans le cadre d'un stage en ingénierie logicielle — CSM-GIAS, Été 2026.*
