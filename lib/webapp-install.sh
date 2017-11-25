###
# Librairies de la gestion de l'installation d'une WEBAPP
# ==============================================================================
# @package olixsh
# @module webapp
# @author Olivier <sabinus52@gmail.com>
##



###
# Installation des paquets additionnels
##
function Webapp.install.packages()
{
    debug "Webapp.install.packages ()"

    local PACKAGES=$(Webapp.get 'install.packages.aptget')
    debug "YML:install.packages.aptget=${PACKAGES}"
    [[ -z $PACKAGES ]] && return 0

    info "Installation des packages '${PACKAGES}'"
    apt-get --yes install $PACKAGES 2> ${OLIX_LOGGER_FILE_ERR} || critical
    Print.echo "Installation des paquets additionnels ${CCYAN}${PACKAGES}${CVOID} : ${CVERT}OK${CVOID}"
}


###
# Création des dossiers additionnels
##
function Webapp.install.directories()
{
    debug "Webapp.install.directories ()"
    local I
    local OWNER=$(Webapp.get 'owner')
    local GROUP=$(Webapp.get 'group')

    # Dossier principal
    local DIR=$(Webapp.get 'path')
    if ! Directory.exists $DIR; then
        info "Création du dossier '${DIR}'"
        mkdir -p $DIR > ${OLIX_LOGGER_FILE_ERR} 2>&1 || critical
    fi
    info "Changement des droits '${OWNER}.${GROUP}'"
    chown -R $OWNER:$GROUP $DIR > ${OLIX_LOGGER_FILE_ERR} 2>&1 || critical
    Print.echo "Création du dossier ${CCYAN}${DIR}${CVOID} : ${CVERT}OK${CVOID}"

    # Dossiers complémentaires
    local DIRS=$(Webapp.get 'install.directories')
    [[ -z $DIRS ]] && return 0
    for I in $DIRS; do
        if ! Directory.exists $I; then
            info "Création du dossier '${I}'"
            mkdir -p $I > ${OLIX_LOGGER_FILE_ERR} 2>&1 || critical
        fi
        info "Changement des droits '${OWNER}.${GROUP}'"
        chown -R $OWNER:$GROUP $I > ${OLIX_LOGGER_FILE_ERR} 2>&1 || critical
        Print.echo "Création du dossier additionnel ${CCYAN}${I}${CVOID} : ${CVERT}OK${CVOID}"
    done
}


###
# Création du dossier qui contiendra les sources
##
function Webapp.install.files()
{
    debug "Webapp.install.files ()"

    local DIR=$(Webapp.get 'path')
    local OWNER=$(Webapp.get 'owner')
    local GROUP=$(Webapp.get 'group')
    local EXCLUDE=$(Webapp.get 'install.exclude.files')
    local PUBKEY="$(eval echo ~$OWNER)/.ssh/id_dsa"

    info "Synchronisation de $(Webapp.origin.uri) vers ${DIR}"
    echo "Mot de passe de connexion au serveur $(Webapp.origin.name)"
    set +x
    #file_synchronize "${OLIX_MODULE_WEBAPP_ORIGIN_PORT} -i ${PUBKEY}" "${OLIX_MODULE_WEBAPP_ORIGIN_USER}@${OLIX_MODULE_WEBAPP_ORIGIN_HOST}:${OLIX_MODULE_WEBAPP_ORIGIN_PATH}" "${DIR}" "${EXCLUDE}"
    Filesystem.synchronize "$(Webapp.origin.port)" "$(Webapp.origin.uri)" "$DIR" "$EXCLUDE" || critical

    info "Changement des droits '${OWNER}.${GROUP}'"
    chown -R $OWNER:$GROUP $DIR > ${OLIX_LOGGER_FILE_ERR} 2>&1 || critical
    Print.echo "Copie des fichiers sources vers ${CCYAN}${DIR}${CVOID} : ${CVERT}OK${CVOID}"
}


###
# Installation des bases de données
##
function Webapp.install.databases()
{
    debug "Webapp.install.databases"
    local I
    local LISTBASES=$(Webapp.get 'bases.bases')

    local EXCLUDE=$(Webapp.get 'install.exclude.bases')

    for I in $LISTBASES; do
        info "Installation de la base '${I}'"
        # Ne copie pas les données pour les bases à exclure
        if String.list.contains "$EXCLUDE" $I; then
            Webapp.install.base $I false
        else
            Webapp.install.base $I true
        fi
        Print.echo "Restauration des données de la base ${CCYAN}${I}${CVOID} : ${CVERT}OK${CVOID}"
    done
}


