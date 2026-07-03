# Exigences Non Fonctionnelles
## CSM-GIAS Resto+
### Solution Intelligente de Gestion du Restaurant d'Entreprise

---

| Champ                  | Détail                                              |
|------------------------|-----------------------------------------------------|
| **Nom du projet**      | CSM-GIAS Resto+                                     |
| **Titre du document**  | Exigences Non Fonctionnelles                        |
| **Référence**          | CSM-GIAS-RESTO-ENF-v1.0                             |
| **Version**            | 1.0                                                 |
| **Date**               | Juillet 2026                                        |
| **Statut**             | Approuvé pour conception architecturale             |
| **Auteur**             | Architecte Logiciel / Stagiaire Ingénieur           |
| **Encadrant**          | Responsable Technique / DSI                         |
| **Confidentialité**    | Usage interne — Document propriétaire               |

---

## Historique des Révisions

| Version | Date         | Auteur                     | Description                                   |
|---------|--------------|----------------------------|-----------------------------------------------|
| 0.1     | Juin 2026    | Stagiaire — Département IT | Ébauche initiale                              |
| 0.9     | Juillet 2026 | Stagiaire — Département IT | Alignement avec la norme ISO/IEC 25010        |
| 1.0     | Juillet 2026 | Stagiaire — Département IT | Version approuvée pour architecture           |

---

## Table des Matières

1. Introduction
2. Exigences Non Fonctionnelles (Attributs de Qualité)
   - NFR-100 — Performance (Efficacité des performances)
   - NFR-200 — Disponibilité (Fiabilité)
   - NFR-300 — Fiabilité (Tolérance aux pannes)
   - NFR-400 — Sécurité (Confidentialité et Intégrité)
   - NFR-500 — Confidentialité (Protection des données privées)
   - NFR-600 — Maintenabilité (Modularité et Testabilité)
   - NFR-700 — Scalabilité (Extensibilité)
   - NFR-800 — Compatibilité (Coexistence et Interopérabilité)
   - NFR-900 — Utilisabilité (Ergonomie et Apprentissage)
   - NFR-1000 — Accessibilité
   - NFR-1100 — Monitoring (Supervision)
   - NFR-1200 — Journalisation (Traçabilité technique)
   - NFR-1300 — Sauvegarde (Protection des données)
   - NFR-1400 — Reprise d'Activité (Plan de Continuité)
   - NFR-1500 — Localisation (Adaptation culturelle)
   - NFR-1600 — Déploiement (Mise en production)
   - NFR-1700 — Contraintes Architecturales
   - NFR-1800 — Observabilité
3. Synthèse des Attributs de Qualité
4. Critères d'Acceptation par Catégorie
5. Glossaire
6. Conclusion

---

## 1. Introduction

### 1.1 Objet du Document

Le présent document définit les **Exigences Non Fonctionnelles (ENF)** ou **Attributs de Qualité** pour l'application **CSM-GIAS Resto+**. Tandis que les exigences fonctionnelles décrivent *ce que* le système doit faire, les exigences non fonctionnelles définissent *comment* le système doit le faire en termes de performance, de sécurité, de fiabilité et de maintenabilité.

Ce document est structuré conformément aux standards internationaux **IEEE 29148** pour la spécification des exigences, et s'appuie sur le modèle de qualité logicielle **ISO/IEC 25010** pour catégoriser de manière exhaustive les propriétés attendues du système.

### 1.2 Périmètre

Ces exigences s'appliquent à l'ensemble des composants de la solution CSM-GIAS Resto+ (version 1.0), incluant l'application mobile déployée sur la tablette Android, l'API backend REST, et la base de données relationnelle associée. Les contraintes s'appliquent également à l'infrastructure d'hébergement sous-jacente.

### 1.3 Relation avec les documents existants

Ce document est le troisième volet de la documentation d'ingénierie des exigences du projet. Il complète :
1. **Document de Vision Projet** : fixe les objectifs stratégiques globaux.
2. **Document des Règles Métier** : définit les contraintes de l'entreprise.
3. **Cahier des Exigences Fonctionnelles** : liste exhaustivement les fonctions du système.

Les exigences non fonctionnelles documentées ici ne dupliquent pas les règles métier ni les exigences fonctionnelles, mais contraignent techniquement leur implémentation. Elles s'assurent que la solution est non seulement fonctionnelle, mais aussi robuste, pérenne et sécurisée.

### 1.4 Importance des Exigences Non Fonctionnelles

Les ENF ont un impact fondamental et transversal sur l'architecture logicielle. Une architecture ne peut être validée que si elle démontre sa capacité à satisfaire ces attributs de qualité. Négliger les ENF conduit invariablement à des systèmes fragiles, coûteux à maintenir, non sécurisés et offrant une mauvaise expérience utilisateur, même si le code respecte parfaitement les exigences fonctionnelles.

