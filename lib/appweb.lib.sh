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
function module_webapp_getListApps()
{
    logger_debug "module_webapp_getListApps ()"
    local I

    local LIST=$(find ${OLIX_CORE_PATH_CONFIG} -maxdepth 1 -mindepth 1 -type f -name "webapp.*.conf")
    [[ $? -ne 0 ]] && return 1
    for I in ${LIST}; do
        echo -n "$(basename $I | sed "s/^webapp.\([a-zA-Z0-9]*\).conf$/\1/") "
    done
    return 0
}


###
# Retourne le fichier de conf de l'application
# @param $1 : Code de l'application
##
function module_webapp_getFileConf()
{
    logger_debug "module_webapp_getFileConf($1)"
    echo -n "${OLIX_CORE_PATH_CONFIG}/webapp.$1.conf"
}


###
# Test si une application existe
# @param $1 : Code de l'application
##
function module_webapp_isExist()
{
    logger_debug "module_webapp_isExist ($1)"
    [[ -r $(module_webapp_getFileConf $1) ]] && return 0
    return 1
}


###
# Retourne le libellé de l'application
# @param $1 : Code de l'application
# @return string
##
function module_webapp_getLabel()
{
    logger_debug "module_webapp_getLabel ($1)"
    if module_webapp_isExist $1; then
        source $(module_webapp_getFileConf $1)
        echo -n ${OLIX_MODULE_APPWEB_LABEL}
    else
        echo -n "inconnu"
    fi
}


###
# Ecrit et sauvegarde les paramètres du fichier de configuration de l'application
# @param $1 : Code de l'application
##
function module_webapp_saveFileConf()
{
    logger_debug "module_webapp_saveFileConf ($1)"
    local FILECONF="${OLIX_CORE_PATH_CONFIG}/${OLIX_MODULE_NAME}.$1.conf"

    logger_info "Création du fichier de configuration ${FILECONF}"
    echo "# Fichier de configuration de l'application $1 du module APPWEB" > ${FILECONF} 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && logger_critical
    logger_debug "OLIX_MODULE_APPWEB_LABEL=\"$(yaml_getConfig "label")\""
    echo "OLIX_MODULE_APPWEB_LABEL=\"$(yaml_getConfig "label")\"" >> ${FILECONF}
    logger_debug "OLIX_MODULE_APPWEB_FILEYML=${OLIX_MODULE_APPWEB_FILEYML}"
    echo "OLIX_MODULE_APPWEB_FILEYML=${OLIX_MODULE_APPWEB_FILEYML}" >> ${FILECONF}
    logger_debug "OLIX_MODULE_APPWEB_ENVIRONMENT=${OLIX_MODULE_APPWEB_ENVIRONMENT}"
    echo "OLIX_MODULE_APPWEB_ENVIRONMENT=${OLIX_MODULE_APPWEB_ENVIRONMENT}" >> ${FILECONF}
    logger_debug "OLIX_MODULE_APPWEB_ORIGIN_NAME=\"${OLIX_MODULE_APPWEB_ORIGIN_NAME}\""
    echo "OLIX_MODULE_APPWEB_ORIGIN_NAME=\"${OLIX_MODULE_APPWEB_ORIGIN_NAME}\"" >> ${FILECONF}
    logger_debug "OLIX_MODULE_APPWEB_ORIGIN_HOST=${OLIX_MODULE_APPWEB_ORIGIN_HOST}"
    echo "OLIX_MODULE_APPWEB_ORIGIN_HOST=${OLIX_MODULE_APPWEB_ORIGIN_HOST}" >> ${FILECONF}
    logger_debug "OLIX_MODULE_APPWEB_ORIGIN_PORT=${OLIX_MODULE_APPWEB_ORIGIN_PORT}"
    echo "OLIX_MODULE_APPWEB_ORIGIN_PORT=${OLIX_MODULE_APPWEB_ORIGIN_PORT}" >> ${FILECONF}
    logger_debug "OLIX_MODULE_APPWEB_ORIGIN_USER=${OLIX_MODULE_APPWEB_ORIGIN_USER}"
    echo "OLIX_MODULE_APPWEB_ORIGIN_USER=${OLIX_MODULE_APPWEB_ORIGIN_USER}" >> ${FILECONF}
    logger_debug "OLIX_MODULE_APPWEB_ORIGIN_PATH=${OLIX_MODULE_APPWEB_ORIGIN_PATH}"
    echo "OLIX_MODULE_APPWEB_ORIGIN_PATH=${OLIX_MODULE_APPWEB_ORIGIN_PATH}" >> ${FILECONF}
}


###
# Vérifie et charge le fichier de conf de l'application
# @param $1 : Code de l'application
##
function module_webapp_loadConfiguration()
{
    logger_debug "module_webapp_loadConfiguration ($1)"

    if ! module_webapp_isExist $1; then
        logger_warning "L'application '$1' n'est apparament pas installée"
        logger_critical "Impossible de charger le fichier de configuration $(module_webapp_getFileConf $1)"
    fi

    source $(module_webapp_getFileConf $1)
    module_webapp_loadFileConfYML "${OLIX_MODULE_APPWEB_FILEYML}" "$1"
}


###
# Charge le fichier de configuration YML REEL
# @param $1 : Emplacement réel du fichier de conf yml
# @param $2 : Code de l'application
##
function module_webapp_loadFileConfYML()
{
    logger_debug "module_webapp_loadFileConfYML ($1, $2)"

    local FILECFG=$1

    if [[ ! -r ${FILECFG} ]]; then
        logger_warning "${FILECFG} absent"
        logger_critical "Impossible de charger le fichier de configuration de l'application '$2'"
    fi

    logger_info "Chargement du fichier '${FILECFG}'"
    yaml_parseFile "${FILECFG}" "${OLIX_MODULE_APPWEB_CONFIG_PREFIX}"
    OLIX_MODULE_APPWEB_CONFIG_DIR_APPWEB=$(dirname ${FILECFG})
}


###
# Affecte un numéro d'origine à une application
# @param $1 : Code de l'application
# @param $2 : Valeur du numéro de l'origine du dépot
##
function module_webapp_setOrigin()
{
    logger_debug "module_webapp_setOrigin ($1, $2)"

    OLIX_MODULE_APPWEB_ORIGIN_NAME=$(yaml_getConfig "origin.server_${2}.name")
    OLIX_MODULE_APPWEB_ORIGIN_HOST=$(yaml_getConfig "origin.server_${2}.host")
    OLIX_MODULE_APPWEB_ORIGIN_PORT=$(yaml_getConfig "origin.server_${2}.port")
    OLIX_MODULE_APPWEB_ORIGIN_USER=$(yaml_getConfig "origin.server_${2}.user")
    OLIX_MODULE_APPWEB_ORIGIN_PATH=$(yaml_getConfig "origin.server_${2}.path")
    [[ -z ${OLIX_MODULE_APPWEB_ORIGIN_HOST} ]] && logger_critical "Aucun serveur de dépot n'est déclaré dans le fichier webapp.yml"

    module_webapp_saveFileConf $1
}

