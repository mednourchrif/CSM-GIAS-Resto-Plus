-- CSM-GIAS Resto+ — Initialisation de la base de données
-- Ce fichier est exécuté automatiquement par le conteneur MySQL Docker

CREATE DATABASE IF NOT EXISTS resto_plus
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'resto_user'@'%' IDENTIFIED BY 'change-me';
GRANT ALL PRIVILEGES ON resto_plus.* TO 'resto_user'@'%';
FLUSH PRIVILEGES;
