# Migrations — Alembic

Ce dossier contient l'historique des migrations de schéma de la base de données MySQL, géré par [Alembic](https://alembic.sqlalchemy.org/).

## Workflow

### 1. Créer une migration automatique

Après avoir modifié un modèle SQLAlchemy (ajout/suppression de colonne, nouvelle table, etc.) :

```bash
alembic revision --autogenerate -m "description du changement"
```

Exemple :
```bash
alembic revision --autogenerate -m "ajout colonne telephone table employe"
```

### 2. **Toujours** réviser la migration générée

Alembic ne détecte pas parfaitement tous les changements (ex : renommage de colonne, changements de contrainte). Ouvrez le fichier généré dans `migrations/versions/` et vérifiez :

- [ ] Les `upgrade()` et `downgrade()` sont symétriques
- [ ] Les types de colonnes sont corrects
- [ ] Les contraintes FK pointent vers les bonnes tables
- [ ] Les index sont nommés correctement
- [ ] Aucune donnée n'est perdue involontairement

### 3. Appliquer la migration

```bash
alembic upgrade head
```

### 4. Revenir en arrière

Revenir d'une étape :
```bash
alembic downgrade -1
```

Revenir à une révision spécifique :
```bash
alembic downgrade <revision_id>
```

### 5. Voir l'état courant

```bash
alembic current          # Révision actuelle de la base
alembic history          # Historique des migrations
alembic heads            # Dernières révisions (branches)
```

## Bonnes pratiques

| Règle | Explication |
|-------|-------------|
| **1 migration = 1 changement logique** | Ne mélangez pas plusieurs modifications indépendantes dans une même révision. |
| **Toujours réviser `upgrade` ET `downgrade`** | Les deux fonctions doivent être implémentées et testées. |
| **Ne jamais éditer une migration déjà commitée** | Créez une nouvelle migration pour corriger. |
| **Tester la migration sur un clone de production** | Avant de déployer, exécutez `alembic upgrade` sur une copie de la base de production. |
| **Versionner tous les fichiers** | Les migrations font partie du code — elles sont commitées et reviewées. |
| **Éviter les `op.execute()` complexes** | Préférez les fonctions Alembic (`add_column`, `create_index`, etc.) qui sont indépendantes du dialecte SQL. |

## En cas d'erreur

```bash
# Voir la dernière migration appliquée
alembic current

# Revenir en arrière
alembic downgrade -1

# Corriger le problème, puis ré-appliquer
alembic upgrade head
```

## Fichiers

| Fichier | Rôle |
|---------|------|
| `env.py` | Configuration Alembic — charge les settings, importe les modèles, configure la connexion |
| `script.py.mako` | Template pour les nouvelles migrations |
| `versions/` | Dossier contenant les fichiers de migration individuels |
| `README.md` | Ce fichier — documentation du workflow |

## Comment Alembic découvre les modèles

Dans `env.py`, l'import explicite des modèles enregistre leurs métadonnées :

```python
from app.database.base import Base      # Le DeclarativeBase
from app.models import ...               # Tous les modèles métier
```

`Base.metadata` est passé à Alembic comme `target_metadata`. Chaque modèle importé contribue automatiquement ses tables, colonnes, index et contraintes à ce metadata. Alembic compare ensuite ce metadata avec l'état réel de la base de données pour générer les migrations.
