# --- gui-tab-outputs.tcl ---

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

# --------- Tab Show Outputs --------------

# Tab which allow to display all network output messages

# It a notebook's tab
set gui(tab_outputs)		[TitleFrame .tab_outputs -text "Outgoing packets"]
set gui(tab_outputsf)		[$gui(tab_outputs) getframe]

# which contains two areas : information about this tab and text
# area to display output messages
set gui(tab_outputsf.fr)	[frame $gui(tab_outputsf).fr] 
set gui(tab_outputs.infos)	[label $gui(tab_outputsf.fr).infos -text \
	"---- In this tab are displayed all outgoing network packets ---" ]

# Add text area to display traces
set gui(tab_outputs.scroll)	[ScrolledWindow $gui(tab_outputsf).sc -auto both -scrollbar vertical]
set gui(tab_outputs.text)	[text $gui(tab_outputs.scroll).txt -wrap word -bg white -undo yes]
$gui(tab_outputs.text)		insert 0.0 "All outgoing packets ..."
$gui(tab_outputs.scroll)	setwidget $gui(tab_outputs.text)
$gui(tab_outputs.text)		configure -state disabled ;# lock text area

proc gui_menucmd_outputs {} {
	global gui
	if {$gui(traces_out) == 1} {
		gui_tab_pietraces "gui_menucmd_outputs : open output traces tab"
		set gui(tab_outputs.tab) [$gui(nb) insert end tab_outputs -text "Output traces"]
		# Pack content of this tab in this tab ;)
		# - tab "Pie traces"
		pack $gui(tab_outputs)		-in $gui(tab_outputs.tab) -fill both -expand yes
		# - frame with text and values
		pack $gui(tab_outputsf.fr)	-fill x
		pack $gui(tab_outputs.infos)	-expand yes
		# - traces area (text)
		pack $gui(tab_outputs.scroll)	-fill both -expand yes
		# - Title frame
		pack $gui(tab_outputsf) -fill both -expand yes
		# - Tab
		pack $gui(tab_outputs.tab) -fill both -expand yes
		$gui(nb) raise [$gui(nb) page end]
		$gui(nb) raise [$gui(nb) page 0]
	} else {
		gui_tab_pietraces "gui_menucmd_outputs : close output traces tab"
		$gui(nb) delete tab_outputs
		$gui(nb) raise [$gui(nb) page 0]
	}
}


# Proc to update text area of output tab, this function has just in
# charge to unlock/dipslay and lock text area and mustn't be called
# from core system but from gui main management interface, 
# TODO : mesgtype may be determined here

proc gui_tab_outputs {mesg mesgtype} {
	global gui
	if {$mesg == ""} {
		gui_exit_on_error "gui_tab_outputs" "Bad call : empty args"
		gui_apps_traces "gui_tab_outputs : Bad call : empty args"
		return 0	;# false
	}
	# unlock text area
	$gui(tab_outputs.text) configure -state normal
	# write messages
	switch $mesgtype {
		"hello" {
				set wrt "HELLO"
				incr gui(nbhello_send) 1
				}
		"mesg"  {
				set wrt "MESSAGE"
				}
		"info"  {
				set wrt "GETINFO"
				incr gui(nnget_send) 1 
				}
		default {
				set wrt "UNKNOWN"
				}
	}
	gui_tab_pietraces "gui_tab_outputs : add a message to tab (type : $wrt)"
	$gui(tab_outputs.text) insert end "\n([ clock format [clock seconds] -format %H:%M:%S ])::TYPE($wrt) >> $mesg"
	# lock
	$gui(tab_outputs.text) configure -state disabled
	# return true
	return 1
}

# -----------------------------------------
