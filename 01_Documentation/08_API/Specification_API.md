# 1. Page de Garde

**Projet** : CSM-GIAS Resto+
**Sous-titre** : Solution Intelligente de Gestion du Restaurant d'Entreprise
**Titre du document** : Specification de l'API REST
**Version** : 1.0
**Date** : Juillet 2026
**Auteur** : Architecte API Senior
**Confidentialite** : Interne - Strictement Confidentiel

## Historique des Revisions

| Version | Date | Auteur | Description |
|---------|------|--------|-------------|
| 1.0 | 04/07/2026 | Architecte API Senior | Creation de la specification complete de l'API REST |

---

# 2. Introduction

## 2.1 Objet du Document

Le present document constitue la specification complete de l'API REST du projet CSM-GIAS Resto+. Il definit l'ensemble des ressources, endpoints, formats d'echange, regles de validation et mecanismes de securite qui regissent la communication entre l'application mobile (React Native) et le backend (FastAPI).

Ce document est le contrat formel entre les equipes de developpement backend et mobile. Il est destine a etre utilise comme reference unique pour l'implementation.

## 2.2 Perimetre

La specification couvre l'integralite des fonctionnalites de la Release 1.0 :
- Authentification et gestion des sessions
- Gestion des utilisateurs (employes, stagiaires, visiteurs, administrateurs, reception)
- Identification par reconnaissance faciale et QR Code
- Enregistrement des repas
- Generation et gestion des QR Codes
- Enrolement biometrique
- Rapports automatiques et statistiques
- Configuration systeme
- Consultation du journal d'audit
- Notifications et messages

## 2.3 Public Cible

Ce document s'adresse aux :
- Developpeurs backend (FastAPI) charges de l'implementation des endpoints
- Developpeurs mobiles (React Native) charges de la consommation de l'API
- Architectes logiciels charges de la validation technique
- Equipes de test charges de la qualification des echanges
- Equipes DevOps charges du deploiement

## 2.4 Relation avec l'Architecture Technique

L'API REST constitue la couche d'abstraction entre le client mobile et la base de donnees MySQL. Elle implemente la logique metier definie dans les regles metier et les User Stories, en s'appuyant sur le schema de base de donnees documente dans le Schema de Base de Donnees.

## 2.5 Relation avec la Base de Donnees

Chaque endpoint API correspond a une ou plusieurs operations sur les entites definies dans le Schema de Base de Donnees. La tracabilite entre les endpoints, les entites et les regles metier est documentee dans la Matrice de Tracabilite (Section 17).

---

# 3. Principes de Conception de l'API

## 3.1 REST

L'API est concue selon les principes REST (Representational State Transfer) :
- Les ressources sont identifiees par des URL
- Les operations sont definies par les methodes HTTP standard
- Les representations des ressources sont echangees en JSON
- Le protocole est sans etat (stateless)
- Les reponses utilisent les codes de statut HTTP appropries

## 3.2 Sans Etat (Stateless)

Chaque requete contient toutes les informations necessaires a son traitement. Le serveur ne conserve aucune information de session entre les requetes. L'authentification est transportee via un jeton JWT dans l'en-tete Authorization.

## 3.3 Cohrence

Tous les endpoints respectent des conventions uniformes :
- Format de date ISO 8601
- Structure de reponse standardisee
- Pagination consistante
- Codes d'erreur normalises
- Nommage en anglais pour les ressources et les champs

## 3.4 Versioning

L'API est versionnee via le prefixe d'URL /api/v1/. Les modifications incompatibles sont introduites dans une nouvelle version. La strategie de versioning est detaillee a la Section 14.

## 3.5 Idempotence

Les methodes GET, PUT, DELETE sont idempotentes. Les methodes POST ne le sont pas. Les methodes PATCH sont idempotentes par conception.

## 3.6 Securite

Tous les endpoints sont proteges par authentification JWT, a l'exception des endpoints d'identification sur la tablette (reconnaissance faciale et QR Code) qui utilisent un mecanisme de securite specifique (cle API de la tablette + horodatage).

## 3.7 Validation

Chaque requete est validee au niveau de l'API avant traitement. Les regles de validation sont definies a la Section 9. Les erreurs de validation retournent un code HTTP 422 avec une structure d'erreur standardisee.

---

# 4. Conventions Globales de l'API

## 4.1 URL de Base

| Environnement | URL de Base |
|--------------|-------------|
| Developpement | http://localhost:8000/api/v1 |
| Recette (Staging) | https://recette.csm-gias-resto.com/api/v1 |
| Production | https://api.csm-gias-resto.com/api/v1 |

## 4.2 Version de l'API

L'API est versionnee via le prefixe /api/v1/. La version est incluse dans l'URL et non dans l'en-tete.

## 4.3 Format des Echanges

- Type de contenu : application/json
- Encodage : UTF-8
- Dates : ISO 8601 (AAAA-MM-JJ)
- Horodatages : ISO 8601 (AAAA-MM-JJTHH:MM:SS.sssZ)
- Fuseau horaire : UTC pour les horodatages, heure locale pour les dates metier
- Identifiants : BIGINT (entiers 64 bits)

## 4.4 En-tetes

| En-tete | Requis | Description |
|---------|--------|-------------|
| Content-Type | OUI | application/json |
| Accept | OUI | application/json |
| Authorization | Conditionnel | Bearer {token} pour les endpoints proteges |
| X-Tablette-API-Key | Conditionnel | Cle API de la tablette pour les endpoints d'identification |
| X-Request-Id | Recommande | Identifiant de correlation pour le tracing distribue (UUID v4) |

## 4.5 Conventions de Nommage

| Element | Convention | Exemple |
|---------|------------|---------|
| Ressources | snake_case, pluriel | /employes, /categories-repas |
| Parametres requete | camelCase | ?page=1&pageSize=20&nom=Durand |
| Corps JSON | camelCase | { "nom": "Durand", "prenom": "Jean" } |
| Reponses JSON | camelCase | { "totalRepas": 150 } |
| Identifiants | bigint | 42 |
| Codes QR | string (UUID v4) | "a1b2c3d4-e5f6-7890-abcd-ef1234567890" |

## 4.6 Methodes HTTP

| Methode | Utilisation | Idempotent |
|---------|-------------|------------|
| GET | Consultation de ressources | OUI |
| POST | Creation de ressources / actions | NON |
| PUT | Mise a jour complete | OUI |
| PATCH | Mise a jour partielle / changement de statut | OUI |
| DELETE | Suppression | OUI |

## 4.7 Codes de Statut HTTP

| Code | Signification | Utilisation |
|------|---------------|-------------|
| 200 | OK | Requete traitee avec succes |
| 201 | Created | Ressource creee avec succes |
| 204 | No Content | Suppression reussie (pas de corps) |
| 400 | Bad Request | Requete invalide (parametres manquants) |
| 401 | Unauthorized | Authentification requise ou echouee |
| 403 | Forbidden | Droits insuffisants |
| 404 | Not Found | Ressource inexistante |
| 409 | Conflict | Conflit (ex: repas deja enregistre) |
| 422 | Unprocessable Entity | Validation des donnees echouee |
| 429 | Too Many Requests | Limite de debit atteinte |
| 500 | Internal Server Error | Erreur serveur inattendue |
| 503 | Service Unavailable | Service temporairement indisponible |

---

# 5. Authentification

## 5.1 Principe

L'API utilise des jetons JWT (JSON Web Tokens) pour l'authentification des administrateurs et du personnel de reception. La tablette utilise un mecanisme distinct base sur une cle API.

## 5.2 Flux d'Authentification

1. L'administrateur ou le membre de la reception envoie ses identifiants (email, mot de passe) a POST /auth/login
2. Le serveur valide les identifiants et retourne un jeton JWT (access token) avec une duree de validite limitee
3. Le client inclut le jeton dans l'en-tete Authorization de chaque requete protegee
4. A expiration du jeton, le client utilise POST /auth/refresh pour obtenir un nouveau jeton
5. Le client appelle POST /auth/logout pour invalider le jeton

## 5.3 Jetons JWT

| Propriete | Valeur |
|-----------|--------|
| Algorithme | HS256 |
| Duree de validite (access) | 30 minutes |
| Duree de validite (refresh) | 24 heures |
| Stockage cote client | Memoire securisee (pas de stockage persistant) |
| Invalidation | Deconnexion, desactivation du compte, expiration |

## 5.4 Claims du JWT

| Claim | Description | Exemple |
|-------|-------------|---------|
| sub | Identifiant de l'utilisateur | 42 |
| email | Adresse email de l'utilisateur | admin@csm-gias.com |
| role | Role de l'utilisateur | ADMINISTRATEUR |
| type | Type d'utilisateur | ADMINISTRATEUR |
| exp | Date d'expiration (timestamp) | 1760000000 |
| iat | Date d'emission (timestamp) | 1759998200 |
| jti | Identifiant unique du jeton (UUID v4) | "a1b2c3d4-e5f6-7890-abcd-ef1234567890" |

## 5.5 Authentification de la Tablette

La tablette utilise une cle API pre-configuree et un mecanisme d'horodatage :
- En-tete X-Tablette-API-Key : cle API de la tablette
- En-tete X-Timestamp : horodatage UNIX de la requete
- En-tete X-Signature : HMAC-SHA256(cle_api + timestamp + corps_requete)

Ce mecanisme est utilise uniquement pour les endpoints d'identification (reconnaissance faciale, QR Code) et d'enregistrement des repas.

---

