# 1. Page de Garde

**Projet** : CSM-GIAS Resto+
**Sous-titre** : Solution Intelligente de Gestion du Restaurant d'Entreprise
**Titre du document** : Specification UX - Application Tablette
**Version** : 1.0
**Date** : Juillet 2026
**Auteur** : Architecte UX Senior
**Confidentialite** : Interne - Strictement Confidentiel

## Historique des Revisions

| Version | Date | Auteur | Description |
|---------|------|--------|-------------|
| 1.0 | 04/07/2026 | Architecte UX Senior | Creation de la specification UX complete |

---

# 2. Introduction

## 2.1 Objet du Document

Le present document constitue la specification complete de l'experience utilisateur (UX) et de l'interface utilisateur (UI) pour l'application tablette Android du projet CSM-GIAS Resto+. Il definit l'ensemble des ecrans, composants, interactions, animations et comportements attendus.

Ce document est le contrat de conception entre l'equipe de design et l'equipe de developpement React Native. Il est destine a etre utilise comme reference unique pour l'implementation.

## 2.2 Public Cible

Ce document s'adresse aux :
- Developpeurs React Native charges de l'implementation de l'interface
- Designers UI/UX charges de la realisation des maquettes
- Equipes de test charges de la validation de l'experience utilisateur
- Product Owner pour la validation fonctionnelle

## 2.3 Relation avec l'API

