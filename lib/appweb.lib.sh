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

    local LIST=$(find ${OLIX_CONFIG_DIR} -maxdepth 1 -mindepth 1 -type l -name "appweb.*.yml")
    [[ $? -ne 0 ]] && return 1
    for I in ${LIST}; do
        echo -n "$(basename $I | sed "s/^appweb.\([a-zA-Z0-9]*\).yml$/\1/") "
    done
    return 0
}


###
# Retourne le fichier de conf YML
# @param $1 : Code de l'application
##
function module_appweb_getFileConfYML()
{
    logger_debug "module_appweb_getFileConfYML($1)"
    echo -n "${OLIX_CONFIG_DIR}/appweb.$1.yml"
}


###
# Test si une application existe
# @param $1 : Code de l'application
##
function module_appweb_isExist()
{
    logger_debug "module_appweb_isExist ($1)"
    [[ -r $(module_appweb_getFileConfYML $1) ]] && return 0
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
        yaml_parseFile $(module_appweb_getFileConfYML $1) "${OLIX_MODULE_APPWEB_CONFIG_PREFIX}"
        yaml_getConfig "label"
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

    local FILECFG=$(module_appweb_getFileConfYML $1)

    if ! module_appweb_isExist $1; then
        logger_warning "L'application '$1' n'est apparament pas installée"
    fi

    FILECFG=$(readlink ${FILECFG})
    module_appweb_loadFileConfYML "${FILECFG}" "$1"
}


###
# Charge le fichier de configuration YML REEL
# @param $1 : Emplacement réel du fichier de conf yml
# @param $2 : Code de l'application
##
function module_appweb_loadFileConfYML()
{
    logger_debug "module_appweb_loadFileConfYML ($1, $2)"

    local FILECFG=$1

    if [[ ! -r ${FILECFG} ]]; then
        logger_warning "${FILECFG} absent"
        logger_critical "Impossible de charger le fichier de configuration de l'application '$2'"
    fi

    logger_info "Chargement du fichier '${FILECFG}'"
    yaml_parseFile "${FILECFG}" "${OLIX_MODULE_APPWEB_CONFIG_PREFIX}"
    OLIX_MODULE_APPWEB_CONFIG_DIR_APPWEB=$(dirname ${FILECFG})
}