# 6. Ressources de l'API

## 6.1 Ressource : Authentification

**URL de base** : /auth

**Responsabilites** :
- Gerer l'authentification des administrateurs et de la reception
- Delivrer, rafraichir et invalider les jetons JWT

**Operations** :
- POST /auth/login : Authentification
- POST /auth/refresh : Rafraichissement du jeton
- POST /auth/logout : Deconnexion

**Regles Metier** : BR-069, BR-070

## 6.2 Ressource : Identification

**URL de base** : /identification

**Responsabilites** :
- Traiter les tentatives d'identification par reconnaissance faciale
- Traiter les tentatives d'identification par QR Code

**Operations** :
- POST /identification/faciale : Identification par reconnaissance faciale
- POST /identification/qr-code : Identification par QR Code

**Regles Metier** : BR-001, BR-002, BR-003, BR-004, BR-005, BR-006

## 6.3 Ressource : Enrolement Biometrique

**URL de base** : /enrolement

**Responsabilites** :
- Gerer l'enrolement et le re-enrolement des employes
- Verifier le statut d'enrolement

**Operations** :
- POST /enrolement : Enrolement biometrique d'un employe
- GET /enrolement/{employe_id} : Consultation du statut d'enrolement
- PUT /enrolement/{employe_id} : Re-enrolement biometrique

**Regles Metier** : BR-007, BR-031, BR-032, BR-035, BR-036, BR-047

## 6.4 Ressource : Employes

**URL de base** : /employes

**Responsabilites** :
- Gerer le cycle de vie des comptes employes (CRUD)
- Gerer l'historique des repas par employe

**Operations** :
- GET /employes : Liste des employes
- POST /employes : Creation d'un employe
- GET /employes/{id} : Detail d'un employe
- PUT /employes/{id} : Modification d'un employe
- PATCH /employes/{id}/desactiver : Desactivation d'un employe
- PATCH /employes/{id}/reactiver : Reactivation d'un employe
- DELETE /employes/{id} : Suppression definitive (RGPD)
- GET /employes/{id}/repas : Historique des repas

**Regles Metier** : BR-008 a BR-012, BR-046

## 6.5 Ressource : Stagiaires

**URL de base** : /stagiaires

**Responsabilites** :
- Gerer le cycle de vie des comptes stagiaires
- Gerer la generation des QR Codes associes

**Operations** :
- GET /stagiaires : Liste des stagiaires
- POST /stagiaires : Creation d'un stagiaire
- GET /stagiaires/{id} : Detail d'un stagiaire
- PUT /stagiaires/{id} : Modification d'un stagiaire
- GET /stagiaires/{id}/qr-code : QR Code du stagiaire

**Regles Metier** : BR-013 a BR-018, BR-045

## 6.6 Ressource : Visiteurs

**URL de base** : /visiteurs

**Responsabilites** :
- Gerer le cycle de vie des comptes visiteurs
- Gerer la generation des QR Codes associes

**Operations** :
- GET /visiteurs : Liste des visiteurs
- POST /visiteurs : Creation d'un visiteur
- GET /visiteurs/{id} : Detail d'un visiteur
- GET /visiteurs/{id}/qr-code : QR Code du visiteur

**Regles Metier** : BR-019 a BR-024, BR-045

## 6.7 Ressource : Administrateurs

**URL de base** : /administrateurs

**Responsabilites** :
- Gerer le cycle de vie des comptes administrateurs

**Operations** :
- GET /administrateurs : Liste des administrateurs
- POST /administrateurs : Creation d'un administrateur
- GET /administrateurs/{id} : Detail d'un administrateur
- PUT /administrateurs/{id} : Modification d'un administrateur
- PATCH /administrateurs/{id}/desactiver : Desactivation
- POST /administrateurs/{id}/reinitialiser-mot-de-passe : Reinitialisation mot de passe

**Regles Metier** : BR-048, BR-049, BR-069

## 6.8 Ressource : QR Codes

**URL de base** : /qrcodes

**Responsabilites** :
- Gerer la consultation et la revocation des QR Codes
- Verifier la validite des QR Codes

**Operations** :
- GET /qrcodes/{id} : Detail d'un QR Code
- PATCH /qrcodes/{id}/revoquer : Revocation d'un QR Code
- POST /qrcodes/verifier : Verification de validite

**Regles Metier** : BR-025, BR-026, BR-027, BR-028, BR-029, BR-030

## 6.9 Ressource : Repas

**URL de base** : /repas

**Responsabilites** :
- Enregistrer les repas valides par les utilisateurs
- Consulter l'historique des repas

**Operations** :
- POST /repas : Enregistrement d'un repas
- GET /repas : Liste des repas (filtrable)
- GET /repas/{id} : Detail d'un repas
- GET /repas/aujourd-hui : Recapitulatif du jour

**Regles Metier** : BR-037 a BR-044, BR-082

## 6.10 Ressource : Categories Repas

**URL de base** : /categories-repas

**Responsabilites** :
- Liste des categories de repas disponibles

**Operations** :
- GET /categories-repas : Liste des categories

**Regles Metier** : BR-037, BR-044

## 6.11 Ressource : Rapports

**URL de base** : /rapports

**Responsabilites** :
- Gerer la generation et la consultation des rapports
- Gerer les destinataires email

**Operations** :
- GET /rapports : Liste des rapports
- GET /rapports/{id} : Metadonnees d'un rapport
- GET /rapports/{id}/telecharger : Telechargement du PDF
- POST /rapports/generer : Generation manuelle d'un rapport
- GET /rapports/destinataires : Liste des destinataires email
- POST /rapports/destinataires : Ajout d'un destinataire
- DELETE /rapports/destinataires/{id} : Suppression d'un destinataire

**Regles Metier** : BR-050, BR-053 a BR-059

## 6.12 Ressource : Statistiques

**URL de base** : /statistiques

**Responsabilites** :
- Fournir les indicateurs statistiques consultables dans l'interface d'administration

**Operations** :
- GET /statistiques/total-repas : Total des repas sur une periode
- GET /statistiques/repartition-categorie : Repartition par categorie
- GET /statistiques/repartition-profil : Repartition par profil utilisateur
- GET /statistiques/frequentation-horaire : Pics de frequentation
- GET /statistiques/export-csv : Export CSV

**Regles Metier** : BR-060 a BR-064

## 6.13 Ressource : Configuration

**URL de base** : /configuration

**Responsabilites** :
- Gerer les parametres configurables du systeme

**Operations** :
- GET /configuration : Liste des configurations
- GET /configuration/{cle} : Valeur d'une configuration
- PUT /configuration/{cle} : Mise a jour d'une configuration

**Regles Metier** : BR-042

## 6.14 Ressource : Audit

**URL de base** : /audit

**Responsabilites** :
- Consulter le journal d'audit du systeme

**Operations** :
- GET /audit : Liste des entrees d'audit
- GET /audit/{id} : Detail d'une entree d'audit

**Regles Metier** : BR-080, BR-081, BR-082, BR-083, BR-084

## 6.15 Ressource : Tablette

**URL de base** : /tablette

**Responsabilites** :
- Gerer le statut et la sante de la tablette

**Operations** :
- GET /tablette/statut : Statut de la tablette
- POST /tablette/ping : Signal de vie (health check)

**Regles Metier** : BR-075, BR-077

---

# 7. Specification des Endpoints

## 7.1 Authentification

### EP-001 : Connexion

- **Methode** : POST
- **URL** : /auth/login
- **Objectif** : Authentifier un administrateur ou un membre de la reception et delivrer un jeton JWT
- **Authentification** : Aucune (endpoint public)
- **Roles autorises** : Tous (validation par type d'utilisateur)

**Parametres de la requete** :

```json
{
  "email": "admin@csm-gias.com",
  "motDePasse": "Mot2Passe!2026"
}
```

**Regles de validation** :
- email : obligatoire, format email valide, max 255 caracteres
- motDePasse : obligatoire, min 8 caracteres, max 128 caracteres

**Reponse en cas de succes (200)** :

```json
{
  "success": true,
  "data": {
    "utilisateur": {
      "id": 1,
      "email": "admin@csm-gias.com",
      "nom": "Dupont",
      "prenom": "Jean",
      "role": "ADMINISTRATEUR"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 1800
  }
}
```

**Codes de statut** :
- 200 : Authentification reussie
- 401 : Email ou mot de passe incorrect
- 422 : Donnees de requete invalides
- 429 : Trop de tentatives echouees

**Regles Metier** : BR-069, BR-070
**User Stories** : US-006
**Exigences Fonctionnelles** : FR-208

**Erreurs possibles** :
- AUTH_001 : Identifiants invalides
- AUTH_002 : Compte desactive
- AUTH_003 : Trop de tentatives (compte temporairement verrouille)

---

### EP-002 : Rafraichissement du jeton

- **Methode** : POST
- **URL** : /auth/refresh
- **Objectif** : Rafraichir un jeton JWT expire a l'aide du refresh token
- **Authentification** : Refresh token dans le corps de la requete

**Corps de la requete** :

```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Reponse en cas de succes (200)** :

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 1800
  }
}
```

**Codes de statut** :
- 200 : Rafraichissement reussi
- 401 : Refresh token invalide ou expire
- 422 : Donnees invalides

---

### EP-003 : Deconnexion

- **Methode** : POST
- **URL** : /auth/logout
- **Objectif** : Invalider le jeton JWT actif
- **Authentification** : JWT requis (Bearer token)

**En-tetes** : Authorization: Bearer {accessToken}

**Reponse en cas de succes (200)** :

```json
{
  "success": true,
  "message": "Deconnexion reussie"
}
```

**Codes de statut** :
- 200 : Deconnexion reussie
- 401 : Jeton invalide ou deja expire

---

## 7.2 Identification

### EP-004 : Identification par reconnaissance faciale

- **Methode** : POST
- **URL** : /identification/faciale
- **Objectif** : Identifier un employe par reconnaissance faciale a partir d'une image capturee par la tablette
- **Authentification** : Cle API tablette (X-Tablette-API-Key + signature)

**Corps de la requete** :

```json
{
  "imageBase64": "/9j/4AAQSkZJRgABAQEASABIAAD...",
  "timestamp": 1759998200
}
```

**Regles de validation** :
- imageBase64 : obligatoire, image JPEG valide, max 5 MB
- timestamp : obligatoire, doit correspondre a l'en-tete X-Timestamp (tolerance 30 secondes)

**Reponse en cas de succes (200)** :

```json
{
  "success": true,
  "data": {
    "utilisateur": {
      "id": 42,
      "nom": "Martin",
      "prenom": "Sophie",
      "type": "EMPLOYE"
    },
    "identificationId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "tempsIdentificationMs": 850
  }
}
```

**Reponse en cas d'echec (200 - echec d'identification)** :

