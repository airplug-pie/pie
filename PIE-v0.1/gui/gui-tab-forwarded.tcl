# --- gui-tabforwarded.tcl ---

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

# ---------Tab Show Forwarded -------------

# Tab which allow to display forwarded streams

# It a notebook's tab
set gui(tab_forwarded)			[TitleFrame .tab_forwarded -text "Forwarded streams information"]
set gui(tab_forwardedf)			[$gui(tab_forwarded) getframe]

# which contains two areas : information about this tab and
# frame to store information about forwarded streams
set gui(tab_forwardedf.fr)		[frame $gui(tab_forwardedf).fr] 
set gui(tab_forwarded.infos)	[label $gui(tab_forwardedf.fr).infos -text \
	"---- In this tab are displayed streams that you are forwarding ---" ]

# Store  information on stream in a notebook, each stream will have its tab
set gui(tab_forwarded.nb)		[NoteBook $gui(tab_forwardedf).nb]

# store stream registered in a list
set gui(forwarded_registered) 	[list]

proc gui_menucmd_forward {} {
	global gui
	if {$gui(traces_fw) == 1} {
		gui_tab_pietraces "gui_menucmd_forward : open forward stream tab"
		set gui(tab_forwarded.tab) [$gui(nb) insert end tab_forwarded -text "Forwarded streams"]
		# Pack content of this tab in this tab ;)
		# - tab "Forwarded streams"
		pack $gui(tab_forwarded)		-in $gui(tab_forwarded.tab) -fill both -expand yes
		# - streams area
		pack $gui(tab_forwardedf.fr)	-fill x
		pack $gui(tab_forwarded.infos)	-expand yes
		pack $gui(tab_forwarded.nb)		-fill both -expand yes
		# - Tab
		pack $gui(tab_forwarded.tab) 	-fill both -expand yes
		$gui(nb) raise					[$gui(nb) page end]
		$gui(nb) raise 					[$gui(nb) page 0]
	} else {
		gui_tab_pietraces "gui_menucmd_forward : close forward stream tab"
		$gui(nb) delete	tab_forwarded
		$gui(nb) raise [$gui(nb) page 0]
	}
}

