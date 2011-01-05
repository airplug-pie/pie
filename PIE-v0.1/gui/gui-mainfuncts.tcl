# --- gui-mainfuncts.tcl ---

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

# ----------- Main gui management functions ---------------

set gui(available_registered) [list]

# call : core => gui
# work : gui(main) => gui(tab)

proc gui_newavailable { stream } {
    global gui
	# if stream is not an object exit on error
	if { [ find objects -class stream  $stream ] < 0 } {
		gui_exit_on_error "gui_newavailable" "Bad call : $stream is not a stream object"
		gui_apps_traces "gui_newavailable : Bad call : $stream is not a stream object"
		return 0
	}
	if { [lsearch $gui(available_registered) $stream] < 0} {
		set nstf [label $gui(mainframe).[string tolower $stream] \
			-relief raised -bg lightgray -text "$stream -- [$stream.user.nickname]\ncar id : [$stream.car_id]"]
		bindtags $nstf [linsert [bindtags $nstf] 1 DropSource ]
		pack $nstf -in $gui(main.availablef) -anchor w -fill x
		lappend gui(available_registered) $stream
		gui_apps_traces "gui_newavailable : New stream available, add it ($stream)"
	} else {
		gui_exit_on_error "gui_newavailable" "Stream $stream is already known (in gui)"
		gui_apps_traces "gui_newavailable : Stream $stream is already known (in gui)"
		return 0
	}
}

proc gui_delavailable { stream } {
	global gui
	if { [lsearch $gui(available_registered) $stream] >= 0} {
		;# - remove stream from gui
		destroy $gui(mainframe).[string tolower $stream]
		gui_apps_traces "gui_delavailable : $stream : remove to GUI"
		;# - remove from suscribed (if need)
		if { [lsearch $gui(subscribed_registered) $stream] >= 0 } {
			gui_subscribed_rem $stream
			gui_apps_traces "gui_delavailable: $stream : remove to subscribed"
		}
		;# - remove from forwarded (if need)
		if { [lsearch $gui(forwarded_registered) $stream] >= 0 } {
			gui_tab_showforwarded_rem $stream
			gui_apps_traces "gui_delavailable : $stream : remove to forwarded"
		}
		lremove gui(available_registered) $stream
		return 1
	} else {
		gui_exit_on_error "gui_delavailable" "Stream $stream is unknown (in gui)"
		gui_apps_traces "gui_delavailable : Stream $stream is unknown (in gui)"
		return 0
	}
}

proc gui_newforward { stream } {
	global gui
	# if stream is not an object exit on error
	if { [ find objects -class stream  $stream ] < 0 } {
		gui_exit_on_error "gui_newforward" "Bad call : $stream is not a stream object"
		gui_apps_traces "gui_newforward : Bad call : $stream is not a stream object"
		return 0
	}
	if { [lsearch $gui(forwarded_registered) $stream] < 0 } {
		gui_tab_showforwarded_add $stream
		gui_apps_traces "gui_newforward : new stream forwarded ($stream)"
		return 1
	} else {
		gui_exit_on_error "gui_newforward" "Stream $stream is already known (in forwarded)"
		gui_apps_traces "gui_newforward : Stream $stream is already known (in forwarded)"
		return 0
	}
}

proc gui_delforward { stream } {
	global gui
	if { [lsearch $gui(forwarded_registered) $stream] >= 0 } {
		gui_tab_showforwarded_rem $stream
		gui_apps_traces "gui_delforward : stream remove to forwarded ($stream)"
		lremove gui(forwarded_registered) $stream
		return 1
	} else {
		gui_exit_on_error "gui_delforward" "Stream $stream is unknown (in forwarded)"
		gui_apps_traces "gui_delforward : Stream $stream is unknown (in forwarded)"
		return 0
	}
}

# call : gui => core
# work : gui => core(internals) and gui(internals)

proc gui_subscrib { stream } {
	global gui
	gui_apps_traces "gui_subscrib : you are now a subscriber of $stream"
	;# - add to subscrided streams
	gui_subscribed_add $stream
	if { ![storage.stream.issubscribed $stream] } {
		storage.subscribed $stream
	}
}

proc gui_unsubscrib { stream } {
	global gui
	gui_apps_traces "gui_unsubscrib : you are no longer subscribed to $stream"
	;# - remove from subscrided streams
	gui_subscribed_rem $stream
	if { ![storage.stream.issubscribed $stream] } {
		storage.unsubscribed $stream
	}
}

proc gui_unforward { stream } {
	global gui
	gui_apps_traces "gui_unforward : you make to $stream is unforwarded from now"
	;# - remove from forwoard
	gui_delforward $stream
	;# - return TODO_CALL_CORE
	return 
}