```json
{
  "success": false,
  "error": {
    "code": "IDF_001",
    "message": "Visage non reconnu",
    "detail": "Aucune correspondance trouvee avec les empreintes enregistrees",
    "recommendation": "Veuillez reessayer ou contacter l'administration"
  }
}
```

**Codes de statut** :
- 200 : Identification traitee (success true ou false)
- 400 : Image invalide ou de qualite insuffisante
- 401 : Cle API tablette invalide
- 422 : Donnees de requete invalides
- 503 : Service de reconnaissance faciale indisponible

**Regles Metier** : BR-001, BR-004, BR-005, BR-033, BR-034
**User Stories** : US-001, US-011, US-012, US-071
**Exigences Fonctionnelles** : FR-201, FR-207, FR-304, FR-305, FR-307

---

### EP-005 : Identification par QR Code

- **Methode** : POST
- **URL** : /identification/qr-code
- **Objectif** : Identifier un stagiaire ou un visiteur par scan de QR Code
- **Authentification** : Cle API tablette (X-Tablette-API-Key + signature)

**Corps de la requete** :

```json
{
  "qrCode": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "timestamp": 1759998200
}
```

**Regles de validation** :
- qrCode : obligatoire, format UUID v4
- timestamp : obligatoire, tolerance 30 secondes

**Reponse en cas de succes (200)** :

```json
{
  "success": true,
  "data": {
    "utilisateur": {
      "id": 75,
      "nom": "Benali",
      "prenom": "Amir",
      "type": "STAGIAIRE"
    },
    "qrCode": {
      "id": 12,
      "type": "NOMINATIF",
      "dateExpiration": "2026-12-31T23:59:59Z"
    },
    "identificationId": "f2g3h4i5-j6k7-8901-lmno-p23456789012"
  }
}
```

**Reponse en cas de QR expire (200)** :

```json
{
  "success": false,
  "error": {
    "code": "QR_002",
    "message": "QR Code expire",
    "detail": "Ce QR Code a expire le 30/06/2026",
    "recommendation": "Veuillez contacter l'accueil ou l'administration"
  }
}
```

**Codes de statut** :
- 200 : Identification traitee
- 401 : Cle API tablette invalide
- 422 : Donnees invalides

**Regles Metier** : BR-002, BR-003, BR-004, BR-025, BR-026, BR-027, BR-029
**User Stories** : US-002, US-003, US-004, US-005
**Exigences Fonctionnelles** : FR-202, FR-203, FR-204, FR-205

---

## 7.3 Enrolement Biometrique

### EP-006 : Enrolement biometrique

- **Methode** : POST
- **URL** : /enrolement
- **Objectif** : Enroler un employe par capture de ses donnees faciales
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Corps de la requete** :

```json
{
  "employeId": 42,
  "imageBase64": "/9j/4AAQSkZJRgABAQEASABIAAD...",
  "timestamp": 1759998200
}
```

**Regles de validation** :
- employeId : obligatoire, doit correspondre a un employe actif non enrole
- imageBase64 : obligatoire, qualite suffisante validee par l'application

**Reponse en cas de succes (201)** :

```json
{
  "success": true,
  "data": {
    "employeId": 42,
    "statut": "ENROLE",
    "dateEnrolement": "2026-07-04T14:30:00.000Z"
  }
}
```

**Codes de statut** :
- 201 : Enrolement reussi
- 400 : Qualite d'image insuffisante
- 401 : JWT invalide
- 403 : Droits insuffisants
- 404 : Employe non trouve
- 409 : Employe deja enrole
- 422 : Donnees invalides

**Regles Metier** : BR-007, BR-031, BR-047
**User Stories** : US-008, US-076
**Exigences Fonctionnelles** : FR-301, FR-302, FR-606

---

### EP-007 : Consultation du statut d'enrolement

- **Methode** : GET
- **URL** : /enrolement/{employe_id}
- **Objectif** : Consulter le statut d'enrolement d'un employe
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Parametres chemin** : employe_id (bigint, obligatoire)

**Reponse en cas de succes (200)** :

```json
{
  "success": true,
  "data": {
    "employeId": 42,
    "nom": "Martin",
    "prenom": "Sophie",
    "statutEnrolement": "ENROLE",
    "dateEnrolement": "2026-07-04T14:30:00.000Z"
  }
}
```

**Codes de statut** :
- 200 : Succes
- 401 : JWT invalide
- 403 : Droits insuffisants
- 404 : Employe non trouve

---

### EP-008 : Re-enrolement biometrique

- **Methode** : PUT
- **URL** : /enrolement/{employe_id}
- **Objectif** : Mettre a jour les donnees biometriques d'un employe deja enrole
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Corps de la requete** :

```json
{
  "imageBase64": "/9j/4AAQSkZJRgABAQEASABIAAD...",
  "timestamp": 1759999200
}
```

**Codes de statut** :
- 200 : Re-enrolement reussi
- 400 : Qualite d'image insuffisante
- 404 : Employe non trouve
- 409 : Employe non enrole (utiliser POST pour le premier enrolement)

**Regles Metier** : BR-032
**User Stories** : US-010
**Exigences Fonctionnelles** : FR-303

---

## 7.4 Employes

### EP-009 : Liste des employes

- **Methode** : GET
- **URL** : /employes
- **Objectif** : Lister les employes avec pagination et filtres
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Parametres requete** :

| Parametre | Type | Obligatoire | Description |
|-----------|------|-------------|-------------|
| page | integer | Non | Page courante (defaut : 1) |
| pageSize | integer | Non | Nombre par page (defaut : 20, max : 100) |
| nom | string | Non | Filtre par nom (recherche partielle) |
| prenom | string | Non | Filtre par prenom (recherche partielle) |
| statut | enum | Non | Filtre par statut (ACTIF, INACTIF) |
| enrole | boolean | Non | Filtre par statut d'enrolement |
| sortBy | string | Non | Champ de tri (defaut : nom) |
| sortOrder | enum | Non | Ordre de tri (asc, desc, defaut : asc) |

