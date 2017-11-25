###
# Installation d'une application depuis une source distante
# ==============================================================================
# @package olixsh
# @module webapp
# @author Olivier <sabinus52@gmail.com>
##


###
# Librairies
##
load 'utils/filesystem.sh'


###
# Vérification des paramètres
##
info "Test si root"
System.logged.isRoot || critical "Seulement root peut executer cette action"

if [[ -z $OLIX_MODULE_WEBAPP_ORIGIN_SERVER ]]; then
    Module.execute.usage "install"
    critical "Chaine de connexion au serveur distant manquante"
fi
if ! String.list.contains "$OLIX_MODULE_WEBAPP_LISTENV" $OLIX_MODULE_WEBAPP_ENVIRONMENT; then
    Module.execute.usage "install"
    critical "Valeur de l'environnement incorrecte"
fi
if ! String.digit $OLIX_MODULE_WEBAPP_ORIGIN_PORT; then
    Module.execute.usage "install"
    critical "Valeur du port incorrecte"
fi


###
# Récupération du fichier webapp.yml vers /tmp/webapp.yml
##
info "Récupération de ${OLIX_MODULE_WEBAPP_ORIGIN_SERVER}"
echo "Mot de passe du serveur contenant webapp.yml"
scp -P $OLIX_MODULE_WEBAPP_ORIGIN_PORT $OLIX_MODULE_WEBAPP_ORIGIN_SERVER /tmp/webapp.yml 2> ${OLIX_LOGGER_FILE_ERR}
[[ $? -ne 0 ]] && critical

Webapp.loadYML '/tmp/webapp.yml'



###
# Alerte
##
echo -e "${CROUGE}ATTENTION !!! ${CVOID}${Cjaune}Cela va écraser toutes les données actuelles (fichiers + base)${CVOID}"
echo -e "${Cjaune}Dossier : $(Webapp.get 'path')${CVOID}"
echo -e "${Cjaune}Base(s) : $(Webapp.get 'bases.bases')${CVOID}"
Read.confirm "Confirmer" false
[[ $OLIX_FUNCTION_RETURN == false ]] && return 0



###
# Traitement de l'installation
##
Print.head1 "Installation de l'application web %s %s %s" "$(Webapp.get 'label') (${OLIX_MODULE_WEBAPP_CODE})"

Webapp.origin.check
Webapp.origin.read


###
# Installation de paquets additionnels
##
Print.head2 "Installation de paquets additionnels"
Webapp.install.packages


###
# Installation des sources
##
Print.head2 "Installation des fichiers sources"
Webapp.install.directories
Webapp.install.files


###
# Restauration des bases de données
##
Print.head2 "Installation des bases de données"
Webapp.install.databases


###
# Si présence d'un script personnalisé
##
Print.head2 "Installation via le script personnalisé"
Webapp.install.script


###
# Installation de la configuration système
##
Print.head2 "Installation des fichiers systèmes"
Webapp.install.logrotate
Webapp.install.crontab
Webapp.install.apache
Webapp.install.certificate
systemctl restart apache2
if [[ $? -ne 0 ]]; then
    systemctl status apache2
    critical "Problème de démarrage d'Apache"
fi


###
# Création du fichier de configuration du serveur
##
OLIX_MODULE_WEBAPP_FILEYML=$(Webapp.fileyml)
if ! File.exists $OLIX_MODULE_WEBAPP_FILEYML; then
    Read.file "Chemin et fichier de configuration 'webapp.yml' de l'application $OLIX_MODULE_WEBAPP_CODE"
    OLIX_MODULE_WEBAPP_FILEYML=$OLIX_FUNCTION_RETURN
fi
OLIX_MODULE_WEBAPP_LABEL=$(Webapp.get 'label')
Webapp.config.save $OLIX_MODULE_WEBAPP_CODE
[[ $? -ne 0 ]] && critical "Erreur lors de la création du fichier de configuration webapp.${OLIX_MODULE_WEBAPP_CODE}.conf"



###
# FIN
##
echo -e "${CVERT}Action terminée avec succès${CVOID}"
