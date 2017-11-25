###
# Usage du module WEBAPP
# ==============================================================================
# @package olixsh
# @module webapp
# @author Olivier <sabinus52@gmail.com>
##



###
# Usage principale  du module
##
function olixmodule_webapp_usage_main()
{
    debug "olixmodule_webapp_usage_main ()"
    echo
    echo -e "Gestion des applications web"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}webapp ${CJAUNE}ACTION${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des ACTIONS disponibles${CVOID} :"
    echo -e "${Cjaune} create   ${CVOID}  : Initialisation et création d'une nouvelle application"
    echo -e "${Cjaune} install  ${CVOID}  : Installation de l'application depuis un autre serveur"
    echo -e "${Cjaune} help     ${CVOID}  : Affiche cet écran"
    echo -e "${CJAUNE}Liste des ACTIONS disponibles pour une webapp donnée${CVOID} :"
    echo -e "${Cjaune} config   ${CVOID}  : Visualise et modifie la configuration de l'application sur ce serveur"
    echo -e "${Cjaune} origin   ${CVOID}  : Visualise ou affecte un nouveau dépôt d'origine des sources"
    echo -e "${Cjaune} applysys ${CVOID}  : Applique la configuration système (Apache, crontab, logrotate)"
    echo -e "${Cjaune} backup   ${CVOID}  : Fait une sauvegarde de l'application (base+fichiers)"
}


###
# Usage de l'action CREATE
##
function olixmodule_webapp_usage_create()
{
    debug "olixmodule_webapp_usage_create ()"
    echo
    echo -e "Initialisation et création d'une nouvelle application"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}webapp ${CJAUNE}create${CVOID}"
}


###
# Usage de l'action INSTALL
##
function olixmodule_webapp_usage_install()
{
    debug "olixmodule_webapp_usage_install ()"
    echo
    echo -e "Installation d'une application et copie des sources depuis un autre serveur"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}webapp ${CJAUNE}install${CVOID} ${CBLANC}[USER]@[HOST]:[PATH] [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -en "${CBLANC} --env=$OLIX_MODULE_WEBAPP_ENVIRONMENT ${CVOID}"; String.pad "--env=$OLIX_MODULE_WEBAPP_ENVIRONMENT" 20 " "; echo " : Environnement ($OLIX_MODULE_WEBAPP_LISTENV)"
    echo -en "${CBLANC} --port=$OLIX_MODULE_WEBAPP_ORIGIN_PORT ${CVOID}"; String.pad "--port=$OLIX_MODULE_WEBAPP_ORIGIN_PORT" 20 " "; echo " : Port de connexion au host"
    echo
    echo -e "${CJAUNE}[USER]@[HOST]:[PATH]${CVOID} :"
    echo -e "${Cjaune} user ${CVOID} : Nom de l'utilisateur de connexion au serveur"
    echo -e "${Cjaune} host ${CVOID} : Host du serveur"
    echo -e "${Cjaune} path ${CVOID} : Chemin complet du fichier de configuration webapp.yml"
    echo -e "    Exemple : toto@domain.tld:/home/toto/conf/webapp.yml"
}


###
# Usage de l'action CONFIG
##
function olixmodule_webapp_usage_config()
{
    debug "olixmodule_webapp_usage_config ()"
    echo
    echo -e "Visualise et modifie la configuration d'une application (l'installation doit être faite auparavant)"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}webapp ${CJAUNE}config${CVOID} ${CBLANC}<application>${CVOID}"
    echo
    olixmodule_webapp_usage_listapps
}


###
# Usage de l'action ORIGIN
##
function olixmodule_webapp_usage_origin()
{
    debug "olixmodule_webapp_usage_origin ()"
    echo
    echo -e "Visualise ou affecte un nouveau dépôt d'origine des sources"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}webapp ${CJAUNE}origin${CVOID} ${CBLANC}<application> [nouveau depot]${CVOID}"
    echo
    olixmodule_webapp_usage_listapps
}


###
# Usage de l'action APPLYSYS
##
function olixmodule_webapp_usage_applysys()
{
    debug "olixmodule_webapp_usage_applysys ()"
    echo
    echo -e "Applique la configuration système (Apache, crontab, logrotate)"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}webapp ${CJAUNE}applysys${CVOID} ${CBLANC}<application>${CVOID}"
    echo
    olixmodule_webapp_usage_listapps
}


###
# Usage de l'action BACKUP
##
function olixmodule_webapp_usage_backup()
{
    debug "olixmodule_webapp_usage_backup ()"
    echo
    echo -e "Installation d'une application et copie des sources depuis un autre serveur"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename $OLIX_ROOT_SCRIPT) ${CVERT}webapp ${CJAUNE}backup${CVOID} ${CBLANC}<application> [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -en "${CBLANC} --env=${OLIX_MODULE_WEBAPP_ENVIRONMENT} ${CVOID}"; stdout_strpad "--env=${OLIX_MODULE_WEBAPP_ENVIRONMENT}" 20 " "; echo " : Environnement (${OLIX_MODULE_WEBAPP_LISTENV})"
    echo
    olixmodule_webapp_usage_listapps
}


###
# Affiche la liste des applications disponibles
##
function olixmodule_webapp_usage_listapps()
{
    echo -e "${CJAUNE}Liste des APPLICATIONS disponibles${CVOID} :"
    for I in $(Webapp.applications); do
        Print.usage.item "$I" "Application $(Webapp.config.label $I)" 15
    done
}