---

## 2. Exigences Non Fonctionnelles (Attributs de Qualité)

Les exigences sont classées par catégorie de qualité. La priorité indique l'importance de l'exigence pour le lancement en production (Critique, Haute, Moyenne, Basse). Chaque exigence est associée à un critère de validation technique permettant de prouver son respect lors de la phase de test (QA).

### NFR-100 — Performance

Cette section définit les contraintes d'efficacité temporelle et d'utilisation des ressources du système.

| ID | Catégorie | Exigence Non Fonctionnelle | Priorité | Critère de validation |
|---|---|---|---|---|
| NFR-101 | Performance | Le temps de réponse de l'API pour une requête d'authentification par QR Code ne doit pas excéder 500 millisecondes (ms) au 95ème percentile. | Critique | Mesure de charge (Load Testing) via outil APM. |
| NFR-102 | Performance | Le processus complet d'identification par reconnaissance faciale, de la capture vidéo au retour de l'API, doit s'effectuer en moins de 3 secondes dans 99% des cas. | Critique | Chronométrage de bout en bout sur 100 tentatives. |
| NFR-103 | Performance | L'application sur tablette doit démarrer (Cold Start) et être prête à l'utilisation en moins de 2,5 secondes. | Haute | Profiling de démarrage sur la tablette cible. |
| NFR-104 | Performance | L'enregistrement d'un repas dans la base de données doit être confirmé à l'utilisateur final en moins de 400 ms. | Haute | Tests de latence réseau et temps de traitement DB. |
| NFR-105 | Performance | L'application mobile ne doit pas consommer plus de 150 Mo de mémoire vive (RAM) en fonctionnement normal continu. | Haute | Monitoring de la consommation mémoire sous Android Profiler. |
| NFR-106 | Performance | La génération du rapport mensuel (agrégation des données) doit s'exécuter en moins de 5 secondes, même avec un historique de 1 million d'enregistrements. | Haute | Simulation de base de données volumineuse et profiling SQL. |

---

### NFR-200 — Disponibilité

Cette section définit les exigences de temps de fonctionnement et d'accès ininterrompu au système.

| ID | Catégorie | Exigence Non Fonctionnelle | Priorité | Critère de validation |
|---|---|---|---|---|
| NFR-201 | Disponibilité | Le backend du système doit garantir un taux de disponibilité (Uptime) de 99,9% durant les jours ouvrés de l'entreprise. | Critique | Rapports de monitoring externe (Pingdom/Datadog). |
| NFR-202 | Disponibilité | Le système de restauration doit être pleinement opérationnel sans aucune interruption planifiée durant la plage horaire de 12h00 à 14h30. | Critique | Politique d'astreinte et gestion des fenêtres de maintenance. |
| NFR-203 | Disponibilité | Le temps d'arrêt maximum toléré pour un déploiement de mise à jour (Downtime) ne doit pas excéder 5 minutes en dehors des heures d'ouverture du restaurant. | Haute | Procédure de déploiement et métriques CI/CD. |
| NFR-204 | Disponibilité | En cas de perte de connectivité réseau momentanée (Micro-coupure), l'application mobile doit se reconnecter silencieusement en moins de 2 secondes au retour du réseau. | Haute | Tests de simulation de perte/rétablissement réseau (Chaos Testing). |
| NFR-205 | Disponibilité | L'API doit être conçue en mode sans état (Stateless) pour permettre la redondance et garantir la haute disponibilité. | Critique | Revue d'architecture et de code. |

---

### NFR-300 — Fiabilité

Cette section définit la tolérance aux pannes, la maturité et la capacité de récupération du système.

| ID | Catégorie | Exigence Non Fonctionnelle | Priorité | Critère de validation |
|---|---|---|---|---|
| NFR-301 | Fiabilité | Le taux d'erreur serveur (HTTP 500) du backend ne doit pas excéder 0,1% du total des requêtes sur une période de 24 heures. | Critique | Analyse des logs serveur et métriques APM. |
| NFR-302 | Fiabilité | En cas de plantage (Crash) de l'application Android, celle-ci doit redémarrer automatiquement sans intervention humaine. | Haute | Tests d'injection d'exceptions non gérées (Monkey Testing). |
| NFR-303 | Fiabilité | Les transactions en base de données pour l'enregistrement d'un repas doivent respecter les propriétés ACID (Atomicité, Cohérence, Isolation, Durabilité). | Critique | Revue d'architecture de la base de données. |
| NFR-304 | Fiabilité | Si un composant tiers (ex: serveur SMTP) devient indisponible, le système applicatif principal ne doit pas crasher (Isolation des pannes). | Haute | Simulation de défaillance réseau sur les dépendances. |
| NFR-305 | Fiabilité | L'application doit gérer gracieusement l'absence de réseau avec un message informatif, sans bloquer le thread principal (UI). | Haute | Tests applicatifs en mode avion. |
| NFR-306 | Fiabilité | Si la connexion réseau est temporairement indisponible, l'application doit informer clairement l'utilisateur et reprendre automatiquement le fonctionnement normal dès le rétablissement de la connexion. | Haute | Tests de déconnexion et reconnexion réseau. |

