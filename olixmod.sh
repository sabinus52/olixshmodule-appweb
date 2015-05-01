###
# Module de la gestion des applications web
# ==============================================================================
# ------------------------------------------------------------------------------
# @package olixsh
# @module appweb
# @author Olivier <sabinus52@gmail.com>
##

OLIX_MODULE_NAME="appweb"


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
    echo -e ""
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

    echo -n ""
}


###
# Initialisation du module
##
olixmod_init()
{
    logger_debug "module_appweb__olixmod_init (null)"
    source lib/stdin.lib.sh
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
    source modules/appweb/lib/usage.lib.sh

    if ! type "module_appweb_action_$ACTION" >/dev/null 2>&1; then
        logger_warning "Action inconnu : '$ACTION'"
        olixmod_usage 
        core_exit 1
    fi
    logger_info "Execution de l'action '${ACTION}' du module ${OLIX_MODULE_NAME}"
    
    # Charge la configuration du module
    config_loadConfigModule "${OLIX_MODULE_NAME}"

    # Affichage de l'aide de l'action
    [[ "$2" == "help" && "$1" != "init" ]] && module_appweb_usage_$ACTION && core_exit 0

    shift
    module_appweb_usage_getParams $@
    module_appweb_action_$ACTION $@
}
