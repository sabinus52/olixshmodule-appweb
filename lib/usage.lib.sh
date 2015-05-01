###
# Usage du module APPWEB
# ==============================================================================
# @package olixsh
# @module appweb
# @author Olivier <sabinus52@gmail.com>
##



###
# Usage principale  du module
##
function module_appweb_usage_main()
{
    logger_debug "module_appweb_usage_main ()"
    stdout_printVersion
    echo
    echo -e "Gestion des applications web"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}appweb ${CJAUNE}ACTION${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des ACTIONS disponibles${CVOID} :"
    echo -e "${Cjaune} init    ${CVOID}  : Initialisation du module"
    echo -e "${Cjaune} install ${CVOID}  : Installation de l'application depuis un autre serveur"
    echo -e "${Cjaune} backup  ${CVOID}  : Fait une sauvegarde de l'application (base+fichiers)"
    echo -e "${Cjaune} help    ${CVOID}  : Affiche cet écran"
}
