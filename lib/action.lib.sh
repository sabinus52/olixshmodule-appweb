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

    # Emplacement de la configuration
    stdin_readDirectory "Chemin contenant la liste de la configuration de chaque application web" "${OLIX_MODULE_APPWEB_CONFIG_DIR}"
    logger_debug "OLIX_MODULE_APPWEB_CONFIG_DIR=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_APPWEB_CONFIG_DIR=${OLIX_STDIN_RETURN}

    # Ecriture du fichier de configuration
    logger_info "Création du fichier de configuration ${OLIX_MODULE_FILECONF}"
    echo "# Fichier de configuration du module APPWEB" > ${OLIX_MODULE_FILECONF} 2> ${OLIX_LOGGER_FILE_ERR}
    [[ $? -ne 0 ]] && logger_error
    echo "OLIX_MODULE_APPWEB_CONFIG_DIR=${OLIX_MODULE_APPWEB_CONFIG_DIR}" >> ${OLIX_MODULE_FILECONF}

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
    return 0
}