# This function add stream and available information about it if
# it doesn't exist yet else function update informations available,
# in plus fonction completely defined stream widget and button fonctions
proc gui_tab_showforwarded_add { stream } {
	global gui
	if {$stream == ""} {
		gui_exit_on_error "gui_tab_showforwarded_add" "Bad call : empty args"
		gui_apps_traces "gui_tab_showforwarded_add : Bad call : empty args"
		return 0 	;# false
	}
	# if stream is not an object exit on error
	if { [ find objects -class stream  $stream ] < 0 } {
		gui_exit_on_error "gui_tab_showforwarded_add" "Bad call : $stream is not a stream object"
		gui_apps_traces "gui_tab_showforwarded_add : Bad call : $stream is not a stream object"
		return 0
	}
	# look if stream is already registered
	if { [ lsearch $gui(forwarded_registered) $stream ] < 0 } {
		gui_tab_pietraces "gui_tab_showforwarded_add : add a unregistered stream to forward tab"
		lappend gui(forwarded_registered) 	$stream
		set gui(tab_forwarded.$stream)		[$gui(tab_forwarded.nb) insert end $stream -text "$stream"]
		set gui(tab_forwarded.$stream._)	[TitleFrame $gui(tab_forwarded.$stream).t -text "Information about $stream"]
		set gui(tab_forwarded.$stream.f)	[$gui(tab_forwarded.$stream._) getframe]
		set gui(tab_forwarded.$stream.tv)	[frame $gui(tab_forwarded.$stream.f).tv]
		set gui(tab_forwarded.$stream.bt)	[frame $gui(tab_forwarded.$stream.f).bt]

		set gui(tab_forwarded.$stream.bt1)	[button $gui(tab_forwarded.$stream.bt).b1 -text "update" -command "gui_tab_showforwarded_update $stream" ]
		set gui(tab_forwarded.$stream.bt2)	[button $gui(tab_forwarded.$stream.bt).b2 -text "unforward" -command "gui_unforward $stream"]

		# Nickname
		set gui(tab_forwarded.$stream.ft1)	[frame $gui(tab_forwarded.$stream.tv).f1]
		set gui(tab_forwarded.$stream.t1)	[label $gui(tab_forwarded.$stream.ft1).t1	-text "User nickanme : "]
		set gui($stream.user.nickname)		[$stream.user.nickname]
		set gui(tab_forwarded.$stream.tv1)	[label $gui(tab_forwarded.$stream.ft1).tv1 -textvariable gui($stream.user.nickname)]

		# Car_id
		set gui(tab_forwarded.$stream.ft2)	[frame $gui(tab_forwarded.$stream.tv).f2]
		set gui(tab_forwarded.$stream.t2)	[label $gui(tab_forwarded.$stream.ft2).t2	-text "Car identifier : "]
		set gui($stream.car_id)				[$stream.car_id]
		set gui(tab_forwarded.$stream.tv2)	[label $gui(tab_forwarded.$stream.ft2).tv2 -textvariable gui($stream.car_id)]

		# Available since
		set gui(tab_forwarded.$stream.ft3)	[frame $gui(tab_forwarded.$stream.tv).f3]
		set gui(tab_forwarded.$stream.t3)	[label $gui(tab_forwarded.$stream.ft3).t3	-text "Stream available since : "]
		set gui($stream.time_available)		[$stream.time_available]
		set gui(tab_forwarded.$stream.tv3)	[label $gui(tab_forwarded.$stream.ft3).tv3 -textvariable gui($stream.time_available)]

		# Last mesg
		set gui(tab_forwarded.$stream.ft4)	[frame $gui(tab_forwarded.$stream.tv).f4]
		set gui(tab_forwarded.$stream.t4)	[label $gui(tab_forwarded.$stream.ft4).t4	-text "Last message at : "]
		set gui($stream.time_lastmsg)		[$stream.time_lastmsg]
		set gui(tab_forwarded.$stream.tv4)	[label $gui(tab_forwarded.$stream.ft4).tv4 -textvariable gui($stream.time_lastmsg)]

		# Last hello
		set gui(tab_forwarded.$stream.ft5)	[frame $gui(tab_forwarded.$stream.tv).f5]
		set gui(tab_forwarded.$stream.t5)	[label $gui(tab_forwarded.$stream.ft5).t5	-text "Last hello at : "]
		set gui($stream.time_lasthello)		[$stream.time_lasthello]
		set gui(tab_forwarded.$stream.tv5)	[label $gui(tab_forwarded.$stream.ft5).tv5 -textvariable gui($stream.time_lasthello)]

		# nb mesg
		set gui(tab_forwarded.$stream.ft6)	[frame $gui(tab_forwarded.$stream.tv).f6]
		set gui(tab_forwarded.$stream.t6)	[label $gui(tab_forwarded.$stream.ft6).t6	-text "nb of messages send : "]
		set gui($stream.nb_mesg)			[$stream.nb_mesg]
		set gui(tab_forwarded.$stream.tv6)	[label $gui(tab_forwarded.$stream.ft6).tv6 -textvariable gui($stream.nb_mesg)]

		# fullname
		set gui(tab_forwarded.$stream.ft7)	[frame $gui(tab_forwarded.$stream.tv).f7]
		set gui(tab_forwarded.$stream.t7)	[label $gui(tab_forwarded.$stream.ft7).t7	-text "User fullname : "]
		set gui($stream.fullname)			[$stream.user.fullname]
		set gui(tab_forwarded.$stream.tv7)	[label $gui(tab_forwarded.$stream.ft7).tv -textvariable gui($stream.fullname)]

		# firstname
		set gui(tab_forwarded.$stream.ft8)	[frame $gui(tab_forwarded.$stream.tv).f8]
		set gui(tab_forwarded.$stream.t8)	[label $gui(tab_forwarded.$stream.ft8).t8	-text "User firstname : "]
		set gui($stream.firstname)			[$stream.user.firstname]
		set gui(tab_forwarded.$stream.tv8)	[label $gui(tab_forwarded.$stream.ft8).tv8 -textvariable gui($stream.firstname)]

		# email
		set gui(tab_forwarded.$stream.ft9)	[frame $gui(tab_forwarded.$stream.tv).f9]
		set gui(tab_forwarded.$stream.t9)	[label $gui(tab_forwarded.$stream.ft9).t9	-text "Email address : "]
		set gui($stream.email)				[$stream.user.email]
		set gui(tab_forwarded.$stream.tv9)	[label $gui(tab_forwarded.$stream.ft9).tv9 -textvariable gui($stream.email)]

		# phone_nb
		set gui(tab_forwarded.$stream.ft10)	[frame $gui(tab_forwarded.$stream.tv).f10]
		set gui(tab_forwarded.$stream.t10)	[label $gui(tab_forwarded.$stream.ft10).t10	-text "Phone number : "]
		set gui($stream.phone_nb)				[$stream.user.phone_nb]
		set gui(tab_forwarded.$stream.tv10)	[label $gui(tab_forwarded.$stream.ft10).tv10 -textvariable gui($stream.phone_nb)]

		# age
		set gui(tab_forwarded.$stream.ft11)	[frame $gui(tab_forwarded.$stream.tv).f11]
		set gui(tab_forwarded.$stream.t11)	[label $gui(tab_forwarded.$stream.ft11).t11	-text "Age of user : "]
		set gui($stream.age)				[$stream.user.age]
		set gui(tab_forwarded.$stream.tv11)	[label $gui(tab_forwarded.$stream.ft11).tv11 -textvariable gui($stream.age)]

		# sex
		set gui(tab_forwarded.$stream.ft12)	[frame $gui(tab_forwarded.$stream.tv).f12]
		set gui(tab_forwarded.$stream.t12)	[label $gui(tab_forwarded.$stream.ft12).t12	-text "Sex of user : "]
		set gui($stream.sex)				[$stream.user.sex]
		set gui(tab_forwarded.$stream.tv12)	[label $gui(tab_forwarded.$stream.ft12).tv12 -textvariable gui($stream.sex)]

		# dest
		set gui(tab_forwarded.$stream.ft13)	[frame $gui(tab_forwarded.$stream.tv).f13]
		set gui(tab_forwarded.$stream.t13)	[label $gui(tab_forwarded.$stream.ft13).t13	-text "Destination of the user car : "]
		set gui($stream.dest)				[$stream.user.dest]
		set gui(tab_forwarded.$stream.tv13)	[label $gui(tab_forwarded.$stream.ft13).tv13 -textvariable gui($stream.dest)]

		# desc
		set gui(tab_forwarded.$stream.ft14)	[frame $gui(tab_forwarded.$stream.tv).f14]
		set gui(tab_forwarded.$stream.t14)	[label $gui(tab_forwarded.$stream.ft14).t14 -text "Description of pie user : "]
		set gui($stream.desc)				[$stream.user.desc]
		set gui(tab_forwarded.$stream.tv14)	[label $gui(tab_forwarded.$stream.ft14).tv14 -wraplength 300 -textvariable gui($stream.desc)]


		# Pack text/value
		for {set i 1} {$i  < 15} {incr i 1} {
			pack $gui(tab_forwarded.$stream.ft$i) -fill x
			if {$i != 14} {
				pack $gui(tab_forwarded.$stream.t$i)  -anchor w -side left
				pack $gui(tab_forwarded.$stream.tv$i) -anchor e
			} else {
				pack $gui(tab_forwarded.$stream.t$i)  -anchor w
				pack $gui(tab_forwarded.$stream.tv$i) -anchor w
			}
		}

		# Button, their frame and frame with text/value
		pack $gui(tab_forwarded.$stream.bt1)	-side left -fill x -expand yes
		pack $gui(tab_forwarded.$stream.bt2)	-side right -fill x -expand yes

		pack $gui(tab_forwarded.$stream.tv)	-fill both -expand yes
		pack $gui(tab_forwarded.$stream.bt)	-fill x

		# Main frame of this stream
		pack $gui(tab_forwarded.$stream._)	-fill both -expand yes
		pack $gui(tab_forwarded.$stream.f)	-fill both -expand yes
		pack $gui(tab_forwarded.$stream)	-fill both -expand yes

		# update gui
		$gui(tab_forwarded.nb)	raise $stream
		$gui(tab_forwarded.nb)	raise [$gui(tab_forwarded.nb) page 0]

		# append stream to registered stream
		lappend gui(forwarded_registered)	$stream
	} else {
		gui_tab_pietraces "gui_tab_showforwarded_add : stream $stream is already registered in forward"
	}
}

