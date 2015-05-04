###
# Librairies de la gestion des applications web
# ==============================================================================
# @package olixsh
# @module mysql
# @author Olivier <sabinus52@gmail.com>
##



###
# Retourne la liste des applications
# @return string
##
function module_appweb_getListApps()
{
    logger_debug "module_appweb_getListApps ()"
    local I

    local LIST=$(find ${OLIX_MODULE_APPWEB_CONFIG_DIR} -maxdepth 1 -mindepth 1 -type d)
    [[ $? -ne 0 ]] && return 1
    for I in ${LIST}; do
        echo -n "$(basename $I) "
    done
    return 0
}


###
# Test si une application existe
# @param $1 : Code de l'application
##
function module_appweb_isExist()
{
    logger_debug "module_appweb_isExist ($1)"
    [[ -r ${OLIX_MODULE_APPWEB_CONFIG_DIR}/$1/${OLIX_MODULE_APPWEB_FILECFG} ]] && return 0
    return 1
}


###
# Retourne le libellé de l'application
# @param $1 : Code de l'application
# @return string
##
function module_appweb_getLabel()
{
    logger_debug "module_appweb_getLabel ($1)"
    if module_appweb_isExist $1; then
        source ${OLIX_MODULE_APPWEB_CONFIG_DIR}/$1/${OLIX_MODULE_APPWEB_FILECFG}
        echo -n "${OLIX_CONF_PROJECT_NAME}"
    else
        echo -n "inconnu"
    fi
}


###
# Vérifie et charge le fichier de conf de l'application
# @param $1 : Code de l'application
##
function module_appweb_loadConfiguration()
{
    logger_debug "module_appweb_loadConfiguration ($1)"
    local FILECFG="${OLIX_MODULE_APPWEB_CONFIG_DIR}/$1/${OLIX_MODULE_APPWEB_FILECFG}"

    if ! module_appweb_isExist $1; then
        logger_warning "${FILECFG} absent"
        logger_error "Impossible de charger le fichier de configuration de l'application '$1'"
    fi
    logger_info "Chargement du fichier '${FILECFG}'"
    
    eval $(file_parseYaml ${FILECFG} "OLIX_MODULE_APPWEB_CONF_")
    OLIX_MODULE_APPWEB_CONFIG_DIR_APPWEB="${OLIX_MODULE_APPWEB_CONFIG_DIR}/${OLIX_MODULE_APPWEB_CODE}"
}
