# --- gui-tab-state.tcl ---

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

# ------------ State Active ---------------
proc gui_menucmd_active {} {
	global gui
	if {$gui(state_active) == 1} {
		if {$gui(state) == "scan"} {
			set gui(state_scan) 0
			gui_apps_traces "gui_menucmd_active : switch scan mode to active"
		}
		if {$gui(state) == "passive"} {
			set gui(state_passive) 0
			gui_apps_traces "gui_menucmd_active : switch passive mode to active"
		}
		set gui(state) "active"
	} else {
		;# if you already are in a mode you
		;# can't disabled it without choosing another
		if {$gui(state) == "active"} {
			gui_apps_traces "gui_menucmd_active : nothing to do : you must choose one mode"
			set gui(state_active) 1
		}
	}
}
# -----------------------------------------

# ------------ State Passive --------------
proc gui_menucmd_passive {} {
	global gui
	if {$gui(state_passive) == 1} {
		if {$gui(state) == "scan"} {
			set gui(state_scan) 0
			gui_apps_traces "gui_menucmd_passive : switch scan mode to passive"
		}
		if {$gui(state) == "active"} {
			set gui(state_active) 0
			gui_apps_traces "gui_menucmd_passive : switch active mode to passive"
		}
		set gui(state) "passive"
	} else {
		;# if you already are in a mode you
		;# can't disabled it without choosing another
		if {$gui(state) == "passive"} {
			gui_apps_traces "gui_menucmd_passive : nothing to do : you must choose one mode"
			set gui(state_passive) 1
		}
	}
}
# -----------------------------------------

# ------------- State Scan ----------------
proc gui_menucmd_scan {} {
	global gui
	if {$gui(state_scan) == 1} {
		if {$gui(state) == "active"} {
			set gui(state_active) 0
			gui_apps_traces "gui_menucmd_scan : switch active mode to scan"
		}
		if {$gui(state) == "passive"} {
			set gui(state_passive) 0
			gui_apps_traces "gui_menucmd_scan : switch passive mode to scan"
		}
		set gui(state) "scan"
	} else {
		;# if you already are in a mode you
		;# can't disabled it without choosing another
		if {$gui(state) == "scan"} {
			gui_apps_traces "gui_menucmd_scan : nothing to do : you must choose one mode"
			set gui(state_scan) 1
		}
	}
}
# -----------------------------------------
