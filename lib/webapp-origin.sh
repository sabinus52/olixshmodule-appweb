###
# Librairies de la gestion des origines d'une WEBAPP
# ==============================================================================
# @package olixsh
# @module webapp
# @author Olivier <sabinus52@gmail.com>
##


function Webapp.origin.port()
{
    echo -n $OLIX_MODULE_WEBAPP_ORIGIN_PORT
}


function Webapp.origin.uri()
{
    echo -n "$OLIX_MODULE_WEBAPP_ORIGIN_USER@$OLIX_MODULE_WEBAPP_ORIGIN_HOST:$OLIX_MODULE_WEBAPP_ORIGIN_PATH"
}


function Webapp.origin.name()
{
    echo -n "$OLIX_MODULE_WEBAPP_ORIGIN_NAME"
}


function Webapp.origin.check()
{
    debug "Webapp.origin.check ()"

    local I OHOST OPORT OUSER ONAME OPATH

    # Test des valeurs origin
    OHOST=$(Webapp.get 'origin.server_1.host')
    [[ -z $OHOST ]] && critical "Le paramètre 'origin.server_1' n'est pas renseigné"

    for (( I = 1; I < 10; I++ )); do
        OHOST=$(Webapp.get "origin.server_${I}.host")
        [[ -z $OHOST ]] && break

        ONAME=$(Webapp.get "origin.server_${I}.name")
        [[ -z $ONAME ]] && critical "Le paramètre 'origin.server_${I}' n'est pas renseigné"
        OPORT=$(Webapp.get "origin.server_${I}.port")
        [[ -z $OPORT ]] && critical "Le paramètre 'origin.server_${I}' n'est pas renseigné"
        OUSER=$(Webapp.get "origin.server_${I}.user")
        [[ -z $OUSER ]] && critical "Le paramètre 'origin.server_${I}' n'est pas renseigné"
        OPATH=$(Webapp.get "origin.server_${I}.path")
        [[ -z $OPATH ]] && critical "Le paramètre 'origin.server_${I}' n'est pas renseigné"
    done
}


function Webapp.origin.read()
{
    echo "Choix du serveur d'origine des sources"
    local I CHOICE OHOST ONAME
    for (( I = 1; I < 10; I++ )); do
        OHOST=$(Webapp.get "origin.server_${I}.host")
        [[ -z $OHOST ]] && break
        CHOICE="$CHOICE $I"
        ONAME=$(Webapp.get "origin.server_${I}.name")
        echo -e " ${CJAUNE}$I${CVOID} : $ONAME ($OHOST)"
    done
    Read.choices "" "$(Webapp.get 'origin.default')" "$CHOICE"

    OLIX_MODULE_WEBAPP_ORIGIN_NAME=$(Webapp.get "origin.server_$OLIX_FUNCTION_RETURN.name")
    OLIX_MODULE_WEBAPP_ORIGIN_HOST=$(Webapp.get "origin.server_$OLIX_FUNCTION_RETURN.host")
    OLIX_MODULE_WEBAPP_ORIGIN_PORT=$(Webapp.get "origin.server_$OLIX_FUNCTION_RETURN.port")
    OLIX_MODULE_WEBAPP_ORIGIN_USER=$(Webapp.get "origin.server_$OLIX_FUNCTION_RETURN.user")
    OLIX_MODULE_WEBAPP_ORIGIN_PATH=$(Webapp.get "origin.server_$OLIX_FUNCTION_RETURN.path")
}