function Webapp.install.base()
{
    debug "Webapp.install.base ($1, $2)"
    local DBENGINE=$(Webapp.dbengine)
    local MYROLE=$(Webapp.get 'bases.role')
    local MYPASS=$(Webapp.get 'bases.password')

    # Création de la base
    info "Création de la base '$1' avec le rôle '${MYROLE}'"
    [[ $DBENGINE == "Mysql" ]] && MYROLE=$MYROLE@localhost
    $DBENGINE.base.initialize "$1" "$MYROLE" "$MYPASS" || critical

    # Demande d'infos du serveur distant de la BD
    Read.connection
    #Read.password "Mot de passe de connexion au serveur ${OLIX_RETURN_HOST}"
    #OLIX_RETURN_PASS=$OLIX_FUNCTION_RETURN
    $DBENGINE.action.read $OLIX_RETURN_HOST $OLIX_RETURN_PORT $OLIX_RETURN_USER $OLIX_RETURN_PASS
    OLIX_RETURN_BASE=$OLIX_FUNCTION_RETURN

    # Synchronisation de la base
    if [[ -n $OLIX_RETURN_BASE ]]; then
        info "Synchronisation de la base '${OLIX_RETURN_BASE}' (${OLIX_RETURN_HOST}) vers '$1'"
        case $DBENGINE in
            Mysql)      Mysql.action.synchronize \
                            "--host=$OLIX_RETURN_HOST --port=$OLIX_RETURN_PORT --user=$OLIX_RETURN_USER -p" \
                            "$OLIX_RETURN_BASE" \
                            "--host=$OLIX_MODULE_MYSQL_HOST --port=$OLIX_MODULE_MYSQL_PORT --user=$OLIX_MODULE_MYSQL_USER --password=$OLIX_MODULE_MYSQL_PASS" \
                            "$1"
                            ;;
            Postgres)   Postgres.action.synchronize \
                            "--host=$OLIX_RETURN_HOST --port=$OLIX_RETURN_PORT --user=$OLIX_RETURN_USER" "$OLIX_RETURN_PASS" \
                            "$OLIX_RETURN_BASE" "$1"
                            ;;
        esac
        [[ $? -ne 0 ]] && critical "Echec de la synchronisation de '${1}' depuis '${OLIX_RETRUN_BASE}' (${OLIX_RETRUN_USER}@${OLIX_RETRUN_HOST}:${OLIX_RETRUN_PORT})"
    fi

    return 0
}


function Webapp.install.script()
{
    debug "Webapp.install.script ()"
    local SCRIPT=$(Webapp.pathconf)/$(Webapp.get 'install.script')

    [[ -z $(Webapp.get 'install.script') ]] && warning "Pas de script personnalisé à installer" && return 0
    [[ ! -r $SCRIPT ]] && critical "Script $SCRIPT absent ou non executable"
    info "Exécution du script '$SCRIPT'"
    source $SCRIPT
    return 0
}



###
# Installation du fichier logrotate
##
function Webapp.install.logrotate()
{
    debug "Webapp.install.logrotate ()"
    local FILE=$(Webapp.get "system.$OLIX_MODULE_WEBAPP_ENVIRONMENT.logrotate")

    [[ -z $FILE ]] && warning "Pas de configuration trouvée pour logrotate" && return 0
    FILE=$(Webapp.pathconf)/$FILE
    info "Copie de ${FILE} vers /etc/logrotate.d"
    File.copy "$FILE" "/etc/logrotate.d/$OLIX_MODULE_WEBAPP_CODE" || critical
    Print.echo "Mise en place de ${CCYAN}$(basename $FILE)${CVOID} vers /etc/logrotate.d : ${CVERT}OK${CVOID}"
}


###
# Installation du fichier crontab
##
function Webapp.install.crontab()
{
    debug "Webapp.install.crontab ()"
    local FILE=$(Webapp.get "system.$OLIX_MODULE_WEBAPP_ENVIRONMENT.crontab")

    [[ -z $FILE ]] && warning "Pas de configuration trouvée pour crontab" && return 0
    FILE=$(Webapp.pathconf)/$FILE
    info "Copie de ${FILE} vers /etc/cron.d"
    File.copy "$FILE" "/etc/cron.d/$OLIX_MODULE_WEBAPP_CODE" || critical
    Print.echo "Mise en place de ${CCYAN}$(basename $FILE)${CVOID} vers /etc/cron.d : ${CVERT}OK${CVOID}"
}


###
# Installation du fichier du virtualhost pour Apache
##
function Webapp.install.apache()
{
    debug "Webapp.install.apache ()"
    local VHOST=$(Webapp.get "system.$OLIX_MODULE_WEBAPP_ENVIRONMENT.apache")

    [[ -z $VHOST ]] && warning "Pas de configuration trouvée pour apache" && return 0
    VHOST=$(Webapp.pathconf)/$VHOST
    info "Copie de ${VHOST} vers /etc/apache2/sites-available"
    File.copy "$VHOST" "/etc/apache2/sites-available/$OLIX_MODULE_WEBAPP_CODE.conf" || critical
    info "Activation du site ${OLIX_MODULE_WEBAPP_CODE}"
    a2ensite ${OLIX_MODULE_WEBAPP_CODE} > ${OLIX_LOGGER_FILE_ERR} 2>&1 || critical
    Print.echo "Activation du site ${CCYAN}$OLIX_MODULE_WEBAPP_CODE${CVOID} : ${CVERT}OK${CVOID}"
}


