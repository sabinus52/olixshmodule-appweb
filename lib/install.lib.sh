###
# Librairies pour l'installation d'une application du module APPWEB
# ==============================================================================
# @package olixsh
# @module appweb
# @author Olivier <sabinus52@gmail.com>
##


###
# Installation des paquets additionnels
##
function module_appweb_install_packages()
{
    logger_debug "module_appweb_install_packages ()"

    local PACKAGES=$(yaml_getConfig "install.packages.aptget")
    logger_debug "YML:install.packages.aptget=${PACKAGES}"
    [[ -z ${PACKAGES} ]] && return 0

    logger_info "Installation des packages '${PACKAGES}'"
    apt-get --yes install ${PACKAGES} 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && logger_error "Impossible d'installer les packages"

    echo -e "Installation des paquets additionnels ${CCYAN}${PACKAGES}${CVOID} : ${CVERT}OK${CVOID}"
}


###
# Création du dossier qui contiendra les sources
##
function module_appweb_install_preparePath()
{
    logger_debug "module_appweb_install_preparePath ()"

    local DIR=$(yaml_getConfig "path")
    [[ -z ${DIR} ]] && logger_error "Le paramètre 'path' n'est pas renseigné dans '${OLIX_MODULE_APPWEB_FILECFG}'"

    if [[ ! -d ${DIR} ]]; then
        logger_info "Création du dossier '${DIR}'"
        mkdir -p ${DIR} > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_error
    fi

    echo -e "Création du dossier ${CCYAN}${DIR}${CVOID} : ${CVERT}OK${CVOID}"
}


###
# Synchronisation des sources depuis un serveur distant
##
function module_appweb_install_synchronizePath()
{
    logger_debug "module_appweb_install_synchronizePath ()"

    local DIR=$(yaml_getConfig "path")
    local EXCLUDE=$(yaml_getConfig "install.exclude.files")

    stdin_readConnexionServer "" "22" "root"
    stdin_read "Dossier distant de l'application" "$1"
    local PATH_DISTANT=${OLIX_STDIN_RETURN}

    logger_info "Synchronisation de ${OLIX_STDIN_RETURN_USER}@${OLIX_STDIN_RETURN_HOST}:${PATH_DISTANT} vers ${DIR}"
    echo "Mot de passe de connexion au serveur ${OLIX_STDIN_RETURN_USER}@${OLIX_STDIN_RETURN_HOST}"
    file_synchronize "${OLIX_STDIN_RETURN_PORT}" "${OLIX_STDIN_RETURN_USER}@${OLIX_STDIN_RETURN_HOST}:${PATH_DISTANT}" "${DIR}" "${EXCLUDE}"
    [[ $? -ne 0 ]] && logger_error

    echo -e "Copie des fichiers sources vers ${CCYAN}${DIR}${CVOID} : ${CVERT}OK${CVOID}"
}


###
# Finalise l'installation du dossier
##
function module_appweb_install_finalizePath()
{
    logger_info "module_appweb_install_finalizePath ()"

    local DIR=$(yaml_getConfig "path")
    local OWNER=$(yaml_getConfig "owner")
    local GROUP=$(yaml_getConfig "group")

    [[ -z ${OWNER} ]] && logger_error "Le paramètre 'owner' n'est pas renseigné dans '${OLIX_MODULE_APPWEB_FILECFG}'"
    [[ -z ${GROUP} ]] && logger_error "Le paramètre 'group' n'est pas renseigné dans '${OLIX_MODULE_APPWEB_FILECFG}'"

    logger_info "Changement des droits '${OWNER}.${GROUP}'"
    chown -R ${OWNER}.${GROUP} ${DIR} > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
}


###
# Installation des bases de données
##
function module_appweb_install_dataBases()
{
    logger_debug "module_appweb_install_dataBases"
    local I
    local LISTBASES=$(yaml_getConfig "bases.mysql.bases")
    local MYROLE=$(yaml_getConfig "bases.mysql.role")
    local MYPASS=$(yaml_getConfig "bases.mysql.password")
    local EXCLUDE=$(yaml_getConfig "install.exclude.bases")

    for I in ${LISTBASES}; do
        logger_info "Installation de la base MYSQL '${I}'"

        module_appweb_install_prepareDatabase "${I}" "${MYROLE}" "${MYPASS}"
        echo -e "Création de la base ${CCYAN}${I}${CVOID} : ${CVERT}OK ...${CVOID}"

        # Ne copie pas les données pour les bases à exclure
        core_contains "${I}" "${EXCLUDE}" && continue

        module_appweb_install_restoreDatabase "${I}"
        echo -e "Restauration des données de la base ${CCYAN}${I}${CVOID} : ${CVERT}OK ...${CVOID}"
    done
}


