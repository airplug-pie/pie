# --- gui-tab-subscribed.tcl ---

# Author(s) :
#		Jonathan Roudiere <joe.roudiere@gmail.com>
#
# Copyright : 
#		Copyright (C) 2010 Jonathan Roudiere <joe.roudiere@gmail.com>
#

# What include or source, How all that works ??
#       ==> see README.API in order to obtain more information

# =========================================================================

# ----------- Tab Subscribed --------------

# Subscribed streams are shown in a new window
set gui(win_subscribed) [toplevel .subscribed]

# set a title & size & hide windows by default
wm geometry $gui(win_subscribed) 500x600
wm title	$gui(win_subscribed) "-- Subscribed streams --"
wm withdraw $gui(win_subscribed)

# Store stream registered in a list
set gui(subscribed_registered) [list]

# All is in a frame and we use a notebook and each
# new subscribed streams will be in a tab
set gui(win_subscribed.f)		[frame $gui(win_subscribed).f]
set gui(win_subscribed.nb)		[NoteBook $gui(win_subscribed.f).nb] 
set gui(win_subscribed.info)	[label $gui(win_subscribed.f).info -text \
	"\n---- In this window are shown subscirbed stream, info and messages ----\n"]

# Pack all
pack $gui(win_subscribed.info) 	-fill x 
pack $gui(win_subscribed.nb)	-fill both -expand yes
pack $gui(win_subscribed.f)		-fill both -expand yes

# we do not want the window is destructible, so when
# window is close we don't destroy, just hide it 
wm protocol $gui(win_subscribed) WM_DELETE_WINDOW gui_hide_subscribed_win

# with this function
proc gui_hide_subscribed_win {} {
	global gui
	gui_tab_pietraces "gui_hide_subscribed_win : hide subscirbed panel (use (x) button)"
	set gui(subscribed)	0
	wm withdraw $gui(win_subscribed)
}

# show and hide from menu
proc gui_menucmd_subscribed {} {
	global gui
	if {$gui(subscribed) == 1} {
		gui_tab_pietraces "gui_menucmd_subscribed : show subscirbed panel (from menu)"
		wm deiconify $gui(win_subscribed)
	} else {
		gui_tab_pietraces "gui_menucmd_subscribed : hide subscirbed panel (from menu)"
		wm withdraw $gui(win_subscribed)
	}
}

