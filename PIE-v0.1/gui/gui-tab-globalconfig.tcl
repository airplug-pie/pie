# --- gui-tab-globalconfig.tcl ---

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
# ------------------------ End : Requirement ------------------------------

# Note about Notebook's tabs : insert/delete the same tab without destroy
# seems to be buggy feature, so we can't create tab's content using a tab
# as root path, so we just create tab's content by using root window path 
# and we add it when it's necessary (when tab are show/hide)

# ------------------------ Global config tab ------------------------------

# Global config variables
#	default_user
#	pie_mode
#	show_current_conf_tab
#	show_global_conf_tab
#	show_nettraces_tab
#	show_pietraces_tab
#	show_outputs_tab
#	show_inputs_tab
#	show_forwarded_tab
#	show_subscribed_tab
#	show_localmesg_tab

# --------------- Global Tab ------------------

# Tab global conf
set gui(tab_global)			[TitleFrame .tab_global -text "Modify global setting"]
set gui(tab_globalf)		[$gui(tab_global) getframe]
set gui(tab_globalf.fr)		[frame $gui(tab_globalf).fr]
set gui(tab_global.infos)	[label $gui(tab_globalf.fr).infos -text \
	"\n--- Here you can modify global setting ---\n"]
set gui(tab_globalf.txt)	[frame $gui(tab_globalf.fr).txt]

set gui(tab_global.save)	[button $gui(tab_globalf.fr).bt -text "Save modif" -command {gui_save_profile "global"}]