###
# Préparation de la base de données
# @param $1 : Nom de la base
# @param $2 : Nom du rôle
# @param $3 : Mot de passe du rôle
##
function module_appweb_install_prepareDatabase()
{
    logger_debug "module_appweb_install_prepareDatabase ($1)"

    logger_info "Suppression de la base '$1'"
    module_mysql_dropDatabaseIfExists "$1"
    [[ $? -ne 0 ]] && logger_error "Impossible de supprimer la base '$1'"

    logger_info "Création de la base '$1'"
    module_mysql_createDatabase "$1"
    [[ $? -ne 0 ]] && logger_error "Impossible de créer la base '$1'"

    logger_info "Création du rôle '$2'"
    module_mysql_createRole "$1" "$2" "$3"
    [[ $? -ne 0 ]] && logger_error "Impossible de créer le role de '$2' sur la base '$1'"
}


###
# Restauration des données de la base depuis un serveur distant
# @param $1 : Nom de la base
##
function module_appweb_install_restoreDatabase()
{
    logger_debug "module_appweb_install_restoreDatabase ($1)"
    local BASE_SOURCE

    # Demande des infos de connexion à la base distante
    stdin_readConnexionServer "" "3306" "root"
    stdin_readPassword "Mot de passe de connexion au serveur MySQL (${OLIX_STDIN_RETURN_HOST}) en tant que ${OLIX_STDIN_RETURN_USER}"
    OLIX_STDIN_RETURN_PASS=${OLIX_STDIN_RETURN}

    echo "Choix de la base de données source"
    module_mysql_usage_readDatabase "${OLIX_STDIN_RETURN_HOST}" "${OLIX_STDIN_RETURN_PORT}" "${OLIX_STDIN_RETURN_USER}" "${OLIX_STDIN_RETURN_PASS}"
    BASE_SOURCE=${OLIX_STDIN_RETURN}

    if [[ -n ${BASE_SOURCE} ]]; then
        logger_info "Synchronisation de la base '${OLIX_STDIN_RETURN_HOST}:${BASE_SOURCE}' vers '$1'"
        module_mysql_synchronizeDatabase \
            "--host=${OLIX_STDIN_RETURN_HOST} --port=${OLIX_STDIN_RETURN_PORT} --user=${OLIX_STDIN_RETURN_USER} --password=${OLIX_STDIN_RETURN_PASS}" \
            "${BASE_SOURCE}" \
            "--host=${OLIX_MODULE_MYSQL_HOST} --port=${OLIX_MODULE_MYSQL_PORT} --user=${OLIX_MODULE_MYSQL_USER} --password=${OLIX_MODULE_MYSQL_PASS}" \
            "$1"
        [[ $? -ne 0 ]] && logger_error "Echec de la synchronisation de '${OLIX_STDIN_RETURN_HOST}:${BASE_SOURCE}' vers '$1'"
    fi
    return 0
}


###
# Installation du fichier logrotate
##
function module_appweb_install_logrotate()
{
    logger_debug "module_appweb_install_logrotate ()"

    local FILE=$(yaml_getConfig "system.${OLIX_MODULE_APPWEB_ENVIRONMENT}.logrotate")

    [[ -z ${FILE} ]] && logger_warning "Pas de configuration trouvée pour logrotate" && return 0
    logger_info "Copie de ${OLIX_MODULE_APPWEB_CONFIG_DIR_APPWEB}/${FILE} vers /etc/logrotate.d"
    filesystem_copyFileConfiguration "${OLIX_MODULE_APPWEB_CONFIG_DIR_APPWEB}/${FILE}" "/etc/logrotate.d/${OLIX_MODULE_APPWEB_CODE}"
    echo -e "Mise en place de ${CCYAN}${FILE}${CVOID} vers /etc/logrotate.d : ${CVERT}OK ...${CVOID}"
}


