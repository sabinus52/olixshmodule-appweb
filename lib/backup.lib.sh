###
# Librairies pour la sauvegarde d'une application du module APPWEB
# ==============================================================================
# @package olixsh
# @module appweb
# @author Olivier <sabinus52@gmail.com>
##


###
# Initialise la sauvegarde
##
function module_appweb_backup_initialize()
{
    logger_debug "module_appweb_backup_initialize ()"

    # Paramètres généraux
    OLIX_MODULE_APPWEB_BACKUP_PURGE=$(yaml_getRequireConfig "backup.${OLIX_MODULE_APPWEB_ENVIRONMENT}.purge" "5")
    OLIX_MODULE_APPWEB_BACKUP_COMPRESS=$(yaml_getRequireConfig "backup.${OLIX_MODULE_APPWEB_ENVIRONMENT}.compress" "gz")
    OLIX_MODULE_APPWEB_BACKUP_DIR=$(yaml_getRequireConfig "backup.${OLIX_MODULE_APPWEB_ENVIRONMENT}.repository" "/tmp")
    if [[ ! -d ${OLIX_MODULE_APPWEB_BACKUP_DIR} ]]; then
        logger_warning "Création du dossier inexistant backup.${OLIX_MODULE_APPWEB_ENVIRONMENT}.repository: \"${OLIX_MODULE_APPWEB_BACKUP_DIR}\""
        mkdir ${OLIX_MODULE_APPWEB_BACKUP_DIR} || logger_error "Impossible de créer backup.${OLIX_MODULE_APPWEB_ENVIRONMENT}.repository: \"${OLIX_MODULE_APPWEB_BACKUP_DIR}\""
    elif [[ ! -w ${OLIX_MODULE_APPWEB_BACKUP_DIR} ]]; then
        logger_error "Le dossier ${OLIX_MODULE_APPWEB_BACKUP_DIR} n'a pas les droits en écriture"
    fi

    # Paramètres pour le FTP
    OLIX_MODULE_APPWEB_BACKUP_FTP=$(yaml_getRequireConfig "backup.${OLIX_MODULE_APPWEB_ENVIRONMENT}.ftp.sync" false)
    if [[ ${OLIX_MODULE_APPWEB_BACKUP_FTP} != false ]]; then
        ftp_isInstalled ${OLIX_MODULE_APPWEB_BACKUP_FTP}
        OLIX_MODULE_APPWEB_BACKUP_FTP_HOST=$(yaml_getConfig "backup.${OLIX_MODULE_APPWEB_ENVIRONMENT}.ftp.host")
        [[ -z ${OLIX_MODULE_APPWEB_BACKUP_FTP_HOST} ]] && logger_error "La configuration YML:backup.${OLIX_MODULE_APPWEB_ENVIRONMENT}.ftp.host n'est pas définie"
        OLIX_MODULE_APPWEB_BACKUP_FTP_USER=$(yaml_getConfig "backup.${OLIX_MODULE_APPWEB_ENVIRONMENT}.ftp.user")
        [[ -z ${OLIX_MODULE_APPWEB_BACKUP_FTP_USER} ]] && logger_error "La configuration YML:backup.${OLIX_MODULE_APPWEB_ENVIRONMENT}.ftp.user n'est pas définie"
        OLIX_MODULE_APPWEB_BACKUP_FTP_PASS=$(yaml_getConfig "backup.${OLIX_MODULE_APPWEB_ENVIRONMENT}.ftp.pass")
        [[ -z ${OLIX_MODULE_APPWEB_BACKUP_FTP_PASS} ]] && logger_error "La configuration YML:backup.${OLIX_MODULE_APPWEB_ENVIRONMENT}.ftp.pass n'est pas définie"
        OLIX_MODULE_APPWEB_BACKUP_FTP_PATH=$(yaml_getRequireConfig "backup.${OLIX_MODULE_APPWEB_ENVIRONMENT}.ftp.path" "/")
    fi
    
    # Paramètres pour le rapport
    local REPORT_TYPE=$(yaml_getRequireConfig "backup.${OLIX_MODULE_APPWEB_ENVIRONMENT}.report.type" "text")
    local REPORT_PATH=$(yaml_getRequireConfig "backup.${OLIX_MODULE_APPWEB_ENVIRONMENT}.report.path" "/tmp")
    local REPORT_MAIL=$(yaml_getConfig "backup.${OLIX_MODULE_APPWEB_ENVIRONMENT}.report.mail")
    
    report_initialize "${REPORT_TYPE}" "${REPORT_PATH}" "rapport-backup-${OLIX_MODULE_APPWEB_CODE}-${OLIX_SYSTEM_DATE}" "${REPORT_MAIL}"
    stdout_printHead1 "Sauvegarde du projet %s le %s à %s" "${OLIX_MODULE_APPWEB_CODE}" "${OLIX_SYSTEM_DATE}" "${OLIX_SYSTEM_TIME}"
    report_printHead1 "Sauvegarde du projet %s le %s à %s" "${OLIX_MODULE_APPWEB_CODE}" "${OLIX_SYSTEM_DATE}" "${OLIX_SYSTEM_TIME}"
}


