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


### Gestion des dépôts

Command : `olixsh appweb origin <application> [number_repository]`

- `application` : Nom de l'application
- `number_repository` : Numéro du nouveau dépôt à utiliser

*L'info est indiqué dans le fichier conf/appweb.conf dans le paramètre OLIX_MODULE_APPWEB_ORIGIN__application*


### Changement d'utilisation du fichier de conf YML

Les fichiers de configuration de chaque projet sont stockés dans le dossier `conf` du dossier d'installation de **oliXsh**
de la forme `appweb.[CODE_PROJECT].yml` avec **un lien symbolique obligatoirement** de l'emplacement du projet.


Il est possible de faire pointer le projet vers un autre fichier de configuration YML.

Aller dans le dossier d'installation de **oliXsh** et modifier le lien dans le dossier de `conf` :

``` bash
cd [OLIX_PATH_INSTALL]/conf
rm appweb.[PROJECT_NAME].yml
ln -s [PATH_NEW_FILE_CONFIG_YML] appweb.[PROJECT_NAME].yml
```

`[OLIX_PATH_INSTALL]` : Chemin d'installation de **oliXsh**

`[PROJECT_NAME]` : Code du projet

`[PATH_NEW_FILE_CONFIG_YML]` : Emplacement du nouveau fichier de configuration YML du projet

*Remettre les bons droits*