###
# Installation du fichier crontab
##
function module_appweb_install_crontab()
{
    logger_debug "module_appweb_install_crontab ()"

    local FILE=$(yaml_getConfig "system.${OLIX_MODULE_APPWEB_ENVIRONMENT}.crontab")

    [[ -z ${FILE} ]] && logger_warning "Pas de configuration trouvée pour crontab" && return 0
    logger_info "Copie de ${OLIX_MODULE_APPWEB_CONFIG_DIR_APPWEB}/${FILE} vers /etc/cron.d"
    filesystem_copyFileConfiguration "${OLIX_MODULE_APPWEB_CONFIG_DIR_APPWEB}/${FILE}" "/etc/cron.d/${OLIX_MODULE_APPWEB_CODE}"
    echo -e "Mise en place de ${CCYAN}${FILE}${CVOID} vers /etc/cron.d : ${CVERT}OK ...${CVOID}"
}


###
# Installation du fichier du virtualhost pour Apache
##
function module_appweb_install_apache()
{
    logger_debug "module_appweb_install_apache ()"

    local VHOST=$(yaml_getConfig "system.${OLIX_MODULE_APPWEB_ENVIRONMENT}.apache")

    [[ -z ${VHOST} ]] && logger_warning "Pas de configuration trouvée pour apache" && return 0
    logger_info "Copie de ${OLIX_MODULE_APPWEB_CONFIG_DIR_APPWEB}/${VHOST} vers /etc/apache2/sites-available"
    filesystem_copyFileConfiguration "${OLIX_MODULE_APPWEB_CONFIG_DIR_APPWEB}/${VHOST}" "/etc/apache2/sites-available/${OLIX_MODULE_APPWEB_CODE}.conf"
    logger_info "Activation du site ${OLIX_MODULE_APPWEB_CODE}"
    a2ensite ${OLIX_MODULE_APPWEB_CODE} > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    echo -e "Activation du site ${CCYAN}${OLIX_MODULE_APPWEB_CODE}${CVOID} : ${CVERT}OK ...${CVOID}"
}


###
# Génération d'un certificat auto-signé
##
function module_appweb_install_certificates()
{
    logger_debug "module_appweb_install_certificates ()"

    local FQDN=$(yaml_getConfig "system.${OLIX_MODULE_APPWEB_ENVIRONMENT}.certificate.fqdn")
    local COUNTRY=$(yaml_getConfig "system.${OLIX_MODULE_APPWEB_ENVIRONMENT}.certificate.country")
    local PROVINCE=$(yaml_getConfig "system.${OLIX_MODULE_APPWEB_ENVIRONMENT}.certificate.province")
    local CITY=$(yaml_getConfig "system.${OLIX_MODULE_APPWEB_ENVIRONMENT}.certificate.city")
    local ORGANIZATION=$(yaml_getConfig "system.${OLIX_MODULE_APPWEB_ENVIRONMENT}.certificate.organization")
    local EMAIL=$(yaml_getConfig "system.${OLIX_MODULE_APPWEB_ENVIRONMENT}.certificate.email")

    [[ -z ${FQDN} ]] && logger_warning "Pas de certificat trouvé pour apache" && return 0

    # Pour debian auto signé local
    #FILECONFIG=$(core_makeTemp)
    #SSL_KEY_NAME=${FQDN}
    #sed -e "s/@HostName@/${SSL_KEY_NAME}/" -e "s|privkey.pem|/etc/ssl/private/${SSL_KEY_NAME}.key|" '/usr/share/ssl-cert/ssleay.cnf' > "${FILECONFIG}"
    #openssl req -config "${FILECONFIG}" -new -x509 -days 3650 -nodes -out "/etc/ssl/certs/${SSL_KEY_NAME}.crt" -keyout "/etc/ssl/private/${SSL_KEY_NAME}.key"
    #rm "${FILECONFIG}"

    logger_info "Génération de la clé privée"
    openssl genrsa -out /etc/ssl/private/${FQDN}.key 2048 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && logger_error
    chmod 400 /etc/ssl/private/${FQDN}.key 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && logger_error
    logger_info "Génération du certificat auto-signé"
    openssl req -new -x509 -days 3650 -key /etc/ssl/private/${FQDN}.key -out /etc/ssl/certs/${FQDN}.crt <<< "${COUNTRY}
${PROVINCE}
${CITY}
${ORGANIZATION}

${FQDN}
${EMAIL}

" 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && logger_error
    echo -e "Génération du certificat pour ${CCYAN}${FQDN}${CVOID} : ${CVERT}OK ...${CVOID}"
}