# 1. Page de Garde

**Projet** : CSM-GIAS Resto+
**Sous-titre** : Solution Intelligente de Gestion du Restaurant d'Entreprise
**Titre du document** : Schema de Base de Donnees
**Version** : 1.0
**Date** : Juillet 2026
**Auteur** : Architecte Base de Donnees Senior
**Confidentialite** : Interne - Strictement Confidentiel

## Historique des Revisions

| Version | Date | Auteur | Description |
|---------|------|--------|-------------|
| 1.0 | 04/07/2026 | Architecte BDD Senior | Creation du schema logique de la base de donnees |

---

# 2. Introduction

## 2.1 Objet du Document

Le present document constitue la conception logique complete de la base de donnees du projet CSM-GIAS Resto+. Il definit l'ensemble des entites, attributs, relations et contraintes necessaires au stockage persistant des donnees de la solution.

Ce document est le referentiel unique pour l'implementation technique de la couche de persistence. Il est destine a etre transmis directement a l'equipe de developpement backend pour implementation via SQLAlchemy et Alembic.

## 2.2 Perimetre

Le perimetre du schema de donnees couvre l'integralite des fonctionnalites de la Release 1.0 definies dans le Product Backlog, incluant l'identification, la gestion des repas, les QR Codes, l'administration, les rapports, les statistiques, les notifications, l'audit, la configuration et la gestion des utilisateurs.

Les fonctionnalites de la Release 2.0 (Web Dashboard) ne sont pas couvertes par ce schema, mais des dispositions d'extensibilite sont prevues (Section 15).

## 2.3 Public Cible

Ce document s'adresse aux :
- Architectes logiciels charges de valider la coherence technique
- Developpeurs backend responsables de l'implementation SQLAlchemy et Alembic
- Administrateurs de base de donnees charges du deploiement et de la maintenance
- Equipes de test chargees de la validation des donnees

## 2.4 Relation avec l'Architecture Technique

La base de donnees MySQL constitue le systeme de persistence central dans l'architecture technique de CSM-GIAS Resto+. Elle est accessible exclusivement par l'API REST developpee avec FastAPI, qui assure la couche d'abstraction entre le client mobile (tablette React Native) et le stockage de donnees.

Le schema logique presente ici est independant de l'implementation technique et peut etre realise avec tout moteur de base de donnees relationnelle conforme au standard SQL.

---

# 3. Principes de Conception

## 3.1 Normalisation

La conception suit les principes de la troisieme forme normale (3NF) :

- **1NF** : Chaque colonne contient une valeur atomique, chaque ligne est identifiee de maniere unique
- **2NF** : Chaque colonne non-cle depend de la totalite de la cle primaire
- **3NF** : Aucune dependance transitive entre colonnes non-cles

