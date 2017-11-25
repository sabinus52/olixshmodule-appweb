###
# Module de la gestion des applications web
# ==============================================================================
# @package olixsh
# @module webapp
# @label Gestion des applications web
# @author Olivier <sabinus52@gmail.com>
##



###
# Paramètres du modules
##

# Prefix des variables de sorties des paramètre du fichier de config
OLIX_MODULE_WEBAPP_CONFIG_PREFIX="OLIX_MODULE_WEBAPP_CONF_"

# Liste des environnements disponibles
OLIX_MODULE_WEBAPP_LISTENV="prod rect klif devp"

# Par défaut
OLIX_MODULE_WEBAPP_ENVIRONMENT=""
OLIX_MODULE_WEBAPP_ORIGIN_PORT=22


###
# Chargement des librairies requis
##
olixmodule_webapp_require_libraries()
{
    load "modules/webapp/lib/*"
    load "utils/yaml.sh"
}


###
# Retourne la liste des modules requis
##
olixmodule_webapp_require_module()
{
    echo -e ""
}


###
# Retourne la liste des binaires requis
##
olixmodule_webapp_require_binary()
{
    echo -e "openssl"
}


###
# Traitement à effectuer au début d'un traitement
##
# olixmodule_webapp_include_begin()
# {
# }


###
# Traitement à effectuer au début d'un traitement
##
# olixmodule_webapp_include_end()
# {
#    echo "FIN"
# }


###
# Sortie de liste pour la completion
##
# olixmodule_webapp_list()
# {
# }
