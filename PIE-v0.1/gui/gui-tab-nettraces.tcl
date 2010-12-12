# --- gui-tab-nettraces.tcl ---

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

# ---------- Tab Net Traces ---------------

# Net traces allow to see all packets send or received 
# from the network (hello, mesg send/forwarded/received)  

# It a notebook's tab
set gui(tab_nettraces)			[TitleFrame .tab_nettraces -text "Pie Network traces"]
set gui(tab_nettracesf)			[$gui(tab_nettraces) getframe]

# which contains three areas : information about this tab, statistic
# (nb mesg send/received/forwarded, nb hello) and all mesg traces (text) 
# (everything is encapculated in several frames because 'pack' sucks !!)
set gui(tab_nettracesf.fr)	[frame $gui(tab_nettracesf).fr] 
set gui(tab_nettraces.infos)	[label $gui(tab_nettracesf.fr).infos -text \
	"---- In this tab are displayed all Pie network traces ---" ]
set gui(tab_nettracesf.fr1)	[frame $gui(tab_nettracesf.fr).fr1]
set gui(tab_nettraces.stat1l)	[label $gui(tab_nettracesf.fr1).stat1l -text "Number of messages send : "]
set gui(tab_nettraces.stat1)	[label $gui(tab_nettracesf.fr1).stat1 -textvariable gui(nbmesg_send) ]
set gui(tab_nettracesf.fr2)	[frame $gui(tab_nettracesf.fr).fr2]
set gui(tab_nettraces.stat2l)	[label $gui(tab_nettracesf.fr2).stat2l -text "Number of messages received : "]
set gui(tab_nettraces.stat2)	[label $gui(tab_nettracesf.fr2).stat2 -textvariable gui(nbmesg_recv) ]
set gui(tab_nettracesf.fr3)	[frame $gui(tab_nettracesf.fr).fr3]
set gui(tab_nettraces.stat3l)	[label $gui(tab_nettracesf.fr3).stat3l -text "Number of hello send : "]
set gui(tab_nettraces.stat3)	[label $gui(tab_nettracesf.fr3).stat3 -textvariable gui(nbhello_send) ]
set gui(tab_nettracesf.fr4)	[frame $gui(tab_nettracesf.fr).fr4]
set gui(tab_nettraces.stat4l)	[label $gui(tab_nettracesf.fr4).stat4l -text "Number of hello received : "]
set gui(tab_nettraces.stat4)	[label $gui(tab_nettracesf.fr4).stat4 -textvariable gui(nbhello_recv) ]
set gui(tab_nettracesf.fr5)	[frame $gui(tab_nettracesf.fr).fr5]
set gui(tab_nettraces.stat5l)	[label $gui(tab_nettracesf.fr5).stat5l -text "Number of getinfo messages send : "]
set gui(tab_nettraces.stat5)	[label $gui(tab_nettracesf.fr5).stat5 -textvariable gui(nbget_send) ]
set gui(tab_nettracesf.fr6)	[frame $gui(tab_nettracesf.fr).fr6]
set gui(tab_nettraces.stat6l)	[label $gui(tab_nettracesf.fr6).stat6l -text "Number of getinfo messages received : "]
set gui(tab_nettraces.stat6)	[label $gui(tab_nettracesf.fr6).stat6 -textvariable gui(nbget_recv) ]
set gui(tab_nettracesf.fr7)	[frame $gui(tab_nettracesf.fr).fr7]
set gui(tab_nettraces.stat7l)	[label $gui(tab_nettracesf.fr7).stat7l -text "Number of local (from user) messages : "]
set gui(tab_nettraces.stat7)	[label $gui(tab_nettracesf.fr7).stat7 -textvariable gui(nblocalmesg_snd) ]

# Add text area to display traces
set gui(tab_nettraces.scroll)	[ScrolledWindow $gui(tab_nettracesf).sc -auto both -scrollbar vertical]
set gui(tab_nettraces.text)		[text $gui(tab_nettraces.scroll).txt -wrap word -bg white -undo yes]
$gui(tab_nettraces.text)		insert 0.0 "Network traces -- All messages/hello send or received ..."
$gui(tab_nettraces.scroll)		setwidget $gui(tab_nettraces.text)
$gui(tab_nettraces.text)		configure -state disabled ;# lock text area

proc gui_menucmd_nettraces {} {
	global gui
	if {$gui(traces_net) == 1} {
		gui_tab_pietraces "gui_menucmd_nettraces : open network traces"
		set gui(tab_nettraces.tab) [$gui(nb) insert end tab_nettraces -text "Network traces"]
		# Pack content of this tab in this tab ;)
		# - tab "Pie Network traces"
		pack $gui(tab_nettraces)		-in $gui(tab_nettraces.tab) -fill both -expand yes
		# - frame with text and values
		pack $gui(tab_nettracesf.fr)	-fill x
		pack $gui(tab_nettraces.infos)	-expand yes
		# - all texts and values
		for {set i 1} {$i <= 7} {incr i 1} {
			pack $gui(tab_nettracesf.fr${i}) -fill x
			pack $gui(tab_nettraces.stat${i}l) -anchor w -side left
			pack $gui(tab_nettraces.stat${i}) -anchor w
		}
		# - traces area (text)
		pack $gui(tab_nettraces.scroll)	-fill both -expand yes
		# - Title frame
		pack $gui(tab_nettracesf) -fill both -expand yes
		# - Tab
		pack $gui(tab_nettraces.tab) -fill both -expand yes
		$gui(nb) raise [$gui(nb) page end]
		$gui(nb) raise [$gui(nb) page 0]
	} else {
		gui_tab_pietraces "gui_menucmd_nettraces : close network traces"
		$gui(nb) delete tab_nettraces
		$gui(nb) raise [$gui(nb) page 0]
	}
}


# Proc to update text area of Network tab, this function has just in 
# charge to unlock/dipslay and lock text area and mustn't be
# called from core system but from gui main management interface

proc gui_tab_nettraces { mesg from } {
	global gui
	if {$from == "" || $mesg == ""} {
		gui_exit_on_error "gui_tab_nettraces" "Bad call : empty args"
		gui_apps_traces "gui_tab_nettraces : Bad call : empty args"
		return 0 ;# false
	}
	# unlock text area
	$gui(tab_nettraces.text) configure -state normal
	# write messages (input < mesg||output > mesg)
	if {$from == "input"} {
		gui_tab_pietraces "gui_tab_nettraces : add a incoming message (input)"
		set wrt "\nINPUT([ clock format [clock seconds] -format %H:%M:%S ])  <<< $mesg"
	} else {
		gui_tab_pietraces "gui_tab_nettraces : add a outgoing message (output)"
		set wrt "\nOUTPUT([ clock format [clock seconds] -format %H:%M:%S ]) >>> $mesg"
	}
	$gui(tab_nettraces.text) insert end $wrt
	# lock
	$gui(tab_nettraces.text) configure -state disabled
	# return true
	return 1
}
# -----------------------------------------