La normalisation est appliquee de maniere pragmatique. Certaines denormalisations controlees sont autorisees pour des raisons de performance (ex : denormalisation du type d'utilisateur dans la table repas pour eviter des jointures lors de la generation des rapports).

## 3.2 Integrite des Donnees

Les regles suivantes garantissent l'integrite des donnees :

- **Integrite d'entite** : Chaque table possede une cle primaire unique et non nulle
- **Integrite referentielle** : Les relations entre tables sont garanties par des contraintes de cle etrangere
- **Integrite de domaine** : Les valeurs des colonnes sont contraintes par type de donnee, nullable et valeurs autorisees
- **Integrite utilisateur** : Les regles metier sont enforcees au niveau application et, lorsque necessaire, par des contraintes base de donnees

## 3.3 Atomicite

Chaque operation de base de donnees est atomique. Les operations composees (enregistrement de repas, generation de QR Code) sont encapsulees dans des transactions garantissant la coherence en cas d'echec.

## 3.4 Coherence

Le schema garantit la coherence des donnees par :

- L'utilisation de transactions ACID pour les operations critiques
- La validation des contraintes metier avant persistence
- L'horodatage systeme pour toutes les operations d'ecriture
- L'immutabilite du journal d'audit (aucun UPDATE ou DELETE autorise)

## 3.5 Evolutivite

La conception anticipe les evolutions futures :

- Les tables de reference (categories_repas, modes_identification) autorisent l'ajout de nouvelles valeurs
- Le partitionnement par date est prevu pour les tables a fort volume (repas, journal_audit)
- Les colonnes de type enum de base de donnees sont preferees aux chaines de caracteres libres

## 3.6 Maintenabilite

La maintenabilite est assuree par :

- Des conventions de nommage strictes et documentees
- Une tracabilite complete entre regles metier et contraintes de base de donnees
- L'utilisation de migrations versionnees (Alembic) pour toutes les modifications de schema

## 3.7 Principles de Nommage

Les conventions de nommage sont definies a la Section 4. Elles sont appliquees uniformement a toutes les tables, colonnes, index et contraintes du schema.

## 3.8 Audibilite

Toutes les actions de modification des donnees critiques (utilisateurs, QR Codes, configuration) sont journalisees dans le journal d'audit. Le schema garantit l'immutabilite des entrees d'audit.

---

# 4. Conventions de Nommage

## 4.1 Regles Generales

| Element | Convention | Exemple |
|---------|------------|---------|
| Tables | Singulier, snake_case | utilisateur, repas, qr_code |
| Colonnes | snake_case, descriptive | nom, prenom, date_creation |
| Cles primaires | id (auto-increment) | id |
| Cles etrangeres | table_referencee_champ | utilisateur_id, categorie_repas_id |
| Index | idx_table_colonne | idx_repas_utilisateur_id, idx_repas_date |
| Contraintes uniques | uq_table_colonnes | uq_repas_utilisateur_date, uq_qr_code_code |
| Contraintes de verification | ck_table_regle | ck_repas_date_heure, ck_utilisateur_type |
| Contraintes de cle etrangere | fk_table_source_cible | fk_repas_utilisateur, fk_qr_code_utilisateur |

## 4.2 Types de Donnees

| Type Logique | Type MySQL | Utilisation |
|-------------|------------|-------------|
| Identifiant | BIGINT UNSIGNED | Cles primaires et etrangeres |
| Texte court | VARCHAR(255) | Noms, prenoms, emails |
| Texte moyen | VARCHAR(500) | Descriptions, libelles |
| Texte long | TEXT | Messages, details, logs |
| Code unique | CHAR(36) | UUID, codes QR |
| Date | DATE | Dates sans heure (visite, stage) |
| Date et heure | DATETIME(3) | Horodatages avec millisecondes |
| Booleen | TINYINT(1) | Indicateurs binaires |
| Enumere | ENUM | Valeurs limitees fixes |
| Chiffre | BLOB | Donnees biometriques chiffrees |
| Montant | DECIMAL(10,2) | Valeurs monetaires (reserve evolution) |
| JSON | JSON | Donnees semi-structurees (details) |

## 4.3 Suffixes des Colonnes Temporelles

| Convention | Signification |
|-----------|---------------|
| _date | Date calendaire sans heure (type DATE) |
| _horodatage | Date et heure precise (type DATETIME) |
| _creation | Horodatage de creation de l'enregistrement |
| _modification | Horodatage de derniere modification |
| _suppression | Horodatage de suppression logique |

---

# 5. Catalogue des Entites

## 5.1 Liste des Entites

| # | Entite | Type | Volume Estime | Module Fonctionnel |
|---|--------|------|---------------|--------------------|
| 1 | utilisateur | Principale | 500-2000 enregistrements | Gestion des utilisateurs |
| 2 | administrateur | Extension | 2-10 enregistrements | Administration |
| 3 | reception | Extension | 1-5 enregistrements | Administration |
| 4 | employe | Extension | 300-1500 enregistrements | Gestion des employes |
| 5 | stagiaire | Extension | 10-100 enregistrements | Gestion des stagiaires |
| 6 | visiteur | Extension | 5-50 par jour | Gestion des visiteurs |
| 7 | categorie_repas | Reference | 3 enregistrements (fixe) | Gestion des repas |
| 8 | mode_identification | Reference | 2 enregistrements | Identification |
| 9 | repas | Transactionnelle | 100-500 par jour | Gestion des repas |
| 10 | qr_code | Transactionnelle | 5-50 par jour | QR Codes |
| 11 | empreinte_biometrique | Sensible | 300-1500 enregistrements | Identification |
| 12 | session | Temporaire | 1-10 actives | Authentification |
| 13 | journal_audit | Historique | 100-500 par jour | Audit |
| 14 | configuration | Parametrage | 10-30 enregistrements | Configuration |
| 15 | destinataire_email | Parametrage | 2-20 enregistrements | Rapports |
| 16 | rapport | Historique | 40-400 par an | Rapports |
| 17 | notification | Reference | 10-20 enregistrements | Notifications |

## 5.2 Description des Entites

### 5.2.1 utilisateur

**Objectif** : Table centrale du schema. Contient les informations communes a tous les profils d'utilisateurs du systeme (employes, stagiaires, visiteurs, administrateurs, reception).

**Description** : Chaque personne interagissant avec le systeme possede un enregistrement unique dans cette table. Le type d'utilisateur est determine par la colonne `type` et les attributs specifiques sont stockes dans la table d'extension correspondante.

**Responsabilite Metier** : Gerer l'identite de base de chaque personne ayant acces au systeme, independamment de son role.

**Cycle de Vie** : Cree lors de l'inscription (administrateur/reception) ou de la creation de compte (employe, stagiaire, visiteur). Desactive par l'administration. Supprime conformement au RGPD.

**Volume Attendu** : 500 a 2000 enregistrements actifs, avec cumul historique des comptes supprimes.

### 5.2.2 administrateur

**Objectif** : Extension de la table utilisateur pour les profils disposant des droits d'administration complets.

**Description** : Un administrateur peut gerer les utilisateurs, les QR Codes, la configuration, les rapports et l'enrolement biometrique.

**Responsabilite Metier** : Assurer la gestion et la supervision du systeme.

**Cycle de Vie** : Cree par un autre administrateur. Desactive (jamais supprime). Protege contre la suppression du dernier administrateur actif.

**Volume Attendu** : 2 a 10 enregistrements.

### 5.2.3 reception

**Objectif** : Extension de la table utilisateur pour les profils du service d'accueil.

**Description** : La reception dispose de droits limites a la creation des comptes stagiaires et visiteurs, ainsi qu'a la generation de leurs QR Codes.

**Responsabilite Metier** : Gerer l'accueil et l'enregistrement des visiteurs et stagiaires.

**Cycle de Vie** : Cree par un administrateur. Desactive par un administrateur.

**Volume Attendu** : 1 a 5 enregistrements.

### 5.2.4 employe

**Objectif** : Extension de la table utilisateur pour les employes permanents de l'entreprise.

**Description** : Un employe s'identifie par reconnaissance faciale et peut enregistrer un repas par jour. Son enrolement biometrique est gere par l'administration.

**Responsabilite Metier** : Permettre aux employes d'acceder au service de restauration.

**Cycle de Vie** : Cree par un administrateur. Enrole biometriquement par un administrateur. Desactive/reactivable. Supprime conformement au RGPD.

**Volume Attendu** : 300 a 1500 enregistrements.

### 5.2.5 stagiaire

**Objectif** : Extension de la table utilisateur pour les stagiaires en contrat temporaire.

**Description** : Un stagiaire s'identifie par QR Code nominatif expire a la fin de son stage. Ses dates de debut et fin de stage sont obligatoires.

**Responsabilite Metier** : Gerer les acces temporaires des stagiaires au restaurant.

**Cycle de Vie** : Cree par la reception ou un administrateur. Supprime automatiquement apres la duree legale de conservation (RGPD).

**Volume Attendu** : 10 a 100 stagiaires simultanes, en fonction de la taille de l'entreprise.

### 5.2.6 visiteur

**Objectif** : Extension de la table utilisateur pour les visiteurs ponctuels de l'entreprise.

**Description** : Un visiteur recoit un QR Code temporaire valable uniquement le jour de sa visite. Il ne peut pas avoir plusieurs QR Codes actifs le meme jour.

**Responsabilite Metier** : Gerer les acces ponctuels des visiteurs au restaurant.

**Cycle de Vie** : Cree par la reception pour une visite unique. Les donnees sont anonymisees ou supprimees conformement au RGPD apres la periode de conservation.

**Volume Attendu** : 5 a 50 enregistrements par jour.

### 5.2.7 categorie_repas

**Objectif** : Table de reference listant les categories de repas disponibles.

**Description** : Trois categories immuables en version 1.0 : Plat, Pizza, Sandwich. Cette table permet l'evolution future sans modification du schema.

**Responsabilite Metier** : Definir les choix de repas proposes aux utilisateurs.

**Cycle de Vie** : Initialise lors du deploiement. Modifiable uniquement par intervention developpement.

**Volume Attendu** : 3 enregistrements (fixe en V1).

### 5.2.8 mode_identification

**Objectif** : Table de reference listant les modes d'identification supportes par le systeme.

**Description** : Deux modes en version 1.0 : RECONNAISSANCE_FACIALE et QR_CODE. Cette table permet l'ajout de nouveaux modes sans modification du schema.

**Responsabilite Metier** : Categoriser le mode d'identification utilise pour chaque transaction.

**Cycle de Vie** : Initialise lors du deploiement.

**Volume Attendu** : 2 enregistrements (extensible).

### 5.2.9 repas

**Objectif** : Table transactionnelle enregistrant chaque repas valide par un utilisateur.

**Description** : Chaque ligne represente un repas enregistre de maniere irreversible. Contient l'identifiant de l'utilisateur, la categorie choisie, le mode d'identification, la date et l'horodatage.

**Responsabilite Metier** : Assurer la tracabilite de toutes les consommations.

**Cycle de Vie** : Cree lors de la validation du repas. Les donnees sont conservees pour les statistiques et rapports. Anonymisees apres la periode de conservation RGPD.

**Volume Attendu** : 100 a 500 enregistrements par jour, soit 20 000 a 100 000 par an.

### 5.2.10 qr_code

**Objectif** : Table transactionnelle stockant les QR Codes generes pour les stagiaires et visiteurs.

**Description** : Chaque QR Code est unique, lie a un utilisateur, avec une date d'expiration calculee selon le profil (fin de stage pour stagiaire, minuit pour visiteur). Le statut peut etre actif, expire ou revoque.

**Responsabilite Metier** : Gerer le cycle de vie des QR Codes.

**Cycle de Vie** : Cree lors de la generation. Expire automatiquement. Revocable manuellement. Les enregistrements sont conserves pour audit.

**Volume Attendu** : 5 a 50 enregistrements par jour.

### 5.2.11 empreinte_biometrique

**Objectif** : Table sensible stockant les donnees biometriques des employes.

**Description** : Contient le vecteur facial chiffre de chaque employe enrole. Liee a un seul employe. Mise a jour possible par re-enrolement.

**Responsabilite Metier** : Stocker de maniere securisee les donnees necessaires a l'identification par reconnaissance faciale.

**Cycle de Vie** : Cree lors de l'enrolement. Mise a jour lors du re-enrolement. Supprimee lors de la suppression de l'employe.

**Volume Attendu** : 300 a 1500 enregistrements.

### 5.2.12 session

**Objectif** : Table temporaire gerant les sessions d'authentification JWT.

**Description** : Enregistre les jetons JWT actifs delivres aux administrateurs et a la reception. Permet l'invalidation des sessions et la verification de validite.

**Responsabilite Metier** : Gerer le cycle de vie des sessions d'authentification.

**Cycle de Vie** : Creee a l'authentification. Expiree automatiquement. Supprimee lors de la deconnexion ou de l'invalidation.

**Volume Attendu** : 1 a 10 sessions actives simultanement.

### 5.2.13 journal_audit

**Objectif** : Table historique immuable enregistrant toutes les actions significatives du systeme.

**Description** : Chaque ligne contient le type d'action, l'auteur, la cible, les valeurs avant/apres, l'adresse IP et l'horodatage. Aucune modification ou suppression n'est autorisee.

**Responsabilite Metier** : Garantir la tracabilite et l'audibilite de toutes les operations.

**Cycle de Vie** : Cree lors de chaque action administrateur ou enregistrement de repas. Conserve pour la duree legale de conservation. Purgé automatiquement apres cette duree.

**Volume Attendu** : 100 a 500 enregistrements par jour. Croissance rapide.

### 5.2.14 configuration

**Objectif** : Table de parametrage stockant les configurations systeme.

**Description** : Structure cle-valeur avec type de donnee. Permet de configurer les horaires d'ouverture, le fuseau horaire, les durees de conservation, etc.

**Responsabilite Metier** : Centraliser les parametres configurables du systeme.

**Cycle de Vie** : Initialisee lors du deploiement avec les valeurs par defaut. Modifiable par les administrateurs.

**Volume Attendu** : 10 a 30 enregistrements.

### 5.2.15 destinataire_email

**Objectif** : Table de parametrage listant les destinataires des rapports automatiques.

**Description** : Contient les adresses email configurees par l'administrateur pour recevoir les rapports generes par le systeme.

**Responsabilite Metier** : Gerer la liste de diffusion des rapports.

**Cycle de Vie** : Ajoutee par un administrateur. Supprimee par un administrateur.

**Volume Attendu** : 2 a 20 enregistrements.

### 5.2.16 rapport

**Objectif** : Table historique enregistrant les rapports generes par le systeme.

**Description** : Stocke les metadonnees de chaque rapport genere (type, periode, date de generation, statut). Le fichier PDF lui-meme est stocke dans le systeme de fichiers.

**Responsabilite Metier** : Assurer la tracabilite et la regeneration des rapports.

**Cycle de Vie** : Cree lors de la generation du rapport. Conserve conformement a la politique de conservation.

**Volume Attendu** : 365 rapports journaliers, 52 hebdomadaires et 12 mensuels par an, soit environ 430 enregistrements par an.

### 5.2.17 notification

**Objectif** : Table de reference stockant les messages de notification multilingues.

**Description** : Contient les versions francaise, arabe et anglaise de chaque message affiche sur la tablette (confirmation, erreur, information).

**Responsabilite Metier** : Centraliser les messages utilisateur pour maintenance et traduction.

**Cycle de Vie** : Initialisee lors du deploiement. Modifiable sans intervention developpement.

**Volume Attendu** : 10 a 20 enregistrements.

---

# 6. Details des Entites

## 6.1 Entite : utilisateur

| Attribut | Type | Nullable | Unique | Description | Regles de Validation |
|----------|------|----------|--------|-------------|---------------------|
| id | BIGINT | NON | OUI | Identifiant unique attribue automatiquement | Auto-increment, cle primaire |
| nom | VARCHAR(100) | NON | NON | Nom de famille de l'utilisateur | Non vide, longueur 1-100 caracteres |
| prenom | VARCHAR(100) | NON | NON | Prenom de l'utilisateur | Non vide, longueur 1-100 caracteres |
| email | VARCHAR(255) | OUI | OUI | Adresse email professionnelle | Format email valide, unique si renseigne |
| mot_de_passe | VARCHAR(255) | OUI | NON | Mot de passe chiffre (admin/reception uniquement) | Null pour employe/stagiaire/visiteur, minimum 8 caracteres |
| type | ENUM | NON | NON | Role de l'utilisateur dans le systeme | Valeurs autorisees : EMPLOYE, STAGIAIRE, VISITEUR, ADMINISTRATEUR, RECEPTION |
| statut | ENUM | NON | NON | Statut du compte utilisateur | Valeurs autorisees : ACTIF, INACTIF, SUPPRIME |
| langue | ENUM | OUI | NON | Langue preferee pour les notifications | Valeurs autorisees : FR, AR, EN |
| date_creation | DATETIME(3) | NON | NON | Horodatage de creation du compte | Valeur par defaut : NOW() |
| date_modification | DATETIME(3) | OUI | NON | Horodatage de la derniere modification | Mise a jour automatique |
| date_suppression | DATETIME(3) | OUI | NON | Horodatage de suppression logique | Renseigne uniquement si statut = SUPPRIME |

**Justification des attributs** :
- `mot_de_passe` : Nullable car seuls les administrateurs et la reception ont un mot de passe. Les employes, stagiaires et visiteurs s'identifient via d'autres moyens (BR-004).
- `type` : Necessaire pour discriminer le role et appliquer les regles metier specifiques.
- `statut` : Necessaire pour la desactivation des comptes (BR-010, BR-046) sans perte de l'historique.

## 6.2 Entite : administrateur

| Attribut | Type | Nullable | Unique | Description | Regles de Validation |
|----------|------|----------|--------|-------------|---------------------|
| id | BIGINT | NON | OUI | Meme identifiant que la table utilisateur | Cle primaire, cle etrangere vers utilisateur.id |
| derniere_connexion | DATETIME(3) | OUI | NON | Horodatage de la derniere authentification | Mise a jour a chaque connexion |
| tentatives_echouees | TINYINT | NON | NON | Nombre de tentatives de connexion echouees consecutives | Valeur par defaut : 0, maximum : 5 |

**Justification** : Table d'extension de utilisateur pour les droits d'administration (BR-048, BR-049). Les attributs specifiques aux administrateurs sont separees pour ne pas encombrer la table principale.

## 6.3 Entite : reception

| Attribut | Type | Nullable | Unique | Description | Regles de Validation |
|----------|------|----------|--------|-------------|---------------------|
| id | BIGINT | NON | OUI | Meme identifiant que la table utilisateur | Cle primaire, cle etrangere vers utilisateur.id |

**Justification** : Table d'extension minimaliste. La reception herite des droits de creation de comptes stagiaires et visiteurs via son type (BR-045).

## 6.4 Entite : employe

| Attribut | Type | Nullable | Unique | Description | Regles de Validation |
|----------|------|----------|--------|-------------|---------------------|
| id | BIGINT | NON | OUI | Meme identifiant que la table utilisateur | Cle primaire, cle etrangere vers utilisateur.id |
| date_enrolement | DATETIME(3) | OUI | NON | Horodatage de l'enrolement biometrique | Null si non enrole, renseigne apres enrolement |
| statut_enrolement | ENUM | NON | NON | Statut de l'enrolement biometrique | Valeurs autorisees : NON_ENROLE, ENROLE, ENROLEMENT_ECHOUE |

**Justification** : (BR-007, BR-031). Le statut d'enrolement permet de suivre l'etat biometrique de l'employe sans supprimer la fiche.

## 6.5 Entite : stagiaire

| Attribut | Type | Nullable | Unique | Description | Regles de Validation |
|----------|------|----------|--------|-------------|---------------------|
| id | BIGINT | NON | OUI | Meme identifiant que la table utilisateur | Cle primaire, cle etrangere vers utilisateur.id |
| date_debut_stage | DATE | NON | NON | Date de debut du stage | Doit etre anterieure ou egale a date_fin_stage |
| date_fin_stage | DATE | NON | NON | Date de fin du stage | Doit etre posterieure ou egale a date_debut_stage |

**Justification** : (BR-013, BR-016, BR-018). Les dates de stage sont obligatoires pour definir l'expiration du QR Code nominatif.

## 6.6 Entite : visiteur

| Attribut | Type | Nullable | Unique | Description | Regles de Validation |
|----------|------|----------|--------|-------------|---------------------|
| id | BIGINT | NON | OUI | Meme identifiant que la table utilisateur | Cle primaire, cle etrangere vers utilisateur.id |
| date_visite | DATE | NON | NON | Date de la visite | Par defaut : date du jour |

**Justification** : (BR-019, BR-024). La date de visite determine la validite du QR Code temporaire. Un visiteur peut revenir un autre jour, ce qui creera un nouvel enregistrement.

## 6.7 Entite : categorie_repas

| Attribut | Type | Nullable | Unique | Description | Regles de Validation |
|----------|------|----------|--------|-------------|---------------------|
| id | BIGINT | NON | OUI | Identifiant unique | Cle primaire |
| nom | VARCHAR(50) | NON | OUI | Nom de la categorie (Plat, Pizza, Sandwich) | Longueur 2-50 caracteres |
| code_interne | VARCHAR(20) | NON | OUI | Code machine de la categorie | Valeurs autorisees : PLAT, PIZZA, SANDWICH |
| actif | TINYINT(1) | NON | NON | Indique si la categorie est disponible | Par defaut : 1 |

**Justification** : (BR-037, BR-044). Table de reference pour les trois categories immuables. La colonne `actif` permet de desactiver temporairement une categorie sans la supprimer.

## 6.8 Entite : mode_identification

| Attribut | Type | Nullable | Unique | Description | Regles de Validation |
|----------|------|----------|--------|-------------|---------------------|
| id | BIGINT | NON | OUI | Identifiant unique | Cle primaire |
| code | VARCHAR(30) | NON | OUI | Code machine du mode | Valeurs autorisees : RECONNAISSANCE_FACIALE, QR_CODE |
| libelle | VARCHAR(100) | NON | NON | Libelle affichable du mode | Longueur 2-100 caracteres |

**Justification** : (BR-001, BR-002, BR-003). Table de reference pour les modes d'identification. Extensible pour de futurs modes (badge, NFC, etc.).

## 6.9 Entite : repas

| Attribut | Type | Nullable | Unique | Description | Regles de Validation |
|----------|------|----------|--------|-------------|---------------------|
| id | BIGINT | NON | OUI | Identifiant unique | Cle primaire |
| utilisateur_id | BIGINT | NON | NON | Identifiant de l'utilisateur ayant valide le repas | Cle etrangere vers utilisateur.id |
| categorie_repas_id | BIGINT | NON | NON | Categorie de repas selectionnee | Cle etrangere vers categorie_repas.id |
| mode_identification_id | BIGINT | NON | NON | Mode d'identification utilise | Cle etrangere vers mode_identification.id |
| date_repas | DATE | NON | NON | Date calendaire du repas | Par defaut : CURDATE() |
| horodatage | DATETIME(3) | NON | NON | Horodatage precis de la validation | Par defaut : NOW() |
| uuid_transaction | CHAR(36) | NON | OUI | Identifiant unique de transaction | UUID v4 genere automatiquement |

**Justification** : (BR-008, BR-014, BR-021, BR-038, BR-039, BR-040, BR-041, BR-042, BR-082). Table centrale du systeme. L'unicite de la contrainte (utilisateur_id, date_repas) garantit un seul repas par utilisateur par jour. L'horodatage permet le controle de la plage horaire et les statistiques de frequentation.

## 6.10 Entite : qr_code

| Attribut | Type | Nullable | Unique | Description | Regles de Validation |
|----------|------|----------|--------|-------------|---------------------|
| id | BIGINT | NON | OUI | Identifiant unique | Cle primaire |
| utilisateur_id | BIGINT | NON | NON | Identifiant de l'utilisateur lie au QR Code | Cle etrangere vers utilisateur.id |
| code | VARCHAR(64) | NON | OUI | Code unique du QR Code (hash) | Genere automatiquement, unique garanti |
| type | ENUM | NON | NON | Type de QR Code | Valeurs autorisees : NOMINATIF (stagiaire), TEMPORAIRE (visiteur) |
| statut | ENUM | NON | NON | Statut du QR Code | Valeurs autorisees : ACTIF, EXPIRE, REVOQUE |
| date_creation | DATETIME(3) | NON | NON | Horodatage de generation | Par defaut : NOW() |
| date_expiration | DATETIME(3) | NON | NON | Date et heure d'expiration | Calculee selon le profil (stagiaire : date_fin_stage 23h59, visiteur : jour meme 23h59) |
| date_revocation | DATETIME(3) | OUI | NON | Horodatage de revocation manuelle | Null si non revoque |

**Justification** : (BR-016, BR-020, BR-025, BR-026, BR-027, BR-028, BR-029). La table gere le cycle de vie complet des QR Codes. L'unicite de `code` est critique pour la securite (BR-025).

## 6.11 Entite : empreinte_biometrique

| Attribut | Type | Nullable | Unique | Description | Regles de Validation |
|----------|------|----------|--------|-------------|---------------------|
| id | BIGINT | NON | OUI | Identifiant unique | Cle primaire |
| employe_id | BIGINT | NON | OUI | Identifiant de l'employe | Cle etrangere vers employe.id, unique garanti |
| vecteur_chiffre | BLOB | NON | NON | Vecteur facial chiffre de l'employe | Stocke sous forme chiffree uniquement (BR-035, BR-071) |
| algorithme_chiffrement | VARCHAR(50) | NON | NON | Algorithme utilise pour le chiffrement | Reference l'algorithme (ex: AES-256-GCM) |
| date_creation | DATETIME(3) | NON | NON | Horodatage de l'enrolement | Par defaut : NOW() |
| date_modification | DATETIME(3) | OUI | NON | Horodatage du dernier re-enrolement | Mise a jour lors d'un re-enrolement |

**Justification** : (BR-007, BR-031, BR-032, BR-035, BR-036, BR-071). Table sensible contenant les donnees biometriques. La contrainte UNIQUE sur `employe_id` garantit qu'un employe ne peut avoir qu'une seule empreinte active.

## 6.12 Entite : session

| Attribut | Type | Nullable | Unique | Description | Regles de Validation |
|----------|------|----------|--------|-------------|---------------------|
| id | BIGINT | NON | OUI | Identifiant unique | Cle primaire |
| utilisateur_id | BIGINT | NON | NON | Identifiant de l'utilisateur authentifie | Cle etrangere vers utilisateur.id |
| token_jwt | VARCHAR(500) | NON | OUI | Jeton d'authentification | Stocke de maniere securisee |
| date_creation | DATETIME(3) | NON | NON | Horodatage de creation de la session | Par defaut : NOW() |
| date_expiration | DATETIME(3) | NON | NON | Horodatage d'expiration du jeton | Duree de validite definie en configuration |
| date_deconnexion | DATETIME(3) | OUI | NON | Horodatage de deconnexion | Null si session toujours active |

**Justification** : (BR-069, BR-070). Gere le cycle de vie des jetons JWT pour les sessions d'administration et de reception.

## 6.13 Entite : journal_audit

| Attribut | Type | Nullable | Unique | Description | Regles de Validation |
|----------|------|----------|--------|-------------|---------------------|
| id | BIGINT | NON | OUI | Identifiant unique | Cle primaire |
| utilisateur_id | BIGINT | OUI | NON | Identifiant de l'auteur de l'action | Cle etrangere vers utilisateur.id. Null pour actions systeme automatiques |
| type_action | VARCHAR(50) | NON | NON | Type d'action effectuee | Valeurs controlees par l'application |
| entite_concernee | VARCHAR(50) | NON | NON | Nom de l'entite cible (table) | Table concernee par l'action |
| id_entite | BIGINT | OUI | NON | Identifiant de l'enregistrement cible | Null si non applicable |
| details_avant | JSON | OUI | NON | Valeurs des attributs avant modification | Structure JSON. Null pour les creations |
| details_apres | JSON | OUI | NON | Valeurs des attributs apres modification | Structure JSON. Null pour les suppressions |
| adresse_ip | VARCHAR(45) | OUI | NON | Adresse IP de l'auteur | Format IPv4 ou IPv6 |
| horodatage | DATETIME(3) | NON | NON | Horodatage de l'action | Par defaut : NOW(). Jamais modifiable |

**Justification** : (BR-080, BR-081, BR-082, BR-083). Table immuable. Aucun UPDATE ou DELETE autorise. Les operations de purge sont effectuees par un processus planifie et journalise.

## 6.14 Entite : configuration

| Attribut | Type | Nullable | Unique | Description | Regles de Validation |
|----------|------|----------|--------|-------------|---------------------|
| id | BIGINT | NON | OUI | Identifiant unique | Cle primaire |
| cle | VARCHAR(100) | NON | OUI | Cle de configuration unique | Snake_case, descriptive |
| valeur | TEXT | NON | NON | Valeur de configuration | Stockee en texte, convertie selon le type |
| type_donnee | VARCHAR(20) | NON | NON | Type de donnee attendu pour la valeur | Valeurs autorisees : STRING, INTEGER, BOOLEAN, TIME, EMAIL |
| description | VARCHAR(500) | OUI | NON | Description de la configuration | Explique l'usage et les valeurs attendues |
| modifiable | TINYINT(1) | NON | NON | Indique si la configuration est modifiable par l'interface admin | Par defaut : 1 |

**Justification** : Centralise les parametres configurables : horaires d'ouverture (BR-042), duree de conservation (BR-084), timeout session (BR-070), fuseau horaire, etc.

## 6.15 Entite : destinataire_email

| Attribut | Type | Nullable | Unique | Description | Regles de Validation |
|----------|------|----------|--------|-------------|---------------------|
| id | BIGINT | NON | OUI | Identifiant unique | Cle primaire |
| email | VARCHAR(255) | NON | OUI | Adresse email destinataire | Format email valide, unique |
| actif | TINYINT(1) | NON | NON | Indique si le destinataire est actif | Par defaut : 1 |
| date_ajout | DATETIME(3) | NON | NON | Horodatage d'ajout | Par defaut : NOW() |

**Justification** : (BR-050, BR-056). Liste des destinataires des rapports automatiques. La desactivation logique permet de suspendre un destinataire sans perdre l'historique.

## 6.16 Entite : rapport

| Attribut | Type | Nullable | Unique | Description | Regles de Validation |
|----------|------|----------|--------|-------------|---------------------|
| id | BIGINT | NON | OUI | Identifiant unique | Cle primaire |
| type_rapport | ENUM | NON | NON | Periodicite du rapport | Valeurs autorisees : JOURNALIER, HEBDOMADAIRE, MENSUEL |
| date_debut_periode | DATE | NON | NON | Debut de la periode couverte | Doit etre anterieure ou egale a date_fin_periode |
| date_fin_periode | DATE | NON | NON | Fin de la periode couverte | Doit etre posterieure ou egale a date_debut_periode |
| date_generation | DATETIME(3) | NON | NON | Horodatage de generation | Par defaut : NOW() |
| chemin_fichier | VARCHAR(500) | OUI | NON | Chemin d'acces au fichier PDF stocke | Null si generation echouee |
| statut | ENUM | NON | NON | Statut de generation et d'envoi | Valeurs autorisees : GENERE, ENVOYE, ERREUR |

**Justification** : (BR-053, BR-054, BR-055, BR-059). Metadonnees des rapports generes. Le fichier PDF est stocke dans le systeme de fichiers.

## 6.17 Entite : notification

| Attribut | Type | Nullable | Unique | Description | Regles de Validation |
|----------|------|----------|--------|-------------|---------------------|
| id | BIGINT | NON | OUI | Identifiant unique | Cle primaire |
| code | VARCHAR(50) | NON | OUI | Code unique identifiant la notification | Snake_case, descriptif |
| message_fr | TEXT | NON | NON | Message en francais | Longueur maximale : 500 caracteres |
| message_ar | TEXT | NON | NON | Message en arabe | Longueur maximale : 500 caracteres |
| message_en | TEXT | NON | NON | Message en anglais | Longueur maximale : 500 caracteres |
| type | ENUM | NON | NON | Type de notification | Valeurs autorisees : SUCCES, ERREUR, INFORMATION |

**Justification** : (BR-065, BR-066, BR-067, BR-068). Centralise les messages multilingues du systeme. Permet la maintenance des textes sans intervention developpement.

---

# 7. Relations

## 7.1 Relations One-to-One

### R1 : utilisateur -> administrateur
- **Type** : 1..0..1 (optionnel)
- **Cardinalite** : Un utilisateur de type ADMINISTRATEUR peut avoir zero ou un enregistrement dans administrateur
- **Justification** : Tous les utilisateurs ne sont pas administrateurs. Seuls ceux de type ADMINISTRATEUR ont un enregistrement correspondant.

### R2 : utilisateur -> reception
- **Type** : 1..0..1 (optionnel)
- **Cardinalite** : Un utilisateur de type RECEPTION peut avoir zero ou un enregistrement dans reception
- **Justification** : Similaire a R1. Les profils reception sont distincts des administrateurs.

### R3 : utilisateur -> employe
- **Type** : 1..0..1 (optionnel)
- **Cardinalite** : Un utilisateur de type EMPLOYE peut avoir zero ou un enregistrement dans employe
- **Justification** : Chaque employe a exactement une fiche employee. L'enregistrement est cree en meme temps que l'utilisateur.

### R4 : utilisateur -> stagiaire
- **Type** : 1..0..1 (optionnel)
- **Cardinalite** : Un utilisateur de type STAGIAIRE peut avoir zero ou un enregistrement dans stagiaire
- **Justification** : Les stagiaires ont des attributs specifiques (dates de stage) non partages avec d'autres profils.

### R5 : utilisateur -> visiteur
- **Type** : 1..0..1 (optionnel)
- **Cardinalite** : Un utilisateur de type VISITEUR peut avoir zero ou un enregistrement dans visiteur
- **Justification** : Chaque visite genere un enregistrement visiteur avec la date de visite.

### R6 : employe -> empreinte_biometrique
- **Type** : 1..0..1 (optionnel)
- **Cardinalite** : Un employe peut avoir zero ou une empreinte biometrique
- **Justification** : (BR-031). L'enrolement est optionnel jusqu'a sa realisation. Un seul vecteur biometrique actif par employe.

## 7.2 Relations One-to-Many

### R7 : utilisateur -> repas
- **Type** : 1..*
- **Cardinalite** : Un utilisateur peut enregistrer plusieurs repas (un par jour)
- **Justification** : (BR-008, BR-014, BR-021). Chaque repas est lie a l'utilisateur qui l'a valide.

### R8 : utilisateur -> qr_code
- **Type** : 1..*
- **Cardinalite** : Un utilisateur (stagiaire ou visiteur) peut avoir plusieurs QR Codes dans le temps
- **Justification** : Un stagiaire peut avoir un QR Code renouvele. Un visiteur a un QR Code par visite.

### R9 : categorie_repas -> repas
- **Type** : 1..*
- **Cardinalite** : Une categorie peut etre selectionnee dans plusieurs repas
- **Justification** : (BR-037, BR-038). Chaque repas est categorise selon le choix de l'utilisateur.

### R10 : mode_identification -> repas
- **Type** : 1..*
- **Cardinalite** : Un mode peut etre utilise pour plusieurs repas
- **Justification** : (BR-082). Chaque repas enregistre le mode d'identification utilise.

### R11 : utilisateur -> session
- **Type** : 0..*
- **Cardinalite** : Un utilisateur (admin/reception) peut avoir plusieurs sessions (consecutives ou simultanees)
- **Justification** : (BR-069). L'historique des sessions permet le suivi des authentifications.

### R12 : utilisateur -> journal_audit
- **Type** : 0..*
- **Cardinalite** : Un utilisateur peut etre auteur de plusieurs entrees d'audit
- **Justification** : (BR-080). Toute action administrateur est journalisee.

### R13 : configuration -> (aucune relation directe)
- **Type** : Table parametrage isolee
- **Justification** : Les configurations sont des paires cle-valeur accessibles par l'ensemble du systeme.

### R14 : utilisateur -> rapport (via generation)
- **Type** : Conceptuelle (pas de cle etrangere directe)
- **Justification** : Les rapports sont generes par le systeme et non lies a un utilisateur specifique.

## 7.3 Relations Many-to-Many

Aucune relation Many-to-Many n'est necessaire dans la version 1.0 du schema. Toutes les relations sont correctement modelisees en One-to-One ou One-to-Many.

---

# 8. Integrite Referentielle

## 8.1 Strategies de Suppression

| Table Enfant | Table Parent | Strategie | Justification |
|-------------|--------------|-----------|---------------|
| administrateur | utilisateur | CASCADE | La suppression de l'utilisateur entraine celle de son extension admin |
| reception | utilisateur | CASCADE | Meme logique que ci-dessus |
| employe | utilisateur | CASCADE | Meme logique |
| stagiaire | utilisateur | CASCADE | Meme logique |
| visiteur | utilisateur | CASCADE | Meme logique |
| repas | utilisateur | RESTRICT | Un repas ne peut pas etre orphelin. L'utilisateur ne peut pas etre supprime s'il a des repas (anonymisation avant) |
| repas | categorie_repas | RESTRICT | Une categorie ne peut pas etre supprimee si des repas y font reference |
| repas | mode_identification | RESTRICT | Meme logique |
| qr_code | utilisateur | CASCADE | Les QR Codes sont lies a l'utilisateur et supprimes avec lui |
| empreinte_biometrique | employe | CASCADE | L'empreinte est supprimee avec l'employe (BR-036) |
| session | utilisateur | CASCADE | Les sessions expirees sont nettoyees automatiquement |
| journal_audit | utilisateur | SET NULL | La suppression d'un utilisateur ne supprime pas son historique d'audit, mais anonymise le lien |
| destinataire_email | (aucun) | - | Table independante, pas de cle etrangere |

## 8.2 Regles Metier Appliquees

| Regle | Implementation |
|-------|---------------|
| BR-008, BR-014, BR-021 | Contrainte UNIQUE (utilisateur_id, date_repas) |
| BR-016, BR-020 | Verification de la date d'expiration avant autorisation |
| BR-022 | Verification qu'aucun QR Code actif n'existe pour le meme visiteur le meme jour |
| BR-025 | Contrainte UNIQUE sur qr_code.code |
| BR-029 | Verification immediate du statut REVOQUE |
| BR-031 | Contrainte UNIQUE sur empreinte_biometrique.employe_id |
| BR-036 | CASCADE suppression entre employe et empreinte_biometrique |
| BR-049 | Contrainte applicative : au moins un administrateur actif |
| BR-083 | Aucun UPDATE/DELETE autorise sur journal_audit |

---

# 9. Contraintes

## 9.1 Contraintes Uniques

| Table | Colonnes | Regle Metier | Description |
|-------|----------|--------------|-------------|
| utilisateur | email | - | Un email ne peut etre utilise que par un seul compte |
| repas | (utilisateur_id, date_repas) | BR-008, BR-014, BR-021 | Un seul repas par utilisateur par jour |
| qr_code | code | BR-025 | Chaque QR Code est unique dans le systeme |
| empreinte_biometrique | employe_id | BR-031 | Un employe ne peut avoir qu'une seule empreinte active |
| configuration | cle | - | Chaque cle de configuration est unique |
| notification | code | - | Chaque code de notification est unique |
| categorie_repas | nom, code_interne | BR-037 | Les noms et codes de categories sont uniques |
| mode_identification | code | - | Les codes des modes d'identification sont uniques |

## 9.2 Contraintes de Verification

| Table | Contrainte | Regle Metier | Description |
|-------|-----------|--------------|-------------|
| utilisateur | type IN (EMPLOYE, STAGIAIRE, VISITEUR, ADMINISTRATEUR, RECEPTION) | - | Le type doit correspondre a un role valide |
| utilisateur | statut IN (ACTIF, INACTIF, SUPPRIME) | BR-010, BR-046 | Le statut doit etre un etat valide |
| stagiaire | date_debut_stage <= date_fin_stage | BR-013 | La date de debut doit etre anterieure a la date de fin |
| visiteur | date_visite <= CURDATE() | BR-019 | La date de visite ne peut pas etre dans le passe (sauf administration) |
| qr_code | statut IN (ACTIF, EXPIRE, REVOQUE) | BR-026, BR-028, BR-029 | Le statut doit etre un etat valide |
| qr_code | date_expiration > date_creation | BR-016, BR-020 | La date d'expiration doit etre posterieure a la date de creation |
| qr_code | date_revocation IS NULL OR date_revocation >= date_creation | BR-028 | La revocation ne peut pas precder la creation |
| repas | horodatage compris dans plage ouverture (controle applicatif) | BR-042 | L'enregistrement doit etre dans la plage horaire |
| employe | statut_enrolement IN (NON_ENROLE, ENROLE, ENROLEMENT_ECHOUE) | BR-007, BR-031 | Le statut d'enrolement doit etre valide |
| rapport | type_rapport IN (JOURNALIER, HEBDOMADAIRE, MENSUEL) | BR-053, BR-054, BR-055 | Le type de rapport doit etre valide |

## 9.3 Contraintes Metier (Application Level)

Certaines contraintes ne peuvent pas etre enforcees uniquement au niveau base de donnees et necessitent une validation applicative :

| Regle | Description | Niveau de Validation |
|-------|-------------|---------------------|
| BR-001 | Employes identifies exclusivement par reconnaissance faciale | Application (selon type utilisateur) |
| BR-002 | Stagiaires identifies exclusivement par QR Code | Application |
| BR-003 | Visiteurs identifies exclusivement par QR Code | Application |
| BR-004 | Aucune saisie d'identifiant/mot de passe pour les non-admins | Application |
| BR-006 | Une seule identification a la fois | Application (verrou) |
| BR-042 | Plage horaire 12h30-14h00 | Application + Verification en base |
| BR-049 | Protection du dernier administrateur actif | Application |
| BR-083 | Immutabilite du journal d'audit | Base (privileges) + Application |

---

# 10. Strategie d'Indexation

## 10.1 Index Primaires

Chaque table possede un index primaire sur sa colonne `id` (cle primaire, auto-increment). Ces indexes sont crees automatiquement par MySQL.

## 10.2 Index Etrangers

Les colonnes de cle etrangere doivent etre indexees pour optimiser les operations de jointure :

| Table | Colonne | Type d'Index | Justification |
|-------|---------|--------------|---------------|
| repas | utilisateur_id | BTREE | Jointure frequente avec utilisateur pour les statistiques et rapports |
| repas | categorie_repas_id | BTREE | Jointure avec categorie_repas pour les statistiques par categorie |
| repas | mode_identification_id | BTREE | Jointure avec mode_identification |
| qr_code | utilisateur_id | BTREE | Recherche des QR Codes par utilisateur |
| empreinte_biometrique | employe_id | BTREE | Recherche de l'empreinte par employe |
| session | utilisateur_id | BTREE | Recherche des sessions actives par utilisateur |
| journal_audit | utilisateur_id | BTREE | Filtrage des actions par auteur |

## 10.3 Index de Recherche

| Table | Colonne(s) | Type d'Index | Justification |
|-------|------------|--------------|---------------|
| utilisateur | nom, prenom | INDEX COMPOSITE | Recherche par nom et prenom dans les listes d'administration |
| utilisateur | email | INDEX UNIQUE | Recherche par email (authentification) |
| utilisateur | type | BTREE | Filtrage par type d'utilisateur dans les listes |
| repas | date_repas | BTREE | Filtrage des repas par date pour les rapports et statistiques |
| repas | horodatage | BTREE | Tri temporel pour l'analyse de frequentation |
| qr_code | code | INDEX UNIQUE | Recherche par code QR (identification par scan) |
| qr_code | statut | BTREE | Filtrage par statut pour les listes d'administration |
| qr_code | date_expiration | BTREE | Identification des QR Codes expires pour verification |
| journal_audit | horodatage | BTREE | Tri chronologique pour la consultation d'audit |
| journal_audit | type_action | BTREE | Filtrage par type d'action |
| configuration | cle | INDEX UNIQUE | Acces par cle de configuration |

## 10.4 Index Composites

| Table | Colonnes | Justification |
|-------|----------|---------------|
| repas | (utilisateur_id, date_repas) | Contrainte UNIQUE + recherche de verification d'unicite journaliere |
| repas | (date_repas, categorie_repas_id) | Statistiques de repartition par jour et par categorie |
| repas | (date_repas, utilisateur_id) | Verification rapide de l'unicite par jour et utilisateur |
| qr_code | (utilisateur_id, statut) | Recherche des QR Codes actifs d'un utilisateur |
| journal_audit | (horodatage, type_action) | Consultation chronologique filtree par type |
| journal_audit | (utilisateur_id, horodatage) | Historique des actions d'un utilisateur |

## 10.5 Optimisation Attendue

| Requete | Index Utilise | Gain Attendu |
|---------|---------------|--------------|
| Verification repas du jour | repas (utilisateur_id, date_repas) | Acces unique -> 1-2ms |
| Scan QR Code | qr_code (code) | Acces unique -> 1ms |
| Statistiques mensuelles | repas (date_repas, categorie_repas_id) | Scan intervalle -> 10-50ms |
| Liste utilisateurs avec filtre | utilisateur (nom, prenom) | Scan partiel -> 5-20ms |
| Journal d'audit pour un utilisateur | journal_audit (utilisateur_id, horodatage) | Scan intervalle -> 5-30ms |

---

# 11. Strategie Transactionnelle

## 11.1 Enregistrement d'un Repas

**Phases** :
1. Debut de transaction
2. Verification de l'unicite du repas pour l'utilisateur et la date courante (SELECT avec verrou)
3. Verification de la validite du QR Code (si identification par QR)
4. Verification de la plage horaire (controle applicatif)
5. Verification du statut actif de l'utilisateur
6. INSERT dans la table repas
7. INSERT dans le journal_audit (enregistrement du repas)
8. Commit

**Niveau d'isolation** : REPEATABLE READ
**Verrou** : Ligne dans repas avec FOR UPDATE pour eviter les doubles enregistrements simultanes

## 11.2 Enrolement Biometrique

**Phases** :
1. Debut de transaction
2. Verification de l'existence de l'employe (SELECT avec verrou)
3. DELETE de l'ancienne empreinte si mise a jour (BR-032)
4. INSERT ou UPDATE de l'empreinte biometrique
5. Mise a jour du statut d'enrolement de l'employe
6. INSERT dans le journal_audit
7. Commit

**Niveau d'isolation** : REPEATABLE READ
**Verrou** : Ligne dans employe + empreinte_biometrique

## 11.3 Generation d'un QR Code

**Phases** :
1. Debut de transaction
2. Verification du type d'utilisateur (stagiaire ou visiteur)
3. Verification de l'absence de QR Code actif pour ce visiteur le meme jour (BR-022)
4. Calcul de la date d'expiration selon le profil
5. Generation du code unique
6. INSERT dans qr_code
7. INSERT dans le journal_audit
8. Commit

**Niveau d'isolation** : REPEATABLE READ
**Verrou** : Verification anti-doublon avec SELECT FOR UPDATE

## 11.4 Generation de Rapport

**Phases** :
1. Debut de transaction
2. Calcul des statistiques pour la periode (SELECT agrege sur repas)
3. INSERT dans rapport avec statut GENERE
4. Generation du fichier PDF (hors transaction)
5. Mise a jour du statut du rapport
6. Commit

**Niveau d'isolation** : READ COMMITTED (lecture seule des donnees)
**Note** : La generation du PDF est effectuee hors transaction pour eviter les verrous longs.

## 11.5 Gestion des Administrateurs

**Creation** :
1. Debut de transaction
2. INSERT dans utilisateur avec type ADMINISTRATEUR
3. INSERT dans administrateur
4. INSERT dans le journal_audit
5. Commit

**Desactivation** :
1. Debut de transaction
2. Verification qu'il ne s'agit pas du dernier administrateur actif (BR-049)
3. Verification que l'administrateur ne se desactive pas lui-meme
4. Mise a jour du statut de l'utilisateur
5. Invalidation des sessions actives
6. INSERT dans le journal_audit
7. Commit

---

# 12. Strategie d'Audit

## 12.1 Principe

Le systeme d'audit repose sur une table unique `journal_audit` qui enregistre de maniere immuable toutes les actions significatives. L'approche choisie est celle du **journalisation centralisee avec capture avant/apres**.

## 12.2 Actions Auditees

| Categorie | Actions | Detail |
|-----------|---------|--------|
| Utilisateurs | Creation, Modification, Desactivation, Suppression | Nom, prenom, statut, type |
| Administrateurs | Creation, Desactivation, Reinitialisation mot de passe | Identite, droits |
| QR Codes | Generation, Revocation | Type, expiration |
| Repas | Enregistrement | Categorie, mode, utilisateur |
| Empreintes | Enrolement, Re-enrolement, Suppression | Employe concerne |
| Configuration | Modification | Nouvelle et ancienne valeur |
| Rapports | Generation, Echec | Type, periode |

## 12.3 Structure des Entrees

Chaque entree d'audit contient :
- **Qui** : utilisateur_id (l'auteur de l'action)
- **Quand** : horodatage (timestamp automatique)
- **Quoi** : type_action (creation, modification, suppression)
- **Qui est concerne** : entite_concernee + id_entite
- **Avant** : details_avant (JSON des valeurs avant modification)
- **Apres** : details_apres (JSON des valeurs apres modification)
- **Ou** : adresse_ip

## 12.4 Immutabilite

L'immutabilite du journal d'audit (BR-083) est assuree par :
- Privileges MySQL : l'utilisateur applicatif dispose uniquement du droit INSERT sur journal_audit
- Aucun UPDATE ou DELETE autorise dans l'API pour cette table
- Verification applicative du type d'operation

## 12.5 Conservation et Purge

La conservation des entrees d'audit est definie par la configuration `DUREE_CONSERVATION_AUDIT` (table configuration). Le processus de purge :
1. Declenche par un job planifie (mensuel)
2. Supprime les entrees dont l'horodatage est anterieur a la duree de conservation
3. Journalise l'operation de purge dans le journal d'audit lui-meme (entree speciale)
4. Les donnees statistiques anonymement sont conservees independamment

---

# 13. Cycle de Vie des Donnees

## 13.1 utilisateur

| Phase | Declencheur | Comportement |
|-------|-------------|--------------|
| Creation | Inscription (admin/reception) ou creation par admin (employe/stagiaire/visiteur) | INSERT avec statut ACTIF |
| Modification | Action administrateur | UPDATE avec journalisation dans journal_audit |
| Desactivation | Action administrateur | UPDATE statut = INACTIF. Sessions invalidees |
| Reactivation | Action administrateur | UPDATE statut = ACTIF. Enrolement preserve |
| Suppression logique | Action administrateur | UPDATE statut = SUPPRIME, date_suppression = NOW() |
| Purge RGPD | Processus automatique planifie | DELETE physique apres duree de conservation. Donnees de repas anonymisees |

## 13.2 repas

| Phase | Declencheur | Comportement |
|-------|-------------|--------------|
| Creation | Validation du repas par l'utilisateur | INSERT irreversible |
| Modification | Jamais autorisee | BR-040 : enregistrement definitif |
| Suppression | Jamais autorisee (sauf purge) | Les donnees sont conservees pour les statistiques |
| Anonymisation | Processus automatique planifie | UPDATE : utilisateur_id remplace par NULL ou identifiant anonyme |
| Purge | Conformement a la politique de conservation | DELETE apres anonymisation et duree de conservation |

## 13.3 qr_code

| Phase | Declencheur | Comportement |
|-------|-------------|--------------|
| Creation | Generation par la reception ou l'administration | INSERT avec statut ACTIF |
| Expiration | Automatique (date_atteinte) | Verification lors du scan, pas de mise a jour automatique de statut |
| Revocation | Action manuelle de l'administration | UPDATE statut = REVOQUE, date_revocation = NOW() |
| Conservation | Duree definie par configuration | Conserve pour audit et tracabilite |
| Purge | Processus automatique | DELETE apres duree de conservation |

## 13.4 empreinte_biometrique

| Phase | Declencheur | Comportement |
|-------|-------------|--------------|
| Creation | Enrolement par l'administration | INSERT avec vecteur chiffre |
| Mise a jour | Re-enrolement | UPDATE du vecteur existant |
| Suppression | Suppression de l'employe | DELETE en cascade (BR-036) |

## 13.5 rapport

| Phase | Declencheur | Comportement |
|-------|-------------|--------------|
| Creation | Job automatique planifie | INSERT avec statut GENERE |
| Envoi | Job automatique (apres generation) | UPDATE statut = ENVOYE |
| Conservation | Duree definie par configuration | Stocke dans le systeme de fichiers |
| Purge | Processus automatique planifie | DELETE de l'enregistrement + suppression du fichier PDF |

---

# 14. Securite

## 14.1 Donnees Sensibles

Les donnees suivantes sont considerees comme sensibles et beneficient de protections specifiques :

| Donnee | Protection | Justification |
|--------|------------|---------------|
| Vecteur biometrique | Chiffrement AES-256-GCM au repos + HTTPS en transit | BR-035, BR-071, RGPD |
| Mot de passe | Hachage bcrypt (cout 12) | BR-069, conformite securite |
| JWT Jeton | Stocke en session, expire automatiquement | BR-070 |
| Adresse IP | Journalisee dans l'audit, pas de conservation longue | Respect de la vie privee |
| Nom/Prenom | Accessible uniquement via API authentifiee | BR-072 |

## 14.2 Chiffrement Biometrique

Les donnees biometriques sont chiffrees selon le processus suivant :
- Algorithme : AES-256-GCM (chiffrement authentifie)
- Cle : stockee dans un coffre-fort de cles (vault), jamais en clair dans la base
- Chiffrement : effectue au niveau application avant envoi a la base de donnees
- Dechiffrement : effectue uniquement au moment de la comparaison lors de l'identification

## 14.3 Gestion des Mots de Passe

Les mots de passe des administrateurs et de la reception sont :
- Haches avec bcrypt (cout 12) avant stockage
- Jamais stockes en clair
- Reinitialisables par un autre administrateur (mot de passe temporaire force au changement)
- Soumis a une politique de complexite (8 caracteres minimum, mixte)

## 14.4 Restrictions d'Acces

| Role | Tables Accessibles | Operations |
|------|--------------------|------------|
| Administrateur | Toutes les tables | CRUD complet (sauf journal_audit : INSERT + SELECT uniquement) |
| Reception | utilisateur (type stagiaire/visiteur), qr_code | INSERT + SELECT (creation comptes) |
| API (non authentifiee) | repas (INSERT), qr_code (SELECT pour verification) | Identification et enregistrement des repas |
| Systeme (jobs) | rapport, journal_audit, configuration | INSERT et SELECT |

---

# 15. Evolutivite

## 15.1 D'une Tablette a Plusieurs Tablettes

L'architecture actuelle supporte deja plusieurs tablettes :
- La table `repas` contient un identifiant utilisateur et un horodatage, independamment de la tablette source
- L'ajout d'une colonne `tablette_id` permettrait de traquer la provenance des enregistrements
- La synchronisation entre tablettes serait geree par l'API centrale (FastAPI)

## 15.2 D'un Restaurant a Plusieurs Restaurants

L'evolution vers plusieurs restaurants necessite :
- Ajout d'une entite `restaurant` avec ses propres parametres (horaires, categories)
- Ajout d'une colonne `restaurant_id` dans les tables utilisateur, repas, configuration
- Partitionnement des donnees par restaurant
- Aucune modification majeure du schema actuel n'est requise

## 15.3 Vers une Plateforme Centralisee

La migration vers une plateforme centralisee (Web Dashboard + API) est facilitee par :
- L'architecture REST de l'API qui dissocie deja le client de la base
- Les indexes de recherche qui supportent des volumes de donnees plus importants
- La table `configuration` qui permet un parametrage centralise
- La table `rapport` qui stocke les metadonnees independamment du client

---

# 16. Sauvegarde et Recuperation

## 16.1 Strategie de Sauvegarde

| Type | Frequence | Contenu | Retention |
|------|-----------|---------|-----------|
| Sauvegarde complete | Quotidienne | Toutes les donnees | 7 jours |
| Sauvegarde incrementale | Horaire (pendant service) | Donnees modifiees depuis la derniere complete | 24 heures |
| Sauvegarde hebdomadaire | Hebdomadaire (dimanche) | Toutes les donnees | 4 semaines |
| Sauvegarde mensuelle | Mensuelle | Toutes les donnees | 12 mois |

## 16.2 Strategie de Recuperation

| Scenario | RPO | RTO | Procedure |
|----------|-----|-----|-----------|
| Panne materielle | 24h | 4h | Restauration depuis la derniere sauvegarde complete |
| Corruption de donnees | 1h | 2h | Restauration depuis la sauvegarde incrementale la plus recente |
| Erreur humaine | 1h | 1h | Restauration de l'enregistrement ou de la table concernee |
| Sinistre majeur | 24h | 24h | Restauration depuis la sauvegarde mensuelle sur site secondaire |

## 16.3 Objectifs de Recuperation

- **RPO (Recovery Point Objective)** : Maximum 1 heure de donnees perdues en cas d'incident
- **RTO (Recovery Time Objective)** : Maximum 4 heures pour le retablissement complet du service

---

# 17. Checklist de Validation de la Base de Donnees

| Criteres | Verification | Statut |
|----------|-------------|--------|
| **Normalisation** | Toutes les tables sont en 3NF | CONFORME |
| **Absence de donnees dupliquees** | Aucune redondance non controlee | CONFORME |
| **Integrite referentielle** | Toutes les foreign keys sont definies | CONFORME |
| **Tracabilite complete** | Chaque entite est liee a des regles metier (BR) | CONFORME |
| **Evolutivite** | Ajout de colonnes/entites sans refonte | CONFORME |
| **Securite des donnees sensibles** | Chiffrement biometrique + hachage mots de passe | CONFORME |
| **Audibilite** | Journal d'audit immuable pour toutes les actions critiques | CONFORME |
| **Performance** | Index couvrant les requetes principales | CONFORME |
| **Contraintes metier** | Unicite repas/jour, unicite QR Code, etc. | CONFORME |
| **Immutabilite audit** | Aucun UPDATE/DELETE autorise sur journal_audit | CONFORME |
| **Support multilingue** | Table notification avec colonnes FR/AR/EN | CONFORME |
| **Gestion des cycles de vie** | Creation, modification, archivage, purge definis | CONFORME |
| **Partitionnement possible** | Tables volumineuses partitionnables par date | CONFORME |

---

# 18. Risques

## 18.1 Corruption de Donnees

**Impact** : Critique. Perte de l'integrite des enregistrements de repas et d'audit.
**Probabilite** : Faible.
**Mitigation** :
- Transactions ACID pour toutes les operations critiques
- Contraintes de cle etrangere et d'unicite au niveau base de donnees
- Sauvegardes regulieres (Section 16)
- Tests de validation avant chaque migration de schema

## 18.2 Enregistrement Concurrent de Repas

**Impact** : Eleve. Possibilite de double enregistrement pour le meme utilisateur le meme jour.
**Probabilite** : Moyenne (deux tentatives simultanees).
**Mitigation** :
- Verrouillage SELECT FOR UPDATE lors de la verification d'unicite
- Contrainte UNIQUE (utilisateur_id, date_repas) comme filet de securite
- Transaction encapsulant verification et insertion

## 18.3 Duplication de QR Code

**Impact** : Eleve. Un QR Code duplique permettrait a deux personnes de s'identifier avec le meme code.
**Probabilite** : Tres faible.
**Mitigation** :
- Contrainte UNIQUE sur qr_code.code
- Generation de code avec UUID v4 ou equivalent cryptographique
- Verification du statut et de l'unicite lors de chaque scan

## 18.4 Compromission des Donnees Biometriques

**Impact** : Critique. Donnees personnelles sensibles irreversibles.
**Probabilite** : Tres faible.
**Mitigation** :
- Chiffrement AES-256-GCM au repos
- Cle de chiffrement stockee hors base de donnees (vault)
- Acces restreint aux seuls administrateurs habilites
- Pas de stockage en clair ni de transmission sans chiffrement

## 18.5 Degradation des Performances

**Impact** : Moyen. Ralentissement de l'identification et de l'enregistrement des repas.
**Probabilite** : Moyenne (croissance des donnees).
**Mitigation** :
- Index couvrant les requetes principales (Section 10)
- Partitionnement temporel des tables volumineuses
- Nettoyage et purge periodiques des donnees obsoletes
- Surveillance des performances avec alertes

---

# 19. Evolution Future

Les entites suivantes ne sont pas implementees en version 1.0 mais sont identifiees pour les versions futures :

## 19.1 Tableau de Bord et Analytics

Entites potentielles :
- **indicateur_performance** : Stocke les KPI precalcules pour le dashboard web
- **vue_materialisee_statistiques** : Agregats precalcules pour des performances optimales
- **alerte_seuil** : Configuration des seuils d'alerte (frequentation maximale, stock) 
- **tableau_bord** : Configuration des preferences d'affichage du dashboard

## 19.2 Multi-Tablettes et Multi-Restaurants

Entites potentielles :
- **tablette** : Enregistrement des tablettes deployeees avec leur statut et version logicielle
- **restaurant** : Sites de restauration multiples avec leurs propres parametres et horaires
- **affectation_tablette** : Lien entre une tablette et un restaurant

## 19.3 Gestion des Stocks et Approvisionnements

Entites potentielles (non incluses dans le perimetre actuel) :
- **inventaire_ingredient** : Suivi des stocks disponibles
- **commande_fournisseur** : Gestion des approvisionnements
- **mouvement_stock** : Traçabilite des entrees et sorties de stock

## 19.4 Intelligence Artificielle et Insights

Entites potentielles :
- **modele_prediction** : Configuration des modeles predictifs de frequentation
- **recommendation_menu** : Suggestions basees sur les preferences historiques
- **analyse_sentiment** : Retour utilisateur sur la qualite des repas

---

# 20. Conclusion

Le schema de base de donnees presente dans ce document constitue le fondement de la couche de persistence de la solution CSM-GIAS Resto+. Il a ete concu selon les principes de l'ingenierie des donnees d'entreprise, en respectant les contraintes suivantes :

**Adequation fonctionnelle** : Chaque entite, attribut et relation du schema repond a un besoin metier documente dans les regles metier (BR), les exigences fonctionnelles (FR) et les User Stories (US) validees. Aucune entite superflue n'a ete introduite.

**Integrite et coherence** : Les contraintes d'unicite, de verification et d'integrite referentielle garantissent que les donnees stockees refletent fidelement les regles de gestion de l'entreprise : un repas par personne par jour, des QR Codes uniques et non reutilisables, des donnees biometriques chiffrees et protegees.

**Performance et evolutivite** : La strategie d'indexation couvre l'ensemble des requetes critiques identifiees, de l'identification par QR Code (moins de 1 ms) aux statistiques mensuelles (moins de 50 ms). L'architecture anticipe les evolutions vers la multi-tablette, le multi-restaurant et la plateforme centralisee sans refonte majeure.

**Securite et conformite** : Les donnees biometriques sont chiffrees, les mots de passe haches, les sessions temporisees et le journal d'audit immuable. Ces dispositions assurent la conformite avec le RGPD et les politiques de securite de l'entreprise.

**Gouvernance et maintenabilite** : Les conventions de nommage strictes, la documentation detaillee de chaque entite et la strategie de migration versionnee (Alembic) permettent a l'equipe de developpement de mettre en oeuvre le schema avec precision et confiance.

Ce document est destine a etre utilise directement par l'equipe de developpement backend pour l'implementation du modele SQLAlchemy et la creation des migrations Alembic. Il constitue la source unique de verite pour toutes les decisions relatives a la persistence des donnees de CSM-GIAS Resto+.
