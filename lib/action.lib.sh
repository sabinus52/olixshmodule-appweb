###
# Librairies des actions du module WEBAPP
# ==============================================================================
# @package olixsh
# @module webapp
# @author Olivier <sabinus52@gmail.com>
##


###
# Création d'une application
##
function module_webapp_action_create()
{
    logger_debug "module_webapp_action_create ($@)"

    # Test si ROOT
    logger_info "Test si root"
    core_checkIfRoot
    [[ $? -ne 0 ]] && logger_critical "Seulement root peut executer cette action"

    # Chargement de la librairie des fonctions de création
    source modules/webapp/lib/create.lib.sh

    # Demande d'infos
    module_webapp_create_readCode
    module_webapp_create_readDatas
    
    # Prépare le dossier
    module_webapp_create_prepare

    # Ecriture du fichier de configuration
    module_webapp_loadFileConfYML ${OLIX_MODULE_WEBAPP_FILEYML} ${OLIX_MODULE_WEBAPP_CODE}
    module_webapp_saveFileConf ${OLIX_MODULE_WEBAPP_CODE}

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Installation d'une application
# @param $1 : user@host:/path_of_webapp.yml
##
function module_webapp_action_install()
{
    logger_debug "module_webapp_action_install ($@)"

    # Test si ROOT
    logger_info "Test si root"
    core_checkIfRoot
    [[ $? -ne 0 ]] && logger_critical "Seulement root peut executer cette action"

    echo -e "${CROUGE}ATTENTION !!! ${CVOID}${Cjaune}Cela va écraser toutes les données actuelles (fichiers + base)"
    stdin_readYesOrNo "Confirmer" false
    [[ ${OLIX_STDIN_RETURN} == false ]] && return 0

    # Chargement de la librairie des fonctions d'installation
    source modules/webapp/lib/install.lib.sh

    # Chargement de la configuration distante
    module_webapp_install_pullConfigYML $1
    module_webapp_install_loadConfigYML
    
    stdout_printHead1 "Installation de l'application web %s %s %s" "$(yaml_getConfig "label") (${OLIX_MODULE_WEBAPP_CODE})"
    
    # Initialise
    module_webapp_install_initialize
    module_webapp_install_origin

    # Paquets additionnels
    module_webapp_install_packages

    # Dossiers supplémentaires
    module_webapp_install_directories

    # Source fichier
    stdout_printHead2 "Installation des fichiers sources"
    module_webapp_install_preparePath
    module_webapp_install_synchronizePath
    module_webapp_install_finalizePath

    # Base de données
    stdout_printHead2 "Installation des bases de données"
    module_webapp_install_dataBases
    
    # Variables pour l'empacement des fichiers de configuration necessaire à Apache, Tuning et script personnalisé
    OLIX_MODULE_WEBAPP_PATH=$(yaml_getConfig "path")
    OLIX_MODULE_WEBAPP_PATH_XCONF=${OLIX_MODULE_WEBAPP_PATH}${OLIX_MODULE_WEBAPP_CONFIG_PATH}

    # Si présence d'un script personnalisé
    logger_info "Test si sctipt personnalisé"
    local CUSTOM_SCRIPT=$(yaml_getConfig "install.script")
    if [[ -n ${CUSTOM_SCRIPT} ]]; then
        stdout_printHead2 "Installation via le script personnalisé"
        [[ ! -x ${OLIX_MODULE_WEBAPP_PATH_XCONF}/${CUSTOM_SCRIPT} ]] && logger_critical "Script ${OLIX_MODULE_WEBAPP_PATH_XCONF}/${CUSTOM_SCRIPT} absent ou non executable"
        source ${OLIX_MODULE_WEBAPP_PATH_XCONF}/${CUSTOM_SCRIPT}
    fi

    # Apache
    stdout_printHead2 "Installation des fichiers systèmes"
    module_webapp_install_logrotate
    module_webapp_install_crontab
    module_webapp_install_apache
    module_webapp_install_certificates
    service apache2 restart
    [[ $? -ne 0 ]] && logger_critical "Problème de démarrage d'Apache"
    
    # Ecriture du fichier de configuration
    OLIX_MODULE_WEBAPP_FILEYML="${OLIX_MODULE_WEBAPP_PATH}${OLIX_MODULE_WEBAPP_CONFIG_PATH}/${OLIX_MODULE_WEBAPP_CONFIG_FILE}"
    if [[ ! -r ${OLIX_MODULE_WEBAPP_FILEYML} ]]; then
        logger_warning "Le fichier de configuration ${OLIX_MODULE_WEBAPP_FILEYML} est absent"
        stdin_readFile "Chemin et fichier de configuration 'webapp.yml' de l'application ${OLIX_MODULE_WEBAPP_CODE}" "${OLIX_MODULE_WEBAPP_FILEYML}" false
        logger_debug "OLIX_MODULE_WEBAPP_FILEYML=${OLIX_STDIN_RETURN}"
        OLIX_MODULE_WEBAPP_FILEYML=${OLIX_STDIN_RETURN}
    fi

    module_webapp_saveFileConf ${OLIX_MODULE_WEBAPP_CODE}

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Configuration de l'application en modifiant le fichier de configuration
# @param $1 : Nom de l'application
##
function module_webapp_action_config()
{
    logger_debug "module_webapp_action_config ($@)"

    # Affichage de l'aide
    [ $# -lt 1 ] && module_webapp_usage_config && core_exit 1

    logger_info "Test si c'est le propriétaire"
    core_checkIfOwner
    [[ $? -ne 0 ]] && logger_critical "Seul l'utilisateur \"$(core_getOwner)\" peut exécuter ce script"

    # Vérifie les paramètres en chargeant le conf
    module_webapp_loadConfiguration "${OLIX_MODULE_WEBAPP_CODE}"

    # Affichage de la configuration
    echo -e "Contenu du fichier de configuration de l'application ${CCYAN}${OLIX_MODULE_WEBAPP_CODE}${CVOID}"
    echo "------------"
    cat $(module_webapp_getFileConf ${OLIX_MODULE_WEBAPP_CODE})
    echo "------------"

    stdin_readYesOrNo "Modifier la configuration" false
    [[ ${OLIX_STDIN_RETURN} == "false" ]] && return 0

    # Fichier webapp.yml
    stdin_readFile "Chemin et fichier de configuration 'webapp.yml' de l'application ${OLIX_MODULE_WEBAPP_CODE}" "${OLIX_MODULE_WEBAPP_FILEYML}" true
    logger_debug "OLIX_MODULE_WEBAPP_FILEYML=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_WEBAPP_FILEYML=${OLIX_STDIN_RETURN}

    # Environnement
    stdin_readSelect "Environnement de l'applications" "${OLIX_MODULE_WEBAPP_LISTENV}" "${OLIX_MODULE_WEBAPP_ENVIRONMENT}"
    logger_debug "OLIX_MODULE_WEBAPP_ENVIRONMENT=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_WEBAPP_ENVIRONMENT=${OLIX_STDIN_RETURN}

    # Origine
    stdin_read "Nom de l'origine des sources" "${OLIX_MODULE_WEBAPP_ORIGIN_NAME}"
    logger_debug "OLIX_MODULE_WEBAPP_ORIGIN_NAME=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_WEBAPP_ORIGIN_NAME="${OLIX_STDIN_RETURN}"
    stdin_read "Hostname du serveur d'origine des sources" "${OLIX_MODULE_WEBAPP_ORIGIN_HOST}"
    logger_debug "OLIX_MODULE_WEBAPP_ORIGIN_HOST=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_WEBAPP_ORIGIN_HOST="${OLIX_STDIN_RETURN}"
    stdin_read "Port du serveur d'origine des sources" "${OLIX_MODULE_WEBAPP_ORIGIN_PORT}"
    logger_debug "OLIX_MODULE_WEBAPP_ORIGIN_PORT=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_WEBAPP_ORIGIN_PORT="${OLIX_STDIN_RETURN}"
    stdin_read "Utilisateur de connexion du serveur d'origine des sources" "${OLIX_MODULE_WEBAPP_ORIGIN_USER}"
    logger_debug "OLIX_MODULE_WEBAPP_ORIGIN_USER=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_WEBAPP_ORIGIN_USER="${OLIX_STDIN_RETURN}"
    stdin_read "Chemin distant sur le serveur d'origine des sources" "${OLIX_MODULE_WEBAPP_ORIGIN_PATH}"
    logger_debug "OLIX_MODULE_WEBAPP_ORIGIN_PATH=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_WEBAPP_ORIGIN_PATH="${OLIX_STDIN_RETURN}"

    # Ecriture du fichier de configuration
    module_webapp_saveFileConf ${OLIX_MODULE_WEBAPP_CODE}

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
    return 0
}


###
# Visuralise ou change le dépot d'une application
# @param $1 : Nom de l'application
# @param $2 : Nouveau numéro de dépôt à changer
##
function module_webapp_action_origin()
{
    logger_debug "module_webapp_action_origin ($@)"

    # Affichage de l'aide
    [ $# -lt 1 ] && module_webapp_usage_origin && core_exit 1

    logger_info "Test si c'est le propriétaire"
    core_checkIfOwner
    [[ $? -ne 0 ]] && logger_critical "Seul l'utilisateur \"$(core_getOwner)\" peut exécuter ce script"

    # Vérifie les paramètres en chargeant le conf
    module_webapp_loadConfiguration "${OLIX_MODULE_WEBAPP_CODE}"

    if [[ -n $2 ]]; then

        # Changement du dépôt
        echo -e "Changement du dépôt pour le numéro ${CVERT}${2}${CVOID}"
        module_webapp_setOrigin "${OLIX_MODULE_WEBAPP_CODE}" "$2"
        module_webapp_loadConfiguration "${OLIX_MODULE_WEBAPP_CODE}"
        #module_webapp_loadOrigin "${OLIX_MODULE_WEBAPP_CODE}"
        echo -e "   Nom         : ${Ccyan}${OLIX_MODULE_WEBAPP_ORIGIN_NAME}${CVOID}"
        echo -e "   Serveur     : ${Ccyan}${OLIX_MODULE_WEBAPP_ORIGIN_HOST}${CVOID}"
        echo -e "   Port        : ${Ccyan}${OLIX_MODULE_WEBAPP_ORIGIN_PORT}${CVOID}"
        echo -e "   Utilisateur : ${Ccyan}${OLIX_MODULE_WEBAPP_ORIGIN_USER}${CVOID}"
        echo -e "   Chemin      : ${Ccyan}${OLIX_MODULE_WEBAPP_ORIGIN_PATH}${CVOID}"

    else

        # Affiche le dépôt courant
        echo -e "Actuellement, le dépôt utilisé pour l'application ${CCYAN}${OLIX_MODULE_WEBAPP_CODE}${CVOID}"
        echo -e "   Nom         : ${Ccyan}${OLIX_MODULE_WEBAPP_ORIGIN_NAME}${CVOID}"
        echo -e "   Serveur     : ${Ccyan}${OLIX_MODULE_WEBAPP_ORIGIN_HOST}${CVOID}"
        echo -e "   Port        : ${Ccyan}${OLIX_MODULE_WEBAPP_ORIGIN_PORT}${CVOID}"
        echo -e "   Utilisateur : ${Ccyan}${OLIX_MODULE_WEBAPP_ORIGIN_USER}${CVOID}"
        echo -e "   Chemin      : ${Ccyan}${OLIX_MODULE_WEBAPP_ORIGIN_PATH}${CVOID}"
        echo
        echo -e "Dépôts disponibles :"
        for (( I = 1; I < 10; I++ )); do
            local OHOST=$(yaml_getConfig "origin.server_${I}.host")
            [[ -z ${OHOST} ]] && break
            local ONAME=$(yaml_getConfig "origin.server_${I}.name")
            echo -e " ${CJAUNE}${I}${CVOID} : ${Cjaune}${ONAME}${CVOID} (${OHOST})"
        done
        echo
        echo -e "Pour changer de dépôt, taper la commande suivante :"
        echo -e "  ${CBLANC}olixsh webapp origin ${OLIX_MODULE_WEBAPP_CODE} [number repository]${CVOID}"

    fi
}


###
# Applique la configuration système
# @param $1 : Nom de l'application
##
function module_webapp_action_applysys()
{
    logger_debug "module_webapp_action_applysys ($@)"
    local IS_ERROR=false

    # Affichage de l'aide
    [ $# -lt 1 ] && module_webapp_usage_applysys && core_exit 1

    # Test si ROOT
    logger_info "Test si root"
    core_checkIfRoot
    [[ $? -ne 0 ]] && logger_critical "Seulement root peut executer cette action"

    # Vérifie les paramètres en chargeant le conf
    module_webapp_loadConfiguration "${OLIX_MODULE_WEBAPP_CODE}"
    
    # Variables pour l'empacement des fichiers de configuration necessaire à Apache, Tuning et script personnalisé
    OLIX_MODULE_WEBAPP_PATH=$(yaml_getConfig "path")
    OLIX_MODULE_WEBAPP_PATH_XCONF=${OLIX_MODULE_WEBAPP_PATH}${OLIX_MODULE_WEBAPP_CONFIG_PATH}

    source modules/webapp/lib/install.lib.sh

    module_webapp_install_logrotate
    module_webapp_install_crontab
    module_webapp_install_apache
    module_webapp_install_certificates
    service apache2 restart
    [[ $? -ne 0 ]] && logger_critical "Problème de démarrage d'Apache"

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Sauvegarde d'une application
# @param $1 : Nom de l'application
##
function module_webapp_action_backup()
{
    logger_debug "module_webapp_action_backup ($@)"
    local IS_ERROR=false

    # Affichage de l'aide
    [ $# -lt 1 ] && module_webapp_usage_backup && core_exit 1

    # Vérifie les paramètres en chargeant le conf
    module_webapp_loadConfiguration "${OLIX_MODULE_WEBAPP_CODE}"

    source modules/webapp/lib/backup.lib.sh
    source lib/report.lib.sh
    source lib/backup.lib.sh
    source lib/ftp.lib.sh

    # Mise en place du rapport
    module_webapp_backup_initialize

    # Sauvegarde des bases
    module_webapp_backup_databases
    [[ $? -ne 0 ]] && IS_ERROR=true

    # Sauvegarde des dossiers
    module_webapp_backup_files
    [[ $? -ne 0 ]] && IS_ERROR=true

    # Synchronisation du FTP
    module_webapp_backup_syncFTP
    [[ $? -ne 0 ]] && IS_ERROR=true

    module_webapp_backup_finalize "${IS_ERROR}"

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}
