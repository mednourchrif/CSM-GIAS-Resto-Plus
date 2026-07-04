# CSM-GIAS Resto+ — Backend

Backend API pour la Solution Intelligente de Gestion du Restaurant d'Entreprise.

## Stack Technique

| Composant        | Technologie            |
|-----------------|------------------------|
| Framework       | FastAPI (Python 3.13)  |
| ORM             | SQLAlchemy 2.x         |
| Migrations      | Alembic                |
| Base de données | MySQL 8.0              |
| Validation      | Pydantic v2            |
| Authentification| JWT + BCrypt           |
| Logging         | Loguru                 |
| Tests           | Pytest                 |

## Structure du Projet

```
backend/
├── app/                    # Code source principal
│   ├── api/                # Points d'entrée HTTP (routes)
│   │   └── v1/             # Version 1 de l'API
│   ├── core/               # Configuration, constantes, settings
│   ├── database/           # Session SQLAlchemy, connexion DB
│   ├── models/             # Modèles ORM (entités SQLAlchemy)
│   ├── schemas/            # Schémas Pydantic (validation/sérialisation)
│   ├── repositories/       # Accès aux données (Repository Pattern)
│   ├── services/           # Logique métier
│   ├── middlewares/        # Intercepteurs HTTP
│   ├── utils/              # Fonctions utilitaires
│   ├── security/           # JWT, hachage, clés API
│   ├── reports/            # Génération de rapports PDF
│   ├── statistics/         # Calculs statistiques
│   └── emails/             # Envoi d'emails SMTP
├── tests/                  # Tests unitaires et d'intégration
├── scripts/                # Scripts utilitaires (init, seed, backups)
├── migrations/             # Migrations Alembic
├── docs/                   # Documentation technique complémentaire
├── pyproject.toml          # Configuration du projet Python
├── requirements.txt        # Dépendances Python
├── .env.example            # Exemple de configuration d'environnement
├── .gitignore              # Fichiers ignorés par Git
└── docker-compose.yml      # Infrastructure locale (MySQL)
```

## Démarrage Rapide

```bash
# 1. Cloner le dépôt
# 2. Créer l'environnement virtuel
python -m venv .venv

# 3. Activer l'environnement
#   Windows : .venv\Scripts\Activate.ps1
#   Linux   : source .venv/bin/activate

# 4. Installer les dépendances
pip install -r requirements.txt

# 5. Copier et configurer les variables d'environnement
copy .env.example .env

# 6. Démarrer la base de données (Docker)
docker-compose up -d

# 7. Exécuter les migrations
alembic upgrade head

# 8. Démarrer le serveur de développement
uvicorn app.main:create_app --reload
```

## Commandes Essentielles

```bash
# Lancer les tests
pytest

# Vérifier le style
ruff check app/
black --check app/
isort --check-only app/

# Formater le code
ruff check --fix app/
black app/
isort app/

# Vérifier les types
mypy app/

# Générer une migration
alembic revision --autogenerate -m "description"

# Appliquer les migrations
alembic upgrade head
```

## Conventions

- **Python 3.13+** obligatoire
- **Type hints** sur toutes les fonctions
- **Docstrings** en français pour la logique métier
- Tests unitaires avec couverture minimale de 80%
- Formatage avec Black (100 caractères max)
- Import sorting avec isort (profil Black)
- Linting avec Ruff