---

### NFR-400 — Sécurité

Cette section définit les protections contre les accès non autorisés, les altérations de données et les menaces réseau.

| ID | Catégorie | Exigence Non Fonctionnelle | Priorité | Critère de validation |
|---|---|---|---|---|
| NFR-401 | Sécurité | L'intégralité des échanges de données entre l'application mobile et le serveur doit être chiffrée via le protocole TLS 1.3 (HTTPS). | Critique | Audit réseau et analyse SSL Labs. |
| NFR-402 | Sécurité | Les mots de passe des administrateurs doivent être hachés en base de données en utilisant l'algorithme Argon2 ou bcrypt avec un sel unique (Salt). | Critique | Revue de code et audit base de données. |
| NFR-403 | Sécurité | Les jetons d'authentification JWT de l'administration doivent expirer obligatoirement après 60 minutes d'inactivité. | Haute | Tests de session et d'expiration de Token. |
| NFR-404 | Sécurité | L'API doit implémenter une limitation de débit (Rate Limiting) pour prévenir les attaques par force brute ou les dénis de service (DDoS). | Haute | Tests de pénétration automatisés (PenTest). |
| NFR-405 | Sécurité | La base de données ne doit pas être directement exposée sur Internet. Elle doit être isolée au sein d'un réseau privé virtuel (VPC). | Critique | Audit de configuration réseau et règles de pare-feu. |
| NFR-406 | Sécurité | Toute entrée utilisateur provenant de l'application ou de requêtes API doit être systématiquement validée (Sanitization) contre les injections SQL et failles XSS. | Critique | Tests d'analyse de code statique (SAST) et PenTest. |

---

### NFR-500 — Confidentialité

Cette section couvre la protection des informations personnelles, spécifiquement les données biométriques.