proc gui_tab_showforwarded_rem { stream } {
	global gui
	if {$stream == ""} {
		gui_exit_on_error "gui_tab_showforwarded_rem" "Bad call : empty args"
		gui_apps_traces "gui_tab_showforwarded_rem : Bad call : empty args"
		return 0 	;# false
	}
	if {[lsearch $gui(forwarded_registered) $stream] < 0} {
		gui_exit_on_error "gui_tab_showforwarded_rem" "Bad call : $stream is not shown"
		gui_apps_traces "gui_tab_showforwarded_rem : Bad call : $stream is not shown"
		return 0
	}
	gui_tab_pietraces "gui_tab_showforwarded_rem : remove $stream to forwarded tab"
	$gui(tab_forwarded.nb) delete $stream
	lremove gui(forwarded_registered) $stream
	if { [$gui(tab_forwarded.nb) page 0] != ""} {
		$gui(tab_forwarded.nb)  raise [$gui(tab_forwarded.nb) page 0]
	}
}

proc gui_tab_showforwarded_update { stream } {
	global gui
	if {$stream == ""} {
		gui_exit_on_error "gui_tab_showforwarded_rem" "Bad call : empty args"
		gui_apps_traces "gui_tab_showforwarded_rem : Bad call : empty args"
		return 0 	;# false
	}
	if {[lsearch $gui(forwarded_registered) $stream] < 0} {
		gui_exit_on_error "gui_tab_showforwarded_rem" "Bad call : $stream is not shown"
		gui_apps_traces "gui_tab_showforwarded_rem : Bad call : $stream is not shown"
		return 0
	}
	gui_tab_pietraces "gui_tab_showforwarded_update : update $stream to forwarded tab"
	gui_tab_showforwarded_rem $stream
	gui_tab_showforwarded_add $stream
	$gui(tab_forwarded.nb)  raise $stream
}

# -----------------------------------------
