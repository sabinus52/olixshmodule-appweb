###
# Parse les paramètres de la commande en fonction des options
# ==============================================================================
# @package olixsh
# @module webapp
# @author Olivier <sabinus52@gmail.com>
##



###
# Parsing des paramètres
##
function olixmodule_webapp_params_parse()
{
    debug "olixmodule_webapp_params_parse ($@)"
    local ACTION=$1
    local PARAM

    shift
    while [[ $# -ge 1 ]]; do
        case $1 in
            --env=*)
                OLIX_MODULE_WEBAPP_ENVIRONMENT=$(String.lower $(String.explode.value $1))
                ;;
            --port=*)
                OLIX_MODULE_WEBAPP_ORIGIN_PORT=$(String.lower $(String.explode.value $1))
                ;;
            *)
                olixmodule_webapp_params_get "${ACTION}" "$1"
                ;;
        esac
        shift
    done

    olixmodule_webapp_params_debug $ACTION
}


###
# Fonction de récupération des paramètres
# @param $1 : Nom de l'action
# @param $2 : Nom du paramètre
##
function olixmodule_webapp_params_get()
{
    case $1 in
        config|applysys|origin|backup)
            [[ -z $OLIX_MODULE_WEBAPP_CODE ]] && OLIX_MODULE_WEBAPP_CODE=$2 && return
            ;;
        install)
            [[ -z $OLIX_MODULE_WEBAPP_ORIGIN_SERVER ]] && OLIX_MODULE_WEBAPP_ORIGIN_SERVER=$2 && return
            ;;
    esac
}


###
# Mode DEBUG
# @param $1 : Action du module
##
function olixmodule_webapp_params_debug ()
{
    case $1 in
        config|applysys|origin|backup)
            debug "OLIX_MODULE_WEBAPP_CODE=${OLIX_MODULE_WEBAPP_CODE}"
            ;;
        install)
            debug "OLIX_MODULE_WEBAPP_ENVIRONMENT=${OLIX_MODULE_WEBAPP_ENVIRONMENT}"
            debug "OLIX_MODULE_WEBAPP_ORIGIN_PORT=${OLIX_MODULE_WEBAPP_ORIGIN_PORT}"
            ;;
    esac
}
