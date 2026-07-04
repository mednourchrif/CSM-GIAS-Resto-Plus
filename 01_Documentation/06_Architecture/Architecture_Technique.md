# ARCHITECTURE TECHNIQUE ET CONCEPTION SYSTÈME
## CSM-GIAS Resto+
### Solution Intelligente de Gestion du Restaurant d'Entreprise

---

## 1. Page de Garde

| Propriété | Détail |
|---|---|
| **Nom du Projet** | CSM-GIAS Resto+ |
| **Sous-titre** | Solution Intelligente de Gestion du Restaurant d'Entreprise |
| **Type de Document** | Dossier d'Architecture Technique (DAT) |
| **Version** | 1.0 |
| **Date** | Juillet 2026 |
| **Auteur** | Architecte Solutions & Logiciels Principal |
| **Destinataires** | Équipes de Développement Mobile & Backend, Administrateurs Système, DevOps, Direction Générale |
| **Confidentialité** | Usage Interne — Strictement Confidentiel |

### Historique des Révisions

| Version | Date | Auteur | Description des Modifications |
|---|---|---|---|
| 0.1 | Juin 2026 | Architecte Logiciel | Ébauche initiale et sélection de la pile technologique |
| 0.9 | Juin 2026 | Architecte Solutions | Alignement avec le Product Backlog et les Règles Métier |
| 1.0 | Juillet 2026 | Lead Architect | Version finale validée pour le démarrage des développements |

---

## 2. Introduction

### 2.1 Objet du Document
Le présent Dossier d'Architecture Technique (DAT) définit les orientations d'architecture physique, logique et applicative pour la solution **CSM-GIAS Resto+**. Il fait office de document de référence et de contrat technique pour l'ensemble des équipes d'ingénierie (développeurs backend, développeurs mobiles, ingénieurs QA et administrateurs système).

### 2.2 Portée du Document
Ce document couvre l'architecture de la version 1.0 de la solution, qui consiste en une application sur tablette Android (React Native/Expo) installée à l'entrée du restaurant d'entreprise, communiquant avec un serveur d'API (FastAPI) et une base de données relationnelle (MySQL). Il anticipe également les évolutions futures telles que le tableau de bord web d'administration et la mise en place d'infrastructures multi-tablettes.

### 2.3 Public Cible
Ce document s'adresse :
- Aux **Développeurs** pour guider la structure et la conception du code.
- Aux **Administrateurs Système & DevOps** pour le déploiement et la supervision.
- Aux **Superviseurs & Management** pour valider la conformité avec les exigences de sécurité et de performance de l'entreprise.

### 2.4 Relation avec les Documents Précédents
Ce document est construit sur la base des exigences fonctionnelles (FR), non fonctionnelles (NFR), des règles métier (BR) et du Product Backlog validé. Il assure une continuité technologique parfaite sans altérer ni réinventer les exigences opérationnelles du projet.

---

## 3. Architectural Objectives

La conception globale du système repose sur le respect strict des critères opérationnels de qualité suivants :

### 3.1 Maintenabilité
Le code doit être structuré de manière modulaire afin de faciliter les corrections de bogues et l'ajout de fonctionnalités futures. L'utilisation d'une architecture en couches découplée limite les effets de bord lors de modifications.

### 3.2 Scalabilité (Évolutivité)
La solution doit supporter l'augmentation du nombre de transactions (repas enregistrés) et de comptes utilisateurs. Elle doit pouvoir évoluer d'une seule tablette vers un réseau multi-tablettes réparti sur plusieurs restaurants d'entreprise sans réécriture majeure.

### 3.3 Sécurité
Le système manipule des données sensibles (données biométriques chiffrées des employés) et contrôle l'accès physique à un service d'entreprise. L'architecture doit garantir la confidentialité des flux, la résistance aux attaques de type rejeu et l'inviolabilité de la tablette en production.

### 3.4 Performance
Le temps d'identification d'un utilisateur (reconnaissance faciale ou scan de QR code) et d'enregistrement de sa sélection de repas doit être minimal (< 30 secondes pour le processus complet, < 3 secondes pour l'identification faciale) afin de garantir la fluidité du passage.

