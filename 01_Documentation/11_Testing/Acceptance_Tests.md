# Tests d'Acceptabilité — Acceptance Tests

---

## 🎯 Objectif des Tests d'Acceptabilité
Les tests d'acceptabilité (UAT) valident que le produit répond parfaitement aux besoins des utilisateurs finaux et des commanditaires de l'entreprise avant la signature finale de mise en production.

---

## 📋 Scénarios d'Acceptabilité Clés

### 1. Enrôlement Administrateur & Premier Passage Employé
- **Acteurs** : Administrateur RH, Employé Pilote.
- **Objectif** : Valider la facilité d'enrôlement biométrique et l'identification consécutive au restaurant.
- **Critère de réussite** : L'enrôlement prend moins de 60 secondes. L'identification au restaurant fonctionne du premier coup en moins de 3 secondes sans saisie manuelle.

### 2. Gestion de l'Accueil (Stagiaires & Visiteurs)
- **Acteurs** : Hôte(sse) d'accueil, Stagiaire, Visiteur Pilote.
- **Objectif** : Valider la création rapide de profils à l'accueil et l'utilisation immédiate des QR Codes générés.
- **Critère de réussite** : La génération du QR Code prend moins de 30 secondes. La lecture sur la tablette à l'entrée du restaurant valide la sélection du repas instantanément.

### 3. Envoi Automatique de Rapports
- **Acteurs** : Administrateur Système.
- **Objectif** : Vérifier que les rapports journaliers et mensuels sont reçus par email et contiennent les graphiques et statistiques attendus.
- **Critère de réussite** : Les destinataires configurés reçoivent l'email à l'heure programmée. Les statistiques concordent à 100% avec les données de la base de données.
