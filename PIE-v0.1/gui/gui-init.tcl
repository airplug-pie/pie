# --- gui-init.tcl ---

# Author(s) :
#		Jonathan Roudiere <joe.roudiere@gmail.com>
#
# Copyright : 
#		Copyright (C) 2010 Jonathan Roudiere <joe.roudiere@gmail.com>
#

# What include or source, How all that works ??
#		==> see README.API in order to obtain more information

# =========================================================================

# --------------------------- Requirement --------------------------------
package require BWidget
package require Tk 
package require Itcl
namespace import itcl::*
# ----------------------- End : Requirement ------------------------------

# Main window definition
source gui/gui-main.tcl
# GUI function API 
source gui/gui-mainfuncts.tcl

# Tab your messages and its functions
source gui/gui-tab-yourmesg.tcl

# Tab your messages and its functions
source gui/gui-tab-nettraces.tcl

# Tab Pie traces (debug) and its functions
source gui/gui-tab-pietraces.tcl

# Tab network inputs and its functions
source gui/gui-tab-inputs.tcl

# Tab network outputs and its functions
source gui/gui-tab-outputs.tcl

# Tab forwarded streams and its functions
source gui/gui-tab-forwarded.tcl

# window subscribed streams and its function
source gui/gui-tab-subscribed.tcl

# Function used at startup to look for config
# to initialized global variables and create
# local user stream 
source gui/gui-configfunct.tcl

# Tab current profile and its function
source gui/gui-tab-userprofile.tcl

# Tab global and its function
source gui/gui-tab-globalconfig.tcl

# Popups window (error, About, Help, Quit) 
source gui/gui-tab-popups.tcl

# Function to switch between states (menu)
source gui/gui-tab-state.tcl

# Provide display functions
source core/low_proc.tcl

# Provide storage/stream API
source storage/storage_api.tcl


# ---------------- Gui initialisation ------------------

# Statistics variable
set gui(nbmesg_send)		0	;# Number of messages send (hello/txt/forwarded)
set gui(nbmesg_recv)		0	;# Number of messages received (hello/txt/forwarded)
set gui(nbhello_send)		0	;# Number of hello send
set gui(nbhello_recv)		0	;# Number of hello received
set gui(nbget_send)			0	;# Number of getinfos messages send
set gui(nbget_recv)			0	;# Number of getinfos messages received
set gui(nblocalmesg_snd)	0	;# Number of local (from user) messages

# Default help
set gui(helpfile)			"share/pie_help.txt"

# set default configdir path (~/.pie)
if { [info vars PIE_configdir] == "" } {
	set gui(configdir)			"$env(HOME)/.pie"
} else {
	set gui(configdir)			$PIE_configdir
}
if { [info vars PIE_globalfile] == "" } {
	set gui(globalconffile)		"$gui(configdir)/global.conf"
} else {
	set gui(globalconffile)		$PIE_globalfile
}

# we don't know user profile (nickname ...)
set gui(user_profile_known)	0
set gui(wait_user_change_profile) 0

# Default state of pie
set gui(state) "passive"
set gui(state_passive) 1

# Pack main window tab only
# Pack text editor area
pack $gui(editor_area)		-side left -fill both -expand yes
pack $gui(send_button)		-side right -fill y
pack $gui(main.texteditor)	-fill both -expand yes

# Pack subscribed streams area
pack $gui(main.subscribed)	-fill both -expand yes

# Pack available streams area
pack $gui(main.available)	-fill both -expand yes

# Pack main tab ""PIE's interface"
pack $gui(main.p.l)			-fill both -expand yes
pack $gui(main.p.r)			-fill both -expand yes
pack $gui(main.p)			-fill both -expand yes
pack $gui(main)				-fill both -expand yes

# Pack root widget, mainframe and update tab
pack $gui(nb)				-fill both -expand yes
pack $gui(root)				-fill both -expand yes
$gui(nb)					raise [$gui(nb) page 0]

# Default state
gui_menucmd_passive

# Change window title
wm title . $gui(apps_name)

# Set appropriate size, set exit conf
wm geometry . 600x700
wm protocol . WM_DELETE_WINDOW gui_menucmd_quit

# PIE start
# ---------

# Get config/profile
gui_apps_traces "GUI : PIE start, look for configuration"
gui_init_config_and_profile

# Apply config
gui_apps_traces "GUI : Configuration found or set, update gui"
gui_apply_globalconf

# Create user stream 
gui_apps_traces "GUI : Configuration found or set, create local user stream"
gui_create_user_stream

# PIE is running 

# ----------- Gui initialisation : End ------------------

