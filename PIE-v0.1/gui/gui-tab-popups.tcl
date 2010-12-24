# --- gui-tab-popups.tcl ---

# Author(s) :
#		Jonathan Roudiere <joe.roudiere@gmail.com>
#
# Copyright : 
#		Copyright (C) 2010 Jonathan Roudiere <joe.roudiere@gmail.com>
#

# What include or source, How all that works ??
#       ==> see README.API in order to obtain more information

# =========================================================================

# --------------------------- Requirement --------------------------------
package require BWidget
package require Tk 
package require Itcl
namespace import itcl::*
# ----------------------- End : Requirement ------------------------------

# ----------- Popup Error -----------------
proc gui_exit_on_error { funct mesg } {
	global gui
	set popup_guard 0
	set OldFocus [focus]
	set popup_error [ toplevel .popup_error ]
	wm title .popup_error "Error in function : $funct"
	message $popup_error.msg -aspect 5000 -justify center \
		-text "An error occur in function : $funct\n\nError : $mesg"
	button $popup_error.exit -text "Close" -command { set popup_guard 1 }
	pack $popup_error.msg $popup_error.exit -pady 4
	gui_apps_traces "gui_exit_on_error : call from $funct"
	grab $popup_error
	focus $popup_error
	tkwait variable popup_guard
	grab release $popup_error
	destroy $popup_error
	focus $OldFocus
}
# -----------------------------------------

# ------------ Popup Help -----------------
proc gui_menucmd_help {} {
	global gui
	set popup_guard 0
	set OldFocus [focus]
	set popup_help [ toplevel .popup_help ]
	wm title .popup_help "PIE - Help"
	wm geometry .popup_help 600x870
	message $popup_help.msg -aspect 5000 -justify center \
		-text " - Help -\n"
	set t [text $popup_help.text -wrap word -relief flat -bg grey90]
	set ufile [open "$gui(helpfile)" r]
	while {[gets $ufile line] > -1} {
		$t insert end "$line\n"
	}
	$t configure -state disabled
	close $ufile
	button $popup_help.exit -text "Close" -command { set popup_guard 1 }
	pack $popup_help.msg
	pack $t -fill both -expand yes
	pack $popup_help.exit
	gui_apps_traces "gui_menucmd_help : open help"
	# comment grab : in order to allow to keep help open 
	#grab $popup_help
	focus $popup_help
	tkwait variable popup_guard
	#grab release $popup_help
	destroy $popup_help
	focus $OldFocus
}
# -----------------------------------------

# ----------- Popup About -----------------
proc gui_menucmd_about {} {
	global gui
	set popup_guard 0
	set OldFocus [focus]
	set popup_about [ toplevel .popup_about ]
	wm title .popup_about "PIE - About"
	#wm geometry .popup_about 200x260
	message $popup_about.msg -aspect 5000 -justify center \
		-text "PIE $gui(pie_version)\n\nPie Application\n-------------------\n\nAuthor/Copyright :\n------------------------\n\nChristophe Boudet\nJulien Castaigne\nJonathan Roudiere\nChristophe Roquette\nJérémy Subtil\n(L'or expresso, bien tassé !!)"
	button $popup_about.exit -text "Close" -command { set popup_guard 1 }
	pack $popup_about.msg $popup_about.exit -pady 4
	gui_apps_traces "gui_menucmd_about : open About"
	#grab $popup_about
	focus $popup_about
	tkwait variable popup_guard
	#grab release $popup_about
	destroy $popup_about
	focus $OldFocus
}
# -----------------------------------------

