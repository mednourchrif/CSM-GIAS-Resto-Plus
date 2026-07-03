# Cas de Tests — Test Cases

Ce document liste les cas de tests fonctionnels à exécuter lors de la campagne de validation.

---

## 🧪 Scénarios de Test Fonctionnels

### 📌 TC-001 : Identification réussie d'un employé par reconnaissance faciale
- **Exigence associée** : `FR-201`, `FR-304`
- **Prérequis** : L'employé "Dupont Jean" est enrôlé avec succès. Son profil est actif.
- **Étapes** :
  1. L'employé se présente devant la caméra de la tablette.
  2. La reconnaissance faciale s'enclenche.
- **Résultat Attendu** : Le visage est reconnu en moins de 3 secondes, l'écran affiche les catégories de repas et aucun clavier virtuel n'est requis.

### 📌 TC-002 : Tentative de double enregistrement le même jour (Bloqué)
- **Exigence associée** : `FR-508`, `FR-905`
- **Prérequis** : L'employé "Dupont Jean" a déjà enregistré un repas "Pizza" à 12h40.
- **Étapes** :
  1. "Dupont Jean" se représente devant la caméra à 13h10 le même jour.
  2. La reconnaissance faciale l'identifie.
- **Résultat Attendu** : L'enregistrement du repas est refusé. Un message d'erreur s'affiche indiquant : "Vous avez déjà enregistré votre repas pour aujourd'hui." en français, arabe et anglais.

### 📌 TC-003 : Utilisation d'un QR Code visiteur expiré (Rejeté)
- **Exigence associée** : `FR-204`, `FR-407`
- **Prérequis** : Un QR Code visiteur a été généré la veille (02 Juillet) pour "Martin Paul".
- **Étapes** :
  1. "Martin Paul" présente son QR Code devant le lecteur de la tablette le 03 Juillet.
- **Résultat Attendu** : Le système rejette le QR Code et affiche un message indiquant que le QR Code est expiré.