| ID | Catégorie | Exigence Non Fonctionnelle | Priorité | Critère de validation |
|---|---|---|---|---|
| NFR-501 | Confidentialité | Les vecteurs de caractéristiques faciales (Face Embeddings) extraits doivent être stockés de manière chiffrée au repos (Encryption at Rest) dans la base de données. | Critique | Audit de chiffrement des volumes de stockage. |
| NFR-502 | Confidentialité | L'application ne doit en aucun cas stocker ou conserver localement des photos des employés sur le système de fichiers de la tablette. | Critique | Inspection du système de fichiers de la tablette post-utilisation. |
| NFR-503 | Confidentialité | Le système doit permettre l'exportation structurée des données personnelles d'un employé sur demande (Droit d'accès RGPD). | Haute | Démonstration de l'extraction par l'administration (script ou requêtes SQL). |
| NFR-504 | Confidentialité | Le système doit garantir la purge effective des données biométriques sous 24 heures suite à la suppression d'un profil employé. | Critique | Vérification en base de données après exécution de l'opération. |
| NFR-505 | Confidentialité | Les logs applicatifs (techniques et métier) ne doivent contenir aucune donnée personnellement identifiable (PII) en clair. | Haute | Audit régulier des fichiers de logs système. |

---

### NFR-600 — Maintenabilité

Cette section définit la facilité avec laquelle le système peut être modifié, corrigé ou mis à jour par l'équipe de développement.

| ID | Catégorie | Exigence Non Fonctionnelle | Priorité | Critère de validation |
|---|---|---|---|---|
| NFR-601 | Maintenabilité | Le code source backend doit atteindre une couverture de tests unitaires (Test Coverage) minimale de 80% pour la logique métier. | Haute | Rapport d'analyse statique (SonarQube/Jacoco/Coverage). |
| NFR-602 | Maintenabilité | Le projet doit adhérer strictement à un guide de style de codage industriel (ex: PEP8 pour Python, ESLint pour JS/TS) validé automatiquement par intégration continue. | Moyenne | Exécution réussie des Linters en CI. |
| NFR-603 | Maintenabilité | L'architecture du backend doit respecter les principes SOLID pour garantir un haut niveau de modularité et une faible dépendance (Loose Coupling). | Haute | Revue d'architecture par un pair technique. |
| NFR-604 | Maintenabilité | L'ensemble des points d'entrée de l'API REST doit être documenté via la spécification OpenAPI (Swagger) avec des exemples de requêtes et de réponses. | Haute | Vérification de la disponibilité et de l'exactitude de la page Swagger. |
| NFR-605 | Maintenabilité | La complexité cyclomatique des fonctions métier (règles de gestion des repas, expirations) ne doit pas dépasser le score de 10. | Haute | Rapport d'analyse statique du code (ex: SonarQube). |

---

### NFR-700 — Scalabilité

Cette section définit la capacité du système à absorber une montée en charge sans dégradation des performances.

| ID | Catégorie | Exigence Non Fonctionnelle | Priorité | Critère de validation |
|---|---|---|---|---|
| NFR-701 | Scalabilité | Le backend doit être capable de traiter au minimum 100 requêtes d'identification simultanées par seconde (RPS) sans dégrader le temps de réponse. | Haute | Stress Testing via outils de simulation de charge (JMeter/Locust). |
| NFR-702 | Scalabilité | L'architecture API doit supporter une mise à l'échelle horizontale (Horizontal Scaling) sans nécessité de modifier le code applicatif. | Haute | Démonstration de déploiement sur plusieurs instances/conteneurs derrière un Load Balancer. |
| NFR-703 | Scalabilité | La base de données relationnelle doit supporter jusqu'à 5 millions d'enregistrements dans la table des repas avec une dégradation des requêtes d'agrégation inférieure à 10%. | Moyenne | Tests de performance sur une base de données de test provisionnée massivement. |
| NFR-704 | Scalabilité | Le système d'envoi d'emails doit être asynchrone (via file d'attente ou workers) pour ne pas bloquer les ressources API lors de l'envoi de rapports volumineux. | Haute | Revue d'architecture technique du traitement des tâches planifiées. |

---

### NFR-800 — Compatibilité

Cette section définit les contraintes de fonctionnement avec d'autres systèmes, plateformes et environnements.

| ID | Catégorie | Exigence Non Fonctionnelle | Priorité | Critère de validation |
|---|---|---|---|---|
| NFR-801 | Compatibilité | L'application mobile (APK) doit être compatible avec le système d'exploitation Android, à partir de la version 10.0 (API Level 29) et supérieures. | Critique | Installation et exécution réussies sur émulateurs et terminaux cibles Android 10+. |
| NFR-802 | Compatibilité | L'API backend doit fournir des réponses strictes au format JSON standard (application/json) pour toutes ses routes d'échange de données. | Haute | Inspection des Headers HTTP des réponses API. |
| NFR-803 | Compatibilité | La taille de l'écran cible pour l'interface de l'application tablette est le format 10 pouces (orientation portrait), avec une résolution minimale de 1920x1200 pixels. | Critique | Vérification visuelle du rendu UI sur un écran aux dimensions spécifiées. |
| NFR-804 | Compatibilité | L'export ou l'impression des rapports générés (via email) doit conserver son intégrité visuelle sur les principaux clients mail (Outlook, Gmail, Apple Mail). | Moyenne | Tests d'affichage sur Litmus ou manuellement sur plusieurs plateformes. |

---

### NFR-900 — Utilisabilité

Cette section définit les critères d'ergonomie, de facilité d'usage et d'expérience pour l'utilisateur final.

| ID | Catégorie | Exigence Non Fonctionnelle | Priorité | Critère de validation |
|---|---|---|---|---|
| NFR-901 | Utilisabilité | Le contraste des éléments textuels de l'interface par rapport à leur arrière-plan doit respecter au minimum le ratio de 4.5:1 (Standard WCAG AA). | Haute | Analyse de l'interface via un outil de vérification de contraste (ex: Contrast Checker). |
| NFR-902 | Utilisabilité | La taille minimale des boutons d'interaction principaux (Catégories de repas) doit être de 48x48 dp pour garantir un confort d'utilisation tactile (Tap Target Size). | Haute | Inspection des spécifications UI et tests tactiles. |
| NFR-903 | Utilisabilité | Les messages d'erreur affichés sur la tablette ne doivent contenir aucun code d'erreur technique (ex: Stacktrace, code SQL) mais uniquement un message fonctionnel vulgarisé. | Critique | Revue fonctionnelle des cas d'échecs. |
| NFR-904 | Utilisabilité | Aucune interaction complexe nécessitant un clavier virtuel ne doit être demandée aux utilisateurs finaux (Employés, Stagiaires, Visiteurs) lors du processus d'enregistrement du repas. | Critique | Parcours UX validé sans nécessité d'input textuel. |

---

### NFR-1000 — Accessibilité

Cette section traite de la capacité du système à être utilisé par le plus grand nombre, quelles que soient leurs contraintes éventuelles, bien que l'application soit destinée à un usage interne très spécifique.

| ID | Catégorie | Exigence Non Fonctionnelle | Priorité | Critère de validation |
|---|---|---|---|---|
| NFR-1001 | Accessibilité | Les statuts de validation ou d'erreur sur l'écran de la tablette ne doivent pas dépendre uniquement de la couleur (ex: ajout d'icônes spécifiques) pour être perçus par des personnes daltoniennes. | Haute | Revue de l'UI avec filtres de simulation de daltonisme. |
| NFR-1002 | Accessibilité | L'interface doit supporter le mode "Texte élargi" du système d'exploitation Android sans casser la mise en page (Layout Overflow). | Moyenne | Tests applicatifs avec la taille de police système réglée au maximum. |
| NFR-1003 | Accessibilité | Les animations et transitions visuelles (ex: scan du visage) ne doivent pas déclencher de clignotements rapides (inférieurs à 3 Hz) pour éviter tout risque lié à la photosensibilité. | Haute | Audit visuel des animations de l'interface. |

---

### NFR-1100 — Monitoring

Cette section décrit les capacités d'observation en temps réel de l'état de santé du système.

| ID | Catégorie | Exigence Non Fonctionnelle | Priorité | Critère de validation |
|---|---|---|---|---|
| NFR-1101 | Monitoring | L'API backend doit exposer une route de vérification d'état (Healthcheck, ex: `/health`) retournant le statut opérationnel de la base de données et du service. | Critique | Appel curl sur l'endpoint retournant un HTTP 200 avec payload JSON d'état. |
| NFR-1102 | Monitoring | Le système doit permettre l'exportation des métriques d'infrastructure (CPU, RAM, Latence HTTP) dans un format lisible par un outil comme Prometheus. | Haute | Intégration vérifiée avec un serveur de monitoring. |
| NFR-1103 | Monitoring | Les tâches de génération de rapports (Cron jobs) doivent exposer une métrique indiquant leur succès ou leur échec lors de leur dernière exécution. | Moyenne | Inspection des métriques personnalisées du système. |

---

### NFR-1200 — Journalisation (Logging)

Cette section couvre les exigences de traçabilité technique (distinctes du journal d'audit fonctionnel).

| ID | Catégorie | Exigence Non Fonctionnelle | Priorité | Critère de validation |
|---|---|---|---|---|
| NFR-1201 | Journalisation | Tous les logs techniques générés par le backend doivent être formatés en JSON structuré pour faciliter leur ingestion par des systèmes centralisés (ex: ELK stack). | Haute | Inspection de la sortie standard (stdout) du backend applicatif. |
| NFR-1202 | Journalisation | Les niveaux de logs doivent être strictement respectés et configurables via variable d'environnement (DEBUG, INFO, WARN, ERROR). En production, le niveau doit être restreint à INFO. | Haute | Modification de la variable d'environnement et vérification de l'application de la règle. |
| NFR-1203 | Journalisation | Chaque requête entrante sur l'API doit être logguée avec une référence unique (Trace ID, Correlation ID) afin de suivre le flux de traitement de la requête de bout en bout. | Haute | Analyse des logs montrant la propagation d'un identifiant de requête. |
| NFR-1204 | Journalisation | Le système de journalisation local ne doit pas dépasser 5 Go d'espace disque. Une politique de rotation (Log Rotation) des fichiers locaux doit être configurée. | Haute | Audit des configurations de rotation de logs système. |

---

### NFR-1300 — Sauvegarde

Cette section définit les exigences de protection contre la perte de données à long terme.

| ID | Catégorie | Exigence Non Fonctionnelle | Priorité | Critère de validation |
|---|---|---|---|---|
| NFR-1301 | Sauvegarde | Le système de base de données doit faire l'objet d'une sauvegarde complète (Full Backup) de manière automatisée une fois par jour (en dehors des heures de service). | Critique | Vérification de la configuration des tâches planifiées de la base de données. |
| NFR-1302 | Sauvegarde | Les fichiers de sauvegarde doivent être conservés sur une période glissante de 30 jours, puis supprimés automatiquement pour des raisons d'optimisation de stockage. | Haute | Revue de la politique de rétention (Lifecycle Policy) du système de stockage externe. |
| NFR-1303 | Sauvegarde | Les sauvegardes doivent être stockées dans un emplacement de stockage distant et isolé géographiquement (Off-site storage) par rapport à l'infrastructure de production principale. | Critique | Audit de l'architecture de stockage des sauvegardes. |

---

### NFR-1400 — Reprise d'Activité

Cette section définit la capacité de restauration rapide après une catastrophe technique majeure.

| ID | Catégorie | Exigence Non Fonctionnelle | Priorité | Critère de validation |
|---|---|---|---|---|
| NFR-1401 | Reprise d'Activité | L'objectif de point de récupération (RPO - Recovery Point Objective) du système ne doit pas excéder 24 heures (soit la perte maximale de données acceptable équivalant à une journée de repas). | Critique | Analyse formelle de la stratégie de sauvegarde. |
| NFR-1402 | Reprise d'Activité | L'objectif de temps de récupération (RTO - Recovery Time Objective) pour restaurer complètement le système backend à partir d'une sauvegarde sur une infrastructure vierge ne doit pas excéder 4 heures. | Haute | Exercice pratique annuel de simulation de reprise (Disaster Recovery Drill). |
| NFR-1403 | Reprise d'Activité | Les scripts de provisionnement d'infrastructure (ex: Terraform, Ansible) et de déploiement doivent être conservés dans un gestionnaire de code source pour permettre une reconstruction rapide (Infrastructure as Code). | Haute | Audit du dépôt de configuration. |

---

### NFR-1500 — Localisation

Cette section définit l'adaptabilité du système aux contraintes régionales et linguistiques techniques.

| ID | Catégorie | Exigence Non Fonctionnelle | Priorité | Critère de validation |
|---|---|---|---|---|
| NFR-1501 | Localisation | Tous les composants du système (Base de données, Serveur, Application) doivent traiter et stocker les chaînes de caractères en utilisant strictement l'encodage UTF-8 (support des caractères arabes). | Critique | Insertion et récupération réussies de données multilingues dans la base de données. |
| NFR-1502 | Localisation | L'ensemble de la logique temporelle du backend (horodatage, expirations, contrôle de plage horaire) doit reposer sur l'heure de référence universelle UTC (Coordinated Universal Time). | Critique | Revue de code pour la gestion des instances temporelles. |
| NFR-1503 | Localisation | La conversion entre le temps UTC (backend) et l'heure locale (affichage interface, génération de rapports) doit se faire de manière dynamique selon le fuseau horaire du serveur (TZ variable). | Haute | Tests avec la modification artificielle du fuseau horaire serveur (Timezone). |
| NFR-1504 | Localisation | Le système doit utiliser une source horaire unique et synchronisée (NTP/SNTP) afin de garantir la cohérence des contrôles horaires et des rapports. | Critique | Vérification de la configuration NTP du serveur et de l'écart maximal toléré. |

---

### NFR-1600 — Déploiement

Cette section définit les contraintes de mise à disposition et d'installation des environnements.

| ID | Catégorie | Exigence Non Fonctionnelle | Priorité | Critère de validation |
|---|---|---|---|---|
| NFR-1601 | Déploiement | Le packaging du backend doit être réalisé sous forme d'image de conteneur (ex: Docker) afin de garantir une isolation stricte des dépendances d'exécution par rapport à l'hôte. | Haute | Vérification de la disponibilité du fichier de définition de conteneur (Dockerfile). |
| NFR-1602 | Déploiement | L'application tablette Android doit être signée numériquement avec une clé d'entreprise sécurisée pour permettre le déploiement MDM (Mobile Device Management). | Critique | Tentative d'installation via la politique MDM d'entreprise de test. |
| NFR-1603 | Déploiement | Le processus de déploiement des API backend doit être automatisé via un pipeline d'Intégration Continue / Déploiement Continu (CI/CD) validant les tests automatisés avant le push en production. | Haute | Démonstration du fonctionnement du pipeline CI/CD sur un dépôt Git. |
| NFR-1604 | Déploiement | L'application doit gérer ses configurations via des variables d'environnement externes (Environment Variables) conformes à la méthodologie "Twelve-Factor App", sans nécessiter la recompilation du code. | Haute | Déploiement réussi sur deux environnements différents (Staging / Prod) avec le même livrable. |
| NFR-1605 | Déploiement | Le système doit supporter plusieurs environnements distincts : Développement (Dev), Recette (Staging) et Production (Prod), chacun avec sa propre configuration isolée. | Critique | Déploiement et exécution réussis sur au moins deux environnements distincts. |

---

### NFR-1700 — Contraintes Architecturales

Cette section recense les directives technologiques majeures imposées à l'équipe de développement.

| ID | Catégorie | Exigence Non Fonctionnelle | Priorité | Critère de validation |
|---|---|---|---|---|
| NFR-1701 | Contrainte Architecture | Le développement mobile doit respecter l'architecture retenue et documentée dans les Architecture Decision Records (ADR) du projet. | Critique | Vérification de conformité avec les ADR du projet. |
| NFR-1702 | Contrainte Architecture | L'API backend doit respecter l'architecture retenue et documentée dans les Architecture Decision Records (ADR) du projet. | Critique | Vérification de conformité avec les ADR du projet. |
| NFR-1703 | Contrainte Architecture | La couche de persistance doit respecter l'architecture retenue et documentée dans les Architecture Decision Records (ADR) du projet. | Critique | Vérification de conformité avec les ADR du projet. |
| NFR-1704 | Contrainte Architecture | Le système de reconnaissance faciale utilisé doit être capable de traiter le flux biométrique sans dépendance à une API Cloud externe, garantissant un traitement Edge ou serveur local. | Haute | Preuve de concept (PoC) en environnement hors-ligne externe. |

---

### NFR-1800 — Observabilité

Cette section définit les capacités d'observation avancée du système permettant de comprendre son comportement interne en production, au-delà du simple monitoring traditionnel.

| ID | Catégorie | Exigence Non Fonctionnelle | Priorité | Critère de validation |
|---|---|---|---|---|
| NFR-1801 | Observabilité | Le système doit implémenter un mécanisme de traçage distribué (Distributed Tracing) permettant de suivre le parcours d'une requête à travers l'ensemble des composants (tablette, API, base de données). | Haute | Visualisation d'une trace complète dans un outil APM (Jaeger, Zipkin). |
| NFR-1802 | Observabilité | Chaque requête traitée par le système doit se voir attribuer un identifiant de corrélation unique (Correlation ID), propagé à travers tous les composants et logs. | Critique | Présence du Correlation ID dans les logs de chaque composant pour une même transaction. |
| NFR-1803 | Observabilité | Le système doit exposer des métriques techniques en temps réel (temps de réponse, débit, taux d'erreur, utilisation mémoire) au format standard (Prometheus). | Haute | Intégration vérifiée avec un serveur Prometheus et visualisation dans Grafana. |
| NFR-1804 | Observabilité | Un tableau de bord de supervision (Dashboard) doit être fourni, visualisant l'état de santé en temps réel du système, incluant le trafic, les latences et les erreurs par composant. | Moyenne | Dashboard fonctionnel présentant au moins 5 métriques clés. |
| NFR-1805 | Observabilité | Le système doit permettre la configuration d'alertes automatisées se déclenchant en cas de dépassement de seuils critiques (latence excessive, taux d'erreur anormal, indisponibilité d'un composant). | Haute | Alerte déclenchée et notifiée lors d'un test de dégradation volontaire. |

---

## 3. Synthèse des Attributs de Qualité

Le tableau suivant récapitule les 17 catégories de qualités couvertes par les exigences non fonctionnelles de la solution.

| Catégorie ISO 25010 | Attribut technique (ENF) | Nombre d'exigences |
|---|---|---|
| **Efficacité des performances** | NFR-100 — Performance | 6 |
| **Fiabilité** | NFR-200 — Disponibilité | 5 |
| **Fiabilité** | NFR-300 — Fiabilité (Tolérance) | 6 |
| **Sécurité** | NFR-400 — Sécurité | 6 |
| **Sécurité** | NFR-500 — Confidentialité | 5 |
| **Maintenabilité** | NFR-600 — Maintenabilité | 5 |
| **Efficacité des performances** | NFR-700 — Scalabilité | 4 |
| **Compatibilité** | NFR-800 — Compatibilité | 4 |
| **Utilisabilité** | NFR-900 — Utilisabilité | 4 |
| **Utilisabilité** | NFR-1000 — Accessibilité | 3 |
| **Maintenabilité (Analyse)** | NFR-1100 — Monitoring | 3 |
| **Maintenabilité (Analyse)** | NFR-1200 — Journalisation | 4 |
| **Fiabilité (Récupération)** | NFR-1300 — Sauvegarde | 3 |
| **Fiabilité (Récupération)** | NFR-1400 — Reprise d'Activité | 3 |
| **Compatibilité (Coexistence)** | NFR-1500 — Localisation | 4 |
| **Portabilité (Installation)** | NFR-1600 — Déploiement | 5 |
| **Portabilité (Environnement)**| NFR-1700 — Contraintes Arch. | 4 |
| **Maintenabilité (Analyse)** | NFR-1800 — Observabilité | 5 |
| **Total** | | **79 Exigences** |

---

## 4. Critères d'Acceptation par Catégorie

Afin de simplifier la validation globale de la solution, voici les critères d'acceptation macroscopiques que la QA doit vérifier pour valider les principaux piliers de qualité avant la mise en production :

- **Performance** : Tous les endpoints API critiques (enregistrement, authentification) répondent systématiquement en dessous de la barre des 500 ms (hors réseau client). L'application consomme moins de 150 Mo de RAM.
- **Disponibilité** : Le monitoring prouve une disponibilité minimale de 99.9% sur l'environnement de recette prolongée de 15 jours consécutifs, garantissant l'absence de fuites mémoire (Memory Leaks) fatales.
- **Sécurité** : Le rapport de PenTest automatisé ne remonte aucune vulnérabilité de niveau Élevé ou Critique. L'audit confirme le chiffrement strict des bases de données de visages.
- **Maintenabilité** : Le score de couverture de tests sur le backend est certifié >= 80% par l'outil de CI. L'API est dotée d'une page Swagger fonctionnelle.
- **Utilisabilité** : Le parcours d'enregistrement nominal sur la tablette d'une personne novice complète se déroule sans accroc, sans clavier virtuel, en moins de 10 secondes (incluant la prise de connaissance visuelle des options).
- **Compatibilité** : L'APK est installé et s'exécute nativement et sans glitch visuel sur une tablette de test de 10 pouces sous Android 10+.
- **Accessibilité** : L'application passe avec succès un audit automatisé vérifiant le respect des contrastes WCAG AA (ratio 4.5:1).

---

## 5. Glossaire

Le présent glossaire définit les termes techniques, relatifs à l'architecture logicielle et à la qualité, utilisés spécifiquement dans ce document. 

---

**Authentification (Authentication)** : Processus de vérification de l'identité d'une entité. Dans ce système, l'authentification est réalisée de manière biométrique (visage), cryptographique (QR Code) ou via jeton d'accès (JWT pour admin).

**Autorisation (Authorization)** : Mécanisme qui détermine si l'entité authentifiée a le droit d'effectuer une action spécifique.

**Backup (Sauvegarde)** : Action de copier l'état exact des données (Base de données) à un instant T vers un stockage sécurisé et séparé physiquement, afin de prévenir la perte d'informations.

**Disponibilité (Availability)** : Probabilité (exprimée en pourcentage, ex: 99.9%) que le système soit fonctionnel et accessible aux utilisateurs autorisés à un moment donné, particulièrement lors de la plage horaire d'ouverture du restaurant.

**Disaster Recovery (Reprise d'Activité)** : Ensemble des processus techniques permettant de restaurer le système d'information complet à la suite d'un sinistre majeur (panne serveur matérielle, corruption grave de base de données). Défini principalement par les objectifs RTO (Temps de restauration) et RPO (Point de restauration).

**Encryption (Chiffrement)** : Processus de conversion des informations lisibles en données illisibles appelées "données chiffrées" via un algorithme mathématique, garantissant que seuls les systèmes possédant la clé de déchiffrement peuvent lire la donnée originale. (ex: Chiffrement en transit via TLS).

**Logging (Journalisation)** : Enregistrement chronologique et technique des événements du système. Permet le diagnostic post-mortem en cas de bug. (Différent de l'Audit fonctionnel métier).

**Maintainability (Maintenabilité)** : Attribut de qualité mesurant la facilité, la rapidité et la sécurité avec lesquelles le code source peut être modifié, que ce soit pour corriger un bug ou pour ajouter une nouvelle fonctionnalité, souvent estimée via la couverture de tests et l'utilisation de principes d'architecture logicielle propres (ex: SOLID, Clean Architecture).

**Monitoring (Supervision)** : Action d'observer en continu les métriques techniques du système (ex: Utilisation CPU, utilisation RAM, temps de latence réseau) afin de détecter les comportements anormaux avant qu'ils ne se transforment en pannes visibles par les utilisateurs.

**Reliability (Fiabilité)** : Degré auquel le système performe ses fonctions spécifiées sous des conditions données pendant une période donnée. Inclut les concepts de tolérance aux pannes (Fault Tolerance) et la résilience logicielle.

**Scalability (Scalabilité ou Mise à l'échelle)** : Capacité du système logiciel à gérer une augmentation soudaine de la charge de travail (plus d'utilisateurs, plus de données) en ajoutant des ressources proportionnelles, de manière fluide et prévisible, sans dégrader le service.

---

## 6. Conclusion

L'établissement de ce référentiel d'**Exigences Non Fonctionnelles** constitue l'étape décisive clôturant la phase d'Ingénierie des Exigences pour la version 1.0 du projet CSM-GIAS Resto+. 

Les exigences fonctionnelles garantissent que le logiciel est utile (enregistrement de repas, génération de rapports). Mais ce sont les exigences non fonctionnelles définies dans ce présent document qui garantissent que le logiciel est **utilisable en production d'entreprise**. Elles certifient que l'application ne s'effondrera pas à l'heure de pointe, que les données biométriques privées des employés resteront protégées face aux cybermenaces, et que l'architecture logicielle sera capable d'absorber la future roadmap (Tableau de bord web) sans nécessiter de refonte technique.

Ces 79 contraintes structurelles, inspirées de l'ISO/IEC 25010, imposent des fondations solides. Elles fournissent désormais aux architectes logiciels les limites précises au sein desquelles concevoir la solution conformément aux Architecture Decision Records (ADR) du projet. Elles servent également de référence absolue aux équipes de Qualité (QA) et DevOps pour paramétrer leurs outils de CI/CD, définir leurs métriques de monitoring, et concevoir les campagnes de tests de charge et de pénétration automatisées. 

La validation stricte de l'ensemble de ces critères conditionnera l'autorisation de mise en production de la solution CSM-GIAS Resto+.

---

*Document rédigé dans le cadre d'un stage en ingénierie logicielle — CSM-GIAS, Été 2026.*