**Reponse en cas de succes (200)** :

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "nom": "Durand",
      "prenom": "Pierre",
      "email": "pierre.durand@csm-gias.com",
      "statut": "ACTIF",
      "statutEnrolement": "ENROLE",
      "dateCreation": "2026-01-15T08:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalElements": 350,
    "totalPages": 18
  }
}
```

**Codes de statut** :
- 200 : Succes
- 401 : JWT invalide
- 403 : Droits insuffisants

**User Stories** : US-047, US-052, US-054
**Exigences Fonctionnelles** : FR-101, FR-106, FR-110, FR-111

---

### EP-010 : Creation d'un employe

- **Methode** : POST
- **URL** : /employes
- **Objectif** : Creer un nouveau compte employe
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Corps de la requete** :

```json
{
  "nom": "Durand",
  "prenom": "Pierre"
}
```

**Regles de validation** :
- nom : obligatoire, 1-100 caracteres, lettres et tirets autorises
- prenom : obligatoire, 1-100 caracteres, lettres et tirets autorises

**Reponse en cas de succes (201)** :

```json
{
  "success": true,
  "data": {
    "id": 351,
    "nom": "Durand",
    "prenom": "Pierre",
    "statut": "ACTIF",
    "statutEnrolement": "NON_ENROLE",
    "dateCreation": "2026-07-04T15:00:00.000Z"
  }
}
```

**Codes de statut** :
- 201 : Employe cree
- 401 : JWT invalide
- 403 : Droits insuffisants
- 422 : Donnees invalides

**Regles Metier** : BR-011
**User Stories** : US-047
**Exigences Fonctionnelles** : FR-101

---

### EP-011 : Detail d'un employe

- **Methode** : GET
- **URL** : /employes/{id}
- **Objectif** : Obtenir les details d'un employe
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Reponse en cas de succes (200)** :

```json
{
  "success": true,
  "data": {
    "id": 42,
    "nom": "Martin",
    "prenom": "Sophie",
    "email": null,
    "statut": "ACTIF",
    "statutEnrolement": "ENROLE",
    "dateEnrolement": "2026-07-04T14:30:00.000Z",
    "dateCreation": "2026-01-15T08:00:00.000Z",
    "dateModification": "2026-07-04T14:30:00.000Z"
  }
}
```

**Codes de statut** :
- 200 : Succes
- 404 : Employe non trouve

---

### EP-012 : Modification d'un employe

- **Methode** : PUT
- **URL** : /employes/{id}
- **Objectif** : Modifier les informations d'un employe
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Corps de la requete** :

```json
{
  "nom": "Martin",
  "prenom": "Sophie"
}
```

**Codes de statut** :
- 200 : Modification reussie
- 404 : Employe non trouve
- 422 : Donnees invalides

**User Stories** : US-055
**Exigences Fonctionnelles** : FR-102

---

### EP-013 : Desactivation d'un employe

- **Methode** : PATCH
- **URL** : /employes/{id}/desactiver
- **Objectif** : Desactiver un compte employe (suspendre les droits d'acces)
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Codes de statut** :
- 200 : Employe desactive
- 404 : Employe non trouve
- 409 : Employe deja desactive

**User Stories** : US-048
**Exigences Fonctionnelles** : FR-103

---

### EP-014 : Reactivation d'un employe

- **Methode** : PATCH
- **URL** : /employes/{id}/reactiver
- **Objectif** : Reactiver un compte employe precedemment desactive
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Codes de statut** :
- 200 : Employe reactive
- 404 : Employe non trouve
- 409 : Employe deja actif

**User Stories** : US-056
**Exigences Fonctionnelles** : FR-104

---

### EP-015 : Suppression d'un employe (RGPD)

- **Methode** : DELETE
- **URL** : /employes/{id}
- **Objectif** : Supprimer definitivement un employe et ses donnees biometriques (conformement au RGPD)
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Codes de statut** :
- 204 : Employe supprime
- 404 : Employe non trouve
- 409 : Employe non desactivable (conflit)

**Regles Metier** : BR-012, BR-036
**User Stories** : US-049, US-074
**Exigences Fonctionnelles** : FR-105, FR-308

---

### EP-016 : Historique des repas d'un employe

- **Methode** : GET
- **URL** : /employes/{id}/repas
- **Objectif** : Consulter l'historique des repas d'un employe
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Parametres requete** :

| Parametre | Type | Obligatoire | Description |
|-----------|------|-------------|-------------|
| page | integer | Non | Page courante (defaut : 1) |
| pageSize | integer | Non | Nombre par page (defaut : 20) |
| dateDebut | date | Non | Filtre debut de periode |
| dateFin | date | Non | Filtre fin de periode |

**Reponse en cas de succes (200)** :

```json
{
  "success": true,
  "data": [
    {
      "id": 1024,
      "categorie": "PLAT",
      "date": "2026-07-04",
      "horodatage": "2026-07-04T12:45:00.000Z",
      "modeIdentification": "RECONNAISSANCE_FACIALE"
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalElements": 85,
    "totalPages": 5
  }
}
```

**User Stories** : US-051
**Exigences Fonctionnelles** : FR-106

---

## 7.5 Stagiaires

### EP-017 : Liste des stagiaires

- **Methode** : GET
- **URL** : /stagiaires
- **Objectif** : Lister les stagiaires avec pagination
- **Authentification** : JWT requis (role ADMINISTRATEUR ou RECEPTION)

**Reponse en cas de succes (200)** :

```json
{
  "success": true,
  "data": [
    {
      "id": 75,
      "nom": "Benali",
      "prenom": "Amir",
      "dateDebutStage": "2026-06-01",
      "dateFinStage": "2026-12-31",
      "qrCodeStatut": "ACTIF",
      "dateExpirationQR": "2026-12-31T23:59:59Z"
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalElements": 15,
    "totalPages": 1
  }
}
```

**User Stories** : US-050
**Exigences Fonctionnelles** : FR-110

---

### EP-018 : Creation d'un stagiaire

- **Methode** : POST
- **URL** : /stagiaires
- **Objectif** : Creer un compte stagiaire avec generation automatique du QR Code nominatif
- **Authentification** : JWT requis (role ADMINISTRATEUR ou RECEPTION)

**Corps de la requete** :

```json
{
  "nom": "Benali",
  "prenom": "Amir",
  "dateDebutStage": "2026-06-01",
  "dateFinStage": "2026-12-31"
}
```

**Regles de validation** :
- nom : obligatoire, 1-100 caracteres
- prenom : obligatoire, 1-100 caracteres
- dateDebutStage : obligatoire, format AAAA-MM-JJ
- dateFinStage : obligatoire, posterieure ou egale a dateDebutStage

**Reponse en cas de succes (201)** :

```json
{
  "success": true,
  "data": {
    "id": 76,
    "nom": "Benali",
    "prenom": "Amir",
    "dateDebutStage": "2026-06-01",
    "dateFinStage": "2026-12-31",
    "qrCode": {
      "id": 45,
      "code": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "dateExpiration": "2026-12-31T23:59:59Z",
      "type": "NOMINATIF"
    },
    "qrCodeImageBase64": "data:image/png;base64,iVBOR..."
  }
}
```

**Codes de statut** :
- 201 : Stagiaire cree avec QR Code
- 401 : JWT invalide
- 403 : Droits insuffisants
- 422 : Donnees invalides (dates incoherentes)

**Regles Metier** : BR-013, BR-016, BR-018, BR-025, BR-045
**User Stories** : US-057, US-077
**Exigences Fonctionnelles** : FR-107, FR-401, FR-610

---

### EP-019 : Modification d'un stagiaire

- **Methode** : PUT
- **URL** : /stagiaires/{id}
- **Objectif** : Modifier les informations d'un stagiaire (notamment les dates de stage)
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Corps de la requete** :

```json
{
  "nom": "Benali",
  "prenom": "Amir",
  "dateDebutStage": "2026-06-01",
  "dateFinStage": "2026-03-31"
}
```

**Codes de statut** :
- 200 : Modification reussie (QR Code mis a jour automatiquement)
- 404 : Stagiaire non trouve
- 422 : Donnees invalides

**Regles Metier** : BR-018
**User Stories** : US-058
**Exigences Fonctionnelles** : FR-108

---

### EP-020 : QR Code d'un stagiaire

- **Methode** : GET
- **URL** : /stagiaires/{id}/qr-code
- **Objectif** : Obtenir le QR Code actif d'un stagiaire
- **Authentification** : JWT requis (role ADMINISTRATEUR ou RECEPTION)

**Reponse en cas de succes (200)** :

```json
{
  "success": true,
  "data": {
    "qrCode": {
      "id": 45,
      "code": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "statut": "ACTIF",
      "dateExpiration": "2026-12-31T23:59:59Z",
      "type": "NOMINATIF"
    },
    "qrCodeImageBase64": "data:image/png;base64,iVBOR..."
  }
}
```

---

## 7.6 Visiteurs

### EP-021 : Liste des visiteurs

- **Methode** : GET
- **URL** : /visiteurs
- **Objectif** : Lister les visiteurs d'une journee
- **Authentification** : JWT requis (role ADMINISTRATEUR ou RECEPTION)

**Parametres requete** :

| Parametre | Type | Obligatoire | Description |
|-----------|------|-------------|-------------|
| date | date | Non | Date des visiteurs (defaut : aujourd'hui) |

**Reponse** : Structure similaire a EP-017.

**User Stories** : US-079
**Exigences Fonctionnelles** : FR-111

---

### EP-022 : Creation d'un visiteur

- **Methode** : POST
- **URL** : /visiteurs
- **Objectif** : Creer un compte visiteur avec generation automatique du QR Code temporaire
- **Authentification** : JWT requis (role ADMINISTRATEUR ou RECEPTION)

**Corps de la requete** :

```json
{
  "nom": "Bernard",
  "prenom": "Paul",
  "dateVisite": "2026-07-04"
}
```

**Regles de validation** :
- dateVisite : doit etre la date courante (par defaut) ou une date passee (pour administration)
- Verification anti-doublon : aucun visiteur actif avec le meme nom et prenom pour la meme date

**Reponse en cas de succes (201)** :

```json
{
  "success": true,
  "data": {
    "id": 120,
    "nom": "Bernard",
    "prenom": "Paul",
    "dateVisite": "2026-07-04",
    "qrCode": {
      "id": 46,
      "code": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
      "dateExpiration": "2026-07-04T23:59:59Z",
      "type": "TEMPORAIRE"
    },
    "qrCodeImageBase64": "data:image/png;base64,iVBOR..."
  }
}
```

**Regles Metier** : BR-019, BR-020, BR-022, BR-024, BR-025, BR-045
**User Stories** : US-059, US-079
**Exigences Fonctionnelles** : FR-109, FR-403, FR-611

---

## 7.7 QR Codes

### EP-023 : Revocation d'un QR Code

- **Methode** : PATCH
- **URL** : /qrcodes/{id}/revoquer
- **Objectif** : Revoquer manuellement un QR Code actif
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Reponse en cas de succes (200)** :

```json
{
  "success": true,
  "data": {
    "id": 45,
    "statut": "REVOQUE",
    "dateRevocation": "2026-07-04T15:30:00.000Z"
  }
}
```

**Regles Metier** : BR-028, BR-029
**User Stories** : US-025, US-026
**Exigences Fonctionnelles** : FR-409, FR-410, FR-612

---

### EP-024 : Verification d'un QR Code

- **Methode** : POST
- **URL** : /qrcodes/verifier
- **Objectif** : Verifier la validite d'un QR Code avant enregistrement d'un repas
- **Authentification** : Cle API tablette

**Corps de la requete** :

```json
{
  "qrCode": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

**Reponse** : Statut valide/invalide avec motif de rejet le cas echeant.

**Regles Metier** : BR-026, BR-027, BR-029
**User Stories** : US-067
**Exigences Fonctionnelles** : FR-406

---

## 7.8 Repas

### EP-025 : Enregistrement d'un repas

- **Methode** : POST
- **URL** : /repas
- **Objectif** : Enregistrer un repas valide par un utilisateur identifie
- **Authentification** : Cle API tablette (post-identification)

**Corps de la requete** :

```json
{
  "identificationId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "categorieRepasId": 2,
  "horodatage": "2026-07-04T12:45:00.000Z"
}
```

**Regles de validation** :
- identificationId : obligatoire, doit correspondre a une identification valide et non utilisee
- categorieRepasId : obligatoire, doit correspondre a une categorie existante
- horodatage : obligatoire, doit etre dans la plage 12h30-14h00 (BR-042)
- Verification de l'unicite du repas pour l'utilisateur et la date courante (BR-008, BR-014, BR-021)

**Reponse en cas de succes (201)** :

```json
{
  "success": true,
  "data": {
    "id": 1024,
    "utilisateur": {
      "id": 42,
      "nom": "Martin",
      "prenom": "Sophie"
    },
    "categorie": {
      "id": 2,
      "nom": "Pizza"
    },
    "modeIdentification": "RECONNAISSANCE_FACIALE",
    "date": "2026-07-04",
    "horodatage": "2026-07-04T12:45:00.000Z",
    "uuidTransaction": "c3d4e5f6-a7b8-9012-cdef-234567890123"
  }
}
```

**Reponse en cas de conflit (409)** :

```json
{
  "success": false,
  "error": {
    "code": "REP_001",
    "message": "Repas deja enregistre",
    "detail": "Un repas a deja ete enregistre pour cet utilisateur le 04/07/2026",
    "recommendation": "Un seul repas est autorise par jour"
  }
}
```

**Codes de statut** :
- 201 : Repas enregistre
- 400 : Identification invalide ou deja utilisee
- 401 : Cle API tablette invalide
- 409 : Conflit (repas deja enregistre ou hors plage horaire)
- 422 : Donnees invalides

**Regles Metier** : BR-008, BR-014, BR-021, BR-037 a BR-044, BR-082
**User Stories** : US-013 a US-020
**Exigences Fonctionnelles** : FR-501 a FR-510

---

### EP-026 : Liste des repas

- **Methode** : GET
- **URL** : /repas
- **Objectif** : Consulter la liste des repas enregistres avec filtres
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Parametres requete** :

| Parametre | Type | Obligatoire | Description |
|-----------|------|-------------|-------------|
| page | integer | Non | Page courante |
| pageSize | integer | Non | Nombre par page |
| dateDebut | date | Non | Debut de periode |
| dateFin | date | Non | Fin de periode |
| categorieId | integer | Non | Filtre par categorie |
| typeUtilisateur | enum | Non | Filtre par type (EMPLOYE, STAGIAIRE, VISITEUR) |
| modeIdentificationId | integer | Non | Filtre par mode d'identification |

**Reponse** : Liste paginee des enregistrements de repas.

**User Stories** : US-036, US-069
**Exigences Fonctionnelles** : FR-801, FR-802

---

## 7.9 Categories Repas

### EP-027 : Liste des categories de repas

- **Methode** : GET
- **URL** : /categories-repas
- **Objectif** : Obtenir la liste des categories de repas disponibles
- **Authentification** : Cle API tablette (par la tablette) ou JWT (interface admin)

**Reponse (200)** :

```json
{
  "success": true,
  "data": [
    { "id": 1, "nom": "Plat", "codeInterne": "PLAT" },
    { "id": 2, "nom": "Pizza", "codeInterne": "PIZZA" },
    { "id": 3, "nom": "Sandwich", "codeInterne": "SANDWICH" }
  ]
}
```

**Regles Metier** : BR-037, BR-044
**User Stories** : US-013
**Exigences Fonctionnelles** : FR-501

---

## 7.10 Rapports

### EP-028 : Liste des rapports generes

- **Methode** : GET
- **URL** : /rapports
- **Objectif** : Consulter la liste des rapports generes
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Parametres requete** :

| Parametre | Type | Obligatoire | Description |
|-----------|------|-------------|-------------|
| type | enum | Non | Filtre par type (JOURNALIER, HEBDOMADAIRE, MENSUEL) |
| dateDebut | date | Non | Debut de periode de generation |
| dateFin | date | Non | Fin de periode de generation |

**Reponse (200)** :

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "type": "JOURNALIER",
      "dateDebutPeriode": "2026-07-04",
      "dateFinPeriode": "2026-07-04",
      "dateGeneration": "2026-07-04T14:15:00.000Z",
      "statut": "ENVOYE"
    }
  ],
  "pagination": { "page": 1, "pageSize": 20, "totalElements": 15, "totalPages": 1 }
}
```

---

### EP-029 : Telechargement d'un rapport

- **Methode** : GET
- **URL** : /rapports/{id}/telecharger
- **Objectif** : Telecharger le fichier PDF d'un rapport genere
- **Authentification** : JWT requis (role ADMINISTRATEUR ou RESPONSABLE_RESTAURANT)
- **Reponse** : Fichier PDF (Content-Type: application/pdf)

**Codes de statut** :
- 200 : Fichier PDF retourne
- 404 : Rapport non trouve ou fichier manquant

---

### EP-030 : Generation manuelle d'un rapport

- **Methode** : POST
- **URL** : /rapports/generer
- **Objectif** : Declencher manuellement la generation d'un rapport
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Corps de la requete** :

```json
{
  "type": "JOURNALIER",
  "date": "2026-07-04"
}
```

**Regles Metier** : BR-053, BR-054, BR-055
**User Stories** : US-031, US-032, US-061
**Exigences Fonctionnelles** : FR-701, FR-702, FR-703

---

### EP-031 : Gestion des destinataires email

- **Methode** : GET /rapports/destinataires
- **Objectif** : Lister les destinataires email des rapports
- **Authentification** : JWT requis (role ADMINISTRATEUR)

- **Methode** : POST /rapports/destinataires
- **Objectif** : Ajouter un destinataire email
- **Corps** : { "email": "responsable@csm-gias.com" }

- **Methode** : DELETE /rapports/destinataires/{id}
- **Objectif** : Supprimer un destinataire email

**Regles Metier** : BR-050, BR-056
**User Stories** : US-030, US-033
**Exigences Fonctionnelles** : FR-607, FR-704

---

## 7.11 Statistiques

### EP-032 : Total des repas sur une periode

- **Methode** : GET
- **URL** : /statistiques/total-repas
- **Objectif** : Obtenir le nombre total de repas enregistres sur une periode
- **Authentification** : JWT requis (role ADMINISTRATEUR ou RESPONSABLE_RESTAURANT)

**Parametres requete** :

| Parametre | Type | Obligatoire | Description |
|-----------|------|-------------|-------------|
| dateDebut | date | Oui | Debut de la periode |
| dateFin | date | Oui | Fin de la periode |

**Reponse (200)** :

```json
{
  "success": true,
  "data": {
    "totalRepas": 1250,
    "periode": {
      "dateDebut": "2026-07-01",
      "dateFin": "2026-07-31"
    }
  }
}
```

**Regles Metier** : BR-060
**User Stories** : US-036
**Exigences Fonctionnelles** : FR-801

---

### EP-033 : Repartition par categorie

- **Methode** : GET
- **URL** : /statistiques/repartition-categorie
- **Objectif** : Obtenir la repartition des repas par categorie (Plat/Pizza/Sandwich)
- **Authentification** : JWT requis

**Reponse (200)** :

```json
{
  "success": true,
  "data": {
    "categories": [
      { "categorie": "Plat", "total": 520, "pourcentage": 41.6 },
      { "categorie": "Pizza", "total": 380, "pourcentage": 30.4 },
      { "categorie": "Sandwich", "total": 350, "pourcentage": 28.0 }
    ],
    "total": 1250
  }
}
```

**Regles Metier** : BR-061
**User Stories** : US-069
**Exigences Fonctionnelles** : FR-802

---

### EP-034 : Repartition par profil utilisateur

- **Methode** : GET
- **URL** : /statistiques/repartition-profil
- **Objectif** : Obtenir la repartition des repas par type d'utilisateur
- **Authentification** : JWT requis

**Reponse (200)** :

```json
{
  "success": true,
  "data": {
    "profils": [
      { "type": "EMPLOYE", "total": 1100, "pourcentage": 88.0 },
      { "type": "STAGIAIRE", "total": 100, "pourcentage": 8.0 },
      { "type": "VISITEUR", "total": 50, "pourcentage": 4.0 }
    ],
    "total": 1250
  }
}
```

**Regles Metier** : BR-063
**User Stories** : US-037
**Exigences Fonctionnelles** : FR-804

---

### EP-035 : Frequentaton horaire

- **Methode** : GET
- **URL** : /statistiques/frequentation-horaire
- **Objectif** : Obtenir la frequentation par tranche de 15 minutes
- **Authentification** : JWT requis

**Parametres requete** : date (optionnelle, defaut : aujourd'hui)

**Reponse (200)** :

```json
{
  "success": true,
  "data": [
    { "tranche": "12:30", "total": 15 },
    { "tranche": "12:45", "total": 42 },
    { "tranche": "13:00", "total": 78 },
    { "tranche": "13:15", "total": 55 },
    { "tranche": "13:30", "total": 30 },
    { "tranche": "13:45", "total": 12 }
  ]
}
```

**Regles Metier** : BR-062
**User Stories** : US-038
**Exigences Fonctionnelles** : FR-803

---

### EP-036 : Export CSV des statistiques

- **Methode** : GET
- **URL** : /statistiques/export-csv
- **Objectif** : Exporter les statistiques au format CSV
- **Authentification** : JWT requis (role ADMINISTRATEUR)
- **Reponse** : Fichier CSV (Content-Type: text/csv)

**User Stories** : US-060
**Exigences Fonctionnelles** : FR-806

---

## 7.12 Configuration

### EP-037 : Liste des configurations

- **Methode** : GET
- **URL** : /configuration
- **Objectif** : Obtenir la liste des parametres configurables
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Reponse (200)** :

```json
{
  "success": true,
  "data": [
    {
      "cle": "HEURE_OUVERTURE",
      "valeur": "12:30",
      "type": "TIME",
      "description": "Heure d'ouverture du restaurant"
    },
    {
      "cle": "HEURE_FERMETURE",
      "valeur": "14:00",
      "type": "TIME",
      "description": "Heure de fermeture du restaurant"
    },
    {
      "cle": "DUREE_CONSERVATION_AUDIT",
      "valeur": "1095",
      "type": "INTEGER",
      "description": "Duree de conservation du journal d'audit (en jours)"
    }
  ]
}
```

---

### EP-038 : Mise a jour d'une configuration

- **Methode** : PUT
- **URL** : /configuration/{cle}
- **Objectif** : Mettre a jour la valeur d'une configuration
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Corps de la requete** :

```json
{
  "valeur": "12:00"
}
```

**User Stories** : US-066
**Exigences Fonctionnelles** : FR-507

---

## 7.13 Audit

### EP-039 : Consultation du journal d'audit

- **Methode** : GET
- **URL** : /audit
- **Objectif** : Consulter les entrees du journal d'audit
- **Authentification** : JWT requis (role ADMINISTRATEUR)

**Parametres requete** :

| Parametre | Type | Obligatoire | Description |
|-----------|------|-------------|-------------|
| page | integer | Non | Page courante |
| pageSize | integer | Non | Nombre par page (defaut : 20) |
| dateDebut | datetime | Non | Debut de periode |
| dateFin | datetime | Non | Fin de periode |
| typeAction | string | Non | Filtre par type d'action |
| utilisateurId | integer | Non | Filtre par auteur |

**Reponse (200)** :

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "horodatage": "2026-07-04T15:30:00.000Z",
      "utilisateur": { "id": 1, "nom": "Dupont", "prenom": "Jean" },
      "typeAction": "CREATION_EMPLOYE",
      "entiteConcernee": "employe",
      "idEntite": 351,
      "detailsApres": { "nom": "Durand", "prenom": "Pierre", "statut": "ACTIF" }
    }
  ],
  "pagination": { "page": 1, "pageSize": 20, "totalElements": 450, "totalPages": 23 }
}
```