proc gui_send_mesg {} {
	global gui
	gui_apps_traces "gui_send_mesg : you have sent a new mesg"
	;# - add to "your messages" and clean
	;# - get text
	set msg_content [$gui(text_area) get 0.0 {1.0 lineend} ]
	;# - add to your messages
	gui_tab_localsend $msg_content
	;# - clean text area
	$gui(text_area) insert 0.0 "sent" ;# to be sure its not empty
	$gui(text_area) delete 0.0 end
	;# - add to counter
	incr gui(nblocalmesg_snd) 1
	;# - the message is posted
	PIE_post $msg_content
}

# global management function

# call : core => gui
# work : gui(main) => gui(tab)

proc gui_stream_recvmesg { stream mesg } {
	global gui
	if { [lsearch $gui(subscribed_registered) $stream] >= 0 } {
		gui_subscribed_newmesg $stream $mesg
		gui_apps_traces "gui_stream_recvmesg : new messages received from $stream"	
		return 1
	} else {
		gui_apps_traces "gui_stream_recvmesg : WARNING : message received from a unsubscirbed stream"
		return 0
	}
}

proc gui_netmesg { mesg from } {
	global gui
	gui_apps_traces "gui_netmesg : network message : from $from"
	;# - display in net traces
	gui_tab_nettraces $mesg $from
	;# - either in or out messages display in appropriate tab
	if { "$from" == "input"} {
		gui_netmesg_recv $mesg
		;# - update counter
		incr gui(nbmesg_recv) 1
	} else {
		gui_netmesg_send $mesg
		;# - update counter
		incr gui(nbmesg_send) 1
	}
}

proc gui_netmesg_send { mesg } {
	global gui
	gui_apps_traces "gui_netmesg_send : network message sent"
	;# - display in output
	# TODO message type 
	set mesgtype "unknown" 
	gui_tab_inputs $mesg $mesgtype
}

proc gui_netmesg_recv { mesg } {
	global gui
	gui_apps_traces "gui_netmesg_send : network message received"
	;# - display in input
	# TODO message type
	set mesgtype "unknown" 
	gui_tab_outputs $mesg $mesgtype

}

# overide pdebug and pstr
proc gui_apps_traces { mesg } {
	global gui
	;# - display messages in pie traces
	gui_tab_pietraces $mesg
}

proc gui_stream_getinfos_snd_popup_ok { stream } {
	global gui
	set popup_guard 0
	set OldFocus [focus]
	set popup_getinfo [ toplevel .popup_getinfo ]
	wm title .popup_getinfo "Getinfo : $stream"
	message $popup_getinfo.msg -aspect 5000 -justify center \
		-text "Getinfo request send !!\n\nIf you received a response then stream information\nwill be updated automaticaly"
	button $popup_getinfo.exit -text "Close" -command { set popup_guard 1 }
	pack $popup_getinfo.msg $popup_getinfo.exit -pady 4
	gui_apps_traces "gui_stream_getinfos_snd : popup_ok : getinfo request is gone"
	grab $popup_getinfo
	focus $popup_getinfo
	tkwait variable popup_guard
	grab release $popup_getinfo
	destroy $popup_getinfo
	focus $OldFocus
}

proc gui_stream_getinfos_snd { stream } {
	global gui
	gui_stream_getinfos_snd_popup_ok $stream
	gui_apps_traces "gui_stream_getinfos_snd : getinfo request is gone"
	;# TODO_CALL_CORE send getinfo packet
}

proc gui_stream_getinfos_rcv { stream } {
	global gui
	gui_apps_traces "gui_stream_getinfos_rcv : Getinfo response received to stream $stream"
	if { [lsearch $gui(subscribed_registered) $stream] >= 0 } {
		gui_apps_traces "gui_stream_getinfos_rcv : Getinfo response received, update subscribed"
		gui_subscribed_update $stream
	}
	if { [lsearch $gui(forwarded_registered) $stream] >= 0 } {
		gui_apps_traces "gui_stream_getinfos_rcv : Getinfo response received, update forwarded"
		gui_tab_showforwarded_update $stream
	}
}

# TODO NOT IMPLEMENTED
#proc gui_forward_send { mesg } {}
#proc gui_forward_recv { mesg } {}
#proc gui_hello_send { mesg }   {}
#proc gui_hello_recv { mesg }   {}
#proc gui_getinfo_send { mesg } {}
#proc gui_getinfo_recv { mesg } {}

# --------------------------------------------------------------------------------------