proc gui_subscribed_add { stream } {
	global gui
	if {$stream == ""} {
		gui_exit_on_error "gui_subscribed_add" "Bad call : empty args"
		gui_apps_traces "gui_subscribed_add : Bad call : empty args"
		return 0 	;# false
	}
	# if stream is not an object exit on error
	if { [ find objects -class stream  $stream ] == "" } {
		gui_exit_on_error "gui_subscribed_add" "Bad call : $stream is not a stream object"
		gui_apps_traces "gui_subscribed_add : Bad call : $stream is not a stream object"
		return 0
	}
	# look if stream is already registered
	if { [ lsearch $gui(subscribed_registered) $stream ] < 0 } {
		gui_tab_pietraces "gui_subscribed_add : add a unregistered stream ($stream) to subscribed panel"
		lappend gui(subscribed_registered) $stream
		set gui(win_subscribed.$stream)		[$gui(win_subscribed.nb) insert end $stream -text "$stream"]
		set gui(win_subscribed.$stream._)	[TitleFrame $gui(win_subscribed.$stream).t -text "Messages of $stream"]
		set gui(win_subscribed.$stream.f)	[$gui(win_subscribed.$stream._) getframe]

		# Display stream info
		set gui(win_subscribed.$stream.tv)	[frame $gui(win_subscribed.$stream.f).tv]

		# Two button to getinfos and unsubscirbed
		set gui(win_subscribed.$stream.bt)	[frame $gui(win_subscribed.$stream.f).bt]

		# A frame to display text messages
		set gui(win_subscribed.$stream.txt)	[frame $gui(win_subscribed.$stream.f).txt]

		# text messages area
		set gui(win_subscribed.$stream.mg)	[TitleFrame $gui(win_subscribed.$stream.txt).mesg -text "Messages sent by $stream"]
		set gui(win_subscribed.$stream.mgf)	[$gui(win_subscribed.$stream.mg) getframe]
		set gui(win_subscribed.$stream.mge)	[ScrolledWindow $gui(win_subscribed.$stream.mgf).edit -auto both -scrollbar vertical]
		set gui(win_subscribed.$stream.mgt) [text $gui(win_subscribed.$stream.mge).zt -wrap word -width 2 -heigh 5 -bg white -undo yes]
		$gui(win_subscribed.$stream.mge)	setwidget $gui(win_subscribed.$stream.mgt)
		$gui(win_subscribed.$stream.mgt) 	insert 0.0 "Messages of $stream ...."
		$gui(win_subscribed.$stream.mgt)	configure -state disabled

		# Button definition
		set gui(win_subscribed.$stream.bt1)	[button $gui(win_subscribed.$stream.bt).b1 -text "getinfos" -command "gui_stream_getinfos_snd $stream" ]
		set gui(win_subscribed.$stream.bt2)	[button $gui(win_subscribed.$stream.bt).b2 -text "unsubscirbed" -command "gui_StreamDrop .window.frame.$stream $gui(main.availablef)"]

		# Nickname
		set gui(win_subscribed.$stream.ft1)	[frame $gui(win_subscribed.$stream.tv).f1]
		set gui(win_subscribed.$stream.t1)	[label $gui(win_subscribed.$stream.ft1).t1	-text "User nickanme : "]
		set gui($stream.user.nickname)		[$stream.user.nickname]
		set gui(win_subscribed.$stream.tv1)	[label $gui(win_subscribed.$stream.ft1).tv1 -textvariable gui($stream.user.nickname)]

		# Car_id
		set gui(win_subscribed.$stream.ft2)	[frame $gui(win_subscribed.$stream.tv).f2]
		set gui(win_subscribed.$stream.t2)	[label $gui(win_subscribed.$stream.ft2).t2	-text "Car identifier : "]
		set gui($stream.car_id)				[$stream.car_id]
		set gui(win_subscribed.$stream.tv2)	[label $gui(win_subscribed.$stream.ft2).tv2 -textvariable gui($stream.car_id)]

		# Available since
		set gui(win_subscribed.$stream.ft3)	[frame $gui(win_subscribed.$stream.tv).f3]
		set gui(win_subscribed.$stream.t3)	[label $gui(win_subscribed.$stream.ft3).t3	-text "Stream available since : "]
		set gui($stream.time_available)		[$stream.time_available]
		set gui(win_subscribed.$stream.tv3)	[label $gui(win_subscribed.$stream.ft3).tv3 -textvariable gui($stream.time_available)]

		# Last mesg
		set gui(win_subscribed.$stream.ft4)	[frame $gui(win_subscribed.$stream.tv).f4]
		set gui(win_subscribed.$stream.t4)	[label $gui(win_subscribed.$stream.ft4).t4	-text "Last message at : "]
		set gui($stream.time_lastmsg)		[$stream.time_lastmsg]
		set gui(win_subscribed.$stream.tv4)	[label $gui(win_subscribed.$stream.ft4).tv4 -textvariable gui($stream.time_lastmsg)]

		# Last hello
		set gui(win_subscribed.$stream.ft5)	[frame $gui(win_subscribed.$stream.tv).f5]
		set gui(win_subscribed.$stream.t5)	[label $gui(win_subscribed.$stream.ft5).t5	-text "Last hello at : "]
		set gui($stream.time_lasthello)		[$stream.time_lasthello]
		set gui(win_subscribed.$stream.tv5)	[label $gui(win_subscribed.$stream.ft5).tv5 -textvariable gui($stream.time_lasthello)]

		# nb mesg
		set gui(win_subscribed.$stream.ft6)	[frame $gui(win_subscribed.$stream.tv).f6]
		set gui(win_subscribed.$stream.t6)	[label $gui(win_subscribed.$stream.ft6).t6	-text "nb of messages send : "]
		set gui($stream.nb_mesg)			[$stream.nb_mesg]
		set gui(win_subscribed.$stream.tv6)	[label $gui(win_subscribed.$stream.ft6).tv6 -textvariable gui($stream.nb_mesg)]

		# fullname
		set gui(win_subscribed.$stream.ft7)	[frame $gui(win_subscribed.$stream.tv).f7]
		set gui(win_subscribed.$stream.t7)	[label $gui(win_subscribed.$stream.ft7).t7	-text "User fullname : "]
		set gui($stream.fullname)			[$stream.user.fullname]
		set gui(win_subscribed.$stream.tv7)	[label $gui(win_subscribed.$stream.ft7).tv -textvariable gui($stream.fullname)]

		# firstname
		set gui(win_subscribed.$stream.ft8)	[frame $gui(win_subscribed.$stream.tv).f8]
		set gui(win_subscribed.$stream.t8)	[label $gui(win_subscribed.$stream.ft8).t8	-text "User firstname : "]
		set gui($stream.firstname)			[$stream.user.firstname]
		set gui(win_subscribed.$stream.tv8)	[label $gui(win_subscribed.$stream.ft8).tv8 -textvariable gui($stream.firstname)]

		# email
		set gui(win_subscribed.$stream.ft9)	[frame $gui(win_subscribed.$stream.tv).f9]
		set gui(win_subscribed.$stream.t9)	[label $gui(win_subscribed.$stream.ft9).t9	-text "Email address : "]
		set gui($stream.email)				[$stream.user.email]
		set gui(win_subscribed.$stream.tv9)	[label $gui(win_subscribed.$stream.ft9).tv9 -textvariable gui($stream.email)]

		# phone_nb
		set gui(win_subscribed.$stream.ft10)	[frame $gui(win_subscribed.$stream.tv).f10]
		set gui(win_subscribed.$stream.t10) 	[label $gui(win_subscribed.$stream.ft10).t10	-text "Phone number : "]
		set gui($stream.phone_nb)				[$stream.user.phone_nb]
		set gui(win_subscribed.$stream.tv10)	[label $gui(win_subscribed.$stream.ft10).tv10 -textvariable gui($stream.phone_nb)]

		# age
		set gui(win_subscribed.$stream.ft11)	[frame $gui(win_subscribed.$stream.tv).f11]
		set gui(win_subscribed.$stream.t11) 	[label $gui(win_subscribed.$stream.ft11).t11	-text "Age of user : "]
		set gui($stream.age)					[$stream.user.age]
		set gui(win_subscribed.$stream.tv11)	[label $gui(win_subscribed.$stream.ft11).tv11 -textvariable gui($stream.age)]

		# sex
		set gui(win_subscribed.$stream.ft12)	[frame $gui(win_subscribed.$stream.tv).f12]
		set gui(win_subscribed.$stream.t12)		[label $gui(win_subscribed.$stream.ft12).t12	-text "Sex of user : "]
		set gui($stream.sex)					[$stream.user.sex]
		set gui(win_subscribed.$stream.tv12)	[label $gui(win_subscribed.$stream.ft12).tv12 -textvariable gui($stream.sex)]

		# dest
		set gui(win_subscribed.$stream.ft13)	[frame $gui(win_subscribed.$stream.tv).f13]
		set gui(win_subscribed.$stream.t13)		[label $gui(win_subscribed.$stream.ft13).t13	-text "Destination of the user car : "]
		set gui($stream.dest)					[$stream.user.dest]
		set gui(win_subscribed.$stream.tv13)	[label $gui(win_subscribed.$stream.ft13).tv13 -textvariable gui($stream.dest)]

		# desc
		set gui(win_subscribed.$stream.ft14)	[frame $gui(win_subscribed.$stream.tv).f14]
		set gui(win_subscribed.$stream.t14)		[label $gui(win_subscribed.$stream.ft14).t14 -text "Description of pie user : "]
		set gui($stream.desc)					[$stream.user.desc]
		set gui(win_subscribed.$stream.tv14)	[label $gui(win_subscribed.$stream.ft14).tv14 -wraplength 300 -textvariable gui($stream.desc)]


		# Pack text/value
		for {set i 1} {$i  < 15} {incr i 1} {
			pack $gui(win_subscribed.$stream.ft$i) -fill x
			if {$i != 14} {
				pack $gui(win_subscribed.$stream.t$i)  -anchor w -side left
				pack $gui(win_subscribed.$stream.tv$i) -anchor e
			} else {
				pack $gui(win_subscribed.$stream.t$i)  -anchor w
				pack $gui(win_subscribed.$stream.tv$i) -anchor w
			}
		}

		# Button, their frame and frame with text/value
		pack $gui(win_subscribed.$stream.bt1)	-side left -fill x -expand yes
		pack $gui(win_subscribed.$stream.bt2)	-side right -fill x -expand yes

		pack $gui(win_subscribed.$stream.tv)	-fill both -expand yes
		pack $gui(win_subscribed.$stream.bt)	-fill x

		# Text area
		pack $gui(win_subscribed.$stream.mge)	-fill both -expand yes
		pack $gui(win_subscribed.$stream.mg)	-fill both -expand yes
		pack $gui(win_subscribed.$stream.mg)	-fill both -expand yes
		pack $gui(win_subscribed.$stream.txt)	-fill both -expand yes

		# Main frame of this stream
		pack $gui(win_subscribed.$stream._)		-fill both -expand yes
		pack $gui(win_subscribed.$stream.f)		-fill both -expand yes
		pack $gui(win_subscribed.$stream)		-fill both -expand yes


		# update view
		$gui(win_subscribed.nb)  			raise $stream
		$gui(win_subscribed.nb)  			raise [$gui(win_subscribed.nb) page 0]
	} else {
		gui_apps_traces "gui_subscribed_add : $stream is already registered as subscribed"
	}
}

