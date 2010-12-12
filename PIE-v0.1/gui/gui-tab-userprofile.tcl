# --- gui-tab-userprofile.tcl ---

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
# ------------------------- End : Requirement -----------------------------

# Note about Notebook's tabs : insert/delete the same tab without destroy
# seems to be buggy feature, so we can't create tab's content using a tab
# as root path, so we just create tab's content by using root window path 
# and we add it when it's necessary (when tab are show/hide)

# ------------------------- User profile tab ------------------------------

# User config variables
#	nickname
#	car_id
#	fullname
#	firstname
#	age
#	sex
#	email
#	phone_nb
#	dest
#	desc

# -------------- Current Tab --------------

# Tab current conf
set gui(tab_current)		[TitleFrame .tab_current -text "Modify current configuration"]
set gui(tab_currentf)		[$gui(tab_current) getframe]
set gui(tab_currentf.fr)	[frame $gui(tab_currentf).fr]
set gui(tab_current.infos)	[label $gui(tab_currentf.fr).infos -text \
	"\n--- Here you can modify current profile information ---"]
set gui(tab_current.infos2)	[label $gui(tab_currentf.fr).infos2 -text \
	"(at least nickname and car_id must be different to <undefined>\n\n"]
set gui(tab_currentf.txt)	[frame $gui(tab_currentf.fr).txt]

set gui(tab_current.save)	[button $gui(tab_currentf.fr).bt -text "Save modif" -command {gui_save_profile "current"}]

