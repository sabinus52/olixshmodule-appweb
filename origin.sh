###
# Visualise ou change le dépot d'une application
# ==============================================================================
# @package olixsh
# @module webapp
# @author Olivier <sabinus52@gmail.com>
##


###
# Librairies
##


###
# Vérification des paramètres
##
info "Test si propriétaire"
checkOlixshOwner || critical "Seulement $(Core.owner) peut executer cette action"

if [[ -z $OLIX_MODULE_WEBAPP_CODE ]]; then
    Module.execute.usage "origin"
    critical "Nom de la webapp manquante"
fi
if ! Webapp.config.exists $OLIX_MODULE_WEBAPP_CODE; then
    Module.execute.usage "origin"
    critical "L'application '${OLIX_MODULE_WEBAPP_CODE}' n'existe pas"
fi


Webapp.load $OLIX_MODULE_WEBAPP_CODE



###
# Affichage de la configuration du dépôt courant
##
echo -e "Actuellement, le dépôt utilisé pour l'application ${CCYAN}${OLIX_MODULE_WEBAPP_CODE}${CVOID}"
echo -e "   Nom         : ${Ccyan}${OLIX_MODULE_WEBAPP_ORIGIN_NAME}${CVOID}"
echo -e "   Serveur     : ${Ccyan}${OLIX_MODULE_WEBAPP_ORIGIN_HOST}${CVOID}"
echo -e "   Port        : ${Ccyan}${OLIX_MODULE_WEBAPP_ORIGIN_PORT}${CVOID}"
echo -e "   Utilisateur : ${Ccyan}${OLIX_MODULE_WEBAPP_ORIGIN_USER}${CVOID}"
echo -e "   Chemin      : ${Ccyan}${OLIX_MODULE_WEBAPP_ORIGIN_PATH}${CVOID}"
echo
Webapp.origin.read


###
# Création du fichier de configuration du serveur
##
Webapp.config.save $OLIX_MODULE_WEBAPP_CODE
[[ $? -ne 0 ]] && critical "Erreur lors de la création du fichier de configuration webapp.${OLIX_MODULE_WEBAPP_CODE}.conf"


###
# FIN
##
echo -e "${CVERT}Action terminée avec succès${CVOID}"
