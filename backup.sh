###
# Sauvegarde d'une application
# ==============================================================================
# @package olixsh
# @module webapp
# @author Olivier <sabinus52@gmail.com>
##


###
# Librairies
##
load 'utils/backup.sh'
load 'utils/report.sh'



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

# Chargement de la WEBAPP
Webapp.load $OLIX_MODULE_WEBAPP_CODE
IS_ERROR=false


###
# Traitement
##
Print.head1 "Sauvegarde du projet %s le %s à %s" "$OLIX_MODULE_WEBAPP_CODE" "$OLIX_SYSTEM_DATE" "$OLIX_SYSTEM_TIME"

# Initialisation
Webapp.backup.initialize || IS_ERROR=true

# Sauvegarde des bases
Webapp.backup.databases || IS_ERROR=true

# Sauvegarde des dossiers
Webapp.backup.files || IS_ERROR=true

# Synchronisation du FTP
Backup.ftp.synchronize || IS_ERROR=true


###
# FIN
##
if [[ $IS_ERROR == true ]]; then
    Print.echo; Print.line; Print.echo "Sauvegarde terminée en $(System.exec.time) secondes avec des erreurs" "${Crouge}"
    Report.terminate "ERREUR - Rapport de backup des bases du serveur $HOSTNAME"
else
    Print.echo; Print.line; Print.echo "Sauvegarde terminée en $(System.exec.time) secondes avec succès" "${Cvert}"
    Report.terminate "Rapport de backup des bases du serveur $HOSTNAME"
fi
