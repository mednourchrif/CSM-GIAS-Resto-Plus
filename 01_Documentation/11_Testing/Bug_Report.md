# Rapport d'Anomalie — Bug Report Template

Ce gabarit doit être utilisé par l'équipe QA pour déclarer tout dysfonctionnement constaté lors des campagnes de tests.

---

## 📄 Fiche d'Anomalie

| Champ | Détail |
|---|---|
| **ID de l'Anomalie** | *Ex: BUG-001* |
| **Titre** | *Ex: Crash de l'application lors du scan d'un QR Code non reconnu* |
| **Sévérité** | **Bloquant** / **Majeur** / **Mineur** / **Évolutif** |
| **Priorité** | **Haute** / **Moyenne** / **Basse** |
| **Date de Découverte** | *JJ/MM/AAAA* |
| **Auteur** | *Nom du testeur* |
| **Version du Logiciel** | *Ex: v1.0-RC1* |

---

## 🔄 Étapes de Reproduction
1. Ouvrir l'application sur la tablette Android.
2. Présenter un QR Code endommagé ou mal formaté devant l'appareil photo.
3. Attendre la tentative de traitement par l'application.

---

## 📈 Comportement Obtenu
- L'application se fige pendant 5 secondes puis s'arrête brusquement (Crash) et retourne à l'écran d'accueil d'Android.

---

## 📉 Comportement Attendu
- Le système doit afficher un message d'erreur visuel clair indiquant : "QR Code non lisible ou mal formaté" et inviter l'utilisateur à réessayer, sans fermer l'application.

---

## 🛠️ Pièces Jointes & Logs
- Logs de l'émulateur (logcat) ou capture d'écran de l'erreur réseau.
