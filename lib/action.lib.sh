###
# Librairies des actions du module APPWEB
# ==============================================================================
# @package olixsh
# @module appweb
# @author Olivier <sabinus52@gmail.com>
##



###
# Initialisation du module en créant le fichier de configuration
# @var OLIX_MODULE_APPWEB_*
##
function module_appweb_action_init()
{
    logger_debug "module_appweb_action_init ($@)"

    # Environnement
    stdin_readSelect "Environnement des applications" "${OLIX_MODULE_APPWEB_LISTENV}" "prod"
    logger_debug "OLIX_MODULE_APPWEB_ENVIRONMENT=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_APPWEB_ENVIRONMENT=${OLIX_STDIN_RETURN}

    # Ecriture du fichier de configuration
    logger_info "Création du fichier de configuration ${OLIX_MODULE_FILECONF}"
    echo "# Fichier de configuration du module APPWEB" > ${OLIX_MODULE_FILECONF} 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && logger_error
    echo "OLIX_MODULE_APPWEB_ENVIRONMENT=${OLIX_MODULE_APPWEB_ENVIRONMENT}" >> ${OLIX_MODULE_FILECONF}

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
    return 0
}



###
# Installation d'une application
# @param $1 : Nom de l'application
##
function module_appweb_action_install()
{
    logger_debug "module_appweb_action_install ($@)"

    # Test si ROOT
    logger_info "Test si root"
    core_checkIfRoot
    [[ $? -ne 0 ]] && logger_error "Seulement root peut executer cette action"

    echo -e "${CROUGE}ATTENTION !!! ${CVOID}${Cjaune}Cela va écraser toutes les données actuelles (fichiers + base)"
    stdin_readYesOrNo "Confirmer" false
    [[ ${OLIX_STDIN_RETURN} == false ]] && return 0

    # Chargement de la librairie des fonctions d'installation
    source modules/appweb/lib/install.lib.sh

    # Chargement de la configuration distante
    module_appweb_install_initialize
    module_appweb_install_loadConfigYML
    
    stdout_printHead1 "Installation de l'application web %s %s %s" "$(yaml_getConfig "label") (${OLIX_MODULE_APPWEB_CODE})"
    
    # Paquets additionnels
    module_appweb_install_packages

    # Dossiers supplémentaires
    module_appweb_install_directories #@TODO

    # Source fichier
    stdout_printHead2 "Installation des fichiers sources"
    module_appweb_install_preparePath
    module_appweb_install_synchronizePath
    module_appweb_install_finalizePath

    # Base de données
    stdout_printHead2 "Installation des bases de données"
    module_appweb_install_dataBases

    # Apache
    stdout_printHead2 "Installation des fichiers systèmes"
    OLIX_MODULE_APPWEB_CONFIG_DIR_APPWEB="$(yaml_getConfig "path")/conf"
    module_appweb_install_logrotate
    module_appweb_install_crontab
    module_appweb_install_apache
    module_appweb_install_certificates
    service apache2 restart

    # Lien de la conf vers OliXsh
    local OLIX_MODULE_APPWEB_PATH=$(yaml_getConfig "path")
    logger_info "Lien de la configuration vers ${OLIX_MODULE_APPWEB_PATH}/conf/${OLIX_MODULE_APPWEB_CONFIG_FILE}"
    rm -f ${OLIX_CONFIG_DIR}/appweb.${OLIX_MODULE_APPWEB_CODE}.yml > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_critical
    ln -s ${OLIX_MODULE_APPWEB_PATH}/conf/${OLIX_MODULE_APPWEB_CONFIG_FILE} ${OLIX_CONFIG_DIR}/appweb.${OLIX_MODULE_APPWEB_CODE}.yml > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_critical "Le lien de la configuration n'a pas pu être créé"
    echo -e "Enregistrement de la configuration de ${CCYAN}${OLIX_MODULE_APPWEB_CODE}${CVOID} dans oliXsh : ${CVERT}OK${CVOID}"

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Sauvegarde d'une application
# @param $1 : Nom de l'application
##
function module_appweb_action_backup()
{
    logger_debug "module_appweb_action_backup ($@)"
    local IS_ERROR=false

    # Affichage de l'aide
    [ $# -lt 1 ] && module_appweb_usage_backup && core_exit 1

    # Vérifie les paramètres
    module_appweb_isExist $1
    [[ $? -ne 0 ]] && logger_error "L'application '${OLIX_MODULE_APPWEB_CODE}' n'existe pas"

    module_appweb_loadConfiguration "${OLIX_MODULE_APPWEB_CODE}"

    source modules/appweb/lib/backup.lib.sh
    source lib/report.lib.sh
    source lib/backup.lib.sh
    source lib/ftp.lib.sh

    # Mise en place du rapport
    module_appweb_backup_initialize

    # Sauvegarde des bases
    module_appweb_backup_databases
    [[ $? -ne 0 ]] && IS_ERROR=true

    # Sauvegarde des dossiers
    module_appweb_backup_files
    [[ $? -ne 0 ]] && IS_ERROR=true

    # Synchronisation du FTP
    module_appweb_backup_syncFTP
    [[ $? -ne 0 ]] && IS_ERROR=true

    module_appweb_backup_finalize "${IS_ERROR}"

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}
