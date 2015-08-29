###
# Module de la gestion des applications web
# ==============================================================================
# @package olixsh
# @module appweb
# @author Olivier <sabinus52@gmail.com>
##

OLIX_MODULE_NAME="appweb"

# Nom du fichier de conf de l'application
OLIX_MODULE_APPWEB_CONFIG_FILE="/conf/appweb.yml"

# Prefix des variables de sorties des paramètre du fichier de config
OLIX_MODULE_APPWEB_CONFIG_PREFIX="OLIX_MODULE_APPWEB_CONF_"

# Liste des environnements disponibles
OLIX_MODULE_APPWEB_LISTENV="prod rect klif devp"

# Environnement de travail (fichier de conf conf/appweb.conf ou par paramètre --env=)
OLIX_MODULE_APPWEB_ENVIRONMENT=

# Code de l'application (en paramètre)
OLIX_MODULE_APPWEB_CODE=

# Emplacement du répertoire de la configuration de l'application (defini lors du chargement de la conf YML)
OLIX_MODULE_APPWEB_CONFIG_DIR_APPWEB=

# Host d'origine des sources (en paramètre)
OLIX_MODULE_APPWEB_ORIGIN_NAME=
OLIX_MODULE_APPWEB_ORIGIN_HOST=
OLIX_MODULE_APPWEB_ORIGIN_PORT=22
OLIX_MODULE_APPWEB_ORIGIN_USER=
OLIX_MODULE_APPWEB_ORIGIN_PATH=


###
# Retourne la liste des modules requis
##
olixmod_require_module()
{
    echo -e "mysql"
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
    logger_debug "module_appweb__olixmod_usage ()"

    source modules/appweb/lib/usage.lib.sh
    module_appweb_usage_main
}


###
# Fonction de liste
##
olixmod_list()
{
    logger_debug "module_appweb__olixmod_list ($@)"

    config_loadConfigQuietModule "${OLIX_MODULE_NAME}"
    source modules/appweb/lib/appweb.lib.sh
    echo -n $(module_appweb_getListApps)
}


###
# Initialisation du module
##
olixmod_init()
{
    logger_debug "module_appweb__olixmod_init (null)"
    source modules/appweb/lib/action.lib.sh
    module_appweb_action_init $@
}


###
# Function principale
##
olixmod_main()
{
    logger_debug "module_appweb__olixmod_main ($@)"
    local ACTION=$1

    # Affichage de l'aide
    [ $# -lt 1 ] && olixmod_usage && core_exit 1
    [[ "$1" == "help" ]] && olixmod_usage && core_exit 0

    # Librairies necessaires
    source modules/appweb/lib/appweb.lib.sh
    source modules/appweb/lib/usage.lib.sh
    source modules/appweb/lib/action.lib.sh
    source lib/stdin.lib.sh
    source lib/file.lib.sh
    source lib/yaml.lib.sh
    source lib/filesystem.lib.sh
    source lib/system.lib.sh
    source modules/mysql/lib/mysql.lib.sh
    source modules/mysql/lib/usage.lib.sh

    if ! type "module_appweb_action_$ACTION" >/dev/null 2>&1; then
        logger_warning "Action inconnu : '$ACTION'"
        olixmod_usage 
        core_exit 1
    fi
    logger_info "Execution de l'action '${ACTION}' du module ${OLIX_MODULE_NAME}"
    
    # Charge la configuration du module
    config_loadConfigModule "${OLIX_MODULE_NAME}"
    config_loadConfigModule "mysql"

    # Affichage de l'aide de l'action
    [[ "$2" == "help" && "$1" != "init" ]] && module_appweb_usage_$ACTION && core_exit 0

    shift
    module_appweb_usage_getParams $@
    module_appweb_action_$ACTION $@
}
