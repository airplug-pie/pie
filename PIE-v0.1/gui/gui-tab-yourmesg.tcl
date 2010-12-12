# --- gui-tab-yourmesg.tcl ---

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
# --------------------- End : Requirement --------------------------------

# Note about Notebook's tabs : insert/delete the same tab without destroy
# seems to be buggy feature, so we can't create tab's content using a tab
# as root path, so we just create tab's content by using root window path 
# and we add it when it's necessary (when tab are show/hide)

# --------- Tab Your Messages -------------

# In this tab are displayed all mesg localy send,
# (eq. message send by local user of PIE apps ;)

# It a notebook's tab
set gui(tab_localsend)			[TitleFrame .tab_localsend -text "Previous messages sent"]
set gui(tab_localsendf)			[$gui(tab_localsend) getframe]

# which contains two areas : information about this tab and text
# area to display debug application messages
set gui(tab_localsendf.fr)		[frame $gui(tab_localsendf).fr] 
set gui(tab_localsend.infos)	[label $gui(tab_localsendf.fr).infos -text \
	"---- In this tab are displayed all previous messages that you have sent ---" ]

# Add text area to display traces
set gui(tab_localsend.scroll)	[ScrolledWindow $gui(tab_localsendf).sc -auto both -scrollbar vertical]
set gui(tab_localsend.text)		[text $gui(tab_localsend.scroll).txt -wrap word -bg white -undo yes]
$gui(tab_localsend.text)		insert 0.0 "Previous mesg sent ..."
$gui(tab_localsend.scroll)		setwidget $gui(tab_localsend.text)
$gui(tab_localsend.text)		configure -state disabled ;# lock text area

proc gui_menucmd_localsend {} {
	global gui
	if {$gui(traces_localsend) == 1} {
		gui_tab_pietraces "gui_menucmd_localsend : open tab \"your message\""
		set gui(tab_localsend.tab) [$gui(nb) insert end tab_localsend -text "Your messages"]
		# Pack content of this tab in this tab ;)
		# - tab "Pie traces"
		pack $gui(tab_localsend)		-in $gui(tab_localsend.tab) -fill both -expand yes
		# - frame with text and values
		pack $gui(tab_localsendf.fr)	-fill x
		pack $gui(tab_localsend.infos)	-expand yes
		# - traces area (text)
		pack $gui(tab_localsend.scroll)	-fill both -expand yes
		# - Title frame
		pack $gui(tab_localsendf) -fill both -expand yes
		# - Tab
		pack $gui(tab_localsend.tab) -fill both -expand yes
		$gui(nb) raise [$gui(nb) page end]
		$gui(nb) raise [$gui(nb) page 0]
	} else {
		gui_tab_pietraces "gui_menucmd_localsend : close tab \"your message\""
		$gui(nb) delete tab_localsend
		$gui(nb) raise [$gui(nb) page 0]
	}
}


# Proc to update text area of "your messages" tab (localsend), this
# function has just in charge to unlock/dipslay and lock text area
# and mustn't be called from core system but from gui main management
# interface

proc gui_tab_localsend { mesg } {
	global gui
	gui_tab_pietraces "gui_tab_localsend : add a message to \"your message\" tab"
	if {$mesg == ""} {
		;# Allow empty message
		;# gui_exit_on_error "gui_tab_localsend" "Bad call : empty args"
		;# return 0	;# false
		set mesg " -- Empty message sent ... -- "
	}
	# unlock text area
	$gui(tab_localsend.text) configure -state normal
	# write messages 
	$gui(tab_localsend.text) insert end "\n[ clock format [clock seconds] -format %H:%M:%S ] :: $mesg"
	# lock
	$gui(tab_localsend.text) configure -state disabled
	# return true
	return 1
}
# -----------------------------------------
