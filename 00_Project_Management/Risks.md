# Registre des Risques — Risks

Ce registre identifie les risques techniques, organisationnels et fonctionnels identifiés pour la réussite de la version 1.0 de **CSM-GIAS Resto+**.

---

## Matrice des Risques

| ID | Description du Risque | Catégorie | Probabilité | Impact | Plan de Mitigation |
|---|---|---|---|---|---|
| **R1** | Performance de la reconnaissance faciale sur la tablette (latence, luminosité changeante). | Technique | Moyenne | Élevé | Utiliser des modèles légers adaptés aux architectures mobiles (Edge AI) ou déporter le matching lourd sur le serveur local. Mettre en place un éclairage stable à l'entrée du restaurant. |
| **R2** | Non-respect de la plage horaire stricte due à la désynchronisation de la tablette. | Fonctionnel | Basse | Moyen | Synchroniser l'heure de la tablette via un protocole NTP régulier et valider systématiquement l'heure côté serveur (API) avant d'enregistrer le repas. |
| **R3** | Fuite de données personnelles ou biométriques (non-conformité RGPD). | Sécurité | Basse | Critique | Ne jamais stocker de photos d'employés, mais uniquement des empreintes faciales vectorielles chiffrées (embeddings non réversibles). Sécuriser les API par JWT et HTTPS. |
| **R4** | Surcharge réseau ou coupures réseau bloquant l'accès au restaurant à 12h30. | Infrastructure | Moyenne | Élevé | Configurer un serveur local robuste et prévoir des mécanismes de reconnexion automatique. Éduquer l'équipe d'accueil à l'utilisation de listes d'urgence si la panne persiste. |
| **R5** | Glissement de planning (Scope Creep) lié à la conception du tableau de bord web. | Projet | Moyenne | Moyen | Exclure strictement le dashboard web du périmètre de la V1.0 (MVP) et se concentrer uniquement sur l'application mobile et l'API backend REST. |
