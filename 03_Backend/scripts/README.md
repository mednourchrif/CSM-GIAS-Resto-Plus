# scripts — Scripts Utilitaires du Backend

Ce dossier contient des scripts utilitaires Python ou Bash pour automatiser les tâches administratives et le développement du backend :
- `seed.py` : Script d'initialisation de la base de données. Crée les rôles (ADMIN, RECEPTION), un administrateur par défaut, un réceptionniste par défaut et les catégories de repas (Plat, Pizza, Sandwich). Idempotent — peut être exécuté plusieurs fois sans dupliquer les données.
- `reset_db.py` : Script pour réinitialiser les tables de la base de données locale.
- `enrol_test_user.py` : Outil en ligne de commande pour simuler l'enrôlement biométrique d'un employé.
