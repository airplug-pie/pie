# --- gui-tab-pietraces.tcl ---

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

# ---------- Tab PIE Traces ---------------

# Pie traces allow to show all log of the application it is eq.
# to a debug display (that an overload of the pdebug function
# (as consequency this function MUST NOT CALL pdebug -> loop)

# It a notebook's tab
set gui(tab_pietraces)			[TitleFrame .tab_pietraces -text "Pie debug"]
set gui(tab_pietracesf)			[$gui(tab_pietraces) getframe]

# which contains two areas : information about this tab and text
# area to display debug application messages
set gui(tab_pietracesf.fr)		[frame $gui(tab_pietracesf).fr] 
set gui(tab_pietraces.infos)	[label $gui(tab_pietracesf.fr).infos -text \
	"---- In this tab are displayed all Pie traces (debug panel) ---" ]

# Add text area to display traces
set gui(tab_pietraces.scroll)	[ScrolledWindow $gui(tab_pietracesf).sc -auto both -scrollbar vertical]
set gui(tab_pietraces.text)		[text $gui(tab_pietraces.scroll).txt -wrap word -bg white -undo yes]
$gui(tab_pietraces.text)		insert 0.0 "Pie traces -- All debug application messages ..."
$gui(tab_pietraces.scroll)		setwidget $gui(tab_pietraces.text)
$gui(tab_pietraces.text)		configure -state disabled ;# lock text area

proc gui_menucmd_pietraces {} {
	global gui
	if {$gui(traces_pie) == 1} {
		gui_tab_pietraces "gui_menucmd_pietraces : open pie traces tab"
		set gui(tab_pietraces.tab) [$gui(nb) insert end tab_pietraces -text "Pie traces"]
		# Pack content of this tab in this tab ;)
		# - tab "Pie traces"
		pack $gui(tab_pietraces)		-in $gui(tab_pietraces.tab) -fill both -expand yes
		# - frame with text and values
		pack $gui(tab_pietracesf.fr)	-fill x
		pack $gui(tab_pietraces.infos)	-expand yes
		# - traces area (text)
		pack $gui(tab_pietraces.scroll)	-fill both -expand yes
		# - Title frame
		pack $gui(tab_pietracesf) -fill both -expand yes
		# - Tab
		pack $gui(tab_pietraces.tab) -fill both -expand yes
		$gui(nb) raise [$gui(nb) page end]
		$gui(nb) raise [$gui(nb) page 0]
	} else {
		gui_tab_pietraces "gui_menucmd_pietraces : close pie traces tab"
		$gui(nb) delete tab_pietraces
		$gui(nb) raise [$gui(nb) page 0]
	}
}


# Proc to update text area of Pie traces tab (debug tab), this function
# has just in  charge to unlock/dipslay and lock text area and mustn't
# be called from core system but from gui main management interface

proc gui_tab_pietraces { mesg } {
	global gui
	if {$mesg == ""} {
		gui_exit_on_error "gui_tab_pietraces" "Bad call : empty args"
		#gui_apps_traces "gui_tab_pietraces : Bad call : empty args" => LOOP
		return 0	;# false
	}
	# unlock text area
	$gui(tab_pietraces.text) configure -state normal
	# write messages 
	$gui(tab_pietraces.text) insert end "\n[ clock format [clock seconds] -format %H:%M:%S ] :: $mesg"
	# lock
	$gui(tab_pietraces.text) configure -state disabled
	# return true
	return 1
}
# -----------------------------------------

