###
# Applique la configuration système
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

if [[ -z $OLIX_MODULE_WEBAPP_CODE ]]; then
    Module.execute.usage "config"
    critical "Nom de la webapp manquante"
fi
if ! Webapp.config.exists $OLIX_MODULE_WEBAPP_CODE; then
    Module.execute.usage "config"
    critical "L'application '${OLIX_MODULE_WEBAPP_CODE}' n'existe pas"
fi


###
# Chargement de la configuration
##
Webapp.load $OLIX_MODULE_WEBAPP_CODE


###
# Installation de la configuration système
##
Print.head2 "Installation des fichiers systèmes"
Webapp.install.logrotate
Webapp.install.crontab
Webapp.install.apache
Webapp.install.certificate
systemctl restart apache2
if [[ $? -ne 0 ]]; then
    systemctl status apache2
    critical "Problème de démarrage d'Apache"
fi


###
# FIN
##
echo -e "${CVERT}Action terminée avec succès${CVOID}"
