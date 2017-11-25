###
# Librairies de la gestion du fichier de config d'une WEBAPP
# ==============================================================================
# @package olixsh
# @module webapp
# @author Olivier <sabinus52@gmail.com>
##



###
# Retourne le nom du fichier de configuration
##
function Webapp.config.fileName()
{
    echo -n "$OLIX_CORE_PATH_CONFIG/webapp.$1.conf"
}


###
# Vérifie si le fichier de configuration existe
##
function Webapp.config.exists()
{
    [[ -r $(Webapp.config.fileName $1) ]] && return 0 || return 1
}


###
# Retourne le label de l'application depuis le fichier de conf
##
function Webapp.config.label()
{
    File.content.value $(Webapp.config.fileName $1) 'OLIX_MODULE_WEBAPP_LABEL'
}


###
# Retourne l'environnement
##
function Webapp.config.env()
{
    echo -n $OLIX_MODULE_WEBAPP_ENVIRONMENT
}


###
# Vérifie si la configuration a été effectuée et la charge en mode silencieux
##
function Webapp.config.load()
{
    debug "Webapp.config.load ($1)"
    local FILECONF=$(Webapp.config.fileName $1)
    info "Charge le fichier de configuration ${FILECONF}"
    [[ ! -r $FILECONF ]] && critical "Fichier de configuration ${FILECONF} introuvable"
    source $FILECONF
    return $?
}


###
# Ecrit et sauvegarde les paramètres du fichier de configuration de l'application
# Valable lors de la création d'une nouvelle application
##
function Webapp.config.save()
{
    debug "Webapp.config.save ($1)"
    local FILECONF=$(Webapp.config.fileName $1)

    info "Création du fichier de configuration ${FILECONF}"
    echo "# Fichier de configuration de l'application $1 du module WEBAPP" > $FILECONF 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && logger_critical
    debug "OLIX_MODULE_WEBAPP_LABEL=${OLIX_MODULE_WEBAPP_LABEL}"
    echo "OLIX_MODULE_WEBAPP_LABEL=\"$OLIX_MODULE_WEBAPP_LABEL\"" >> $FILECONF
    debug "OLIX_MODULE_WEBAPP_FILEYML=${OLIX_MODULE_WEBAPP_FILEYML}"
    echo "OLIX_MODULE_WEBAPP_FILEYML=$OLIX_MODULE_WEBAPP_FILEYML" >> $FILECONF
    debug "OLIX_MODULE_WEBAPP_ENVIRONMENT=${OLIX_MODULE_WEBAPP_ENVIRONMENT}"
    echo "OLIX_MODULE_WEBAPP_ENVIRONMENT=$OLIX_MODULE_WEBAPP_ENVIRONMENT" >> $FILECONF
    debug "OLIX_MODULE_WEBAPP_ORIGIN_NAME=\"${OLIX_MODULE_WEBAPP_ORIGIN_NAME}\""
    echo "OLIX_MODULE_WEBAPP_ORIGIN_NAME=\"$OLIX_MODULE_WEBAPP_ORIGIN_NAME\"" >> $FILECONF
    debug "OLIX_MODULE_WEBAPP_ORIGIN_HOST=${OLIX_MODULE_WEBAPP_ORIGIN_HOST}"
    echo "OLIX_MODULE_WEBAPP_ORIGIN_HOST=$OLIX_MODULE_WEBAPP_ORIGIN_HOST" >> $FILECONF
    debug "OLIX_MODULE_WEBAPP_ORIGIN_PORT=${OLIX_MODULE_WEBAPP_ORIGIN_PORT}"
    echo "OLIX_MODULE_WEBAPP_ORIGIN_PORT=$OLIX_MODULE_WEBAPP_ORIGIN_PORT" >> $FILECONF
    debug "OLIX_MODULE_WEBAPP_ORIGIN_USER=${OLIX_MODULE_WEBAPP_ORIGIN_USER}"
    echo "OLIX_MODULE_WEBAPP_ORIGIN_USER=$OLIX_MODULE_WEBAPP_ORIGIN_USER" >> $FILECONF
    debug "OLIX_MODULE_WEBAPP_ORIGIN_PATH=${OLIX_MODULE_WEBAPP_ORIGIN_PATH}"
    echo "OLIX_MODULE_WEBAPP_ORIGIN_PATH=$OLIX_MODULE_WEBAPP_ORIGIN_PATH" >> $FILECONF
}
