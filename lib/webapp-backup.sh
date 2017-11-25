###
# Fonctions pour la gestion de la sauvegarde
# ==============================================================================
# @package olixsh
# @module webapp
# @author Olivier <sabinus52@gmail.com>
##



###
# Initialise la sauvegarde
##
function Webapp.backup.initialize()
{
    debug "Webapp.backup.initialize ()"
    local ENVIRONMENT=$(Webapp.config.env)
    local IS_ERROR=0

    # Paramètres généraux
    local PURGE COMPRESS PATHDIR
    PURGE=$(Webapp.get "backup.$ENVIRONMENT.purge" "5")
    COMPRESS=$(Webapp.get "backup.$ENVIRONMENT.compress" "gz")
    PATHDIR=$(Webapp.get "backup.$ENVIRONMENT.repository" "/tmp")
    if ! Directory.exists $PATHDIR; then
        warning "Création du dossier inexistant backup.${ENVIRONMENT}.repository: \"${PATHDIR}\""
        mkdir $PATHDIR 2> /dev/null
        if [[ $? -ne 0 ]]; then
            error "Impossible de créer backup.${ENVIRONMENT}.repository: \"${PATHDIR}\", utilisation de la valeur \"/tmp\" par défaut."
            PATHDIR="/tmp"
            IS_ERROR=1
        fi
    elif [[ ! -w $PATHDIR ]]; then
        error "Le dossier ${PATHDIR} n'a pas les droits en écriture, utilisation de la valeur \"/tmp\" par défaut."
        PATHDIR="/tmp"
        IS_ERROR=1
    fi

    # Paramètres pour le FTP
    local FTP FTP_HOST FTP_USER FTP_PASS FTP_PATH
    FTP=$(Webapp.get "backup.$ENVIRONMENT.ftp.sync" false)
    if [[ $FTP != false ]]; then
        ! Ftp.installed $FTP && error "Le binaire $FTP n'est pas présent" && IS_ERROR=1
        FTP_HOST=$(Webapp.get "backup.$ENVIRONMENT.ftp.host")
        [[ -z $FTP_HOST ]] && error "La configuration YML:backup.${ENVIRONMENT}.ftp.host n'est pas définie" && IS_ERROR=1
        FTP_USER=$(Webapp.get "backup.$ENVIRONMENT.ftp.user")
        [[ -z $FTP_USER ]] && error "La configuration YML:backup.${ENVIRONMENT}.ftp.user n'est pas définie" && IS_ERROR=1
        FTP_PASS=$(Webapp.get "backup.$ENVIRONMENT.ftp.pass")
        [[ -z $FTP_PASS ]] && error "La configuration YML:backup.${ENVIRONMENT}.ftp.pass n'est pas définie" && IS_ERROR=1
        FTP_PATH=$(Webapp.get "backup.$ENVIRONMENT.ftp.path" "/")
    fi

    # Paramètres pour le rapport
    local REPORT_TYPE=$(Webapp.get "backup.$ENVIRONMENT.report.type" "text")
    local REPORT_PATH=$(Webapp.get "backup.$ENVIRONMENT.report.path" "/tmp")
    local REPORT_MAIL=$(Webapp.get "backup.$ENVIRONMENT.report.mail")

    Backup.initialize "$PATHDIR" "$COMPRESS" "$PURGE"
    Backup.initialize.ftp "$FTP" "$FTP_HOST" "21" "$FTP_USER" "$FTP_PASS" "$FTP_PATH"
    Report.initialize "$REPORT_TYPE" "$PATHDIR" \
        "rapport-backup-$OLIX_MODULE_WEBAPP_CODE" "$PURGE" \
        "$REPORT_EMAIL"

    return $IS_ERROR
}


###
# Sauvegarde des bases
##
function Webapp.backup.databases()
{
    debug "Webapp.backup.databases ()"
    local I
    local IS_ERROR=0
    local DBENGINE=$(Webapp.dbengine)

    local LIST_BASES=$(Webapp.get 'bases.bases')
    local LIST_EXCLUDE=$(Webapp.get 'backup.exclude.bases')
    local LIST_INCLUDE=$(Webapp.get 'backup.include.bases')
    local LIST_RESULT I

    # Récupération de la liste des bases
    for I in $LIST_BASES; do
        String.list.contains "$LIST_EXCLUDE" "$I" && continue
        LIST_RESULT="$LIST_RESULT $I"
    done
    LIST_RESULT="$LIST_RESULT $LIST_INCLUDE"
    info "Listes des bases à sauvegarder : ${LIST_RESULT}"

    # Traitement
    for I in $LIST_RESULT; do
        $DBENGINE.base.backup $I || IS_ERROR=1
    done
    return $IS_ERROR
}


###
# Sauvegarde des fichiers
##
function Webapp.backup.files()
{
    debug "Webapp.backup.files ()"
    local I
    local IS_ERROR=0

    # Sauvegarde des sources de l'application
    local DIR=$(Webapp.get 'path')
    local EXCLUDE=$(Webapp.get 'backup.exclude.files')
    Backup.directory "$DIR" "$EXCLUDE" || IS_ERROR=1

    # Sauvegarde des dossiers supplémentaires
    local LIST_DIRS=$(Webapp.get 'backup.include.files')
    for I in $LIST_DIRS; do
        Backup.directory "$I" "" || IS_ERROR=1
    done

    return $IS_ERROR
}
