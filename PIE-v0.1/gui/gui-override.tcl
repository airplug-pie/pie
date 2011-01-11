#    pie
#    a twitter-like app for airplug
#    authors: Christophe Boudet, Julien Castaigne, Jonathan Roudière,
#             Christophe Roquette, Jérémy Subtil
#    license type: free of charge license for academic and research purpose
#    see license.txt


### SURCHARGE DE FONCTIONS ####################################################

## Surcharge de la fonction associee au bouton depart
proc APG_int_btstart { } {
    # Le bouton Depart devient "disable"
    APG_int_disablebtstart

    # Le bouton Envoyer de la zone d'emission devient "actif"
    $::gui(send_button) configure -state active

    # Abonnement aux applications 
    APG_begin_air "PIE"
    
    # Envoi des messages HeartBeat
    PIE_start_hbeat
}

###############################################################################