# default_user 
set gui(tab_globalf.txt.1)	[frame $gui(tab_globalf.txt).1]
set gui(tab_globalf.txt.1t)	[label $gui(tab_globalf.txt.1).l -text "Default profile : "]
set gui(tab_globalf.txt.1v) [text $gui(tab_globalf.txt.1).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# pie_mode
set gui(tab_globalf.txt.2)	[frame $gui(tab_globalf.txt).2]
set gui(tab_globalf.txt.2t)	[label $gui(tab_globalf.txt.2).l -text "Default mode (active/passive/scan) : "]
set gui(tab_globalf.txt.2v) [text $gui(tab_globalf.txt.2).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# show_current_conf_tab
set gui(tab_globalf.txt.3)  [frame $gui(tab_globalf.txt).3]
set gui(tab_globalf.txt.3t) [label $gui(tab_globalf.txt.3).l -text "Open current conf by default : "]
set gui(tab_globalf.txt.3v) [text $gui(tab_globalf.txt.3).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# show_global_conf_tab
set gui(tab_globalf.txt.4)  [frame $gui(tab_globalf.txt).4]
set gui(tab_globalf.txt.4t) [label $gui(tab_globalf.txt.4).l -text "Open global setting by default : "]
set gui(tab_globalf.txt.4v) [text $gui(tab_globalf.txt.4).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# show_nettraces_tab 
set gui(tab_globalf.txt.5)  [frame $gui(tab_globalf.txt).5]
set gui(tab_globalf.txt.5t) [label $gui(tab_globalf.txt.5).l -text "Open net traces by default : "]
set gui(tab_globalf.txt.5v) [text $gui(tab_globalf.txt.5).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# show_pietraces_tab
set gui(tab_globalf.txt.6)  [frame $gui(tab_globalf.txt).6]
set gui(tab_globalf.txt.6t) [label $gui(tab_globalf.txt.6).l -text "Open pie traces by default : "]
set gui(tab_globalf.txt.6v) [text $gui(tab_globalf.txt.6).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# show_outputs_tab
set gui(tab_globalf.txt.7)  [frame $gui(tab_globalf.txt).7]
set gui(tab_globalf.txt.7t) [label $gui(tab_globalf.txt.7).l -text "Open outputs traces by default : "]
set gui(tab_globalf.txt.7v) [text $gui(tab_globalf.txt.7).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# show_inputs_tab
set gui(tab_globalf.txt.8)  [frame $gui(tab_globalf.txt).8]
set gui(tab_globalf.txt.8t) [label $gui(tab_globalf.txt.8).l -text "Open inputs traces by default : "]
set gui(tab_globalf.txt.8v) [text $gui(tab_globalf.txt.8).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# show_forwarded_tab
set gui(tab_globalf.txt.9)  [frame $gui(tab_globalf.txt).9]
set gui(tab_globalf.txt.9t) [label $gui(tab_globalf.txt.9).l -text "Open forwarded by default : "]
set gui(tab_globalf.txt.9v) [text $gui(tab_globalf.txt.9).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# show_subscribed_tab
set gui(tab_globalf.txt.10)  [frame $gui(tab_globalf.txt).10]
set gui(tab_globalf.txt.10t) [label $gui(tab_globalf.txt.10).l -text "Open subscribed by default : "]
set gui(tab_globalf.txt.10v) [text $gui(tab_globalf.txt.10).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# show_localmesg_tab
set gui(tab_globalf.txt.11)  [frame $gui(tab_globalf.txt).11]
set gui(tab_globalf.txt.11t) [label $gui(tab_globalf.txt.11).l -text "Open your messages by default : "]
set gui(tab_globalf.txt.11v) [text $gui(tab_globalf.txt.11).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# fill
set gui(tab_globalf.txt.zr)	 [label $gui(tab_globalf.txt).zero]

proc gui_menucmd_global {} {
	global gui
	if {$gui(global) == 1} {
		gui_apps_traces "gui_menucmd_global : open global config tab"
		set gui(tab_global.tab)	[$gui(nb) insert end tab_global -text "Global setting"]
		pack $gui(tab_global)		-in $gui(tab_global.tab) -fill both -expand yes
		pack $gui(tab_globalf.fr)	-fill x
		pack $gui(tab_global.infos) -expand yes

		# put button on the top
		pack $gui(tab_global.save)	-fill x

		# add separator
		pack $gui(tab_globalf.txt.zr)	-fill both -expand yes
		# show text/value
		# default_user pie_mode show_current_conf_tab show_global_conf_tab
		# show_nettraces_tab show_pietraces_tab show_outputs_tab show_inputs_tab
		# show_forwarded_tab show_subscribed_tab show_localmesg_tab
		for {set j 1} {$j < 12} {incr j 1} {
			$gui(tab_globalf.txt.${j}v) insert 0.0 "not"
			$gui(tab_globalf.txt.${j}v)	delete 0.0 end
		}
		$gui(tab_globalf.txt.1v)    insert 0.0 $gui(default_user)
		$gui(tab_globalf.txt.2v)    insert 0.0 $gui(pie_mode)
		$gui(tab_globalf.txt.3v)    insert 0.0 $gui(show_current_conf_tab)
		$gui(tab_globalf.txt.4v)    insert 0.0 $gui(show_global_conf_tab)
		$gui(tab_globalf.txt.5v)    insert 0.0 $gui(show_nettraces_tab)
		$gui(tab_globalf.txt.6v)    insert 0.0 $gui(show_pietraces_tab)
		$gui(tab_globalf.txt.7v)    insert 0.0 $gui(show_outputs_tab)
		$gui(tab_globalf.txt.8v)    insert 0.0 $gui(show_inputs_tab)
		$gui(tab_globalf.txt.9v)    insert 0.0 $gui(show_forwarded_tab)
		$gui(tab_globalf.txt.10v)    insert 0.0 $gui(show_subscribed_tab)
		$gui(tab_globalf.txt.11v)    insert 0.0 $gui(show_localmesg_tab)

		for {set j 1} {$j < 12} {incr j 1} {
			pack $gui(tab_globalf.txt.${j}t) -anchor w -side left
			pack $gui(tab_globalf.txt.${j}v) -anchor e
			pack $gui(tab_globalf.txt.$j) -fill x
		}

		pack $gui(tab_globalf.txt)	-fill both -expand yes
		pack $gui(tab_global.tab)
		$gui(nb) raise [$gui(nb) page end]
		$gui(nb) raise [$gui(nb) page 0]
	} else {
		gui_apps_traces "gui_menucmd_global : close global config tab"
		$gui(nb) delete tab_global
		for {set i 1} {$i < 12} {incr i 1} {
			pack forget $gui(tab_globalf.txt.$i)
		}
		$gui(nb) raise [$gui(nb) page 0]
	}
}
# ---------------------------------------------
# -------------------------------------------------------------------------
