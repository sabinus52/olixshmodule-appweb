###
# Librairies d'une WEBAPP
# ==============================================================================
# @package olixsh
# @module debian
# @author Olivier <sabinus52@gmail.com>
##


OLIX_MODULE_WEBAPP_FILEYML=
OLIX_MODULE_WEBAPP_PATH=


###
# METHOD 1
# Chargement de la WEBAPP depuis son code
# @param $1 : Code de l'application
##
function Webapp.load()
{
    debug "Webapp.load ($1)"

    [[ -z $1 ]] && return 1
    ! Webapp.config.exists $1 && return 1
    ! Webapp.config.load $1 && return 1

    Webapp.loadYML $(Webapp.fileyml)
    return $?
}


###
# METHOD 2
# Chargement de la WEBAPP depuis son fichier YML
# @param $1 : Fichier YML
##
function Webapp.loadYML()
{
    debug "Webapp.loadYML ($1)"

    [[ -z $1 ]] && return 1
    ! File.exists $1 && warning "$1 absent" && return 1

    info "Chargement du fichier '$1'"
    Yaml.parse $1 "$OLIX_MODULE_WEBAPP_CONFIG_PREFIX"

    OLIX_MODULE_WEBAPP_CODE=$(Webapp.get 'code')
    OLIX_MODULE_WEBAPP_PATH=$(Webapp.get 'path')
    Webapp.load.dbengine
    return $?
}


###
# METHOD 3
# Création d'une nouvelle WEBAPP
# @param $1 : Code de l'application
# @param $2 : Emplacement de l'application
##
function Webapp.new()
{
    OLIX_MODULE_WEBAPP_CODE=$1
    OLIX_MODULE_WEBAPP_PATH=$2
}



###
# Retourne le fichier YML de l'application
##
function Webapp.fileyml()
{
    if [[ -z $OLIX_MODULE_WEBAPP_FILEYML ]]; then
        echo -n "$OLIX_MODULE_WEBAPP_PATH/xconf/webapp.yml"
    else
        echo -n $OLIX_MODULE_WEBAPP_FILEYML
    fi
}


###
# Retourne l'emplacement des fichiers de configuration
##
function Webapp.pathconf()
{
    echo -n "$OLIX_MODULE_WEBAPP_PATH/xconf"
}


###
# Environnement
##
alias Webapp.env="Webapp.config.env"


###
# Retourne une configuration
# @param $1 : Nom du paramètre
# @param $2 : Valeur par defaut
##
function Webapp.get()
{
    local VALUE=$(Yaml.get $1)
    if [[ -z $VALUE ]]; then
        [[ -z $2 ]] && echo -n "" && return
        warning "La configuration YAML:$1 n'est pas renseignée, utilisation de la valeur \"$2\" par défaut."
        echo -n "$2"
    else
        echo -n "$VALUE"
    fi
}


###
# Retourne le moteur de base de données utilisé par l'application
##
function Webapp.dbengine()
{
    local DBENGINE=$(String.capitalize $(Webapp.get 'dbengine'))
    case $DBENGINE in
        Mysql|Postgres) echo -n $DBENGINE;;
        *)              echo -n "";;
    esac
}


###
# Chargement des modules de base de données
##
function Webapp.load.dbengine()
{
    debug "Webapp.load.dbengine"
    local DBENGINE=$(Webapp.dbengine)

    case $DBENGINE in
        Mysql)      load "modules/mysql/lib/*"
                    Config.load 'mysql'
                    ;;
        Postgres)   load "modules/postgres/lib/*"
                    Config.load 'postgres'
                    ;;
    esac
}



###
# Retourne la liste des applications
##
function Webapp.applications()
{
    debug "Webapp.applications ()"
    local I

    local LIST=$(find $OLIX_CORE_PATH_CONFIG -maxdepth 1 -mindepth 1 -type f -name "webapp.*.conf")
    [[ $? -ne 0 ]] && return 1
    for I in $LIST; do
        echo -n "$(basename $I | sed "s/^webapp.\([a-zA-Z0-9]*\).conf$/\1/") "
    done
    return 0
}