###
# Sauvegarde des bases
##
function module_appweb_backup_databases()
{
    logger_debug "module_appweb_backup_databases"
    local I
    local IS_ERROR=false

    local LIST_BASES=$(yaml_getConfig "bases.mysql.bases")
    local LIST_EXCLUDE=$(yaml_getConfig "backup.exclude.bases")
    local LIST_INCLUDE=$(yaml_getConfig "backup.include.bases")
    local LIST_RESULT I

    # Récupération de la liste des bases
    for I in ${LIST_BASES}; do
        core_contains "${I}" "${LIST_EXCLUDE}" && continue
        LIST_RESULT="${LIST_RESULT} ${I}"
    done
    LIST_RESULT="${LIST_RESULT} ${LIST_INCLUDE}"
    logger_info "Listes des bases à sauvegarder : ${LIST_RESULT}"

    # Traitement
    for I in ${LIST_RESULT}; do
        module_mysql_backupDatabase "${I}" "${OLIX_MODULE_APPWEB_BACKUP_DIR}" \
            "${OLIX_MODULE_APPWEB_BACKUP_COMPRESS}" "${OLIX_MODULE_APPWEB_BACKUP_PURGE}" \
            "${OLIX_MODULE_APPWEB_BACKUP_FTP}" \
            "${OLIX_MODULE_APPWEB_BACKUP_FTP_HOST}" "${OLIX_MODULE_APPWEB_BACKUP_FTP_USER}" "${OLIX_MODULE_APPWEB_BACKUP_FTP_PASS}" \
            "${OLIX_MODULE_APPWEB_BACKUP_FTP_PATH}"
        [[ $? -ne 0 ]] && IS_ERROR=true
    done
    [[ ${IS_ERROR} == true ]] && return 1 || return 0
}


###
# Sauvegarde des fichiers
##
function module_appweb_backup_files()
{
    logger_debug "module_appweb_backup_files"
    local I
    local IS_ERROR=false

    # Sauvegarde des sources de l'application
    local DIR=$(yaml_getConfig "path")
    local EXCLUDE=$(yaml_getConfig "backup.exclude.files")
    backup_directory "${DIR}" "${EXCLUDE}" "${OLIX_MODULE_APPWEB_BACKUP_DIR}" \
        "${OLIX_MODULE_APPWEB_BACKUP_COMPRESS}" "${OLIX_MODULE_APPWEB_BACKUP_PURGE}" \
        "${OLIX_MODULE_APPWEB_BACKUP_FTP}" \
        "${OLIX_MODULE_APPWEB_BACKUP_FTP_HOST}" "${OLIX_MODULE_APPWEB_BACKUP_FTP_USER}" "${OLIX_MODULE_APPWEB_BACKUP_FTP_PASS}" \
        "${OLIX_MODULE_APPWEB_BACKUP_FTP_PATH}"
    [[ $? -ne 0 ]] && _PB_IS_ERROR=1

    # Sauvegarde des dossiers supplémentaires
    local LIST_DIRS=$(yaml_getConfig "backup.include.files")
    for I in ${LIST_DIRS}; do
        backup_directory "${I}" "" "${OLIX_MODULE_APPWEB_BACKUP_DIR}" \
            "${OLIX_MODULE_APPWEB_BACKUP_COMPRESS}" "${OLIX_MODULE_APPWEB_BACKUP_PURGE}" \
            "${OLIX_MODULE_APPWEB_BACKUP_FTP}" \
            "${OLIX_MODULE_APPWEB_BACKUP_FTP_HOST}" "${OLIX_MODULE_APPWEB_BACKUP_FTP_USER}" "${OLIX_MODULE_APPWEB_BACKUP_FTP_PASS}" \
            "${OLIX_MODULE_APPWEB_BACKUP_FTP_PATH}"
        [[ $? -ne 0 ]] && _PB_IS_ERROR=1
    done

    [[ ${IS_ERROR} == true ]] && return 1 || return 0
}


function module_appweb_backup_syncFTP()
{
    logger_debug "module_appweb_backup_syncFTP ()"

    backup_synchronizeFTP "${OLIX_MODULE_APPWEB_BACKUP_DIR}" \
        "${OLIX_MODULE_APPWEB_BACKUP_FTP}" \
        "${OLIX_MODULE_APPWEB_BACKUP_FTP_HOST}" "${OLIX_MODULE_APPWEB_BACKUP_FTP_USER}" "${OLIX_MODULE_APPWEB_BACKUP_FTP_PASS}" \
        "${OLIX_MODULE_APPWEB_BACKUP_FTP_PATH}"
    return $?
}


###
#
# @param $1 : Si errreur
##
function module_appweb_backup_finalize()
{
    logger_debug "module_appweb_backup_finalize"

    stdout_print; stdout_printLine; stdout_print "${Cvert}Sauvegarde terminée en $(core_getTimeExec) secondes${CVOID}"
    report_print; report_printLine; report_print "Sauvegarde terminée en $(core_getTimeExec) secondes"

    if [[ $1 == true ]]; then
        report_terminate "ERREUR - Rapport de backup du project ${OLIX_MODULE_APPWEB_CODE}"
    else
        report_terminate "Rapport de backup du project ${OLIX_MODULE_APPWEB_CODE}"
    fi
}