**Regles Metier** : BR-080, BR-081
**User Stories** : US-044
**Exigences Fonctionnelles** : FR-1006

---

## 7.14 Tablette

### EP-040 : Statut de la tablette

- **Methode** : GET
- **URL** : /tablette/statut
- **Objectif** : Verifier le statut de la tablette et sa connexion au backend
- **Authentification** : Cle API tablette

**Reponse (200)** :

```json
{
  "success": true,
  "data": {
    "statut": "CONNECTE",
    "versionApplication": "1.0.0",
    "derniereSynchro": "2026-07-04T14:00:00.000Z",
    "heureServeur": "2026-07-04T14:05:00.000Z",
    "decalageMs": 150
  }
}
```

### EP-041 : Ping (Health Check)

- **Methode** : POST
- **URL** : /tablette/ping
- **Objectif** : Envoyer un signal de vie de la tablette
- **Authentification** : Cle API tablette
- **Reponse** : 200 OK avec horodatage serveur

---

# 8. Modele de Reponse Commun

## 8.1 Structure Standard

Toutes les reponses de l'API suivent une structure uniforme :

```json
{
  "success": true|false,
  "data": { ... },
  "error": { ... },
  "pagination": { ... },
  "meta": {
    "requestId": "uuid-de-correlation",
    "timestamp": "2026-07-04T14:00:00.000Z",
    "version": "1.0"
  }
}
```