# nickname
set gui(tab_currentf.txt.1)	[frame $gui(tab_currentf.txt).1]
set gui(tab_currentf.txt.1t)	[label $gui(tab_currentf.txt.1).l -text "Nickname : "]
set gui(tab_currentf.txt.1v) [text $gui(tab_currentf.txt.1).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# car_id
set gui(tab_currentf.txt.2)	[frame $gui(tab_currentf.txt).2]
set gui(tab_currentf.txt.2t)	[label $gui(tab_currentf.txt.2).l -text "Car id : "]
set gui(tab_currentf.txt.2v) [text $gui(tab_currentf.txt.2).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# fullname
set gui(tab_currentf.txt.3)  [frame $gui(tab_currentf.txt).3]
set gui(tab_currentf.txt.3t) [label $gui(tab_currentf.txt.3).l -text "Fullname : "]
set gui(tab_currentf.txt.3v) [text $gui(tab_currentf.txt.3).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# firstname
set gui(tab_currentf.txt.4)  [frame $gui(tab_currentf.txt).4]
set gui(tab_currentf.txt.4t) [label $gui(tab_currentf.txt.4).l -text "Firstname : "]
set gui(tab_currentf.txt.4v) [text $gui(tab_currentf.txt.4).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# age
set gui(tab_currentf.txt.5)  [frame $gui(tab_currentf.txt).5]
set gui(tab_currentf.txt.5t) [label $gui(tab_currentf.txt.5).l -text "Age : "]
set gui(tab_currentf.txt.5v) [text $gui(tab_currentf.txt.5).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# sex
set gui(tab_currentf.txt.6)  [frame $gui(tab_currentf.txt).6]
set gui(tab_currentf.txt.6t) [label $gui(tab_currentf.txt.6).l -text "Sex : "]
set gui(tab_currentf.txt.6v) [text $gui(tab_currentf.txt.6).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# email
set gui(tab_currentf.txt.7)  [frame $gui(tab_currentf.txt).7]
set gui(tab_currentf.txt.7t) [label $gui(tab_currentf.txt.7).l -text "Email address : "]
set gui(tab_currentf.txt.7v) [text $gui(tab_currentf.txt.7).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# phone_nb
set gui(tab_currentf.txt.8)  [frame $gui(tab_currentf.txt).8]
set gui(tab_currentf.txt.8t) [label $gui(tab_currentf.txt.8).l -text "Phone number : "]
set gui(tab_currentf.txt.8v) [text $gui(tab_currentf.txt.8).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# dest
set gui(tab_currentf.txt.9)  [frame $gui(tab_currentf.txt).9]
set gui(tab_currentf.txt.9t) [label $gui(tab_currentf.txt.9).l -text "Your destination : "]
set gui(tab_currentf.txt.9v) [text $gui(tab_currentf.txt.9).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# 
set gui(tab_currentf.txt.10)  [frame $gui(tab_currentf.txt).10]
set gui(tab_currentf.txt.10t) [label $gui(tab_currentf.txt.10).l -text "Short description : "]
set gui(tab_currentf.txt.10v) [text $gui(tab_currentf.txt.10).v -wrap word -width 25 -heigh 1 -bg white -undo yes]
# 
#set gui(tab_currentf.txt.11)  [frame $gui(tab_currentf.txt).11]
#set gui(tab_currentf.txt.11t) [label $gui(tab_currentf.txt.11).l -text "Save current profile definition in (path/nickname.conf) : "]
#set gui(tab_currentf.txt.11v) [text $gui(tab_currentf.txt.11).v -wrap word -width 50 -heigh 1 -bg white -undo yes]
# fill
set gui(tab_currentf.txt.zr)	 [label $gui(tab_currentf.txt).zero]

proc gui_menucmd_current {} {
	global gui
	if {$gui(current) == 1} {
		gui_apps_traces "gui_menucmd_current : open current config tab"
		set gui(tab_current.tab)	[$gui(nb) insert end tab_current -text "Current profile"]
		pack $gui(tab_current)		-in $gui(tab_current.tab) -fill both -expand yes
		pack $gui(tab_currentf.fr)	-fill x
		pack $gui(tab_current.infos) -expand yes
		pack $gui(tab_current.infos2) -expand yes

		# put button on the top
		pack $gui(tab_current.save)	-fill x

		# add separator
		pack $gui(tab_currentf.txt.zr)	-fill both -expand yes
		# show text/value
		# default_user pie_mode show_current_conf_tab show_current_conf_tab
		# show_nettraces_tab show_pietraces_tab show_outputs_tab show_inputs_tab
		# show_forwarded_tab show_subscribed_tab show_localmesg_tab
		for {set j 1} {$j < 11} {incr j 1} {
			$gui(tab_currentf.txt.${j}v) insert 0.0 "not"
			$gui(tab_currentf.txt.${j}v)	delete 0.0 end
		}
		$gui(tab_currentf.txt.1v)    insert 0.0 $gui(nickname)
		$gui(tab_currentf.txt.2v)    insert 0.0 $gui(car_id)
		$gui(tab_currentf.txt.3v)    insert 0.0 $gui(fullname)
		$gui(tab_currentf.txt.4v)    insert 0.0 $gui(firstname)
		$gui(tab_currentf.txt.5v)    insert 0.0 $gui(age)
		$gui(tab_currentf.txt.6v)    insert 0.0 $gui(sex)
		$gui(tab_currentf.txt.7v)    insert 0.0 $gui(email)
		$gui(tab_currentf.txt.8v)    insert 0.0 $gui(phone_nb)
		$gui(tab_currentf.txt.9v)    insert 0.0 $gui(dest)
		$gui(tab_currentf.txt.10v)    insert 0.0 $gui(desc)
		#$gui(tab_currentf.txt.11v)    insert 0.0 $gui(username_conffile)

		for {set j 1} {$j < 11} {incr j 1} {
			pack $gui(tab_currentf.txt.${j}t) -anchor w -side left
			pack $gui(tab_currentf.txt.${j}v) -anchor e
			pack $gui(tab_currentf.txt.$j) -fill x
		}

		pack $gui(tab_currentf.txt)	-fill both -expand yes
		pack $gui(tab_current.tab)
		$gui(nb) raise [$gui(nb) page end]
		if {[info vars $gui(username)] != "" } {
			$gui(nb) raise [$gui(nb) page 0]
		}
	} else {
		gui_apps_traces "gui_menucmd_current : close current config tab"
		$gui(nb) delete tab_current
		for {set i 1} {$i < 11} {incr i 1} {
			pack forget $gui(tab_currentf.txt.$i)
		}
		$gui(nb) raise [$gui(nb) page 0]
	}
}

# -----------------------------------------
