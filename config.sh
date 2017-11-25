###
# Configuration de l'application en modifiant le fichier de configuration
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
    Module.execute.usage "config"
    critical "Nom de la webapp manquante"
fi
if ! Webapp.config.exists $OLIX_MODULE_WEBAPP_CODE; then
    Module.execute.usage "config"
    critical "L'application '${OLIX_MODULE_WEBAPP_CODE}' n'existe pas"
fi


###
# Affichage de la configuration
##
Print.echo "Contenu du fichier de configuration de l'application ${CCYAN}${OLIX_MODULE_WEBAPP_CODE}${CVOID}"
Print.line
cat $(Webapp.config.fileName $OLIX_MODULE_WEBAPP_CODE)
Print.line

Read.confirm "Modifier la configuration" false
[[ $OLIX_FUNCTION_RETURN == false ]] && return



###
# Saisie des nouveaux paramètres de configuration
##
Webapp.config.load $OLIX_MODULE_WEBAPP_CODE

# Fichier webapp.yml
Read.file "Chemin et fichier de configuration 'webapp.yml' de l'application $OLIX_MODULE_WEBAPP_CODE" "$OLIX_MODULE_WEBAPP_FILEYML" true
OLIX_MODULE_WEBAPP_FILEYML=$OLIX_FUNCTION_RETURN

# Environnement
Read.choices "Environnement de l'applications" "$OLIX_MODULE_WEBAPP_ENVIRONMENT" "$OLIX_MODULE_WEBAPP_LISTENV" 
OLIX_MODULE_WEBAPP_ENVIRONMENT=$OLIX_FUNCTION_RETURN

# Origine
Read.string "Nom de l'origine des sources" "$OLIX_MODULE_WEBAPP_ORIGIN_NAME"
OLIX_MODULE_WEBAPP_ORIGIN_NAME=$OLIX_FUNCTION_RETURN
Read.string "Hostname du serveur d'origine des sources" "$OLIX_MODULE_WEBAPP_ORIGIN_HOST"
OLIX_MODULE_WEBAPP_ORIGIN_HOST=$OLIX_FUNCTION_RETURN
Read.string "Port du serveur d'origine des sources" "$OLIX_MODULE_WEBAPP_ORIGIN_PORT"
OLIX_MODULE_WEBAPP_ORIGIN_PORT=$OLIX_FUNCTION_RETURN
Read.string "Utilisateur de connexion du serveur d'origine des sources" "$OLIX_MODULE_WEBAPP_ORIGIN_USER"
OLIX_MODULE_WEBAPP_ORIGIN_USER=$OLIX_FUNCTION_RETURN
Read.string "Chemin distant sur le serveur d'origine des sources" "$OLIX_MODULE_WEBAPP_ORIGIN_PATH"
OLIX_MODULE_WEBAPP_ORIGIN_PATH=$OLIX_FUNCTION_RETURN



###
# Création du fichier de configuration du serveur
##
Webapp.config.save $OLIX_MODULE_WEBAPP_CODE
[[ $? -ne 0 ]] && critical "Erreur lors de la création du fichier de configuration webapp.${OLIX_MODULE_WEBAPP_CODE}.conf"



###
# FIN
##
echo -e "${CVERT}Action terminée avec succès${CVOID}"