## 8.2 Reponse de Succes

```json
{
  "success": true,
  "data": { ... }
}
```

## 8.3 Reponse avec Pagination

```json
{
  "success": true,
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalElements": 350,
    "totalPages": 18
  }
}
```

## 8.4 Reponse d'Erreur de Validation

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_001",
    "message": "Donnees de requete invalides",
    "detail": "Le champ 'nom' est obligatoire",
    "field": "nom",
    "recommendation": "Veuillez fournir une valeur pour le champ 'nom'"
  }
}
```

## 8.5 Reponse d'Erreur Metier

```json
{
  "success": false,
  "error": {
    "code": "REP_001",
    "message": "Repas deja enregistre",
    "detail": "Un repas a deja ete enregistre pour cet utilisateur le 04/07/2026",
    "recommendation": "Un seul repas est autorise par jour"
  }
}
```

## 8.6 Reponse d'Erreur d'Authentification

```json
{
  "success": false,
  "error": {
    "code": "AUTH_001",
    "message": "Identifiants invalides",
    "detail": "L'email ou le mot de passe fourni est incorrect",
    "recommendation": "Veuillez verifier vos identifiants et reessayer"
  }
}
```

---

# 9. Regles de Validation

## 9.1 Validation des Identifiants

| Champ | Regle | Code d'Erreur |
|-------|-------|---------------|
| id (path) | BIGINT, > 0 | PARAM_001 : Identifiant invalide |
| employe_id | Doit exister dans la table employes | PARAM_002 : Employe non trouve |
| administrateur_id | Doit exister dans la table administrateurs | PARAM_003 : Administrateur non trouve |

## 9.2 Validation des Chaines

| Champ | Regle | Code d'Erreur |
|-------|-------|---------------|
| nom | 1-100 caracteres, lettres + tirets + espaces | VALIDATION_010 : Nom invalide |
| prenom | 1-100 caracteres, lettres + tirets + espaces | VALIDATION_011 : Prenom invalide |
| email | Format email valide, max 255 caracteres | VALIDATION_020 : Email invalide |
| motDePasse | Min 8 caracteres, max 128 | VALIDATION_030 : Mot de passe invalide |

## 9.3 Validation des QR Codes

| Regle | Code d'Erreur |
|-------|---------------|
| Le code QR doit etre un UUID v4 valide | QR_001 : Format de QR Code invalide |
| Le QR Code ne doit pas etre expire | QR_002 : QR Code expire |
| Le QR Code ne doit pas etre revoque | QR_003 : QR Code revoque |
| Le QR Code doit exister dans la base | QR_004 : QR Code inconnu |

## 9.4 Validation des Repas

| Regle | Code d'Erreur |
|-------|---------------|
| Un seul repas par utilisateur par jour | REP_001 : Repas deja enregistre |
| Enregistrement autorise uniquement 12h30-14h00 | REP_002 : Restaurant ferme |
| Categorie doit exister | REP_003 : Categorie invalide |
| Utilisateur doit etre actif | REP_004 : Compte desactive |

## 9.5 Validation des Dates

| Regle | Code d'Erreur |
|-------|---------------|
| Date au format ISO 8601 (AAAA-MM-JJ) | DATE_001 : Format de date invalide |
| dateDebut <= dateFin | DATE_002 : Periode invalide |
| dateFinStage >= dateDebutStage | DATE_003 : Dates de stage incoherentes |
| dateVisite ne peut pas etre dans le futur | DATE_004 : Date de visite future non autorisee |

---

# 10. Catalogue des Erreurs

| Code | Statut HTTP | Message | Cause | Action Recommandee |
|------|-------------|---------|-------|-------------------|
| AUTH_001 | 401 | Identifiants invalides | Email ou mot de passe incorrect | Verifier les identifiants |
| AUTH_002 | 401 | Compte desactive | Le compte a ete desactive par l'administration | Contacter l'administration |
| AUTH_003 | 429 | Trop de tentatives | 5 tentatives echouees consecutives | Attendre 15 minutes avant de reessayer |
| AUTH_004 | 401 | Jeton expire | Le jeton JWT a depasse sa duree de validite | Utiliser le refresh token |
| AUTH_005 | 403 | Droits insuffisants | Le role ne permet pas cette action | Contacter un administrateur |
| AUTH_006 | 401 | Cle API invalide | La cle API de la tablette est incorrecte | Verifier la configuration de la tablette |
| IDF_001 | 200 | Visage non reconnu | Aucune correspondance avec les empreintes | Reessayer ou contacter l'administration |
| IDF_002 | 400 | Qualite d'image insuffisante | L'image capturee est trop sombre ou floue | Se placer dans une zone mieux eclairee |
| IDF_003 | 200 | Employe non enrole | L'employe n'a pas encore ete enrole | Contacter l'administration pour l'enrolement |
| QR_001 | 422 | Format QR invalide | Le code ne correspond pas au format UUID | Verifier le QR Code scane |
| QR_002 | 200 | QR Code expire | Le QR Code a depasse sa date d'expiration | Contacter l'accueil pour un nouveau QR |
| QR_003 | 200 | QR Code revoque | Le QR Code a ete revoque par l'administration | Contacter l'administration |
| QR_004 | 404 | QR Code inconnu | Aucun QR Code trouve avec ce code | Verifier le QR Code |
| QR_005 | 409 | Doublon visiteur | Un QR Code actif existe deja pour ce visiteur aujourd'hui | Utiliser le QR Code existant |
| REP_001 | 409 | Repas deja enregistre | L'utilisateur a deja valide un repas aujourd'hui | Un seul repas autorise par jour |
| REP_002 | 400 | Restaurant ferme | Hors de la plage horaire 12h30-14h00 | Revenir pendant les heures d'ouverture |
| REP_003 | 422 | Categorie invalide | La categorie selectionnee n'existe pas | Selectionner une categorie valide |
| REP_004 | 403 | Compte desactive | Le compte utilisateur est desactive | Contacter l'administration |
| REP_005 | 400 | Identification deja utilisee | Cette identification a deja servi a un repas | Une nouvelle identification est necessaire |
| VALIDATION_001 | 422 | Donnees requete invalides | Un ou plusieurs champs obligatoires sont manquants ou invalides | Corriger les champs indiques |
| VALIDATION_010 | 422 | Nom invalide | Le nom contient des caracteres non autorises ou depasse 100 caracteres | Utiliser uniquement des lettres et tirets |
| VALIDATION_020 | 422 | Email invalide | Le format de l'email est incorrect | Verifier le format de l'email |
| PARAM_001 | 404 | Ressource non trouvee | L'identifiant fourni ne correspond a aucune ressource | Verifier l'identifiant |
| SERVER_001 | 500 | Erreur interne | Une erreur inattendue est survenue | Reessayer ulterieurement |
| SERVER_002 | 503 | Service indisponible | Le service de reconnaissance faciale est temporairement indisponible | Reessayer dans quelques instants |
| CONFIG_001 | 403 | Configuration non modifiable | Cette configuration ne peut pas etre modifiee via l'API | Contacter l'equipe de developpement |

---

# 11. Pagination

## 11.1 Modele de Pagination

Tous les endpoints retournant des listes utilisent le modele de pagination suivant :

**Parametres de requete** :
- page : Numero de la page (1-indexed, defaut : 1)
- pageSize : Nombre d'elements par page (defaut : 20, maximum : 100)

**Reponse** :
```json
"pagination": {
  "page": 1,
  "pageSize": 20,
  "totalElements": 350,
  "totalPages": 18
}
```

## 11.2 Tri

Le tri par defaut est defini par ressource. Le parametre `sortBy` permet de specifier le champ de tri. Le parametre `sortOrder` accepte `asc` ou `desc`.

## 11.3 Filtrage

Les filtres sont passes comme parametres de requete. Les operateurs de filtrage avances :
- Egalite exacte : `?statut=ACTIF`
- Recherche partielle (texte) : `?nom=Dur` (recherche les noms contenant "Dur")
- Intervalle de dates : `?dateDebut=2026-07-01&dateFin=2026-07-31`

---

# 12. API des Rapports

## 12.1 Generation Automatique

La generation des rapports est declenchee par des jobs planifies cote serveur, conformement aux regles metier :
- **Rapport journalier** : chaque jour a 14h15 (apres la fermeture du restaurant)
- **Rapport hebdomadaire** : chaque vendredi a 18h00
- **Rapport mensuel** : dernier jour du mois a 23h59

## 12.2 Contenu des Rapports

Les rapports contiennent :
- Tableaux structures des consommations par categorie, par profil et par plage horaire
- Diagramme circulaire (camembert) de repartition Plat/Pizza/Sandwich
- Courbe d'evolution de la frequentation (rapports hebdo et mensuel)
- Histogramme de frequentation horaire par tranche de 15 minutes
- Langue : francaise (100%)

## 12.3 Distribution Email

Apres generation, les rapports sont envoyes automatiquement aux destinataires configures (EP-031). La distribution est asynchrone et ne bloque pas la generation.

---

# 13. Securite

## 13.1 JWT

- Algorithme : HS256
- Cle secrete : generee de maniere securisee, stockee dans un coffre (vault)
- Claims minimaux : sub, email, role, exp, iat, jti
- Validation : signature, expiration, nonce (jti) contre le rejeu

## 13.2 Autorisation

Le controle d'acces est base sur le role (RBAC) :

| Role | Acces |
|------|-------|
| ADMINISTRATEUR | Tous les endpoints |
| RECEPTION | Stagiaires, Visiteurs, QR Codes (lecture/creation) |
| SYSTEME (tablette) | Identification, Repas, Categories |
| RESPONSABLE_RESTAURANT | Rapports, Statistiques (lecture seule) |

## 13.3 Validation des Entrees

Toutes les entrees utilisateur sont validees a deux niveaux :
1. Schema level : JSON Schema / Pydantic (format, types, contraintes)
2. Business level : Regles metier (unicite, coherence temporelle, droits)

## 13.4 Rate Limiting

- Endpoints d'authentification : 5 tentatives par minute par adresse IP
- Endpoints d'identification : 30 requetes par minute par tablette
- Endpoints generaux : 100 requetes par minute par utilisateur

## 13.5 Protection Biometrique

- Les vecteurs biometriques ne sont jamais transmis en clair (HTTPS obligatoire)
- Le traitement d'image est effectue cote serveur, le client envoie l'image brute encodee en Base64
- Aucune donnee biometrique n'est conservee dans les logs ou les reponses API

---

# 14. Versioning de l'API

## 14.1 Version 1.0 (Courante)

L'API v1 couvre l'integralite des fonctionnalites de la Release 1.0 du projet : identification, enregistrement des repas, gestion des utilisateurs, rapports, statistiques, audit et configuration.

## 14.2 Version 2.0 (Future)

La version v2 sera introduite pour le Web Dashboard (Release 2.0) et pourra inclure :
- Nouveaux endpoints pour la gestion multi-tablettes
- Endpoints d'administration avances
- Analytics enrichis

## 14.3 Strategie de Depreciation

- Les versions sont annoncees 6 mois avant depreciation
- Un en-tete de warning (Sunset) est ajoute aux reponses des endpoints concernes
- Les anciennes versions restent disponibles pendant 12 mois apres l'annonce
- La documentation de chaque version est conservee et accessible

---

# 15. Exemples de Flux API

## 15.1 Enregistrement d'un repas employe

1. La tablette capture le visage de l'employe
2. **POST /identification/faciale** : Envoi de l'image au backend
3. Le backend compare le visage avec les empreintes stockees et identifie l'employe
4. Reponse : utilisateur identifie avec un identifiant d'identification temporaire
5. La tablette affiche les categories de repas (recuperees via **GET /categories-repas**)
6. L'employe selectionne une categorie et valide
7. **POST /repas** : Envoi de l'identifiant d'identification et de la categorie choisie
8. Le backend verifie l'unicite du repas pour le jour, la validite horaire, le statut du compte
9. Enregistrement du repas en base de donnees
10. Reponse : confirmation avec UUID de transaction
11. La tablette affiche le message de confirmation (recupere via la configuration ou les notifications)

## 15.2 Enregistrement d'un repas stagiaire/visiteur

1. Le stagiaire/visiteur presente son QR Code devant la camera de la tablette
2. **POST /identification/qr-code** : Envoi du code QR au backend
3. Le backend verifie la validite du QR Code (non expire, non revoque)
4. Identification du stagiaire/visiteur
5. Meme flux que l'employe a partir de l'etape 5

## 15.3 Creation d'un visiteur par la Reception

1. La Reception s'authentifie : **POST /auth/login**
2. Obtention du jeton JWT
3. **POST /visiteurs** avec les donnees du visiteur (nom, prenom)
4. Le backend verifie l'absence de doublon pour le meme jour
5. Creation du compte visiteur et generation du QR Code temporaire
6. Reponse : QR Code genere (code + image en Base64)
7. La Reception imprime ou montre le QR Code au visiteur
8. **POST /auth/logout** : Deconnexion de la Reception

## 15.4 Enrolement biometrique

1. L'administrateur s'authentifie : **POST /auth/login**
2. **GET /employes** avec filtre "nom" pour trouver l'employe a enroler
3. L'employe se place devant la camera de la tablette
4. **POST /enrolement** : Envoi de l'image et de l'identifiant employe
5. Le backend valide la qualite de l'image, chiffre le vecteur facial, stocke l'empreinte
6. Reponse : confirmation de l'enrolement
7. Journalisation dans l'audit

## 15.5 Generation automatique du rapport journalier

1. A 14h15, le job planifie se declenche
2. Le backend interroge les donnees de repas pour la journee
3. Calcul des statistiques (total, repartition, frequentation)
4. Generation du PDF avec tableaux et graphiques
5. Insertion dans la table `rapport` avec statut GENERE
6. Recuperation de la liste des destinataires email
7. Envoi du PDF par email a chaque destinataire
8. Mise a jour du statut du rapport : ENVOYE
9. En cas d'echec : statut ERREUR, nouvelle tentative 15 minutes plus tard

---

# 16. Considerations de Performance

## 16.1 Objectifs de Temps de Reponse

| Endpoint | Objectif | Seuil d'Alerte |
|----------|----------|----------------|
| POST /identification/faciale | < 3 secondes | > 5 secondes |
| POST /identification/qr-code | < 1 seconde | > 2 secondes |
| POST /repas | < 1 seconde | > 2 secondes |
| GET /employes (liste paginee) | < 500 ms | > 1 seconde |
| GET /statistiques/* | < 2 secondes | > 5 secondes |
| GET /auth/login | < 500 ms | > 1 seconde |

## 16.2 Optimisation des Payloads

- Les listes sont toujours paginees (pageSize max 100)
- Les images biometriques sont compressees avant envoi (JPEG qualite 85%)
- Les QR Codes sont retournes en Base64 pour un affichage immediat
- Les donnees sensibles ne sont pas incluses dans les reponses par defaut

## 16.3 Compression

- Tous les echanges sont compresses via gzip (Content-Encoding: gzip)
- Activation cote client : Accept-Encoding: gzip
- Les images et fichiers PDF sont deja compresses, pas de double compression

---

# 17. Matrice de Tracabilite

| BR | FR | US | Ressource API | Endpoints |
|-----|-----|-----|---------------|-----------|
| BR-001, BR-004 | FR-201, FR-304 | US-001 | Identification | EP-004 |
| BR-002, BR-004 | FR-202 | US-002 | Identification | EP-005 |
| BR-003, BR-004 | FR-203 | US-003 | Identification | EP-005 |
| BR-005, BR-034 | FR-210, FR-306 | US-041 | Identification | EP-004 |
| BR-006 | FR-207 | US-011 | Identification | EP-004 (validation applicative) |
| BR-007, BR-031 | FR-301, FR-606 | US-008, US-076 | Enrolement | EP-006 |
| BR-008, BR-014, BR-021 | FR-508, FR-509 | US-020 | Repas | EP-025 |
| BR-010 | FR-103, FR-307 | US-048, US-071 | Employes | EP-013 |
| BR-011 | FR-101, FR-102 | US-047, US-055 | Employes | EP-010, EP-012 |
| BR-012, BR-036 | FR-105, FR-308 | US-049, US-074 | Employes | EP-015 |
| BR-013, BR-016, BR-018 | FR-107, FR-401 | US-021, US-057, US-077 | Stagiaires | EP-018 |
| BR-019, BR-020, BR-022 | FR-109, FR-403 | US-023, US-059, US-079 | Visiteurs | EP-022 |
| BR-025 | FR-401, FR-411 | US-021 | QR Codes | EP-018, EP-022 |
| BR-026, BR-027, BR-029 | FR-204, FR-406 | US-004, US-067 | QR Codes | EP-005, EP-024 |
| BR-028, BR-029 | FR-409, FR-612 | US-025, US-026 | QR Codes | EP-023 |
| BR-032 | FR-303 | US-010 | Enrolement | EP-008 |
| BR-033 | FR-305 | US-012 | Identification | EP-004 (performance) |
| BR-035, BR-071 | FR-309 | US-009 | Enrolement | EP-006 (chiffrement) |
| BR-037, BR-044 | FR-501 | US-013 | Categories Repas | EP-027 |
| BR-038, BR-039, BR-040 | FR-502, FR-503, FR-504 | US-014, US-015, US-016 | Repas | EP-025 |
| BR-041, BR-082 | FR-505, FR-506 | US-017, US-018 | Repas | EP-025 |
| BR-042 | FR-507 | US-019, US-066 | Repas, Configuration | EP-025, EP-038 |
| BR-045 | FR-107, FR-109, FR-610, FR-611 | US-057, US-059, US-077, US-079 | Stagiaires, Visiteurs | EP-018, EP-022 |
| BR-046 | FR-101-106, FR-110, FR-111 | US-047-056 | Employes, Stagiaires | EP-009 a EP-020 |
| BR-047 | FR-301, FR-606 | US-008, US-076 | Enrolement | EP-006 |
| BR-048, BR-049 | FR-603, FR-604, FR-605 | US-028, US-029, US-078 | Administrateurs | Gestion admins |
| BR-050, BR-056 | FR-607, FR-704 | US-030, US-033 | Rapports | EP-031 |
| BR-053, BR-054, BR-055 | FR-701, FR-702, FR-703 | US-031, US-032, US-061 | Rapports | EP-028, EP-030 |
| BR-057, BR-058 | FR-706-711 | US-034, US-035, US-062-064 | Rapports | Generation |
| BR-060 | FR-801 | US-036 | Statistiques | EP-032 |
| BR-061 | FR-802 | US-069 | Statistiques | EP-033 |
| BR-062 | FR-803 | US-038 | Statistiques | EP-035 |
| BR-063 | FR-804 | US-037 | Statistiques | EP-034 |
| BR-065, BR-066, BR-067 | FR-901-907 | US-039, US-040, US-041 | Notifications | Configuration |
| BR-069, BR-070 | FR-208, FR-209 | US-006, US-007 | Authentification | EP-001, EP-002, EP-003 |
| BR-075, BR-077 | N/A | US-045, US-070 | Tablette | EP-040, EP-041 |
| BR-080, BR-081, BR-083 | FR-1001-1006 | US-042, US-043, US-044, US-072 | Audit | EP-039 |
| BR-084 | FR-1007 | US-073, US-080 | Audit, Configuration | EP-037, EP-039 |
| BR-022, BR-024 | FR-405 | US-068 | Visiteurs | EP-022 |
| BR-023 | FR-404 | US-024 | QR Codes | EP-005 |

---

# 18. Risques

## 18.1 Risques de Securite

| Risque | Impact | Probabilite | Mitigation |
|--------|--------|-------------|------------|
| Interception JWT | Eleve | Faible | HTTPS obligatoire, expiration courte (30 min), refresh token |
| Rejeu de requete | Moyen | Faible | Nonce (jti) dans JWT, timestamp avec tolerance dans les requetes tablette |
| Brute force authentification | Eleve | Moyenne | Rate limiting (5 tentatives/min), verrouillage temporaire apres 5 echecs |
| Injection SQL | Critique | Tres faible | ORM (SQLAlchemy) avec parametres, pas de concatenation de requetes |

## 18.2 Risques de Performance

| Risque | Impact | Probabilite | Mitigation |
|--------|--------|-------------|------------|
| Pic de frequentation a 12h30 | Moyen | Haute | Index optimises, mise en cache des categories, connexion pool |
| Generation de rapport pendant le service | Faible | Moyenne | Job planifie apres le service (14h15), execution asynchrone |
| Transfert d'image volumineuse | Moyen | Haute | Compression JPEG, limite de taille (5 MB), timeout adapte |

## 18.3 Risques d'Integration

| Risque | Impact | Probabilite | Mitigation |
|--------|--------|-------------|------------|
| Perte de connexion tablette-serveur | Eleve | Faible | Timeout avec message utilisateur, reessai automatique (PBI-034) |
| Desynchronisation horloge tablette | Moyen | Faible | Verification du timestamp avec tolerance, utilisation NTP |
| Version API obsolete sur la tablette | Moyen | Faible | Verification de version au demarrage, mise a jour forcee si necessaire |

---

# 19. Checklist de Validation de l'API

| Critere | Verification | Statut |
|---------|-------------|--------|
| Conforme aux principes REST | Ressources identifiees par URL, methodes HTTP appropriees | CONFORME |
| Nommage coherent des endpoints | snake_case, pluriel, anglais | CONFORME |
| Securisee par conception | JWT, cle API, validation des entrees, rate limiting | CONFORME |
| Traitable aux regles metier | 100% des BR, FR et US couverts (Section 17) | CONFORME |
| Pagination standardisee | Modele uniforme sur tous les endpoints de liste | CONFORME |
| Gestion d'erreurs uniforme | Structure JSON standardisee, codes d'erreur documentes | CONFORME |
| Versionning explicite | Prefixe /api/v1/, strategie de depreciation documentee | CONFORME |
| Prete pour implementation FastAPI | Specifications claires, DTO detailles, validation definie | CONFORME |
| Prete pour implementation React Native | Formats JSON, exemples complets, flux documentes | CONFORME |
| Documentation des reponses | Codes de statut, corps, cas d'erreur pour chaque endpoint | CONFORME |

---

# 20. Conclusion

La specification de l'API REST presentee dans ce document constitue le contrat formel de developpement entre l'equipe backend (FastAPI) et l'equipe mobile (React Native) pour le projet CSM-GIAS Resto+.

**Couverture fonctionnelle** : Les 58 endpoints documentes couvrent l'integralite des fonctionnalites de la Release 1.0, depuis l'identification des utilisateurs jusqu'a la generation des rapports, en passant par la gestion complete du cycle de vie des utilisateurs, des QR Codes et des repas.

**Qualite architecturale** : La specification respecte les principes REST, les conventions HTTP standard et les meilleures pratiques de securite d'entreprise. La structure uniforme des reponses, la pagination standardisee et le catalogue d'erreurs complet permettent un developpement previsible et efficace.

**Tracabilite** : La matrice de tracabilite demontre que l'ensemble des 84 regles metier, 97 exigences fonctionnelles et 80 User Stories sont couverts par les ressources et endpoints definis. Aucune fonctionnalite documentee n'est orpheline.

**Gouvernance** : Le versionning explicite, la strategie de depreciation et les regles de validation formelles assurent la maintenabilite et l'evolutivite de l'API sur le long terme.

Cette specification est directement exploitable par les equipes de developpement pour :
- L'implementation du backend FastAPI avec validation Pydantic
- La generation de la documentation Swagger/OpenAPI automatique
- L'implementation du client API cote React Native
- La preparation des tests d'integration et de validation

Le Product Owner et l'Architecte API valideront les ecarts eventuels lors des revues de Sprint, conformement a la methodologie Agile du projet.
