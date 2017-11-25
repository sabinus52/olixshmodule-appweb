###
# Initialisation et création d'une nouvelle application
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
info "Test si root"
System.logged.isRoot || critical "Seulement root peut executer cette action"



###
# Lecture du code de la nouvelle application
##
while true; do
    Read.string "Choix du ${CBLANC}code${CVOID} de la nouvelle application" ""
    String.test "$OLIX_FUNCTION_RETURN" "[a-za-Z][a-zA-Z0-9]+" && break
done
OLIX_MODULE_WEBAPP_CODE=$OLIX_FUNCTION_RETURN


###
# Lecture des données de l'application
##

# Label de l'application
while true; do
    Read.string "${CBLANC}Nom${CVOID} de la nouvelle application" ""
    [[ -n $OLIX_FUNCTION_RETURN ]] && break
done
OLIX_MODULE_WEBAPP_LABEL="$OLIX_FUNCTION_RETURN"

# Emplacement où sera installé l'application
Read.string "${CBLANC}Emplacement${CVOID} de la nouvelle application" "/home/${OLIX_MODULE_WEBAPP_CODE}"
OLIX_MODULE_WEBAPP_PATH=$OLIX_FUNCTION_RETURN

# Propriétaire de l'application
while true; do
    Read.string "${CBLANC}Propriétaire${CVOID} de la nouvelle application dans ${CBLANC}${OLIX_MODULE_WEBAPP_PATH}${CVOID}" "otop"
    System.user.exists $OLIX_FUNCTION_RETURN && break
done
OLIX_MODULE_WEBAPP_OWNER=$OLIX_FUNCTION_RETURN

# Groupe de l'application
while true; do
    Read.string "${CBLANC}Groupe${CVOID} de la nouvelle application dans ${CBLANC}${OLIX_MODULE_WEBAPP_PATH}${CVOID}" "users"
    System.group.exists $OLIX_FUNCTION_RETURN && break
done
OLIX_MODULE_WEBAPP_GROUP=$OLIX_FUNCTION_RETURN

# Type de dev de l'application
Read.choices "${CBLANC}Type ${CVOID} de l'application" "symfony" "symfony unknow"
OLIX_MODULE_WEBAPP_TYPE=$OLIX_FUNCTION_RETURN

# Moteur de la base de données
Read.choices "${CBLANC}Moteur BD ${CVOID} de l'application" "postgres" "mysql postgres"
OLIX_MODULE_WEBAPP_DBENGINE=$OLIX_FUNCTION_RETURN

# Choix de l'environnement
Read.choices "Environnement de l'application" "devp" "$OLIX_MODULE_WEBAPP_LISTENV"
OLIX_MODULE_WEBAPP_ENVIRONMENT=$OLIX_FUNCTION_RETURN


###
# Nouvelle application
##
Webapp.new $OLIX_MODULE_WEBAPP_CODE $OLIX_MODULE_WEBAPP_PATH


###
# Création des dossiers
##
if Directory.exists $OLIX_MODULE_WEBAPP_PATH; then
    echo -e "${CJAUNE}ATTENTION !!! Ceci va supprimer le dossier '${OLIX_MODULE_WEBAPP_PATH}'${CVOID}"
    Read.confirm "Confirmer" false
    [[ $OLIX_FUNCTION_RETURN == false ]] && return
fi
rm -rf $OLIX_MODULE_WEBAPP_PATH 2> ${OLIX_LOGGER_FILE_ERR}
[[ $? -ne 0 ]] && critical

# Création du répertoire
info "Création du répertoire ${OLIX_MODULE_WEBAPP_PATH}"
mkdir -p $(dirname $(Webapp.fileyml)) 2> ${OLIX_LOGGER_FILE_ERR}
[[ $? -ne 0 ]] && critical

# Affecte les droits au répertoire
chown -R $OLIX_MODULE_WEBAPP_OWNER:$OLIX_MODULE_WEBAPP_GROUP $OLIX_MODULE_WEBAPP_PATH 2> ${OLIX_LOGGER_FILE_ERR}
[[ $? -ne 0 ]] && critical



###
# Création du fichier de conf webapp.yml
##
OLIX_MODULE_WEBAPP_FILEYML=$(Webapp.fileyml)
cp $OLIX_MODULE_PATH/webapp/res/template.yml $OLIX_MODULE_WEBAPP_FILEYML 2> ${OLIX_LOGGER_FILE_ERR}
[[ $? -ne 0 ]] && critical
sed -i "s/#code#/$OLIX_MODULE_WEBAPP_CODE/g" $OLIX_MODULE_WEBAPP_FILEYML
sed -i "s/#label#/$OLIX_MODULE_WEBAPP_LABEL/g" $OLIX_MODULE_WEBAPP_FILEYML
sed -i "s/#path#/${OLIX_MODULE_WEBAPP_PATH//\//\\\/}/g" $OLIX_MODULE_WEBAPP_FILEYML
sed -i "s/#owner#/$OLIX_MODULE_WEBAPP_OWNER/g" $OLIX_MODULE_WEBAPP_FILEYML
sed -i "s/#group#/$OLIX_MODULE_WEBAPP_GROUP/g" $OLIX_MODULE_WEBAPP_FILEYML
sed -i "s/#type#/$OLIX_MODULE_WEBAPP_TYPE/g" $OLIX_MODULE_WEBAPP_FILEYML
sed -i "s/#dbengine#/$OLIX_MODULE_WEBAPP_DBENGINE/g" $OLIX_MODULE_WEBAPP_FILEYML



###
# Création du fichier de configuration du serveur
##
Webapp.config.save $OLIX_MODULE_WEBAPP_CODE
[[ $? -ne 0 ]] && critical "Erreur lors de la création du fichier de configuration webapp.${OLIX_MODULE_WEBAPP_CODE}.conf"



###
# FIN
##
echo -e "${CVERT}Action terminée avec succès${CVOID}"
