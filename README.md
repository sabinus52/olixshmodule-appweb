# olixshmodule-appweb
Module for oliXsh : Management of web applications


### Initialisation du module

Command : `olixsh appweb init [--force]`

Il suffit d'indiquer dans quel environnement seront installées les applications.
Valeurs possibles : `prod` `devp` `klif` `rect`


### Installation d'une application

**Pré-requis** :

- Le dépôt source doit contenir **obligatoirement** le fichier de conf `conf/appweb.yml`
- Le propriétaire de l'application doit être créé
- Sa clé publique et privée doit être généré dans `/$HOME/.ssh/id_dsa.pub`
avec la commande `ssh-keygen -q -t dsa -f ~/.ssh/id_dsa -N ''`

**Lancement de l'installation**

Command : `olixsh appweb install [<user>@<host>:/<path_of_appweb.yml>] [--env=xxxx] [--port=22]` _(mode intéractif)_

- `user` : Nom de l'utilisateur de connexion au serveur de dépôt
- `host` : Host du serveur de dépôt
- `path_of_appweb.yml` : Chemin complet du fichier de configuration appweb.yml
- `--port=` : Port du serveur de dépôt
- `--env=` : Environnement de l'utilisation des fichiers de configuration système à installer 

Si l'emplacement source du fichier de configuration `appweb.yml` n'est pas défini en paramètre,
il sera demander de les saisir.
La structure du fichier est décrite ici @TODO

Suivre l'execution de la commande


### Configuration de l'application

Changement de l'utilisation du fichier de configuration YML de l'application

Command : `olixsh appweb config <application>`

- `application` : Nom de l'application

Valeur à saisir dans le mode intéractif :

- Emplacement du fichier de configuration YML de l'application (var : `OLIX_MODULE_APPWEB_FILEYML`)
- Environnement `prod` `devp` `klif` `rect` (var : `OLIX_MODULE_APPWEB_ENVIRONMENT`)
- Nom de l'origine des sources (var : `OLIX_MODULE_APPWEB_ORIGIN_NAME`)
- Hostname du serveur d'origine des sources (var : `OLIX_MODULE_APPWEB_ORIGIN_HOST`)
- Port du serveur d'origine des sources (var : `OLIX_MODULE_APPWEB_ORIGIN_PORT`)
- Utilisateur de connexion du serveur d'origine des sources (var : `OLIX_MODULE_APPWEB_ORIGIN_USER`)
- Chemin distant sur le serveur d'origine des sources (var : `OLIX_MODULE_APPWEB_ORIGIN_PATH`)

*Genère le fichier de configuration /etc/olixsh/appweb.<appli>.conf*


### Gestion des dépôts

Command : `olixsh appweb origin <application> [number_repository]`

- `application` : Nom de l'application
- `number_repository` : Numéro du nouveau dépôt à utiliser

*Enregistre l'info dans le fichier /etc/olixsh/appweb.<appli>.conf dans les paramètre OLIX_MODULE_APPWEB_ORIGIN_XXXX*


### Backup de l'application

Réalisation d'une sauvegarde complète de l'application avec rapport pour des tâches planifiées.

Command : `olixsh appweb backup <application> [--env=xxxx]`

- `--env=` : Environnement de la sauvegarde 

Les paramètres supplémentaires pour la réalisation de la sauvegarde
sont dans le fichier de conf YML de l'appli comme suit
``` yml
backup:
    exclude:
        files: app/logs/\*\*.\*|app/cache/\*\*.\*
        bases:
    include:
        files:
        bases:
    prod:
        purge: log
        compress: gz
        repository: /home/projects/var/backup
        ftp:
            sync: lftp
            host: ftp.domain.ltd
            user: ftpuser
            pass: pwduser
            path: /backup
        report:
            type: text
            path: /var/backups
            mail: email@domain.tld
```