### 3.5 Disponibilité et Fiabilité
L'application doit fonctionner sans interruption durant toute la plage horaire de service (12h30–14h00). Le serveur backend et la base de données doivent offrir un taux de disponibilité élevé, avec des mécanismes de surveillance actifs.

### 3.6 Testabilité
Les différentes couches de l'application doivent pouvoir être testées de manière isolée via des tests unitaires et d'intégration, garantissant ainsi l'absence de régressions lors du cycle de vie logiciel.

---

## 4. Pile Technologique

La pile technologique a été sélectionnée pour répondre aux exigences non fonctionnelles de performance, de simplicité de maintenance et de rapidité de déploiement.

### 4.1 React Native & Expo (Mobile)
- **Raison du choix** : React Native permet de développer une application native performante avec une base de code partagée. L'utilisation d'Expo simplifie la gestion du matériel (caméra de la tablette pour l'enrôlement et le scan de QR Code), les mises à jour et le build.
- **Alternatives étudiées** : Android natif (Kotlin). Bien que performant, il requiert des compétences spécifiques et réduit la portabilité future vers d'autres OS.
- **Compromis** : Dépendance vis-à-vis de l'écosystème d'Expo et des mises à jour des modules natifs.

### 4.2 FastAPI & Python (Backend)
- **Raison du choix** : FastAPI offre des performances exceptionnelles grâce à l'utilisation d'ASGI et du mode asynchrone (`async/await`). Il permet une validation automatique des données via Pydantic et génère une documentation OpenAPI interactive par défaut. Python est le standard de l'industrie pour intégrer des modèles de reconnaissance faciale.
- **Alternatives étudiées** : Node.js/Express, Django. Django est jugé trop lourd pour une API REST pure ; Express manque de support natif pour les calculs intensifs en Python.
- **Compromis** : Nécessite une attention particulière sur la gestion du parallélisme lors de l'exécution d'algorithmes CPU-bound (reconnaissance faciale).

### 4.3 MySQL (Base de Données)
- **Raison du choix** : MySQL est un système de gestion de base de données relationnelle éprouvé, performant et largement adopté en entreprise. Il garantit la cohérence des transactions (propriétés ACID) nécessaires pour l'unicité journalière des repas.
- **Alternatives étudiées** : PostgreSQL. Bien que très robuste, MySQL offre une compatibilité simple et des coûts d'exploitation réduits dans l'infrastructure cible actuelle.
- **Compromis** : Moins de fonctionnalités avancées que PostgreSQL, mais suffisant pour le modèle relationnel du projet.

### 4.4 SQLAlchemy & Alembic (ORM & Migrations)
- **Raison du choix** : SQLAlchemy est l'ORM le plus mature de l'écosystème Python. Il offre un excellent contrôle sur les transactions et les requêtes. Alembic permet de gérer les versions et les migrations de schéma de base de données de manière propre et répétable.
- **Alternatives étudiées** : Tortoise ORM, SQLModel. SQLModel est encore récent ; SQLAlchemy offre un support entreprise plus solide.

### 4.5 JWT (Authentification)
- **Raison du choix** : Les JSON Web Tokens (JWT) permettent une authentification stateless pour les sessions administratives. Cela élimine le besoin de stocker l'état des sessions côté serveur et facilite la scalabilité.

### 4.6 SMTP (Emails)
- **Raison du choix** : Protocole standard et universel pour l'expédition des rapports d'activité automatiques au format PDF vers les adresses email configurées.

---

## 5. High-Level Architecture

La solution s'articule autour d'une architecture client-serveur classique découplée, structurée en trois couches principales : le client mobile, le serveur d'API backend et le serveur de base de données.

```
+-------------------------------------------------------+
|                   TABLETTE ANDROID                    |
|  +-------------------------------------------------+  |
|  |             React Native / Expo App             |  |
|  |  - Interface Utilisateur (Sélection Repas)      |  |
|  |  - Caméra (Scan QR Code, Reconnaissance Faciale) |  |
|  +-------------------------------------------------+  |
+---------------------------+---------------------------+
                            |
                            | HTTPS (REST API)
                            v
+-------------------------------------------------------+
|                    SERVEUR BACKEND                    |
|  +-------------------------------------------------+  |
|  |                  FastAPI API                    |  |
|  |  - Routage, Validation (Pydantic), Middlewares   |  |
|  +-----------------------+-------------------------+  |
|                          |
|                          v
|  +-------------------------------------------------+  |
|  |                  Service Layer                  |  |
|  |  - Logique Métier, Biométrie, Validation        |  |
|  +-----------------------+-------------------------+  |
|                          |
|                          v
|  +-------------------------------------------------+  |
|  |                Repository Layer                 |  |
|  |  - Accès aux Données (SQLAlchemy)               |  |
|  +-------------------------------------------------+  |
+---------------------------+---------------------------+
                            |
                            | TCP/IP
                            v
+-------------------------------------------------------+
|                     BASE DE DONNÉES                   |
|  +-------------------------------------------------+  |
|  |                  MySQL Database                 |  |
|  |  - Stockage des données (Utilisateurs, Logs)    |  |
|  +-------------------------------------------------+  |
+-------------------------------------------------------+
```

### 5.1 Flux de Communication
1. **Identification par Reconnaissance Faciale** : La tablette capture le flux vidéo de l'employé, extrait les repères faciaux localement via un module de traitement d'image et envoie l'empreinte vectorielle calculée au backend pour comparaison.
2. **Identification par QR Code** : La tablette scanne le QR Code présenté, extrait la chaîne de caractères et l'envoie au serveur pour vérification fonctionnelle (validité, expiration, révocation).
3. **Sélection de Repas** : Une fois l'utilisateur identifié, le backend renvoie son profil d'autorisation. L'utilisateur sélectionne son repas sur la tablette. La validation envoie une requête POST d'enregistrement de repas au backend.
4. **Validation et Audit** : La couche de service valide la transaction (unicité journalière, plage horaire), met à jour la base de données via le Repository, écrit dans le journal d'audit de manière asynchrone et renvoie le statut de confirmation à la tablette.

---

## 6. Style Architectural

Pour garantir la pérennité de l'application, l'architecture s'appuie sur des principes de conception logicielle rigoureux.

### 6.1 Architecture en Couches (Layered Architecture)
Le système sépare les responsabilités en trois niveaux logiques bien délimités :
- **Couche Présentation / API** : Gère les requêtes HTTP, valide le format d'entrée (schémas Pydantic) et formate les réponses.
- **Couche Application / Service** : Contient la logique métier, applique les règles de gestion (BR) et orchestre les opérations.
- **Couche Accès aux Données / Repository** : Fait l'abstraction des requêtes SQL et manipule la base de données.

### 6.2 Patron de Conception Repository (Repository Pattern)
La couche Repository isole la logique métier du mécanisme d'accès aux données. Elle fournit des méthodes d'accès orientées objet (ex : `get_by_id`, `add`, `update`) sans exposer les détails de SQLAlchemy. Cela permet de remplacer la base de données ou de simuler l'accès pour des tests unitaires sans altérer la logique métier.

### 6.3 Injection de Dépendances
Le backend utilise le système d'injection de dépendances natif de FastAPI (`Depends`). Cela permet de gérer de manière centralisée le cycle de vie des sessions de base de données, l'accès aux configurations et l'authentification des utilisateurs.

### 6.4 Principes SOLID
- **Single Responsibility Principle (SRP)** : Chaque classe, service ou module a une et une seule responsabilité métier.
- **Open/Closed Principle (OCP)** : L'architecture permet l'ajout de nouveaux modes d'identification ou de nouvelles catégories de repas en étendant le code, sans modifier les composants d'audit ou de stockage existants.
- **Liskov Substitution Principle (LSP)** : Les repositories implémentent des interfaces génériques remplaçables.
- **Interface Segregation Principle (ISP)** : L'API expose des endpoints granulaires adaptés aux besoins exclusifs de la tablette ou du dashboard.
- **Dependency Inversion Principle (DIP)** : Les services de haut niveau dépendent d'abstractions (interfaces de repositories) et non d'implémentations concrètes de bases de données.

---

## 7. Backend Architecture

La structure du code backend FastAPI est organisée de manière à découper strictement les responsabilités dans les répertoires suivants :

```
app/
├── api/             # Contrôleurs HTTP, routes de l'API (Endpoints)
├── core/            # Configurations système, clés de chiffrement et constantes
├── database/        # Session SQLAlchemy, fichiers d'initialisation de la DB
├── models/          # Entités ORM SQLAlchemy représentant la structure MySQL
├── schemas/         # Schémas Pydantic pour la validation des données d'entrée/sortie
├── repositories/    # Classes d'accès à la base de données (Repository Pattern)
├── services/        # Logique métier (validation repas, biométrie, QR Codes)
├── middlewares/     # Intercepteurs HTTP (gestion des erreurs, audit automatique)
├── utils/           # Fonctions utilitaires génériques (date, cryptographie)
├── security/        # Gestion JWT, hachage des mots de passe
├── reports/         # Moteur de génération des rapports PDF
├── statistics/      # Logique de calcul des indicateurs de fréquentation
├── emails/          # Service d'envoi automatique de courriels (SMTP)
└── tests/           # Suites de tests unitaires et fonctionnels (Pytest)
```

### Description des dossiers principaux
- `app/api/` : Contient les modules regroupant les routes par thématique (ex: `auth.py`, `meals.py`, `users.py`).
- `app/services/` : Contient des services métier autonomes (`meal_service.py`, `face_service.py`) qui appliquent les règles métier complexes.
- `app/models/` : Déclare les tables MySQL sous forme de classes Python.
- `app/schemas/` : Valide et sérialise les données. Par exemple, empêche l'injection de champs invalides lors de l'enregistrement d'un repas.

---

## 8. Mobile Architecture

L'application mobile React Native est structurée de manière modulaire, en utilisant Expo comme plateforme de support :

```
app/
├── screens/         # Écrans principaux (Accueil, Caméra, Sélection, Confirmation)
├── components/      # Composants graphiques réutilisables (Boutons, Cartes)
├── navigation/      # Configuration du routage et des transitions d'écrans
├── services/        # Appels API (client HTTP Axios ou Fetch)
├── hooks/           # Custom React Hooks pour encapsuler la logique d'état
├── contexts/        # États globaux de l'application (Session, Utilisateur scanné)
├── assets/          # Fichiers médias (images, logos, fichiers de traduction)
├── theme/           # Charte graphique (couleurs, polices de caractères)
├── utils/           # Formatage des dates, gestion du stockage local sécurisé
└── types/           # Déclarations TypeScript pour la cohérence des structures
```

### Description des dossiers principaux
- `app/screens/` : Représente les vues affichées à la tablette (Ex: `MealSelectionScreen.tsx`).
- `app/contexts/` : Permet de propager l'état de l'utilisateur identifié de l'écran d'identification vers l'écran de confirmation sans prop-drilling.
- `app/services/` : Encapsule les requêtes HTTP vers le backend, simplifiant la gestion des erreurs réseau au niveau de l'interface graphique.

---

## 9. Security Architecture

La sécurité est une exigence non fonctionnelle critique de l'architecture. Elle est appliquée à tous les niveaux du système.

### 9.1 Gestion de l'authentification (JWT)
Les jetons JWT (JSON Web Tokens) sécurisent l'interface d'administration. Ils sont signés avec un algorithme robuste (HMAC-SHA256) à l'aide d'une clé secrète asymétrique stockée dans les variables d'environnement. Les jetons ont une durée de validité courte et leur expiration force la déconnexion automatique de l'utilisateur (administrateur ou réception).

### 9.2 Hachage des Mots de Passe
Aucun mot de passe n'est stocké en clair dans la base de données. Le système utilise un algorithme de hachage moderne avec sel (BCrypt) pour persister les identifiants d'accès des administrateurs et des agents d'accueil.

### 9.3 Protection des Données Biométriques (RGPD)
Les empreintes faciales des employés ne sont jamais stockées sous forme d'images faciales ou de photos. Le système convertit l'image capturée lors de l'enrôlement en un vecteur de caractéristiques numériques non inversible (128 ou 512 dimensions). Ce vecteur est chiffré au repos (chiffrement symétrique AES-256) avant d'être persisté dans MySQL.

### 9.4 Sécurisation et validation des QR Codes
Les QR Codes générés pour les stagiaires et visiteurs sont signés cryptographiquement. Le système intègre un jeton unique non prévisible (UUID) et valide sa date d'expiration en temps réel. Le système maintient une table de révocation pour interdire immédiatement l'utilisation d'un QR code révoqué avant sa date limite.

### 9.5 Résistance aux attaques de type rejeu et force brute
- **Attaque par rejeu** : Chaque transaction de repas contient un identifiant unique (nonce) et un horodatage. Le backend rejette toute transaction reçue hors des heures autorisées ou dont l'horodatage dévie de la tablette.
- **Protection par force brute** : Le backend limite le nombre d'appels API d'authentification ou d'identification par adresse IP (Rate Limiting) pour contrer les tentatives répétées de piratage.

---

## 10. Database Architecture

L'architecture des données repose sur un schéma relationnel normalisé au sein de MySQL, garantissant la cohérence transactionnelle et de bonnes performances.

```
       +-----------------------+             +-----------------------+
       |         USERS         |             |         MEALS         |
       +-----------------------+             +-----------------------+
       | id (PK)               |             | id (PK)               |
       | first_name            |             | user_id (FK)          |
       | last_name             |------------>| meal_category         |
       | role (enum)           |             | identification_mode   |
       | is_active (bool)      |             | created_at (timestamp)|
       +-----------------------+             +-----------------------+
                   |                                     |
                   | 1                                   | 1
                   |                                     |
                   v 0..1                                v 0..1
       +-----------------------+             +-----------------------+
       |   BIOMETRIC_DATA      |             |      AUDIT_LOGS       |
       +-----------------------+             +-----------------------+
       | id (PK)               |             | id (PK)               |
       | user_id (FK)          |             | actor_id (FK)         |
       | face_vector (blob)    |             | action_type           |
       | updated_at            |             | details               |
       +-----------------------+             | created_at            |
                   ^                         +-----------------------+
                   | 1
                   |
                   v 0..1
       +-----------------------+
       |       QR_CODES        |
       +-----------------------+
       | id (PK)               |
       | user_id (FK)          |
       | token_value (unique)  |
       | expires_at            |
       | is_revoked (bool)     |
       +-----------------------+
```

### 10.1 Relations et Transactions
- **Transactions ACID** : L'enregistrement de repas utilise des transactions avec le niveau d'isolement par défaut pour s'assurer que l'unicité journalière du repas n'est jamais violée, même en cas d'accès concurrents massifs.
- **Indexation** : Des index sont créés sur les clés étrangères (`user_id`), sur les champs d'identification fréquemment interrogés (`token_value` des QR Codes) et sur les horodatages pour accélérer la génération automatique des rapports d'activité.

### 10.2 Évolutivité future
Bien que MySQL soit déployé en instance unique pour la version 1.0, l'architecture des données prévoit l'ajout de tables de partitionnement ou l'utilisation de réplicas en lecture seule si le volume de données s'accroît lors du passage au multi-tablettes.

---

## 11. API Architecture

Le backend expose une API RESTful conforme aux standards de l'industrie, documentée via OpenAPI.

### 11.1 Versioning de l'API
Pour garantir la stabilité du client mobile et permettre des mises à jour transparentes du backend, les routes de l'API sont versionnées à l'aide d'un préfixe dans l'URL (Ex: `/api/v1/`).

### 11.2 Gestion des erreurs et format de réponse
Toutes les erreurs renvoyées par le backend respectent un format standardisé de type JSON :
- **Code HTTP** : Codes standards (400 Bad Request, 401 Unauthorized, 403 Forbidden, 422 Unprocessable Entity, 500 Internal Server Error).
- **Format de réponse** : Un objet JSON contenant un code d'erreur interne (`error_code`) et un message compréhensible en français (`message`).

### 11.3 Stratégie de pagination et filtrage
Les endpoints retournant des listes (utilisateurs, rapports, logs d'audit) utilisent une pagination par offset/limite (`limit` et `offset`) pour limiter la charge réseau et mémoire. Le filtrage s'effectue via des paramètres de requête HTTP (`query parameters`).

---

## 12. Reporting Architecture

La génération de rapports est un élément fondamental pour le Responsable Restaurant.

### 12.1 Génération et diffusion automatique des rapports
Un planificateur de tâches (cron job interne ou planificateur asynchrone type Celery/APScheduler) déclenche la génération des rapports à la fin du service de restauration (14h15 pour le rapport journalier).
- Le moteur de rapports extrait les agrégations de la base de données MySQL.
- Les rapports sont mis en forme au format PDF.
- Le service SMTP est invoqué de manière asynchrone pour envoyer le PDF en pièce jointe aux destinataires configurés par l'administrateur.

### 12.2 Statistiques en temps réel
Le module de statistiques calcule les indicateurs à la demande pour l'interface d'administration à partir de vues de base de données optimisées ou d'index dédiés, réduisant ainsi la latence lors de la consultation du tableau de bord.

---

## 13. Stratégie de Gestion des Erreurs

Le système doit faire preuve de résilience face aux erreurs logicielles ou réseau.

### 13.1 Typologie des erreurs
- **Erreurs de validation** : Gérées automatiquement par FastAPI (Pydantic). Renvoie un code 422 avec la liste des champs invalides.
- **Erreurs métier** : Renvoient des exceptions personnalisées (ex: `MealAlreadyRegisteredException`) interceptées par des gestionnaires d'exceptions globaux FastAPI pour renvoyer une réponse HTTP 400 propre.
- **Erreurs réseau** : L'application React Native intercepte les échecs de connexion et bascule l'interface utilisateur sur un écran d'erreur réseau invitant à réessayer sans faire crasher la tablette.

### 13.2 Journalisation et Supervision (Logging)
Les journaux d'application du backend sont écrits sur la sortie standard (stdout) au format structuré JSON pour être collectés par un outil tiers. Les erreurs de niveau `CRITICAL` ou `ERROR` déclenchent des entrées de log détaillées contenant la stack trace.

---

## 14. Stratégie de Performance

Des décisions d'optimisation sont prises pour assurer un temps de réponse rapide de la borne et des APIs.

### 14.1 Gestion des connexions à la base de données
L'application utilise un pool de connexions (Connection Pooling) géré par SQLAlchemy afin d'éviter la latence de création/destruction de connexions TCP à chaque requête.

### 14.2 Optimisation des requêtes
- **Lazy Loading contrôlé** : Utilisation de chargements joints explicites (`joinedload`) pour éviter le problème des requêtes N+1 lors de la récupération des utilisateurs et de leurs QR Codes associés.
- **Optimisation des images de reconnaissance faciale** : Les calculs d'extraction d'empreintes sont réalisés sur la tablette ou optimisés côté serveur pour réduire le temps de traitement CPU.

---

## 15. Stratégie de Scalabilité

L'architecture initiale à une tablette est pensée pour évoluer sans impact structurel majeur :

```
             +--------------------+      +--------------------+
             | Tablette Resto A   |      | Tablette Resto B   |
             +---------+----------+      +---------+----------+
                       |                           |
                       +-------------+-------------+
                                     | (HTTPS v1 API)
                                     v
                       +---------------------------+
                       |    Répartiteur de Charge  |
                       |        (Load Balancer)    |
                       +-------------+-------------+
                                     |
                       +-------------+-------------+
                       |                           |
                       v                           v
             +-------------------+       +-------------------+
             | Serveur Backend 1 |       | Serveur Backend 2 |
             +---------+---------+       +---------+---------+
                       |                           |
                       +-------------+-------------+
                                     |
                                     v
                       +---------------------------+
                       |  Cluster Base de Données  |
                       |       MySQL Master/Replica|
                       +---------------------------+
```

### 15.1 Passage au multi-tablettes et multi-restaurants
1. **Équilibreur de charge (Load Balancer)** : L'introduction d'un répartiteur de charge (ex: Nginx, HAProxy) permet de distribuer les requêtes HTTP entre plusieurs instances du serveur d'API FastAPI.
2. **Stateless API** : Le backend étant entièrement sans état (grâce à l'utilisation de jetons d'authentification JWT), n'importe quelle instance FastAPI peut répondre à n'importe quelle requête.
3. **Réplication de base de données** : Si l'écriture de repas s'accroît, la base de données peut être configurée avec un serveur principal (Master) pour les écritures et des serveurs secondaires (Replicas) pour la génération des rapports et la consultation des listes.

---

## 16. Architecture de Déploiement

### 16.1 Architecture Physique du Déploiement

```
 [ Tablette Android (Kiosque) ]   <--->   [ Pare-feu / Routeur Interne ]
                                                    |
                                                    | HTTPS (Port 443)
                                                    v
                                          [ Serveur Backend FastAPI ]
                                                    |
                                                    | TCP/IP (Port 3306)
                                                    v
                                          [ Serveur MySQL Database ]
                                                    |
                                                    | SMTP (Port 587)
                                                    v
                                          [ Serveur Mail SMTP ]
```

### 16.2 Séparation des Environnements
Pour garantir la sécurité et la stabilité de la production, trois environnements isolés sont mis en place :
- **Développement (Local)** : Utilisé par les développeurs. Utilise des bases de données SQLite ou MySQL locales de test.
- **Homologation / Tests** : Déployé sur une infrastructure miroir pour la validation fonctionnelle par l'équipe QA.
- **Production** : Environnement sécurisé à accès restreint. Clés d'API et identifiants SMTP configurés par variables d'environnement.

---

## 17. Architectural Decision Records (ADR)

---

### ADR-001 : Choix du framework backend FastAPI

- **Statut** : Validé
- **Contexte** : La solution nécessite un backend performant, capable de valider des types complexes de données, de gérer de l'asynchronisme pour les flux de repas et d'intégrer des modules Python pour la biométrie faciale.
- **Décision** : Utiliser **FastAPI**.
- **Alternatives** : Django, Flask, Express.js. Django est trop imposant pour une API pure. Express.js compliquerait l'appel des bibliothèques de reconnaissance faciale développées en Python.
- **Conséquences** :
  - *Avantages* : Excellentes performances, génération automatique de la documentation Swagger, typage fort et validation automatique des schémas JSON.
  - *Inconvénients* : Nécessité d'une rigueur sur le code asynchrone pour l'équipe de développement.

---

### ADR-002 : Choix du système de base de données MySQL

- **Statut** : Validé
- **Contexte** : Le système doit stocker des informations de repas et d'utilisateurs. L'intégrité transactionnelle est essentielle pour empêcher la fraude par double repas.
- **Décision** : Utiliser **MySQL**.
- **Alternatives** : PostgreSQL, MongoDB. MongoDB n'offre pas les garanties relationnelles SQL natives requises sans complexité supplémentaire. PostgreSQL est une alternative solide mais MySQL s'intègre plus facilement dans l'infrastructure de serveurs existante de l'entreprise.
- **Conséquences** :
  - *Avantages* : Grande fiabilité, support complet des transactions ACID, simplicité de maintenance.
  - *Inconvénients* : Moins flexible que MongoDB pour les changements de schéma rapides, mais compensé par l'utilisation d'Alembic.

---

### ADR-003 : Choix du framework mobile React Native (Expo)

- **Statut** : Validé
- **Contexte** : L'application doit tourner sur une tablette Android unique à l'entrée du restaurant, avec des besoins d'accès à la caméra pour l'identification.
- **Décision** : Utiliser **React Native avec Expo**.
- **Alternatives** : Android Kotlin natif, Flutter. Kotlin nécessiterait des compétences spécifiques ; Flutter a été écarté pour privilégier l'écosystème JavaScript/React déjà maîtrisé par l'équipe.
- **Conséquences** :
  - *Avantages* : Cycle de développement ultra-rapide, accès simple à la caméra via Expo SDK, portabilité future vers d'autres OS.
  - *Inconvénients* : Dépendance aux mises à jour d'Expo.

---

### ADR-004 : Choix du protocole JWT pour l'authentification d'administration

- **Statut** : Validé
- **Contexte** : Sécuriser l'accès à l'interface d'administration de manière simple, robuste et évolutive.
- **Décision** : Utiliser les jetons **JWT**.
- **Alternatives** : Cookies de session côté serveur.
- **Conséquences** :
  - *Avantages* : API stateless facilitant la montée en charge, jeton autoporteur contenant les rôles de l'utilisateur.
  - *Inconvénients* : La révocation d'un jeton avant sa date d'expiration naturelle nécessite une gestion de liste noire (blacklist) si nécessaire.

---

### ADR-005 : Stockage chiffré des données biométriques

- **Statut** : Validé
- **Contexte** : Les données biométriques (face vectors) des employés doivent être protégées conformément aux exigences de sécurité de l'entreprise et aux législations sur la vie privée.
- **Décision** : Crypter les vecteurs d'empreintes faciales au repos à l'aide de l'algorithme AES-256 avant stockage.
- **Alternatives** : Stockage en clair des vecteurs (rejeté pour non-conformité sécurité).
- **Conséquences** :
  - *Avantages* : Sécurité renforcée en cas de compromission de la base de données.
  - *Inconvénients* : Léger surcoût CPU pour le chiffrement/déchiffrement à chaque identification.

---

### ADR-006 : Style architectural en couches découplées

- **Statut** : Validé
- **Contexte** : Faciliter le travail en parallèle des équipes de développement et assurer la testabilité unitaire de la logique métier.
- **Décision** : Structurer l'application selon une **Architecture en Couches (Controller-Service-Repository)**.
- **Alternatives** : Architecture monolithique classique sans séparation (rejetée pour risques de maintenabilité).
- **Conséquences** :
  - *Avantages* : Découplage fort, réutilisation simple du code, testabilité unitaire par mock.
  - *Inconvénients* : Écriture de fichiers supplémentaires (Repository, Service, Schémas) pour chaque entité métier.

---

## 18. Risques et Atténuations

| Risque technique | Impact | Probabilité | Atténuation |
|---|---|---|---|
| **Luminosité variable affectant la reconnaissance faciale** | Majeur | Moyenne | Utilisation d'un modèle biométrique tolérant aux variations de lumière et intégration d'une fonction de caméra de secours (scan QR Code). |
| **Indisponibilité du serveur de messagerie SMTP** | Moyen | Basse | Mise en file d'attente des emails d'envoi de rapports avec tentatives de réexpédition automatiques. |
| **Coupure réseau entre la tablette et le backend** | Majeur | Moyenne | Affichage d'un écran d'erreur réseau clair sur la tablette avec invites de reconnexion automatique. |
| **Compromission de la base de données MySQL** | Critique | Basse | Chiffrement symétrique AES-256 des empreintes biométriques et hachage BCrypt des mots de passe. |
| **Saturation de la mémoire de la tablette (Mode Kiosque)** | Moyen | Basse | Planification d'un redémarrage automatique quotidien de l'application mobile en dehors des heures de service. |

---

## 19. Liste de Contrôle de Validation de l'Architecture

La validation de l'architecture a été vérifiée par rapport aux critères fondamentaux du projet :

- [x] **Cohérence avec la Vision Projet** : La pile technologique supporte le déploiement sur tablette unique et prévoit l'ajout futur d'un dashboard web.
- [x] **Respect des Règles Métier** : Les transactions de base de données garantissent l'unicité journalière du repas (BR-008). Le contrôle d'horaire (BR-042) est implémenté côté serveur.
- [x] **Conformité de Sécurité** : Pas de stockage d'images réelles des employés. Chiffrement obligatoire des données biométriques en base (BR-035).
- [x] **Objectifs de Performance** : Choix de FastAPI pour un temps de réponse rapide de l'API REST. Traitement asynchrone des tâches lourdes (envoi de mails).
- [x] **Testabilité** : Découplage par l'utilisation du patron Repository permettant de tester la logique de service indépendamment de MySQL.

---

## 20. Conclusion

Le présent Dossier d'Architecture Technique fournit les fondations logicielles requises pour la mise en œuvre de la solution **CSM-GIAS Resto+**. En s'appuyant sur une architecture en couches découplées et une pile technologique moderne (React Native, FastAPI, MySQL), la solution garantit un haut niveau de performance, de maintenabilité et de sécurité.

Ce document fait office de référence unique pour le démarrage immédiat des phases de développement et de configuration d'environnement par les équipes techniques.
