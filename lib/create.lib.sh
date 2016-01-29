###
# Librairies pour la création d'une application du module WEBAPP
# ==============================================================================
# @package olixsh
# @module webapp
# @author Olivier <sabinus52@gmail.com>
##


###
# Lecture du code de la nouvelle application
##
function module_webapp_create_readCode()
{
    logger_debug "module_webapp_create_readCode ()"
    while true; do
        stdin_read "Choix du ${CBLANC}code${CVOID} de la nouvelle application" ""
        [[ -n ${OLIX_STDIN_RETURN} ]] && break
    done
    OLIX_MODULE_WEBAPP_CODE=${OLIX_STDIN_RETURN}
    logger_debug "OLIX_MODULE_WEBAPP_CODE=${OLIX_MODULE_WEBAPP_CODE}"
}


###
# Lecture des données de l'application
##
function module_webapp_create_readDatas()
{
    logger_debug "module_webapp_create_readDatas ()"

    # LABEL
    while true; do
        stdin_read "${CBLANC}Nom${CVOID} de la nouvelle application" ""
        [[ -n ${OLIX_STDIN_RETURN} ]] && break
    done
    OLIX_MODULE_WEBAPP_LABEL="${OLIX_STDIN_RETURN}"

    # PATH
    stdin_read "${CBLANC}Emplacement${CVOID} de la nouvelle application" "/home/${OLIX_MODULE_WEBAPP_CODE}"
    OLIX_MODULE_WEBAPP_PATH=${OLIX_STDIN_RETURN}

    # OWNER
    while true; do
        stdin_read "${CBLANC}Propriétaire${CVOID} de la nouvelle application dans ${CBLANC}${OLIX_MODULE_WEBAPP_PATH}${CVOID}" ""
        system_isUserExist ${OLIX_STDIN_RETURN} && break
    done
    OLIX_MODULE_WEBAPP_OWNER=${OLIX_STDIN_RETURN}

    # GROUP
    while true; do
        stdin_read "${CBLANC}Groupe${CVOID} de la nouvelle application dans ${CBLANC}${OLIX_MODULE_WEBAPP_PATH}${CVOID}" ""
        system_isGroupExist ${OLIX_STDIN_RETURN} && break
    done
    OLIX_MODULE_WEBAPP_GROUP=${OLIX_STDIN_RETURN}

    # TYPE
    stdin_readSelect "${CBLANC}Type ${CVOID} de l'application" "symfony unknow" "symfony"
    OLIX_MODULE_WEBAPP_TYPE=${OLIX_STDIN_RETURN}

    # DBENGINE
    stdin_readSelect "${CBLANC}Moteur BD ${CVOID} de l'application" "mysql postgres" "postgres"
    OLIX_MODULE_WEBAPP_DBENGINE=${OLIX_STDIN_RETURN}

    # ENVIRONNEMENT
    stdin_readSelect "Environnement de l'application" "${OLIX_MODULE_WEBAPP_LISTENV}" ""
    OLIX_MODULE_WEBAPP_ENVIRONMENT=${OLIX_STDIN_RETURN}
}


###
# Préparation de l'application et création des dossiers et du fichiers de conf
##
function module_webapp_create_prepare()
{
    logger_debug "module_webapp_create_prepare ()"
    rm -rf ${OLIX_MODULE_WEBAPP_PATH}

    # Création du répertoire
    logger_info "Création du répertoire ${OLIX_MODULE_WEBAPP_PATH}"
    if [[ ! -d ${OLIX_MODULE_WEBAPP_PATH}/xconf ]]; then
        mkdir -p ${OLIX_MODULE_WEBAPP_PATH}/xconf 2> ${OLIX_LOGGER_FILE_ERR}
        [[ $? -ne 0 ]] && logger_critical
    fi

    # Création du fichier de conf webapp.yml
    cp modules/webapp/res/template.yml ${OLIX_MODULE_WEBAPP_PATH}/xconf/webapp.yml 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && logger_critical
    sed -i "s/#code#/${OLIX_MODULE_WEBAPP_CODE}/g" ${OLIX_MODULE_WEBAPP_PATH}/xconf/webapp.yml
    sed -i "s/#label#/${OLIX_MODULE_WEBAPP_LABEL}/g" ${OLIX_MODULE_WEBAPP_PATH}/xconf/webapp.yml
    sed -i "s/#path#/${OLIX_MODULE_WEBAPP_PATH//\//\\\/}/g" ${OLIX_MODULE_WEBAPP_PATH}/xconf/webapp.yml
    sed -i "s/#owner#/${OLIX_MODULE_WEBAPP_OWNER}/g" ${OLIX_MODULE_WEBAPP_PATH}/xconf/webapp.yml
    sed -i "s/#group#/${OLIX_MODULE_WEBAPP_GROUP}/g" ${OLIX_MODULE_WEBAPP_PATH}/xconf/webapp.yml
    sed -i "s/#type#/${OLIX_MODULE_WEBAPP_TYPE}/g" ${OLIX_MODULE_WEBAPP_PATH}/xconf/webapp.yml
    sed -i "s/#dbengine#/${OLIX_MODULE_WEBAPP_DBENGINE}/g" ${OLIX_MODULE_WEBAPP_PATH}/xconf/webapp.yml
    OLIX_MODULE_WEBAPP_FILEYML=${OLIX_MODULE_WEBAPP_PATH}/xconf/webapp.yml

    # Affecte les droits au répertoire
    chown -R ${OLIX_MODULE_WEBAPP_OWNER}:${OLIX_MODULE_WEBAPP_GROUP} ${OLIX_MODULE_WEBAPP_PATH} 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && logger_critical
}