proc gui_subscribed_newmesg { stream mesg } {
	global gui
	if {$stream == ""} {
		gui_exit_on_error "gui_subscribed_newmesg" "Bad call : empty args"
		gui_apps_traces "gui_subscribed_newmesg : Bad call : empty args"
		return 0 	;# false
	}
	if {[lsearch $gui(subscribed_registered) $stream] < 0} {
		gui_exit_on_error "gui_subscribed_newmesg" "Bad call : you are not subscribed to $stream"
		gui_apps_traces "gui_subscribed_newmesg : Bad call : you are not subscribed to $stream"
		return 0
	}
	gui_apps_traces "gui_subscribed_newmesg : new message from $stream, update panel"
	# Update all field (first two is not usefull ...)
	set gui($stream.user.nickname)		[$stream.user.nickname]
	set gui($stream.car_id)				[$stream.car_id]
	set gui($stream.time_available)		[$stream.time_available]
	set gui($stream.time_lastmsg)		[$stream.time_lastmsg]
	set gui($stream.time_lasthello)		[$stream.time_lasthello]
	set gui($stream.nb_mesg)			[$stream.nb_mesg]
	set gui($stream.fullname)			[$stream.user.fullname]
	set gui($stream.firstname)			[$stream.user.firstname]
	set gui($stream.email)				[$stream.user.email]
	set gui($stream.phone_nb)			[$stream.user.phone_nb]
	set gui($stream.sex)				[$stream.user.sex]
	set gui($stream.sex)				[$stream.user.sex]
	set gui($stream.dest)				[$stream.user.dest]
	set gui($stream.desc)				[$stream.user.desc]

	# unlock
	$gui(win_subscribed.$stream.mgt)	configure -state normal
	# Insert message
	$gui(win_subscribed.$stream.mgt)	insert end "\n[ clock format [clock seconds] -format %H:%M:%S ] :: $mesg"
	# lock 
	$gui(win_subscribed.$stream.mgt)	configure -state disabled

	# open tab if need
	if {$gui(subscribed) == 0} {
		set gui(subscribed) 1
		gui_menucmd_subscribed
		gui_apps_traces "gui_subscribed_newmesg : open panel and focus on it"
		$gui(win_subscribed.nb) raise $stream
	}
}

