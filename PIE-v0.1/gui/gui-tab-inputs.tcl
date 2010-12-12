# --- gui-tab-inputs.tcl ---

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

# Note about Notebook's tabs : insert/delete the same tab without destroy
# seems to be buggy feature, so we can't create tab's content using a tab
# as root path, so we just create tab's content by using root window path 
# and we add it when it's necessary (when tab are show/hide)

# --------- Tab Show Inputs ---------------

# Tab which allow to display all network input messages

# It a notebook's tab
set gui(tab_inputs)			[TitleFrame .tab_inputs -text "Incoming packets"]
set gui(tab_inputsf)		[$gui(tab_inputs) getframe]

# which contains two areas : information about this tab and text
# area to display input messages
set gui(tab_inputsf.fr)		[frame $gui(tab_inputsf).fr] 
set gui(tab_inputs.infos)	[label $gui(tab_inputsf.fr).infos -text \
	"---- In this tab are displayed all incoming network packets ---" ]

# Add text area to display traces
set gui(tab_inputs.scroll)	[ScrolledWindow $gui(tab_inputsf).sc -auto both -scrollbar vertical]
set gui(tab_inputs.text)	[text $gui(tab_inputs.scroll).txt -wrap word -bg white -undo yes]
$gui(tab_inputs.text)		insert 0.0 "All incoming packets ..."
$gui(tab_inputs.scroll)		setwidget $gui(tab_inputs.text)
$gui(tab_inputs.text)		configure -state disabled ;# lock text area

proc gui_menucmd_inputs {} {
	global gui
	if {$gui(traces_in) == 1} {
		gui_tab_pietraces "gui_menucmd_inputs : open input traces tab"
		set gui(tab_inputs.tab) [$gui(nb) insert end tab_inputs -text "Input traces"]
		# Pack content of this tab in this tab ;)
		# - tab "Pie traces"
		pack $gui(tab_inputs)		-in $gui(tab_inputs.tab) -fill both -expand yes
		# - frame with text and values
		pack $gui(tab_inputsf.fr)	-fill x
		pack $gui(tab_inputs.infos)	-expand yes
		# - traces area (text)
		pack $gui(tab_inputs.scroll)	-fill both -expand yes
		# - Title frame
		pack $gui(tab_inputsf) -fill both -expand yes
		# - Tab
		pack $gui(tab_inputs.tab) -fill both -expand yes
		$gui(nb) raise [$gui(nb) page end]
		$gui(nb) raise [$gui(nb) page 0]
	} else {
		gui_tab_pietraces "gui_menucmd_inputs : close input traces tab"
		$gui(nb) delete tab_inputs
		$gui(nb) raise [$gui(nb) page 0]
	}
}


# Proc to update text area of Input tab, this function has just in
# charge to unlock/dipslay and lock text area and mustn't be called
# from core system but from gui main management interface, 
# TODO : mesgtype may be determined here

proc gui_tab_inputs {mesg mesgtype} {
	global gui
	if {$mesg == ""} {
		gui_exit_on_error "gui_tab_inputs" "Bad call : empty args"
		gui_apps_traces "gui_tab_inputs : Bad call : empty args"
		return 0	;# false
	}
	# unlock text area
	$gui(tab_inputs.text) configure -state normal
	# write messages
	switch $mesgtype {
		"hello" {
				set wrt "HELLO"
				incr gui(nbhello_recv) 1
				}
		"mesg"  {
				set wrt "MESSAGE"
				}
		"info"  {
				set wrt "GETINFO"
				incr gui(nbhello_recv) 1
				}
		default {
				set wrt "UNKNOWN"
				}
	}
	gui_tab_pietraces "gui_tab_inputs : add a message to tab (type : $wrt)"
	$gui(tab_inputs.text) insert end "\n([ clock format [clock seconds] -format %H:%M:%S ])::TYPE($wrt) << $mesg"
	# lock
	$gui(tab_inputs.text) configure -state disabled
	# return true
	return 1
}
# -----------------------------------------
