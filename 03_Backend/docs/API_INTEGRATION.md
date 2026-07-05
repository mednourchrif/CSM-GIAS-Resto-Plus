# API d'Intégration — CSM GIAS Resto+

## Sommaire

1. [Informations générales](#1-informations-générales)
2. [Authentification](#2-authentification)
3. [Enveloppe des réponses](#3-enveloppe-des-réponses)
4. [Codes statut HTTP](#4-codes-statut-http)
5. [Gestion des erreurs](#5-gestion-des-erreurs)
6. [Pagination](#6-pagination)
7. [Diagrammes de séquence](#7-diagrammes-de-séquence)
   - [Authentification](#71-authentification)
   - [Enregistrement d'un repas](#72-enregistrement-dun-repas-par-qr)
   - [Génération d'un QR](#73-génération-dun-qr)
   - [Identification faciale](#74-identification-faciale)
8. [Référence des endpoints](#8-référence-des-endpoints)

---

## 1. Informations générales

| Propriété         | Valeur                                  |
|-------------------|-----------------------------------------|
| **Base URL**      | `https://<host>/api/v1`                 |
| **Format**        | JSON (RFC 7159)                         |
| **Encodage**      | UTF-8                                   |
| **Auth**          | Bearer JWT                              |

Toutes les dates sont au format ISO 8601 (`2024-12-25T12:30:00Z`).  
Les UUID sont au format standard `f47ac10b-58cc-4372-a567-0e02b2c3d479`.

---

## 2. Authentification

### 2.1 Obtenir un token

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "admin@csm-gias.resto",
  "mot_de_passe": "********"
}
```

**Réponse :**

```json
{
  "success": true,
  "data": {
    "token": {
      "access_token": "eyJhbGciOiJIUzI1NiIs...",
      "token_type": "bearer",
      "expires_in": 86400
    },
    "admin": {
      "id": 1,
      "uuid": "abc123...",
      "nom": "Admin",
      "prenom": "Super",
      "email": "admin@csm-gias.resto",
      "role": "super-admin",
      "derniere_connexion": null
    }
  }
}
```

### 2.2 Utiliser le token

Toutes les requêtes protégées doivent inclure l'en-tête :

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

### 2.3 Rôles

| Rôle                  | Accès                                              |
|------------------------|------------------------------------------------------|
| `admin`               | Tous les endpoints                                  |
| `reception`           | Meal registration, face verify/identify, visitor QR |
| Non authentifié       | `/auth/login`, `/health`, `/ready` seulement         |

---

## 3. Enveloppe des réponses

### 3.1 Succès simple

```json
{
  "success": true,
  "data": { ... },
  "message": null
}
```

### 3.2 Succès paginé

```json
{
  "success": true,
  "data": [ ... ],
  "total": 150,
  "page": 1,
  "page_size": 20,
  "total_pages": 8
}
```

### 3.3 Erreur

```json
{
  "success": false,
  "error_code": "NOT_FOUND",
  "message": "Employee with UUID ... not found",
  "details": null,
  "timestamp": "2024-12-25T12:30:00Z"
}
```

---

## 4. Codes statut HTTP

| Code | Signification                  | Usage                                    |
|------|--------------------------------|------------------------------------------|
| 200  | OK                             | GET, PUT, PATCH, POST (validation)       |
| 201  | Créé                          | POST (création de ressource)             |
| 204  | Pas de contenu                 | DELETE (soft-delete réussi)              |
| 400  | Mauvaise requête               | Erreur de validation métier              |
| 401  | Non authentifié                | Token manquant ou invalide               |
| 403  | Accès refusé                   | Rôle insuffisant                         |
| 404  | Ressource introuvable          | UUID inexistant                          |
| 409  | Conflit                       | Doublon, état invalide                   |
| 422  | Entité non traitable           | Erreur de validation Pydantic            |
| 500  | Erreur interne                 | Bug côté serveur                         |

---

## 5. Gestion des erreurs

Toutes les erreurs suivent le format `ErrorResponse`. Les codes d'erreur courants :

| error_code          | Signification                              | HTTP status |
|---------------------|--------------------------------------------|-------------|
| `NOT_FOUND`         | Ressource inexistante                      | 404         |
| `VALIDATION_ERROR`  | Données invalides                          | 422         |
| `UNAUTHORIZED`      | Token manquant ou expiré                   | 401         |
| `FORBIDDEN`         | Rôle insuffisant                           | 403         |
| `CONFLICT`          | Conflit métier (déjà mangé, etc.)          | 409         |
| `BUSINESS_ERROR`    | Erreur métier générique                    | 400         |
| `FACE_NO_FACE`      | Aucun visage détecté dans l'image          | 400         |
| `FACE_LOW_QUALITY`  | Qualité d'image insuffisante               | 400         |
| `FACE_MULTIPLE`     | Plusieurs visages détectés                 | 400         |
| `INTERNAL_ERROR`    | Erreur serveur inattendue                  | 500         |

---

## 6. Pagination

Les endpoints de liste (`GET /employees`, `GET /meals`, etc.) acceptent :

| Paramètre    | Type   | Défaut | Description                                |
|-------------|--------|--------|--------------------------------------------|
| `page`      | int    | 1      | Numéro de page (1-indexed)                 |
| `page_size` | int    | 20     | Éléments par page (max 100)                |
| `sort`      | string | —      | Champ de tri (`nom`, `date_creation`, …)   |
| `order`     | string | `asc`  | Direction : `asc` ou `desc`                |
| `search`    | string | —      | Terme de recherche (champ configurable)    |

**Réponse paginée :**

```json
{
  "success": true,
  "data": [ ... ],
  "total": 150,
  "page": 1,
  "page_size": 20,
  "total_pages": 8
}
```

---

## 7. Diagrammes de séquence

### 7.1 Authentification

```mermaid
sequenceDiagram
    participant App as Application Mobile
    participant API as API Gateway
    participant Auth as Auth Service
    participant DB as Base de Données

    App->>API: POST /api/v1/auth/login<br/>{email, mot_de_passe}
    API->>Auth: authenticate(email, password)
    Auth->>DB: SELECT admin WHERE email=?
    DB-->>Auth: Admin + Role
    Auth->>Auth: verify_password(plain, hash)
    Auth->>Auth: generate_jwt(admin_id, role)
    Auth-->>API: token, expires_in, admin
    API-->>App: 200 SuccessResponse<br/>{token, admin}

    Note over App,API: Requêtes ultérieures
    App->>API: GET /api/v1/auth/me<br/>Authorization: Bearer <token>
    API->>Auth: decode_jwt(token)
    Auth-->>API: admin_id, role
    API->>DB: SELECT admin WHERE uuid=?
    DB-->>API: Admin
    API-->>App: 200 SuccessResponse<br/>{admin details}
```

### 7.2 Enregistrement d'un repas (par QR)

```mermaid
sequenceDiagram
    participant Scan as Scanner Mobile
    participant API as API Gateway
    participant QR as QR Service
    participant Meal as Meal Service
    participant DB as Base de Données
    participant Admin as Administrateur

    Scan->>API: POST /api/v1/meals/register<br/>Authorization: Bearer <token><br/>{token, categorie_uuid}
    API->>Admin: require_reception()
    Admin-->>API: receptionist
    API->>QR: validate(token)
    QR->>DB: SELECT qr_code WHERE hash=?
    DB-->>QR: QR Code
    QR->>QR: check expiration, revoked, owner active
    QR-->>API: ValidationResult(VALID, owner_uuid)
    API->>Meal: register_by_qr(db, token, categorie, admin)
    Meal->>DB: SELECT meal WHERE user=? AND today
    DB-->>Meal: Already eaten? → ConflictException
    Meal->>DB: INSERT meal
    DB-->>Meal: Meal
    Meal-->>API: Meal
    API-->>Scan: 201 SuccessResponse<br/>{meal details}
```

### 7.3 Génération d'un QR

```mermaid
sequenceDiagram
    participant AdminApp as App Admin
    participant API as API Gateway
    participant QR as QR Service
    participant DB as Base de Données

    AdminApp->>API: POST /api/v1/qr/generate/intern/{uuid}<br/>Authorization: Bearer <token>
    API->>QR: generate_for_intern(db, uuid, admin)
    QR->>DB: SELECT intern WHERE uuid=?
    DB-->>QR: Intern
    QR->>DB: SELECT active qr WHERE owner=? AND statut=ACTIF
    DB-->>QR: Previous QR (or null)
    alt Previous QR exists
        QR->>DB: UPDATE qr SET statut=REVOQUE
        DB-->>QR: OK
    end
    QR->>QR: generate_raw_token()
    QR->>QR: hash_token()
    QR->>QR: generate_qr_image()
    QR->>DB: INSERT qr_code
    DB-->>QR: QR Code
    QR-->>API: QR Code (with raw_token)
    API->>API: generate_qr_base64(raw_token)
    API-->>AdminApp: 201 SuccessResponse<br/>{qr_token, qr_base64, uuid}
```

### 7.4 Identification faciale

```mermaid
sequenceDiagram
    participant Tablet as Tablette Réception
    participant API as API Gateway
    participant Face as Face Service
    participant AI as AI Engine
    participant DB as Base de Données
    participant Meal as Meal Service

    Tablet->>API: POST /api/v1/face/identify<br/>Authorization: Bearer <token><br/>{image_base64, categorie_uuid?}
    API->>Face: identify(db, image)
    Face->>AI: detect_face(image_bytes)
    AI-->>Face: FaceDetection(bbox, confidence)
    alt No face detected
        Face-->>API: FaceStatut.NO_FACE
        API-->>Tablet: 200 {statut: "NO_FACE"}
    end
    Face->>AI: extract_embedding(image_bytes, detection)
    AI-->>Face: embedding (512-d float32)
    Face->>DB: SELECT active embeddings
    DB-->>Face: all active embeddings
    Face->>Face: cosine_similarity(probe, each gallery)
    Face->>Face: find best match above threshold
    alt Match found
        Face->>DB: SELECT user WHERE uuid=?
        DB-->>Face: User
        opt categorie_uuid provided
            Face->>Meal: register_by_user_uuid(db, user_uuid, categorie, admin)
            Meal-->>Face: Meal registered
        end
        Face-->>API: FaceStatut.MATCH, user info
        API-->>Tablet: 200 {statut: "MATCH", confidence, nom, prenom}
    else No match
        Face-->>API: FaceStatut.NO_MATCH
        API-->>Tablet: 200 {statut: "NO_MATCH"}
    end
```

---

## 8. Référence des endpoints

### 8.1 Authentification

| Méthode | Chemin              | Auth | Rôle   | Description                    |
|---------|--------------------|------|--------|--------------------------------|
| POST    | `/auth/login`      | Non  | —      | Authentification administrateur |
| GET     | `/auth/me`         | Oui  | admin  | Admin connecté                 |

### 8.2 Employés

| Méthode | Chemin               | Auth | Rôle  | Description                    |
|---------|---------------------|------|-------|--------------------------------|
| GET     | `/employees`        | Oui  | admin | Liste paginée                  |
| GET     | `/employees/{uuid}` | Oui  | admin | Détail                         |
| POST    | `/employees`        | Oui  | admin | Création                       |
| PUT     | `/employees/{uuid}` | Oui  | admin | Remplacement                   |
| PATCH   | `/employees/{uuid}` | Oui  | admin | Modification partielle         |
| DELETE  | `/employees/{uuid}` | Oui  | admin | Soft-delete                    |

### 8.3 Stagiaires

Mêmes chemins que les employés, préfixe `/interns`.

### 8.4 Visiteurs

Mêmes chemins que les employés, préfixe `/visitors`.

### 8.5 Réceptionnistes

Mêmes chemins que les employés, préfixe `/receptionists`.

### 8.6 Repas

| Méthode | Chemin                       | Auth | Rôle        | Description                   |
|---------|-----------------------------|------|-------------|-------------------------------|
| POST    | `/meals/register`           | Oui  | reception   | Enregistrer un repas (QR)     |
| GET     | `/meals`                    | Oui  | admin       | Liste paginée                 |
| GET     | `/meals/today`              | Oui  | admin       | Repas du jour                 |
| GET     | `/meals/history/{user_uuid}`| Oui  | admin       | Historique d'un utilisateur   |
| GET     | `/meals/{uuid}`             | Oui  | admin       | Détail                        |

### 8.7 QR Codes

| Méthode | Chemin                             | Auth | Rôle        | Description                     |
|---------|-----------------------------------|------|-------------|---------------------------------|
| POST    | `/qr/generate/intern/{uuid}`      | Oui  | admin       | Générer QR pour stagiaire       |
| POST    | `/qr/generate/visitor/{uuid}`     | Oui  | reception   | Générer QR pour visiteur        |
| POST    | `/qr/validate`                    | Oui  | admin       | Valider un token QR             |
| POST    | `/qr/revoke/{uuid}`               | Oui  | admin       | Révoquer un QR                  |
| POST    | `/qr/regenerate/{uuid}`           | Oui  | admin       | Régénérer un QR                 |
| GET     | `/qr/{uuid}`                      | Oui  | admin       | Détail                          |
| GET     | `/qr/download/{uuid}`             | Oui  | admin       | Télécharger PNG                 |
| GET     | `/qr/history/{owner_uuid}`        | Oui  | admin       | Historique QR d'un propriétaire |

### 8.8 Reconnaissance faciale

| Méthode | Chemin              | Auth | Rôle        | Description                     |
|---------|--------------------|------|-------------|---------------------------------|
| POST    | `/face/enroll`     | Oui  | admin       | Enrôler une empreinte faciale   |
| POST    | `/face/verify`     | Oui  | reception   | Vérifier un utilisateur         |
| POST    | `/face/identify`   | Oui  | reception   | Identifier par visage           |
| GET     | `/face/{uuid}`     | Oui  | reception   | Détail empreinte                |
| DELETE  | `/face/{uuid}`     | Oui  | admin       | Désactiver empreinte            |

### 8.9 Santé

| Méthode | Chemin      | Auth | Description               |
|---------|------------|------|---------------------------|
| GET     | `/health`  | Non  | Health check              |
| GET     | `/ready`   | Non  | Readiness check           |