proc gui_subscribed_rem { stream } {
	global gui
	if {$stream == ""} {
		gui_exit_on_error "gui_subscribed_rem" "Bad call : empty args"
		gui_apps_traces "gui_subscribed_rem : Bad call : empty args"
		return 0 	;# false
	}
	if {[lsearch $gui(subscribed_registered) $stream] < 0} {
		gui_exit_on_error "gui_subscribed_rem" "Bad call : $stream is not shown"
		gui_apps_traces "gui_subscribed_rem : Bad call : $stream is not shown"
		return 0
	}
	gui_apps_traces "gui_subscribed_rem : unregister subscribed stream $stream"
	$gui(win_subscribed.nb) delete $stream
	lremove gui(subscribed_registered) $stream
	if { [$gui(win_subscribed.nb) page 0] != ""} {
		$gui(win_subscribed.nb)  raise [$gui(win_subscribed.nb) page 0]
	}
}

# When mesg or getinfos is received
proc gui_subscribed_update { stream } {
	global gui
	if {$stream == ""} {
		gui_exit_on_error "gui_subscribed_rem" "Bad call : empty args"
		gui_apps_traces "gui_subscribed_rem : Bad call : empty args"
		return 0 	;# false
	}
	if {[lsearch $gui(subscribed_registered) $stream] < 0} {
		gui_exit_on_error "gui_subscribed_rem" "Bad call : $stream is not shown"
		gui_apps_traces "gui_subscribed_rem : Bad call : $stream is not shown"
		return 0
	}
	gui_apps_traces "gui_subscribed_update : update stream $stream tab"
	gui_subscribed_rem $stream
	gui_subscribed_add $stream
}
# -----------------------------------------