###
# Installation des certificats
##
function Webapp.install.certificate()
{
    debug "Webapp.install.certificate ()"

    local KEY=$(Webapp.get "system.$OLIX_MODULE_WEBAPP_ENVIRONMENT.certificate.files.key")
    local FQDN=$(Webapp.get "system.$OLIX_MODULE_WEBAPP_ENVIRONMENT.certificate.autosigned.fqdn")

    [[ -z $KEY ]] && [[ -z $FQDN ]] && warning "Pas de certificat trouvé pour apache" && return 0

    [[ -n $KEY ]] && Webapp.install.certificate.files && return 0
    [[ -n $FQDN ]] && Webapp.install.certificate.autosigned && return 0
}


###
# Installation d'un certificat déjà généré
##
function Webapp.install.certificate.files()
{
    debug "Webapp.install.certificate.files ()"

    local I FILECRT
    local KEY=$(Webapp.get "system.$OLIX_MODULE_WEBAPP_ENVIRONMENT.certificate.files.key")
    local CRT=$(Webapp.get "system.$OLIX_MODULE_WEBAPP_ENVIRONMENT.certificate.files.crt")
    [[ -z $KEY ]] && logger_warning "Pas de certificat trouvé pour apache" && return 0
    [[ -z $CRT ]] && logger_warning "Pas de certificat trouvé pour apache" && return 0

    local FILEKEY=$(Webapp.pathconf)/$KEY
    ! File.exists $FILEKEY && warning "La clé ${KEY} n'a pas été trouvé" && return 0
    info "Copie de $FILEKEY vers /etc/ssl/private"
    File.copy "$FILEKEY" "/etc/ssl/private/$KEY" || critical
    chmod 400 /etc/ssl/private/$KEY 2> ${OLIX_LOGGER_FILE_ERR} || critical

    for I in $CRT; do
        FILECRT=(Webapp.pathconf)/$I
        info "Copie de $FILECRT vers /etc/ssl/certs"
        File.copy "$FILECRT" "/etc/ssl/certs/"
    done

    Print.echo "Installation du certificat ${CCYAN}$CRT${CVOID} : ${CVERT}OK${CVOID}"
}


###
# Génération d'un certificat auto-signé
##
function Webapp.install.certificate.autosigned()
{
    logger_debug "Webapp.install.certificate.autosigned ()"

    local FQDN=$(Webapp.get "system.$OLIX_MODULE_WEBAPP_ENVIRONMENT.certificate.autosigned.fqdn")
    local COUNTRY=$(Webapp.get "system.$OLIX_MODULE_WEBAPP_ENVIRONMENT.certificate.autosigned.country")
    local PROVINCE=$(Webapp.get "system.$OLIX_MODULE_WEBAPP_ENVIRONMENT.certificate.autosigned.province")
    local CITY=$(Webapp.get "system.$OLIX_MODULE_WEBAPP_ENVIRONMENT.certificate.autosigned.city")
    local ORGANIZATION=$(Webapp.get "system.$OLIX_MODULE_WEBAPP_ENVIRONMENT.certificate.autosigned.organization")
    local EMAIL=$(Webapp.get "system.$OLIX_MODULE_WEBAPP_ENVIRONMENT.certificate.autosigned.email")

    [[ -z $FQDN ]] && warning "Pas de certificat trouvé pour apache" && return 0
    File.exists /etc/ssl/certs/$FQDN.crt && warning "Le certificat existe déjà pour apache" && return 0

    # Pour debian auto signé local
    #FILECONFIG=$(core_makeTemp)
    #SSL_KEY_NAME=${FQDN}
    #sed -e "s/@HostName@/${SSL_KEY_NAME}/" -e "s|privkey.pem|/etc/ssl/private/${SSL_KEY_NAME}.key|" '/usr/share/ssl-cert/ssleay.cnf' > "${FILECONFIG}"
    #openssl req -config "${FILECONFIG}" -new -x509 -days 3650 -nodes -out "/etc/ssl/certs/${SSL_KEY_NAME}.crt" -keyout "/etc/ssl/private/${SSL_KEY_NAME}.key"
    #rm "${FILECONFIG}"

    info "Génération de la clé privée"
    openssl genrsa -out /etc/ssl/private/$FQDN.key 2048 2> ${OLIX_LOGGER_FILE_ERR} || critical
    chmod 400 /etc/ssl/private/$FQDN.key 2> ${OLIX_LOGGER_FILE_ERR} || critical
    info "Génération du certificat auto-signé"
    openssl req -new -x509 -days 3650 -key /etc/ssl/private/$FQDN.key -out /etc/ssl/certs/$FQDN.crt <<< "$COUNTRY
$PROVINCE
$CITY
$ORGANIZATION

$FQDN
$EMAIL

" 2> ${OLIX_LOGGER_FILE_ERR} || critical
    Print.echo "Génération du certificat pour ${CCYAN}$FQDN${CVOID} : ${CVERT}OK${CVOID}"
}
