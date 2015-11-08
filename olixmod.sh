###
# Module de la gestion des applications web
# ==============================================================================
# @package olixsh
# @module webapp
# @author Olivier <sabinus52@gmail.com>
##

OLIX_MODULE_NAME="webapp"

# Nom du fichier de conf de l'application par defaut
OLIX_MODULE_WEBAPP_CONFIG_FILE="webapp.yml"

# Nom du répertoire contenant le configuration de la webapp
OLIX_MODULE_WEBAPP_CONFIG_PATH="/xconf"

# Prefix des variables de sorties des paramètre du fichier de config
OLIX_MODULE_WEBAPP_CONFIG_PREFIX="OLIX_MODULE_WEBAPP_CONF_"

# Liste des environnements disponibles
OLIX_MODULE_WEBAPP_LISTENV="prod rect klif devp"

# Code de l'application (en paramètre)
OLIX_MODULE_WEBAPP_CODE=

# Emplacement du répertoire de la configuration de l'application (defini lors du chargement de la conf YML)
OLIX_MODULE_WEBAPP_CONFIG_DIR_WEBAPP=


# Label de l'application (fichier de conf conf/webapp.<appli>.conf) en cache
OLIX_MODULE_WEBAPP_LABEL=

# Emplacement du fichier de conf YML de l'application (fichier de conf conf/webapp.<appli>.conf) en cache
OLIX_MODULE_WEBAPP_FILEYML=

# Environnement de travail (fichier de conf conf/webapp.<appli>.conf ou par paramètre --env=)
OLIX_MODULE_WEBAPP_ENVIRONMENT=""

# Host d'origine des sources (fichier de conf conf/webapp.<appli>.conf)
OLIX_MODULE_WEBAPP_ORIGIN_NAME=
OLIX_MODULE_WEBAPP_ORIGIN_HOST=
OLIX_MODULE_WEBAPP_ORIGIN_PORT=22
OLIX_MODULE_WEBAPP_ORIGIN_USER=
OLIX_MODULE_WEBAPP_ORIGIN_PATH=


###
# Retourne la liste des modules requis
##
olixmod_require_module()
{
    echo -e ""
}


###
# Retourne la liste des binaires requis
##
olixmod_require_binary()
{
    echo -e "openssl"
}


###
# Usage de la commande
##
olixmod_usage()
{
    logger_debug "module_webapp__olixmod_usage ()"

    source modules/webapp/lib/usage.lib.sh
    module_webapp_usage_main
}


###
# Fonction de liste
##
olixmod_list()
{
    logger_debug "module_webapp__olixmod_list ($@)"

    config_loadConfigQuietModule "${OLIX_MODULE_NAME}"
    source modules/webapp/lib/webapp.lib.sh
    echo -n $(module_webapp_getListApps)
}


###
# Initialisation du module
##
olixmod_init()
{
    logger_debug "module_webapp__olixmod_init (null)"
    # Config par application via l'action "config"
    local FILECONF=$(config_getFilenameModule ${OLIX_MODULE_NAME})
    echo "# Fichier de configuration du module WEBAPP" > ${FILECONF}
    echo "# Voir les fichiers de conf par appli webapp.<appli>.conf" > ${FILECONF}
    [[ $? -ne 0 ]] && logger_critical
}


###
# Function principale
##
olixmod_main()
{
    logger_debug "module_webapp__olixmod_main ($@)"
    local ACTION=$1

    # Affichage de l'aide
    [ $# -lt 1 ] && olixmod_usage && core_exit 1
    [[ "$1" == "help" ]] && olixmod_usage && core_exit 0

    # Librairies necessaires
    source modules/webapp/lib/webapp.lib.sh
    source modules/webapp/lib/usage.lib.sh
    source modules/webapp/lib/action.lib.sh
    source lib/stdin.lib.sh
    source lib/file.lib.sh
    source lib/yaml.lib.sh
    source lib/filesystem.lib.sh
    source lib/system.lib.sh
    source modules/mysql/lib/mysql.lib.sh
    source modules/mysql/lib/usage.lib.sh

    if ! type "module_webapp_action_$ACTION" >/dev/null 2>&1; then
        logger_warning "Action inconnu : '$ACTION'"
        olixmod_usage 
        core_exit 1
    fi
    logger_info "Execution de l'action '${ACTION}' du module ${OLIX_MODULE_NAME}"
    
    # Charge la configuration du module
    config_loadConfigModule "${OLIX_MODULE_NAME}"

    # Affichage de l'aide de l'action
    [[ "$2" == "help" && "$1" != "init" ]] && module_webapp_usage_$ACTION && core_exit 0

    shift
    module_webapp_usage_getParams $@
    module_webapp_action_$ACTION $@
}
