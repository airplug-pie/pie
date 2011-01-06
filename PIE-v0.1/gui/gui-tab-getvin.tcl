# --- gui-tab-getvin.tcl ---

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
source $::PATH/pie-vin.tcl
# ----------------------- End : Requirement ------------------------------

# ----------- Popup getVin -----------------
proc gui_menucmd_getvin { } {
	global gui
	set popup_guard 0
	set OldFocus [focus]
	set popup_getvin [ toplevel .popup_getvin ]
	wm title .popup_getvin "Get my VIN !!"
	wm protocol .popup_getvin WM_DELETE_WINDOW { set gui(getvin) 0 ; set popup_guard 1 }
	message $popup_getvin.msg -aspect 5000 -justify center \
		-text "This popup allow to generate a VIN id and the\ncorresponding hash (to protect your privacy)\nCopy it in your profil.\n\nInfo : You are not in a car so we generate \na random VIN"
	frame $popup_getvin.vin
	label $popup_getvin.vinl -text "VIN id : "
	text $popup_getvin.vint -wrap word -width 25 -heigh 1 -bg white -undo yes
	frame $popup_getvin.hash
	label $popup_getvin.hashl -text "Hash : "
	text $popup_getvin.hasht -wrap word -width 25 -heigh 1 -bg white -undo yes
	button $popup_getvin.genvin -text "Get my VIN" -command { \
		.popup_getvin.vint insert end "..." ; \
		.popup_getvin.vint delete 0.0 end ; \
		.popup_getvin.hasht insert end "..." ; \
		.popup_getvin.hasht delete 0.0 end ; \
		set id [ PIE_gen_car_vin ] ; \
		.popup_getvin.vint insert end $id ; \
		.popup_getvin.hasht insert end [ PIE_gen_car_id $id ] }
	button $popup_getvin.exit -text "Close" -command { set gui(getvin) 0 ; set popup_guard 1 }
	pack $popup_getvin.msg
	pack $popup_getvin.vin -fill x
	pack $popup_getvin.vinl 
	pack $popup_getvin.vint -fill x
	pack $popup_getvin.hash -fill x
	pack $popup_getvin.hashl
	pack $popup_getvin.hasht -fill x
	pack $popup_getvin.genvin -padx 6
	pack $popup_getvin.exit -padx 6
	gui_apps_traces "gui_menucmd_getvin : VIN generation"
	#grab $popup_getvin
	focus $popup_getvin
	tkwait variable popup_guard
	#grab release $popup_getvin
	destroy $popup_getvin
	focus $OldFocus
}
# -----------------------------------------


