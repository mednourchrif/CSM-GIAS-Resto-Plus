# CSM-GIAS Resto+
## Solution Intelligente de Gestion du Restaurant d'Entreprise

---

## Présentation du Projet
**CSM-GIAS Resto+** est une application mobile d'entreprise conçue pour digitaliser et automatiser le processus d'enregistrement des repas au sein du restaurant d'entreprise. Déployée sur une tablette Android à l'entrée du restaurant, elle assure l'identification des bénéficiaires et l'enregistrement de leurs consommations sans contact et en temps réel.

### Modes d'Identification :
- **Employés** : Reconnaissance faciale uniquement (traitement local sécurisé).
- **Stagiaires** : QR Code nominatif lié à la durée de leur stage.
- **Visiteurs** : QR Code temporaire généré par l'accueil, valable uniquement pour la journée courante.

### Règles Métier Majeures :
- **Plage horaire** : Enregistrement autorisé uniquement de 12h30 à 14h00.
- **Unicité** : Un seul repas autorisé par personne et par jour (toutes catégories confondues).
- **Catégories de repas** : Plat, Pizza et Sandwich.

---

## Structure du Dépôt

La structure du dépôt suit les standards rigoureux du génie logiciel pour un projet d'entreprise :

```text
CSM-GIAS-Resto-Plus
├── 00_Project_Management/          # Suivi de projet, plannings, réunions et risques
├── 01_Documentation/               # Documents de spécifications et d'architecture
│   ├── 05_Agile/                   # Backlog produit, user stories et gestion de sprint
│   ├── 06_Architecture/            # Choix d'architecture et décisions (ADR)
│   ├── 07_Database/                # Dictionnaires et schémas conceptuels de données
│   ├── 08_API/                     # Spécifications détaillées de l'API backend
│   ├── 09_UML/                     # Diagrammes de modélisation (Cas d'utilisation, classes, etc.)
│   ├── 10_UI_UX/                   # Charte graphique, navigation et wireframes
│   ├── 11_Testing/                 # Stratégies de tests, cas de tests et rapports d'anomalies
│   └── 12_DevOps/                  # Configuration CI/CD, Docker, déploiement et monitoring
├── 02_Design/                      # Maquettes graphiques et ressources d'interface (Branding, Assets...)
├── 03_Backend/                     # API REST FastAPI (Python)
├── 04_Mobile/                      # Application mobile React Native (Android)
├── 05_Web/                         # Dashboard Web d'administration (V2.0 - Hors Périmètre V1.0)
├── 06_Database/                    # Scripts SQL de base de données, tables, index et contraintes
├── 07_API/                         # Fichiers de configuration API, collection de requêtes et Swagger
├── 08_Diagrams/                    # Fichiers sources des diagrammes d'architecture (Ex: Draw.io, Mermaid)
├── 09_AI_Prompts/                  # Prompts d'IA documentés pour assister la maintenance et le dev
├── 10_Resources/                   # Logos, icônes, polices et supports de présentation
└── README.md                       # Ce document de référence
```

---

## Technologies Clés
- **Frontend Mobile** : React Native (Android)
- **Backend API** : FastAPI (Python)
- **Base de Données** : MySQL (8.0+)
- **Sécurisation** : JSON Web Token (JWT) & Chiffrement biométrique AES
- **Modélisation** : UML (Use Case, Sequence, Component)
- **Conteneurisation** : Docker

---

*Développement mené dans le cadre du stage d'été en ingénierie logicielle — Département IT, CSM-GIAS, 2026.*