Chaque ecran de l'application interagit avec des endpoints specifiques de l'API REST (documentee dans la Specification de l'API). Les appels API sont references dans chaque specification d'ecran.

## 2.4 Relation avec les User Stories

Chaque ecran implemente une ou plusieurs User Stories. Les references US sont incluses dans chaque specification d'ecran.

## 2.5 Objectif de Performance UX

L'objectif fondamental de l'experience utilisateur est de permettre a un utilisateur de completer l'integralite du processus d'identification et d'enregistrement d'un repas en **moins de 10 secondes**. Ce temps inclut l'identification, la selection de la categorie et la confirmation.

---

# 3. Principes UX

## 3.1 Simplicite

L'application doit etre utilisable sans aucune formation. Un premier utilisateur doit pouvoir enregistrer son repas sans assistance. L'interface ne doit contenir que les elements necessaires a l'etape courante du flux.

## 3.2 Vitesse

Chaque ecran doit se charger en moins de 500 ms. Les transitions entre ecrans doivent durer moins de 300 ms. La reconnaissance faciale doit s'effectuer en moins de 3 secondes. L'ensemble du processus (identification + selection + validation) doit etre realise en moins de 10 secondes.

## 3.3 Accessibilite

L'application doit etre utilisable par tous, y compris les personnes souffrant de deficience visuelle legere, de daltonisme ou de limitations motrices. Tous les elements interactifs doivent avoir une taille minimale de 48 x 48 dp.

## 3.4 Cohrence

Chaque ecran utilise les memes composants, la meme mise en page et les memes interactions. Les couleurs, la typographie et les espacements sont uniformes dans toute l'application.

## 3.5 Prevention des Erreurs

L'interface doit prevenir les erreurs avant qu'elles ne se produisent : desactiver le bouton de validation tant qu'aucune categorie n'est selectionnee, guider l'utilisateur pour le positionnement du visage, afficher des messages clairs pour les QR Codes invalides.

## 3.6 Feedback

Chaque action utilisateur doit produire un feedback immediat : retour visuel au toucher, message de confirmation apres validation, indication de chargement pendant les operations.

## 3.7 Visibilite

L'etat du systeme doit etre visible a tout moment : ecran d'accueil indiquant que le systeme est pret, message de chargement pendant l'identification, confirmation de la validation.

## 3.8 Charge Cognitive Minimale

L'utilisateur ne doit jamais avoir a memoriser des informations d'un ecran a l'autre. Les choix sont presentes de maniere explicite. Les actions critiques (validation du repas) sont protegees par un ecran de confirmation.

---

# 4. Design System

## 4.1 Palette de Couleurs

| Role | Code Hex | Utilisation |
|------|----------|-------------|
| Primaire | #1B5E20 | Boutons principaux, en-tetes, accents principaux |
| Primaire Claire | #4CAF50 | Etats survoles, fonds de sections, badges |
| Primaire Foncee | #0D3311 | Texte sur fond clair (variante), barre de navigation |
| Secondaire | #FF8F00 | Accents secondaires, icones de notification |
| Secondaire Claire | #FFC107 | Indicateurs d'attention, elements de mise en garde |
| Fond | #F5F5F5 | Fond d'ecran principal |
| Surface | #FFFFFF | Cartes, dialogues, champs de formulaire |
| Erreur | #D32F2F | Messages d'erreur, rejet, expiration |
| Succes | #2E7D32 | Messages de confirmation, validation reussie |
| Information | #1565C0 | Messages d'information, indications |
| Texte Primaire | #212121 | Titres, corps de texte principal |
| Texte Secondaire | #757575 | Sous-titres, libelles, indicateurs |
| Texte sur Primaire | #FFFFFF | Texte sur fond primaire, boutons |
| Separation | #E0E0E0 | Lignes de separation, bordures de cartes |

**Justification** : La palette utilise le vert comme couleur principale (restauration, nature, sante). L'orange est utilise comme accent secondaire pour attirer l'attention sans conflit avec le vert. Les couleurs de statut (succes, erreur, information) suivent les conventions standards des interfaces mobiles.

## 4.2 Typographie

| Style | Police | Taille | Poids | Interlignage | Utilisation |
|-------|--------|--------|-------|-------------|-------------|
| Display | Roboto | 32 sp | Bold | 40 sp | Titres d'ecran, message de confirmation |
| Headline | Roboto | 24 sp | Medium | 32 sp | En-tetes de section, dialogues |
| Title | Roboto | 20 sp | Medium | 28 sp | Titres de carte, noms d'utilisateur |
| Subtitle | Roboto | 16 sp | Regular | 24 sp | Sous-titres, descriptions |
| Body | Roboto | 16 sp | Regular | 24 sp | Corps de texte principal |
| Body Small | Roboto | 14 sp | Regular | 20 sp | Texte secondaire, libelles |
| Caption | Roboto | 12 sp | Regular | 16 sp | Indications, horodatages |
| Button | Roboto | 16 sp | Medium | 24 sp | Texte des boutons |
| Categorie | Roboto | 18 sp | Bold | 24 sp | Noms de categories de repas |

**Justification** : Roboto est la police standard recommandee par Material Design 3 pour Android. Elle offre une excellente lisibilite sur ecran, une large gamme de poids et une prise en charge multilingue (francais, arabe, anglais).

## 4.3 Espacements

| Nom | Valeur | Utilisation |
|-----|--------|-------------|
| xs | 4 dp | Espacement minimal entre icones et texte |
| sm | 8 dp | Espacement interne des cartes |
| md | 16 dp | Marge standard des ecrans, espacement entre cartes |
| lg | 24 dp | Espacement entre sections |
| xl | 32 dp | Espacement avant les boutons d'action |
| xxl | 48 dp | Espacement de titre principal, marges hautes |

## 4.4 Icones

Les icones utilisees dans l'application proviennent de la bibliotheque Material Icons (Google). Chaque icone respecte une taille standard de 24 dp pour les icones de navigation et 48 dp pour les icones fonctionnelles.

| Contexte | Icone | Taille |
|----------|-------|--------|
| Identification faciale | face | 120 dp (ecran plein) |
| QR Code | qr_code_scanner | 120 dp (ecran plein) |
| Categories repas | restaurant_menu, local_pizza, sandwich | 64 dp |
| Confirmation | check_circle | 80 dp |
| Erreur | error, cancel, warning | 80 dp |
| Navigation administration | dashboard, people, assessment, settings | 24 dp |
| Actions | add, edit, delete, search, filter | 24 dp |

## 4.5 Boutons

| Type | Hauteur | Largeur | Coins | Ombre | Etats |
|------|---------|---------|-------|-------|-------|
| Primaire | 56 dp | Pleine largeur (contexte) | 16 dp rounded | Legere | Normal, presse, desactive, charge |
| Secondaire | 48 dp | Ajustee au contenu | 12 dp rounded | Aucune | Normal, presse, desactive |
| Iconique | 48 dp | 48 dp | 24 dp rounded | Aucune | Normal, presse |
| Texte seul | 40 dp | Ajustee au contenu | 8 dp rounded | Aucune | Normal, presse |

## 4.6 Cartes

| Propriete | Valeur |
|-----------|--------|
| Coins | 16 dp rounded |
| Ombre | Elevation 2 dp |
| Padding interne | 16 dp |
| Fond | #FFFFFF |
| Separation | 8 dp entre cartes |

## 4.7 Dialogues

| Propriete | Valeur |
|-----------|--------|
| Coins | 20 dp |
| Largeur | 85% de l'ecran |
| Fond | #FFFFFF |
| Ombre | Elevation 8 dp |
| Animation | Fade in + Scale (200 ms) |

## 4.8 Champs de Formulaire

| Propriete | Valeur |
|-----------|--------|
| Hauteur | 56 dp (champ seul) |
| Coins | 8 dp rounded |
| Bordure | 1 px, #E0E0E0 (repos), 2 px primaire (focus) |
| Etiquette | Flottante (Material Design) |
| Message d'erreur | Sous le champ, texte 14 sp, rouge (#D32F2F) |

---

# 5. Navigation

## 5.1 Flux Principal (Tablette - Public)

```
[SPLASH] --> [ACCUEIL] --> [IDENTIFICATION] --> [SELECTION REPAS] --> [CONFIRMATION] --> [ACCUEIL]

                    |-- Face (employe)
                    |-- QR Scan (stagiaire/visiteur)

                    <-- ECHEC IDENTIFICATION --> [ACCUEIL]
                                                  (avec message d'erreur)
```

## 5.2 Flux Administration

```
[AUTHENTIFICATION] --> [DASHBOARD]
                            |
                    +-------+--------+
                    |        |        |
              [UTILISATEURS] [RAPPORTS] [STATISTIQUES]
                    |        |        |
              +-----+----+   |        |
              |     |    |   |        |
            [EMP] [STAG] [VIS]       |
              |     |    |   |        |
           [ENROLEMENT] [QR] |   [CONFIGURATION]
                              |
                          [AUDIT]
```

## 5.3 Diagramme de Navigation

| Ecran | Acces | Retour | Temps Estime |
|-------|-------|--------|--------------|
| Splash | Demarrage | Automatique | 2 secondes |
| Accueil | Fin du splash | - | Attente |
| Identification | Scan visage/QR | Automatique (10s inactivite) | 3 secondes max |
| Selection repas | Identification reussie | Non autorise | 3 secondes |
| Confirmation | Validation repas | Automatique (3s) | 3 secondes |
| Admin Login | Appui long 5s sur logo | Inactivite 30s | Variable |
| Dashboard | Login reussi | Deconnexion | Exploration |

---

# 6. Parcours Utilisateur

## 6.1 Parcours Employe

1. L'employe s'approche de la tablette installee a l'entree du restaurant
2. L'ecran d'accueil est affiche en permanence (mode kiosque)
3. La camera frontale est deja activee en apercu
4. Le visage de l'employe est automatiquement capture et identifie (0-3 secondes)
5. En cas de succes : l'ecran de selection des categories apparait
6. L'employe appuie sur une des trois categories (Plat, Pizza, Sandwich)
7. Un ecran de confirmation recapitule le choix
8. L'employe confirme (ou est automatiquement valide apres 3 secondes)
9. Un message de confirmation vert s'affiche avec les trois langues
10. Apres 3 secondes, retour automatique a l'ecran d'accueil

**Temps total estime : 8-10 secondes**

## 6.2 Parcours Stagiaire

1. Le stagiaire s'approche de la tablette avec son QR Code imprime ou numerique
2. L'ecran d'accueil est affiche
3. Le stagiaire appuie sur "Scan QR Code" ou presente directement le QR a la camera
4. La camera arriere scanne le QR Code
5. En cas de succes : meme flux que l'employe (selection + confirmation)
6. En cas d'echec (expire, revoque) : message d'erreur multilingue

**Temps total estime : 8-12 secondes**

## 6.3 Parcours Visiteur

Identique au parcours stagiaire, avec QR Code temporaire genere par la Reception.

## 6.4 Parcours Reception

1. La Reception appuie longuement sur le logo (5 secondes) pour acceder a l'ecran de connexion
2. Saisie de l'email et du mot de passe
3. Acces au Dashboard de l'administration
4. Navigation vers "Visiteurs" ou "Stagiaires"
5. Saisie des informations (nom, prenom, dates)
6. Generation du QR Code affiche a l'ecran
7. Impression ou presentation du QR Code au visiteur/stagiaire
8. Retour a la liste ou creation suivante

## 6.5 Parcours Administrateur

1. Connexion via l'ecran d'administration (identique a la Reception)
2. Dashboard avec acces a tous les modules
3. Gestion des employes (CRUD, enrolement)
4. Gestion des administrateurs (CRUD)
5. Consultation des rapports et statistiques
6. Configuration du systeme
7. Consultation de l'audit

---

# 7. Specification des Ecrans

## 7.1 Ecran : Splash

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-001 |
| **Nom** | Splash |
| **Objectif** | Afficher le logo et preparer l'application au demarrage |
| **Acteurs** | Tous |
| **Regles d'acces** | Public |

**Composants UI** :
- Fond : couleur primaire (#1B5E20) plein ecran
- Logo CSM-GIAS Resto+ centre horizontalement et verticalement
- Sous-titre "Solution Intelligente de Gestion du Restaurant d'Entreprise"
- Indicateur de chargement circulaire (blanc)

**Comportement** :
- Affiche pendant 2 secondes ou jusqu'au chargement complet
- Transition vers ACCUEIL avec fade-in (300 ms)
- Verifie la connexion au serveur en arriere-plan

**Etats** :
- Chargement : spinner anime + logo
- Erreur connexion : message "Connexion au serveur..." persistant jusqu'a retablissement

**Accessibilite** : Logo avec text alternatif pour lecteur d'ecran

**User Stories** : US-045
**API Endpoints** : GET /tablette/statut

---

## 7.2 Ecran : Accueil (Idle)

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-002 |
| **Nom** | Accueil |
| **Objectif** | Ecran d'attente principal, invite l'utilisateur a s'identifier |
| **Acteurs** | Tous |
| **Regles d'acces** | Public |

**Description** :
L'ecran d'accueil est l'etat par defaut de la tablette. Il est affiche en permanence lorsqu'aucun utilisateur n'est en cours d'identification. Il doit etre visuellement clair et inviter a l'action.

**Composants UI** :
- Fond : #F5F5F5
- Logo CSM-GIAS Resto+ en haut (hauteur : 60 dp)
- Titre central : "Bonjour !" (Display, 32 sp)
- Sous-titre : "Presentez-vous pour enregistrer votre repas" (Body, 16 sp)
- Deux grandes cartes cote a cote :

  **Carte 1 : Reconnaissance Faciale**
  - Icone : face (120 dp, #1B5E20)
  - Titre : "Employe" (Title, 20 sp)
  - Sous-titre : "Identification automatique par reconnaissance faciale"
  - Animation : legere pulsation de l'icone pour attirer l'attention

  **Carte 2 : QR Code**
  - Icone : qr_code_scanner (120 dp, #FF8F00)
  - Titre : "Stagiaire / Visiteur" (Title, 20 sp)
  - Sous-titre : "Scannez votre QR Code"
  - Animation : legere pulsation de l'icone

- Pied de page : heure courante (Caption, 12 sp)
- Indicateur de connexion reseau (icone verticale, en haut a droite)

**Comportement** :
- La camera frontale est activee en arriere-plan pour la detection automatique des visages
- Si un visage est detecte et stable pendant 1 seconde : transition automatique vers SCR-003 (Identification faciale)
- Si l'utilisateur appuie sur la carte QR : ouverture de la camera arriere pour le scan (SCR-004)
- Inactivite prolongee (30 min) : activation de l'economiseur d'ecran avec horloge
- Appui long (5 secondes) sur le logo : transition vers l'ecran de connexion admin (SCR-006)

**Etats** :
- Normal : affichage complet avec animations
- Hors connexion : message "Reseau indisponible - Mode degrade" en banniere rouge en haut
- Inactivite (nuit) : luminosite reduite, affichage horloge uniquement

**Temps de reponse** : Affichage initial < 200 ms

**Accessibilite** : L'ecran est entierement parcourable par lecteur d'ecran. Les zones tactiles font au moins 120 x 120 dp.

**Regles Metier** : BR-001, BR-002, BR-003, BR-004
**User Stories** : US-001, US-002, US-003, US-045, US-046
**API Endpoints** : GET /categories-repas (prechargement), POST /identification/faciale, POST /identification/qr-code

---

## 7.3 Ecran : Identification Faciale

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-003 |
| **Nom** | Identification Faciale |
| **Objectif** | Capturer et identifier le visage de l'employe |
| **Acteurs** | Employe |
| **Regles d'acces** | Detection automatique depuis SCR-002 |

**Description** :
Ecran plein ecran dedie a la capture du visage pour la reconnaissance faciale. L'interface est minimaliste pour maximiser la zone de capture.

**Composants UI** :
- Apercu camera : plein ecran (camera frontale)
- Cadre de guidage ovale au centre (60% de la largeur)
- Texte indicatif en haut : "Regardez la camera" (francais, arabe, anglais)
- Indicateur lumineux : cercle autour du cadre (blanc en attente, vert en cours, rouge si echec)
- Animation de progression circulaire autour du cadre pendant la capture
- Bouton "Annuler" en haut a gauche (icone close, 48 dp)

**Flux d'interaction** :
1. L'apercu camera s'affiche immediatement
2. Le systeme detecte le visage dans le cadre
3. Si le visage est correctement positionne (taille, angle, luminosite) : le cadre devient vert
4. Capture automatique apres 500 ms de stabilite
5. Envoi au backend pour identification (POST /identification/faciale)
6. Succes : transition vers SCR-005 (Selection repas)
7. Echec : message "Non reconnu(e)" avec option "Reessayer" ou "Contacter l'administration"

**Duree maximale** : 3 secondes de capture a l'identification reussie

**Etats** :
- **Attente** : cadre blanc, texte "Regardez la camera"
- **Detection** : cadre bleu clair, texte "Visage detecte..."
- **Capture** : cadre vert, vibration legere, animation de progression
- **Chargement** : spinner au centre, texte "Identification en cours..."
- **Succes** : cadre vert, transition automatique
- **Echec reconnaissance** : cadre rouge, texte "Non reconnu(e)" + FR/AR/EN
  - Bouton "Reessayer" (primaire)
  - Bouton "Contacter l'administration" (secondaire) -> affiche le numero
- **Echec position** : cadre orange, texte guide "Approchez-vous" ou "Reculez"
- **Compte desactive** : message plein ecran "Compte desactive - Veuillez contacter l'administration"

**Accessibilite** : Feedback vibratoire a la capture. Messages audibles optionnels.

**Regles Metier** : BR-001, BR-005, BR-007, BR-010, BR-033, BR-034
**User Stories** : US-001, US-011, US-012, US-071
**API Endpoints** : POST /identification/faciale

---

## 7.4 Ecran : Scan QR Code

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-004 |
| **Nom** | Scan QR Code |
| **Objectif** | Scanner le QR Code d'un stagiaire ou visiteur |
| **Acteurs** | Stagiaire, Visiteur |
| **Regles d'acces** | Appui sur "Scanner QR" depuis SCR-002 |

**Description** :
Ecran de scan de QR Code utilisant la camera arriere de la tablette. Un cadre de scan guide le positionnement du QR Code.

**Composants UI** :
- Apercu camera arriere : plein ecran
- Cadre de scan carre au centre (70% de la largeur)
- Texte en haut : "Scannez votre QR Code" (francais + arabe + anglais superposes)
- Lignes d'angle animees (scan line qui se deplace verticalement)
- Bouton "Retour" en haut a gauche

**Flux d'interaction** :
1. Apercu camera arriere active
2. Detection automatique du QR Code dans le cadre
3. Vibrations legeres lors de la detection
4. Envoi au backend (POST /identification/qr-code)
5. Succes : transition vers SCR-005
6. Echec (expire) : message rouge "QR Code expire"
7. Echec (revoque) : message orange "QR Code revoque"
8. Echec (inconnu) : message "QR Code non reconnu"

**Temps de scan** : < 1 seconde apres presentation du QR

**Etats** :
- Attente : texte "Positionnez votre QR Code dans le cadre"
- Detection : cadre vert, vibration
- Chargement : spinner, texte "Verification..."
- Succes : transition immediate
- Erreur : message plein ecran avec les trois langues

**Accessibilite** : Flash lumineux a la detection du QR. Feedback vibratoire.

**Regles Metier** : BR-002, BR-003, BR-025, BR-026, BR-029
**User Stories** : US-002, US-003, US-004, US-005
**API Endpoints** : POST /identification/qr-code, POST /qrcodes/verifier

---

## 7.5 Ecran : Selection du Repas

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-005 |
| **Nom** | Selection du Repas |
| **Objectif** | Permettre a l'utilisateur de choisir une categorie de repas |
| **Acteurs** | Employe, Stagiaire, Visiteur |
| **Regles d'acces** | Identification reussie (SCR-003 ou SCR-004) |

**Description** :
Ecran presentant les trois categories de repas sous forme de grandes cartes visuelles. L'utilisateur selectionne une seule categorie.

**Composants UI** :
- Barre en haut : Nom et prenom de l'utilisateur identifie (Subtitle, 16 sp)
- Sous-titre : "Choisissez votre repas" (Title, 20 sp)
- Trois grandes cartes (hauteur : 200 dp minimum) :

  **Carte Plat**
  - Fond : degrade vert clair vers blanc
  - Icone : restaurant_menu (64 dp)
  - Texte : "Plat" (Categorie, 18 sp Bold)
  - Description : "Plat du jour" (Caption, 12 sp)

  **Carte Pizza**
  - Fond : degrade orange clair vers blanc
  - Icone : local_pizza (64 dp)
  - Texte : "Pizza" (Categorie, 18 sp Bold)
  - Description : "Pizza du jour" (Caption, 12 sp)

  **Carte Sandwich**
  - Fond : degrade marron clair vers blanc
  - Icone : sandwich (64 dp)
  - Texte : "Sandwich" (Categorie, 18 sp Bold)
  - Description : "Sandwich du jour" (Caption, 12 sp)

- Bouton "Valider" en bas (Pleine largeur, 56 dp)
  - Desactive (gris) tant qu'aucune categorie n'est selectionnee
  - Actif (vert) des qu'une categorie est choisie

**Comportement** :
- Appui sur une carte : selection unique avec animation de confirmation (echelle 1.05 puis retour)
- La carte selectionnee affiche une bordure verte et un icone check
- Appui sur une autre carte : deplace la selection
- Appui sur "Valider" : transition vers SCR-006
- Le bouton "Valider" reste desactive tant qu'aucune selection n'est faite

**Duree** : 3 secondes maximum (selection + validation)

**Etats** :
- Initial : aucune carte selectionnee, bouton grise
- Selection : carte encadree de vert, icone check visible
- Chargement : spinner sur le bouton "Validation en cours..."
- Erreur : dialogue d'erreur (ex : restaurant ferme, repas deja pris)

**Animation** :
- Apparition des cartes : fade-in + slide-up (300 ms, decalage de 100 ms entre chaque)
- Selection : scale 1.05 puis 1.00 (150 ms)
- Transition vers confirmation : scale 0.95 + fade-out (200 ms)

**Accessibilite** : Les cartes sont des zones tactiles de 200 dp minimum. Contraste suffisant entre les textes et les fonds.

**Regles Metier** : BR-037, BR-038, BR-039, BR-044
**User Stories** : US-013, US-014, US-015
**API Endpoints** : GET /categories-repas, POST /repas

---

## 7.6 Ecran : Confirmation

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-006 |
| **Nom** | Confirmation |
| **Objectif** | Afficher un message de confirmation apres validation du repas |
| **Acteurs** | Employe, Stagiaire, Visiteur |
| **Regles d'acces** | Validation reussie depuis SCR-005 |

**Description** :
Ecran de confirmation simple et rapide, affiche pendant 3 secondes avant retour automatique a l'accueil. Contient le message de succes en trois langues.

**Composants UI** :
- Fond : #2E7D32 (vert succes) plein ecran
- Icone : check_circle (80 dp, blanc)
- Texte principal : "Repas enregistre" (Display, 32 sp, blanc)
- Sous-titre 1 : "تم تسجيل الوجبة" (arabe, 24 sp, blanc)
- Sous-titre 2 : "Meal recorded" (anglais, 18 sp, blanc)
- Indication : "Retour automatique..." (Caption, 12 sp, blanc, opacite 70%)
- Details du repas en bas de l'ecran :
  - Categorie selectionnee avec icone
  - Horodatage
  - Mode d'identification utilise

**Comportement** :
- Affichage immediat apres validation
- Vibration legere de confirmation
- Retour automatique a SCR-002 apres 3 secondes
- L'utilisateur peut appuyer n'importe ou pour revenir plus tot
- Aucune action disponible (ecran purement informatif)

**Duree d'affichage** : 3 secondes

**Etats** :
- Normal : affichage complet
- Transition : fade-out vers accueil (300 ms)

**Accessibilite** : Message en trois langues superposees. Contraste eleve (blanc sur vert).

**Regles Metier** : BR-040, BR-065, BR-067
**User Stories** : US-016, US-039, US-040
**API Endpoints** : POST /repas (appele depuis SCR-005)

---

## 7.7 Ecran : Connexion Administration

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-007 |
| **Nom** | Connexion Administration |
| **Objectif** | Authentifier l'administrateur ou la reception |
| **Acteurs** | Administrateur, Reception |
| **Regles d'acces** | Appui long (5s) sur le logo depuis SCR-002 |

**Description** :
Ecran de connexion securisee avec email et mot de passe. Interface en francais uniquement.

**Composants UI** :
- Fond : #FFFFFF
- Logo en haut (plus petit que sur l'accueil)
- Titre : "Administration" (Headline, 24 sp)
- Champ "Email" avec icone (email, 24 dp)
- Champ "Mot de passe" avec icone (lock, 24 dp), type password
- Bouton "Se connecter" (primaire, pleine largeur)
- Lien "Mot de passe oublie" (texte seul, subtitle)
- Bouton "Retour" en haut a gauche

**Comportement** :
- Saisie de l'email (clavier email, auto-capitalization off)
- Saisie du mot de passe (masque, option afficher/masquer)
- Validation : les deux champs obligatoires
- Appui sur "Se connecter" : appel a POST /auth/login
- Succes : transition vers SCR-008 (Dashboard)
- Echec : message d'erreur sous les champs

**Validation** :
- Email : format email valide
- Mot de passe : minimum 8 caracteres

**Etats** :
- Normal : champs vides
- Saisie : icone de validation sur le champ
- Erreur champ : bordure rouge + message sous le champ
- Erreur serveur : dialogue "Identifiants invalides"
- Chargement : spinner sur le bouton
- Trop de tentatives : message "Compte temporairement verrouille - Reessayez dans 15 minutes"

**Securite** : Deconnexion automatique apres 30 minutes d'inactivite

**Accessibilite** : Champs avec etiquettes visibles. Lecteur d'ecran compatible.

**Regles Metier** : BR-069, BR-070
**User Stories** : US-006, US-007
**API Endpoints** : POST /auth/login, POST /auth/refresh

---

## 7.8 Ecran : Dashboard Administration

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-008 |
| **Nom** | Dashboard Administration |
| **Objectif** | Menu principal de l'interface d'administration |
| **Acteurs** | Administrateur, Reception |
| **Regles d'acces** | Authentification reussie (SCR-007) |

**Description** :
Ecran d'accueil de l'interface d'administration. Presente les modules accessibles sous forme de cartes.

**Composants UI** :
- Barre de navigation superieure :
  - Logo (gauche)
  - Titre : "Administration CSM-GIAS Resto+" (Title)
  - Profil de l'utilisateur connecte (droite)
  - Bouton "Deconnexion" (icone logout)

- Liste des modules en grille (2 colonnes) :

| Module | Icone | Couleur | Description |
|--------|-------|---------|-------------|
| Employes | people | #1B5E20 | Gestion des employes (CRUD + enrolement) |
| Stagiaires | school | #FF8F00 | Gestion des stagiaires |
| Visiteurs | person_pin | #1565C0 | Gestion des visiteurs |
| Administrateurs | admin_panel_settings | #D32F2F | Gestion des administrateurs (admin only) |
| Rapports | assessment | #2E7D32 | Consultation des rapports generes |
| Statistiques | bar_chart | #FF8F00 | Indicateurs et graphiques |
| Configuration | settings | #757575 | Parametrage du systeme (admin only) |
| Journal d'audit | receipt_long | #1B5E20 | Traces d'audit (admin only) |

Chaque carte contient : icone (48 dp), titre (Subtitle), nombre d'elements (si applicable).

**Comportement** :
- Appui sur une carte : navigation vers l'ecran correspondant
- Les modules non autorises (Reception : Admin, Configuration, Audit) sont masques
- La barre de navigation superieure persiste sur tous les ecrans d'administration

**Etat vide** : Premier demarrage, aucune donnee encore enregistree

**Regles Metier** : BR-045, BR-046, BR-048, BR-052
**User Stories** : US-027
**API Endpoints** : GET /employes, GET /stagiaires, GET /visiteurs (prechargement des compteurs)

---

## 7.9 Ecran : Gestion des Employes

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-009 |
| **Nom** | Gestion des Employes |
| **Objectif** | Lister, filtrer, creer et gerer les comptes employes |
| **Acteurs** | Administrateur |
| **Regles d'acces** | Authentifie (role ADMINISTRATEUR) |

**Description** :
Ecran de liste des employes avec fonctionnalites de recherche, pagination, et acces aux actions individuelles.

**Composants UI** :
- Barre de recherche en haut (champ avec icone search)
- Filtres : "Tous", "Actifs", "Inactifs", "Non enroles" (pills horizontales)
- Bouton "Ajouter un employe" (Floating Action Button, en bas a droite)

- Liste paginee (20 elements par page) :
  Chaque ligne contient :
  - Avatar circulaire avec initiales (fond vert, texte blanc)
  - Nom et prenom (Body, 16 sp)
  - Statut (badge : "Actif" vert, "Inactif" gris)
  - Statut enrolement (icone : fingerprint check/fingerprint off)
  - Fleche de navigation vers le detail

- Pagination en bas : nombres + fleches precedent/suivant

**Actions** :
- Appui sur une ligne : navigation vers SCR-010 (Detail employe)
- Appui sur le FAB : dialogue de creation
- Swipe gauche sur un element : action rapide "Desactiver" / "Activer"
- Menu contextuel (trois points) : "Modifier", "Desactiver", "Supprimer"

**Creation d'employe (dialogue modal)** :
- Champ "Nom" (obligatoire)
- Champ "Prenom" (obligatoire)
- Bouton "Creer" (primaire)
- Bouton "Annuler" (secondaire)

**Etats** :
- Liste vide : illustration + "Aucun employe. Ajoutez le premier employe."
- Recherche sans resultat : "Aucun resultat pour votre recherche"
- Chargement : skeleton loading (5 lignes grises animees)

**Accessibilite** : Liste entierement navigable au clavier. Actions swipe egalement disponibles par menu.

**Regles Metier** : BR-011, BR-046
**User Stories** : US-047, US-052, US-054
**API Endpoints** : GET /employes, POST /employes, PATCH /employes/{id}/desactiver

---

## 7.10 Ecran : Detail Employe

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-010 |
| **Nom** | Detail Employe |
| **Objectif** | Consulter et modifier les informations d'un employe |
| **Acteurs** | Administrateur |
| **Regles d'acces** | Selection depuis SCR-009 |

**Description** :
Vue detaillee d'un employe avec toutes les actions disponibles : modification, enrolement, desactivation, suppression, historique.

**Composants UI** :
- En-tete :
  - Avatar large (80 dp) avec initiales
  - Nom complet (Title, 20 sp)
  - Statut badge
  - Statut enrolement badge

- Sections (cartes) :

  **Informations personnelles** (modifiable) :
  - Champ "Nom"
  - Champ "Prenom"
  - Bouton "Enregistrer"

  **Enrolement biometrique** :
  - Statut : "Enrole le 04/07/2026" ou "Non enrole"
  - Bouton "Enroler" (si non enrole) -> navigation vers SCR-015
  - Bouton "Re-enroler" (si deja enrole)
  - Bouton "Supprimer l'empreinte" (avec confirmation)

  **Actions sur le compte** :
  - Bouton "Desactiver le compte" (si actif) avec confirmation
  - Bouton "Reactiver le compte" (si inactif)
  - Bouton "Supprimer definitivement" (RGPD, avec confirmation renforcee)

  **Historique des repas** (5 derniers) :
  - Tableau : Date | Categorie | Heure
  - Lien "Voir tout l'historique"

  **Metadonnees** :
  - Date de creation
  - Derniere modification

**Confirmation de suppression** :
Dialogue modal :
- Titre : "Confirmer la suppression"
- Message : "La suppression est irreversible. Toutes les donnees personnelles et biometriques seront effacees."
- Champ "Tapez CONFIRMER pour valider" (validation renforcee)
- Bouton "Annuler" (secondaire)
- Bouton "Supprimer" (rouge, desactive tant que CONFIRMER n'est pas saisi)

**Etats** :
- Chargement : skeleton
- Employe non trouve : message d'erreur
- Modification : champs en mode edition

**Regles Metier** : BR-010, BR-011, BR-012, BR-036, BR-046
**User Stories** : US-047, US-048, US-049, US-055, US-056, US-074, US-051
**API Endpoints** : GET /employes/{id}, PUT /employes/{id}, DELETE /employes/{id}, GET /employes/{id}/repas

---

## 7.11 Ecran : Gestion des Stagiaires

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-011 |
| **Nom** | Gestion des Stagiaires |
| **Objectif** | Lister, creer et gerer les comptes stagiaires |
| **Acteurs** | Administrateur, Reception |
| **Regles d'acces** | Authentifie (role ADMINISTRATEUR ou RECEPTION) |

**Composants UI** : Similaire a SCR-009 avec adaptations :
- Liste : Nom, Prenom, Dates stage, Statut QR, Expiration
- Filtres : "Tous", "Actifs", "Expires", "Aujourd'hui"

**Creation d'un stagiaire (dialogue modal)** :
- Champ "Nom" (obligatoire)
- Champ "Prenom" (obligatoire)
- Champ "Date debut stage" (date picker, obligatoire)
- Champ "Date fin stage" (date picker, obligatoire)
- Validation : dateFin >= dateDebut
- Bouton "Creer et generer le QR Code"
- Apres creation : affichage du QR Code en grand avec option impression

**Regles Metier** : BR-013, BR-016, BR-018, BR-045
**User Stories** : US-057, US-077, US-050
**API Endpoints** : GET /stagiaires, POST /stagiaires, PUT /stagiaires/{id}

---

## 7.12 Ecran : Gestion des Visiteurs

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-012 |
| **Nom** | Gestion des Visiteurs |
| **Objectif** | Creer et gerer les comptes visiteurs du jour |
| **Acteurs** | Administrateur, Reception |
| **Regles d'acces** | Authentifie (role ADMINISTRATEUR ou RECEPTION) |

**Composants UI** : Similaire a SCR-011 avec adaptations :
- Liste des visiteurs du jour uniquement (filtre date par defaut)
- Nom, Prenom, Date visite, Statut QR, Heure de creation

**Creation d'un visiteur (dialogue modal)** :
- Champ "Nom" (obligatoire)
- Champ "Prenom" (obligatoire)
- Champ "Date visite" (pre-rempli avec aujourd'hui, non modifiable pour la Reception)
- Verification anti-doublon automatique
- Bouton "Creer et generer le QR Code"
- Apres creation : affichage du QR Code en grand

**Regles Metier** : BR-019, BR-020, BR-022, BR-024, BR-045
**User Stories** : US-059, US-079, US-068
**API Endpoints** : GET /visiteurs, POST /visiteurs

---

## 7.13 Ecran : Enrolement Biometrique

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-015 |
| **Nom** | Enrolement Biometrique |
| **Objectif** | Capturer les donnees faciales d'un employe pour l'enrolement |
| **Acteurs** | Administrateur |
| **Regles d'acces** | Authentifie (role ADMINISTRATEUR), acces depuis SCR-010 |

**Description** :
Ecran dedie a la capture de l'empreinte faciale d'un employe. Cet ecran est utilise exclusivement par l'administrateur en face-a-face avec l'employe.

**Composants UI** :
- Apercu camera frontale (grand, occupant 70% de l'ecran)
- Informations de l'employe en haut : photo + nom + prenom
- Cadre de guidage ovale (identique a SCR-003)
- Indicateurs de qualite en temps reel :
  - Position visage : OK / Ajuster
  - Luminosite : OK / Trop sombre / Trop clair
  - Distance : OK / Trop pres / Trop loin
- Bouton "Capturer" (primaire) ou capture automatique
- Bouton "Annuler" (secondaire)

**Flux** :
1. L'employe se place face a la camera
2. Le systeme analyse en temps reel la qualite du visage
3. Quand tous les indicateurs sont verts : bouton "Capturer" devient actif
4. Appui sur "Capturer" : capture, chiffrement, envoi au backend
5. Succes : message de confirmation + retour au detail employe

**Etats** :
- Attente : cadre blanc, indicateurs de qualite
- Pret : cadre vert, "Qualite suffisante - Capturer"
- Capture : spinner
- Succes : message vert "Enrolement reussi"
- Echec qualite : message guide "Placez le visage dans le cadre"

**Regles Metier** : BR-031, BR-032, BR-035, BR-047
**User Stories** : US-008, US-076, US-009, US-010
**API Endpoints** : POST /enrolement, PUT /enrolement/{employe_id}

---

## 7.14 Ecran : Rapports

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-016 |
| **Nom** | Rapports |
| **Objectif** | Consulter et telecharger les rapports generes |
| **Acteurs** | Administrateur, Responsable Restaurant |
| **Regles d'acces** | Authentifie |

**Composants UI** :
- Filtres en haut : "Journalier", "Hebdomadaire", "Mensuel" (pills)
- Selecteur de periode (date picker)
- Liste des rapports :
  - Type (icone)
  - Periode (ex: "04/07/2026" ou "Semaine 27" ou "Juin 2026")
  - Date de generation
  - Statut (GENERE, ENVOYE, ERREUR)
  - Bouton telecharger (icone download)

- Section "Destinataires email" :
  - Liste des emails configures
  - Bouton "Ajouter un destinataire"
  - Bouton supprimer par destinataire

**Regles Metier** : BR-050, BR-053, BR-054, BR-055, BR-056, BR-057, BR-058, BR-059
**User Stories** : US-031, US-032, US-033, US-061, US-062, US-063, US-064, US-034, US-035
**API Endpoints** : GET /rapports, GET /rapports/{id}/telecharger, GET /rapports/destinataires, POST /rapports/destinataires

---

## 7.15 Ecran : Statistiques

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-017 |
| **Nom** | Statistiques |
| **Objectif** | Visualiser les indicateurs d'activite du restaurant |
| **Acteurs** | Administrateur, Responsable Restaurant |
| **Regles d'acces** | Authentifie |

**Description** :
Ecran de visualisation des statistiques avec graphiques et indicateurs. Interface en francais uniquement.

**Composants UI** :
- Selecteur de periode en haut (dateDebut, dateFin)
- Bandes d'indicateurs (4 cartes horizontalement) :
  - Total repas (nombre, icone restaurant)
  - Employes (nombre, icone people)
  - Stagiaires (nombre, icone school)
  - Visiteurs (nombre, icone person_pin)

- Section "Repartition par categorie" :
  - Diagramme circulaire (camembert) avec legende
  - Trois segments : Plat (vert), Pizza (orange), Sandwich (marron)
  - Pourcentages affiches

- Section "Repartition par profil" :
  - Barres horizontales : Employes, Stagiaires, Visiteurs

- Section "Frequentation horaire" :
  - Histogramme : axe X = tranches 15 min, axe Y = nombre
  - Barres de 12h30 a 14h00

- Bouton "Exporter CSV" en bas

**Etats** :
- Chargement : skeleton charts
- Aucune donnee : message "Aucune donnee pour la periode selectionnee"

**Regles Metier** : BR-060, BR-061, BR-062, BR-063, BR-064
**User Stories** : US-036, US-037, US-038, US-060, US-069
**API Endpoints** : GET /statistiques/total-repas, GET /statistiques/repartition-categorie, GET /statistiques/repartition-profil, GET /statistiques/frequentation-horaire, GET /statistiques/export-csv

---

## 7.16 Ecran : Configuration

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-018 |
| **Nom** | Configuration |
| **Objectif** | Parametrer le systeme (horaires, conservations, fuseau horaire) |
| **Acteurs** | Administrateur |
| **Regles d'acces** | Authentifie (role ADMINISTRATEUR) |

**Composants UI** :
- Liste des parametres modifiables sous forme de cartes :

  **Horaires d'ouverture** :
  - Champ "Heure d'ouverture" (time picker)
  - Champ "Heure de fermeture" (time picker)
  - Validation : fermeture > ouverture
  
  **Fuseau horaire** :
  - Selecteur deroulant (liste des fuseaux)
  - Valeur par defaut : UTC+1 (Paris)
  
  **Durees de conservation** :
  - Champ "Conservation audit (jours)"
  - Champ "Conservation rapports (jours)"
  
  **Gestion des emails** :
  - Champ "Serveur SMTP"
  - Champ "Port"
  - Champ "Email expediteur"
  
  **Tablette** :
  - Version application
  - Derniere synchronisation
  - Identifiant tablette

- Chaque modification est immediatement persistee

**Regles Metier** : BR-042
**User Stories** : US-066, US-053
**API Endpoints** : GET /configuration, PUT /configuration/{cle}

---

## 7.17 Ecran : Journal d'Audit

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-019 |
| **Nom** | Journal d'Audit |
| **Objectif** | Consulter les traces d'audit du systeme |
| **Acteurs** | Administrateur |
| **Regles d'acces** | Authentifie (role ADMINISTRATEUR) |

**Composants UI** :
- Filtres en haut :
  - Date (date picker debut/fin)
  - Type d'action (selecteur deroulant)
  - Utilisateur (recherche)

- Liste chronologique (du plus recent au plus ancien) :
  Chaque entree :
  - Horodatage (format lisible)
  - Icone selon le type d'action
  - Utilisateur (nom + prenom)
  - Description de l'action
  - Elements modifies (avant/apres si applicable)

- Pagination standard

**Etats** :
- Liste vide : "Aucune entree d'audit pour les filtres selectionnes"
- Chargement : skeleton

**Regles Metier** : BR-080, BR-081, BR-082, BR-083, BR-084
**User Stories** : US-042, US-043, US-044, US-072, US-073
**API Endpoints** : GET /audit

---

## 7.18 Ecran : Notifications Systeme (Mode Degrade)

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-020 |
| **Nom** | Notifications et Mode Degrade |
| **Objectif** | Afficher les messages d'erreur systeme et les etats degrades |
| **Acteurs** | Tous |
| **Regles d'acces** | Public |

**Ecran "Reseau indisponible"** :
- Fond : #D32F2F (rouge) ou #FF8F00 (orange)
- Icone : wifi_off (80 dp)
- Message (FR) : "Connexion reseau perdue"
- Message (AR) : "اتصال الشبكة مفقود"
- Message (EN) : "Network connection lost"
- Indication : "Reconnexion automatique en cours..."

**Ecran "Restaurant ferme"** :
- Fond : #757575 (gris)
- Icone : lock (80 dp)
- Message (FR) : "Restaurant ferme"
- Message (AR) : "المطعم مغلق"
- Message (EN) : "Restaurant closed"
- Horaires affiches : "Ouvert de 12h30 a 14h00"

**Ecran "Repas deja enregistre"** :
- Fond : #FF8F00 (orange)
- Icone : check_circle (80 dp)
- Message (FR) : "Repas deja enregistre aujourd'hui"
- Message (AR) : "تم تسجيل الوجبة اليوم"
- Message (EN) : "Meal already recorded today"

**Ecran "Compte desactive"** :
- Fond : #D32F2F (rouge)
- Message (FR) : "Compte desactive"
- Message (AR) : "الحساب معطل"
- Message (EN) : "Account disabled"
- Instruction : "Veuillez contacter l'administration"

---

## 7.19 Ecran : Gestion des Administrateurs

| Propriete | Valeur |
|-----------|--------|
| **ID** | SCR-021 |
| **Nom** | Gestion des Administrateurs |
| **Objectif** | Creer, desactiver et reinitialiser les mots de passe des administrateurs |
| **Acteurs** | Administrateur (uniquement) |
| **Regles d'acces** | Authentifie (role ADMINISTRATEUR) |

**Composants UI** :
- Liste des administrateurs avec :
  - Nom, Prenom, Email
  - Statut (Actif/Inactif)
  - Derniere connexion
  - Menu d'actions : "Desactiver", "Reinitialiser mot de passe"

**Creation d'administrateur** :
- Formulaire : Nom, Prenom, Email, Mot de passe
- Validation : mot de passe 8 caracteres minimum

**Regles Metier** : BR-048, BR-049
**User Stories** : US-028, US-029, US-078, US-065
**API Endpoints** : GET /administrateurs, POST /administrateurs, PATCH /administrateurs/{id}/desactiver, POST /administrateurs/{id}/reinitialiser-mot-de-passe

---

# 8. Composants

## 8.1 Composants Principaux

| Composant | Description | Reutilisable |
|-----------|-------------|--------------|
| PrimaryButton | Bouton vert pleine largeur | Tous les ecrans action |
| SecondaryButton | Bouton avec bordure | Dialogues, actions secondaires |
| IconButton | Bouton icone circulaire | Barres de navigation |
| Card | Carte avec ombre et coins arrondis | Listes, menus, sections |
| Avatar | Cercle avec initiales | Listes utilisateurs |
| Badge | Petit indicateur colore | Statuts (actif/inactif) |
| Chip | Pille de filtre | Filtres de liste |
| StatCard | Carte d'indicateur chiffre | Dashboard, statistiques |
| Modal | Dialogue superpose | Confirmations, formulaires |
| Toast | Notification temporaire | Confirmations rapides |
| SkeletonLoad | Animation de chargement | Tous les ecrans avec donnees |
| EmptyState | Illustration + texte | Listes vides |
| ErrorState | Message d'erreur + action | Erreurs API |
| QRDisplay | QR Code avec options | Generation QR |
| CameraPreview | Apercu camera | Identification, enrolement |

## 8.2 Toast (Notification Temporaire)

**Proprietes** :
- Position : bas de l'ecran (centree)
- Duree : 3 secondes
- Fond : selon type (succes = vert, erreur = rouge, info = bleu)
- Texte : Body (16 sp), blanc
- Animation : slide-up (200 ms), fade-out (300 ms)
- Action optionnelle : bouton "Annuler" pour les actions reversibles

## 8.3 Dialogues de Confirmation

**Structure** :
- Titre (Headline, 24 sp)
- Message (Body, 16 sp)
- Bouton "Annuler" (secondaire, gauche)
- Bouton "Confirmer" (primaire, droite, ou rouge pour actions destructrices)

---

# 9. Formulaires

## 9.1 Comportement des Champs

| Propriete | Valeur |
|-----------|--------|
| Etiquette | Flottante (Material Design) |
| Animation etat focus | Label se deplace vers le haut, bordure devient primaire |
| Message d'erreur | Sous le champ, texte 14 sp, rouge |
| Validation | En temps reel (apres 500 ms de saisie) ou a la soumission |
| Auto-focus | Premier champ du formulaire |
| Retour clavier | "Suivant" passe au champ suivant, "Termine" soumet |

## 9.2 Masques de Saisie

| Champ | Masque | Exemple |
|-------|--------|---------|
| Email | Format email standard | admin@csm-gias.com |
| Heure | HH:MM | 12:30 |
| Date | JJ/MM/AAAA | 04/07/2026 |
| Nom | Lettres et tirets uniquement | Dupont |

## 9.3 Validation des Champs

| Champ | Regle | Message d'Erreur |
|-------|-------|------------------|
| Nom | 1-100 caracteres, lettres + tirets | "Le nom est obligatoire" ou "Caracteres non autorises" |
| Prenom | 1-100 caracteres, lettres + tirets | "Le prenom est obligatoire" |
| Email | Format email valide | "Format d'email invalide" |
| Mot de passe | 8 caracteres minimum | "8 caracteres minimum" |
| Date debut | Obligatoire, <= date fin | "Date de debut obligatoire" |
| Date fin | Obligatoire, >= date debut | "Doit etre posterieure a la date de debut" |

---

# 10. Feedback Utilisateur

## 10.1 Animations

| Element | Animation | Duree |
|---------|-----------|-------|
| Transition ecran | Fade + slide (direction selon contexte) | 300 ms |
| Apparition elements | Fade-in + slide-up | 300 ms (decalage 50 ms entre elements) |
| Pression bouton | Ripple effect (Material) | 200 ms |
| Selection carte | Scale 1.05 puis retour | 150 ms |
| Validation repas | Scale 0.95 + fade-out | 200 ms |
| Toast | Slide-up depuis le bas | 200 ms entree, 300 ms sortie |
| Dialogue | Fade-in + scale | 200 ms |
| Spinner | Rotation continue | 1.5 s par tour |

## 10.2 Micro-interactions

| Interaction | Feedback |
|-------------|----------|
| Appui sur carte | Haptic feedback leger, elevation 4 dp |
| Scan QR reussi | Haptic feedback, cadre vert |
| Identification reussie | Haptic feedback, transition fluide |
| Erreur | Haptic feedback court et fort |
| Validation repas | Haptic feedback long et doux |
| Changement d'ecran | Aucun haptic (transition silencieuse) |

---

# 11. Notifications

## 11.1 Messages Systeme

Les messages suivants sont affiches sur la tablette. Chaque message existe en trois langues (FR, AR, EN).

| Contexte | Message FR | Message AR | Message EN | Type |
|----------|-----------|------------|------------|------|
| Repas enregistre | Repas enregistre | تم تسجيل الوجبة | Meal recorded | Succes |
| Identification echouee | Non reconnu, veuillez reessayer | غير معروف، يرجى المحاولة مرة أخرى | Not recognized, please try again | Erreur |
| QR expire | QR Code expire | رمز الاستجابة السريعة منتهي الصلاحية | QR Code expired | Erreur |
| QR revoque | QR Code revoque | تم إلغاء رمز الاستجابة السريعة | QR Code revoked | Erreur |
| Restaurant ferme | Restaurant ferme | المطعم مغلق | Restaurant closed | Information |
| Repas deja pris | Repas deja enregistre aujourd'hui | تم تسجيل الوجبة اليوم | Meal already recorded today | Avertissement |
| Reseau perdu | Connexion reseau perdue | اتصال الشبكة مفقود | Network connection lost | Erreur |
| Service indisponible | Service temporairement indisponible | الخدمة غير متوفرة مؤقتًا | Service temporarily unavailable | Erreur |
| Compte desactive | Compte desactive - Contactez l'administration | الحساب معطل - اتصل بالإدارة | Account disabled - Contact administration | Erreur |
| Enrolement reussi | Enrolement biometrique reussi | تم التسجيل البيومتري بنجاح | Biometric enrollment successful | Succes |
| Employe cree | Employe cree avec succes | تم إنشاء الموظف بنجاح | Employee created successfully | Succes |

## 11.2 Affichage Multilingue

Les messages destines aux utilisateurs (employes, stagiaires, visiteurs) sont affiches en trois langues superposees :
1. Francais (texte principal, taille normale)
2. Arabe (sous le francais, taille legerement reduite)
3. Anglais (sous l'arabe, taille legerement reduite)

Les messages destines a l'administration sont en francais uniquement.

---

# 12. Accessibilite

## 12.1 Cibles Tactiles

| Element | Taille Minimale |
|---------|----------------|
| Boutons | 48 x 48 dp |
| Cartes de selection | 120 x 120 dp minimum |
| Elements de liste | 56 dp de hauteur |
| Icones cliquables | 48 x 48 dp |
| Champs de saisie | 56 dp de hauteur |

## 12.2 Contraste

| Combinaison | Ratio Minimum | Utilisation |
|-------------|---------------|-------------|
| Texte sur fond | 4.5:1 | Texte normal |
| Petit texte | 7:1 | Texte < 14 sp |
| Texte sur primaire | 4.5:1 | Boutons, bannieres |
| Texte desactive | 3:1 | Elements inactifs |

## 12.3 Prise en Charge des Lecteurs d'Ecran

- Tous les icones ont des labels textes alternatifs (contentDescription)
- Les tete de sections sont annoncees
- Les messages multilingues sont lus dans chaque langue
- Les etats (chargement, erreur) sont vocalises
- Les actions (swipe, appui long) sont annoncees

## 12.4 Gestion du Daltonisme

- Les couleurs seules ne sont jamais les uniques indicateurs d'etat
- Les icones et les textes accompagnent les codes couleur
- Les graphiques utilisent des motifs ou etiquettes en plus des couleurs

---

# 13. Performance UX

## 13.1 Temps de Chargement Maximum

| Ecran | Chargement Initial | Operations |
|-------|-------------------|------------|
| Accueil | < 200 ms | Demarrage camera |
| Identification faciale | < 300 ms | Activation camera |
| Scan QR | < 300 ms | Activation camera |
| Selection repas | < 200 ms | Affichage categories (prechargees) |
| Confirmation | < 100 ms | Ecran local |
| Admin Login | < 200 ms | Affichage formulaire |
| Dashboard | < 500 ms | Chargement compteurs |
| Liste employes | < 500 ms | Appel API pagine |
| Detail employe | < 300 ms | Affichage donnees |
| Statistiques | < 1 second | Calculs et graphiques |

## 13.2 Optimisation des Images

- Images de la camera compressees en JPEG qualite 85% avant envoi API
- Apercu camera en resolution reduite (720p) pour la reconnaissance
- QR Codes generes en PNG, stockes en Base64 pour affichage immediat

## 13.3 Cache et Prechargement

- Categories de repas prechargees au demarrage (GET /categories-repas)
- Message de confirmation en local (pas d'appel API necessaire)
- Liste des employes mise en cache (invalidation toutes les 5 minutes)

---

# 14. Gestion des Erreurs

## 14.1 Camera Indisponible

**Comportement** :
- Detection au demarrage de l'application
- Affichage d'un message plein ecran : "Camera indisponible"
- Desactivation des options d'identification (faciale et QR)
- Affichage d'un message : "Contacter l'administration"

## 14.2 Reseau Indisponible

**Comportement** :
- Detection en temps reel de la perte de connexion
- Banniere rouge en haut de l'ecran : "Connexion perdue"
- Apres 30 secondes : ecran plein ecran "Service temporairement indisponible"
- Tentative de reconnexion automatique toutes les 10 secondes
- Retour automatique au fonctionnement normal des que le reseau est retabli

## 14.3 Serveur Indisponible

**Comportement** :
- Timeout de 10 secondes sur chaque requete
- Message : "Serveur momentanement inaccessible"
- Proposition : "Reessayer" (bouton) ou "Contacter l'administration"

## 14.4 Visage Non Reconnu

**Comportement** :
- Apres 3 tentatives echouees : message avec option "Contacter l'administration"
- Affichage d'un message guide : "Assurez-vous d'etre bien eclaire et de faire face a la camera"
- Compteur de tentatives affiche

## 14.5 QR Code Invalide

**Comportement** :
- Message clair indiquant la raison : expire, revoque, ou inconnu
- Proposition : "Contacter l'accueil" pour un nouveau QR
- Retour automatique a l'accueil apres 5 secondes

## 14.6 Repas Deja Enregistre

**Comportement** :
- Message orange : "Repas deja enregistre aujourd'hui"
- Affichage des details : categorie et heure du repas deja enregistre
- Retour automatique a l'accueil

## 14.7 Restaurant Ferme

**Comportement** :
- En dehors de 12h30-14h00 : ecran "Restaurant ferme" avec horaires d'ouverture
- Horaires personnalisables via la configuration
- Pas de possibilite d'identification

---

# 15. Securite UX

## 15.1 Expiration de Session

- Session administration expire apres 30 minutes d'inactivite
- Avertissement : "Votre session va expirer dans 5 minutes" (dialogue)
- Possibilite de prolonger la session
- A expiration : retour a l'ecran de connexion (SCR-007)

## 15.2 Deconnexion Automatique

- L'administration se deconnecte automatiquement a la fermeture de l'application
- Pas de persistance du jeton JWT sur la tablette partagee
- Confirmation avant deconnexion manuelle

## 15.3 Protection de la Capture Biometrique

- L'ecran de capture faciale n'est accessible qu'aux administrateurs
- Les images capturees ne sont jamais stockees localement
- Aucun apercu n'est conserve apres la fin de la session
- Le visage n'est pas affiche pendant la capture (retour guide uniquement)

## 15.4 Dialogues de Confirmation

Les actions destructrices suivantes necessitent une confirmation explicite :
- Suppression d'un employe (saisie du mot "CONFIRMER")
- Revocation d'un QR Code
- Desactivation d'un administrateur
- Modification de la configuration critique

---

# 16. Comportement Responsive

## 16.1 Tablette 10 pouces (1280 x 800) - Cible principale

- Mise en page optimisee pour le format paysage par defaut
- Cartes de categories prenant 60% de la largeur
- Zones de scan grandes et centrees
- Police confortable (taille standard definie dans le Design System)

## 16.2 Tablette 8 pouces (1024 x 768) - Support secondaire

- Mise en page identique, marges reduites (12 dp au lieu de 16 dp)
- Cartes de categories legerement plus petites (80% de la largeur)
- Police identique (pas de reduction)

## 16.3 Future Web Dashboard

L'interface d'administration pourra etre portee sur le web (Release 2.0) avec :
- Mise en page adaptee aux ecrans larges (sidebar + contenu)
- Grille de cartes plus etendue
- Graphiques enrichis
- Pas de changement dans les fonctionnalites proposees

---

# 17. Directives de Design

## 17.1 Cohrence

Tous les ecrans utilisent :
- Les memes couleurs (palette definie en Section 4.1)
- Les memes polices (Roboto, Sections 4.2)
- Les memes espacements (grille 8 dp, Section 4.3)
- Les memes composants (Section 8)

## 17.2 Alignement

- Les elements sont alignes sur une grille de 8 dp
- Les marges laterales standard sont de 16 dp
- Le contenu est centre horizontalement
- Les etiquettes et champs sont alignes a gauche

## 17.3 Hierarchie Visuelle

- Le titre principal est en Display (32 sp)
- Les sections sont en Headline (24 sp)
- Les actions principales sont en bas de l'ecran
- Les informations secondaires sont en Caption (12 sp)

## 17.4 Aspect Professionnel

- Pas d'animations superflues
- Couleurs sobres et harmonieuses
- Typographie claire et lisible
- Espacement sufficient entre les elements
- Coins arrondis moderes (16 dp max)

---

# 18. Checklist de Validation UI

| Critere | Verification | Statut |
|---------|-------------|--------|
| **Simplicite** | L'application est utilisable sans formation | CONFORME |
| **Vitesse** | Processus complet < 10 secondes | CONFORME |
| **Identification** | Reconnaissance faciale < 3 secondes | CONFORME |
| **Accessibilite** | Cibles tactiles 48 dp, contraste 4.5:1 | CONFORME |
| **Professionnel** | Design sobre, couleurs harmonieuses | CONFORME |
| **Pret pour l'entreprise** | Tous les ecrans d'administration sont couverts | CONFORME |
| **Cohrence** | Design system uniforme sur tous les ecrans | CONFORME |
| **Facilite pour les nouveaux utilisateurs** | Flux guide, messages clairs, feedback immediat | CONFORME |
| **Gestion des erreurs** | Tous les cas d'erreur sont couverts | CONFORME |
| **Multilingue** | Messages critiques en FR/AR/EN | CONFORME |
| **Retour au depart** | Retour automatique apres confirmation (3s) | CONFORME |
| **Mode degrade** | Perte reseau, camera, serveur geres | CONFORME |
| **Experience administration** | Interface complete pour la gestion quotidienne | CONFORME |

---

# 19. Evolution Future

Les ameliorations UX suivantes sont identifiees pour les versions futures mais ne sont pas incluses dans la version 1.0 :

## 19.1 Mode Sombre

Un theme sombre pour l'interface d'administration, respectant la palette de couleurs existante, pourrait etre propose pour reduire la fatigue visuelle lors d'une utilisation prolongee.

## 19.2 Notifications Push

Notifications mobiles pour les administrateurs en cas d'evenements importants : echec de generation de rapport, expiration massive de QR Codes, alertes de securite.

## 19.3 Recommendations Personnalisees

Affichage de suggestions basees sur l'historique de l'employe (ex : "Vous avez choisi Pizza 12 fois ce mois-ci") lors de la selection du repas.

## 19.4 Mode Kiosque Avance

Verrouillage renforce de la tablette avec code PIN administrateur pour l'acces aux parametres systeme, desactive en mode normal.

## 19.5 Assistance Vocale

Guide vocal optionnel pour les utilisateurs malvoyants, annoncant les etapes du flux et lisant les messages multilingues.

---

# 20. Conclusion

La specification UX presentee dans ce document definit l'experience utilisateur complete de l'application tablette CSM-GIAS Resto+ pour sa version 1.0.

**Objectif de performance** : L'application a ete concue pour permettre a un employe de completer l'identification et l'enregistrement de son repas en moins de 10 secondes, sans contact et sans formation prealable. Ce temps est atteint grace a la detection automatique du visage, l'affichage immediat des categories, et la validation en un clic.

**Couverture fonctionnelle** : Les 19 ecrans specifies couvrent l'integralite des parcours utilisateurs documentes dans les User Stories : employe (identification faciale), stagiaire et visiteur (QR Code), reception (creation de comptes), et administrateur (gestion complete). Chaque ecran est trace jusqu'aux regles metier, user stories et endpoints API correspondants.

**Qualite d'entreprise** : Le design system uniforme, les principes UX (simplicite, vitesse, accessibilite), la gestion exhaustive des erreurs, et la prise en charge multilingue garantissent une experience professionnelle et inclusive.

**Maintenabilite** : Les composants reutilisables, les conventions strictes et la documentation detaillee de chaque ecran permettent a l'equipe de developpement React Native d'implementer l'interface avec precision et coherence.

Cette specification est directement exploitable par l'equipe de developpement pour la realisation des maquettes et l'implementation des ecrans. Le Product Owner et l'Architecte UX valideront la conformite lors des revues de Sprint.
