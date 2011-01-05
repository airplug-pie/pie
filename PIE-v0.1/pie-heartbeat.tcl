#    pie
#    a twitter-like app for airplug
#    authors: Christophe Boudet, Julien Castaigne, Jonathan Roudière,
#             Christophe Roquette, Jérémy Subtil
#    license type: free of charge license for academic and research purpose
#    see license.txt

### MODULE HEARTBEAT ######################################################
### List of Functions #####################################################
##### Generation Functions
# PIE_gen_list elt			Generate a list from the element
# PIE_add_elt listname elt		Add the element to the variable listname
# PIE_gen_hbeat_elt id nick dist	Generate an element from the given values
# PIE_gen_elt_from_stream stream	Generate an element from the stream
# PIE_gen_elt field			Generate an element from a field
# PIE_gen_field mnemonique val		Generate a field from the Key - Value
# PIE_add_field varelt mnemonique val	Add a field (key-value) to the variable varelt
# PIE_gen_heartbeat			Generate a HeartBeat Message
# PIE_get_offers {length}		Return a string of offers of the given length 
# PIE_get_forward {length}		Return a string of forwarded streams of the given length 
#
##### Cut Functions
# PIE_stream_elt_split chaine		Cut the string into elements
# PIE_stream_field_split elt		Cut the element into fields
# PIE_elt_splitstr elt mnemonique	Give the value for the given key in the element
#
##### Evaluation Functions
# PIE_process_element {forward}		Eval the element as an offer (and a forwarded stream if true)
# PIE_proc_offers 			Eval the offers
# PIE_proc_forwards			Eval the Forward
#
#### Update Functions
# PIE_update_offers_msg raw_msg		Return an offer list with incremented distances
# PIE_update_forward_msg raw_msg	Return a forward list with incremented distances
#
#### See also Timers functions

set PIE_field_eq "-"
set PIE_field_delim ","
set PIE_elt_delim "|"
set PIE_not_found -1

set PIE_hbeat_delay 10000
set PIE_hbeat_timer_active 0
set PIE_garbage_delay 30000
set PIE_garbage_timer_active 0




###########################################################################
### Generation procedures #################################################
###########################################################################

###########################################################################
# Return a list of elements.
#
# elt : First element of the list
# return : List of element (String)
###########################################################################
proc PIE_gen_list { elt } {
	return "$elt"
}

###########################################################################
# Add the element at the end of the list
#
# listname : name of the variable referencing the list
# elt : element to add
###########################################################################
proc PIE_add_elt { listname elt } {
	upvar $listname l
	set l "$l$::PIE_elt_delim$elt"
}

###########################################################################
# Generate an element for a hbeat message
#
# id : id of the car
# nick : user's nickname
# distance : distance in hops, of the car
# return : element in the good format
###########################################################################
proc PIE_gen_hbeat_elt { id nick dist } {
	set elt [PIE_gen_field $::PIE_msg_key_hb_id $id]
	PIE_add_field elt $::PIE_msg_key_hb_nick $nick
	PIE_add_field elt $::PIE_msg_key_hb_dist $dist
	return $elt
}

###########################################################################
# Generate an element from a stream
#
# stream : stream object to get information from
# return : element
###########################################################################
proc PIE_gen_elt_from_stream { stream } {
	return [PIE_gen_hbeat_elt [$stream.car_id] [$stream.user.nickname] [$stream.distance]]
}

###########################################################################
# Generate an element with a field
#
# field : first field of the element
# return : element
###########################################################################
proc PIE_gen_elt { field } {
	return "$field"
}

###########################################################################
# Generate a field from a key and a value
#
# mnemonique : key
# val : value
# return : field (String)
###########################################################################
proc PIE_gen_field { mnemonique val } {
	return "$mnemonique$::PIE_field_eq$val"
}

###########################################################################
# add a field to an element
#
# varelement : name of the variable referencing the element
# mnemonique : key
# val : value
###########################################################################
proc PIE_add_field { varelement mnemonique val } {
	upvar $varelement elt
	set elt "$elt$::PIE_field_delim$mnemonique$::PIE_field_eq$val"
}


###########################################################################
# Generate a HeartBeat message
#
# return : message to send
###########################################################################
proc PIE_gen_heartbeat {} {
	set msg [PIE_gen_header 0 0 $::PIE_msg_type_heartbeat]
	APG_msg_addmsg msg $::PIE_msg_key_hb_offers [PIE_get_offers 500]
	APG_msg_addmsg msg $::PIE_msg_key_hb_forward [PIE_get_forward 500]
	return $msg
}

###########################################################################
# Return a list of offers
#
# length : (optional, default = 60) length of the offer string
# return : offers (string)
###########################################################################
proc PIE_get_offers { {length 60} } {
	set offres ""
	PIE_add_elt offres [PIE_gen_hbeat_elt [ MainUser.car_id ] [ MainUser.user.nickname ] 0]
	foreach stream [available.show] {
		set elt [PIE_gen_elt_from_stream $stream]
		if {[expr [string length $offres] + [string length $elt]] < $length} {
			PIE_add_elt offres $elt
		} else {
			break
		}
	}
	return $offres
}

###########################################################################
# Return a list of forwarded streams
#
# length : (optional, default = 60) length of the forwarded string
# return : forwardeds (string)
###########################################################################
proc PIE_get_forward { {length 60} } {
	set forward ""
	foreach stream [forwarded.show] {
		set elt [PIE_gen_elt_from_stream $stream]
		if {[expr [string length $forward] + [string length $elt]] < $length} {
			PIE_add_elt forward $elt
		} else {
			break
		}
	}
	return $forward
}





###########################################################################
#### Cut procedures #######################################################
###########################################################################

###########################################################################
# Cut a string into elements
#
# chaine : string
# return : Tab of elements
###########################################################################
proc PIE_stream_elt_split { chaine } {
	return [split $chaine "$::PIE_elt_delim"]
}

###########################################################################
# Cut an element into fields
#
# elt : element
# return : tab of fields
###########################################################################
proc PIE_stream_field_split { elt } {
	return [split $elt $::PIE_field_delim]
}

###########################################################################
# Return the value link to a key in the element given
#
# element : element
# mnemonique : key
# return : value found or $::PIE_not_found
###########################################################################
proc PIE_elt_splitstr { element mnemonique } {
    foreach champs [PIE_stream_field_split $element] {
	set name [lindex [split $champs $::PIE_field_eq] 0]
	set value [lindex [split $champs $::PIE_field_eq] 1]
	
	if { $name == $mnemonique } { return $value }
    }
    
    return $::PIE_not_found
}





###########################################################################
### Evaluation procedures #################################################
###########################################################################

###########################################################################
# Update a stream from the element
#
# element : element from the payload
# forward : must be True(1) if the element is from a forward list
###########################################################################
proc PIE_process_element { element { forward 0 } } {
	set nick [PIE_elt_splitstr $element $::PIE_msg_key_hb_nick]
	set id [PIE_elt_splitstr $element $::PIE_msg_key_hb_id]
	set distance [PIE_elt_splitstr $element $::PIE_msg_key_hb_dist]
	if {[string compare $nick [ MainUser.user.nickname ]] != 0 && [string compare $id [ MainUser.car_id ]] != 0 } {
		set stream [ storage.stream_search $id $nick ]
		if { $stream == "" } {
			set stream [storage.new_stream $id $nick]
			$stream.distance.set $distance
			gui_newavailable $stream
		} else {
			$stream.distance.set $distance
			$stream.priority.inc
		}
		if { ![storage.stream.isforwarded $stream] && $forward } {
			storage.forwarded $stream
			gui_newforward $stream
		}
	}
}
###########################################################################
# Process Offers. Eval each element to update the stream
#
#
############################################################################
proc PIE_proc_offers { offres } {
	foreach elt [PIE_stream_elt_split $offres] {
		if { [string length $elt] > 3 } {
			PIE_process_element $elt
		}
	}
}

###########################################################################
# Process Forwards. Eval each element to update the stream
# 
#
############################################################################
proc PIE_proc_forwards { forwards } {
	foreach elt [PIE_stream_elt_split $forwards] {
		if { [string length $elt] > 3 } {
			PIE_process_element $elt 1
		}
	}
}

###########################################################################
# Decrease each element priority
#
#
###########################################################################
proc PIE_garbage_collect_stream {} {
	foreach stream [available.show] {
		$stream.priority.dec
	}
}



###########################################################################
### Update Functions
###########################################################################

###########################################################################
# Update an offer message to forward
# 
# raw_msg : initial offers msg
#
###########################################################################
proc PIE_update_offers_msg { raw_msg } {
	set msg ""
	foreach elt [PIE_stream_elt_split raw_msg] {
		set new_elt [PIE_update_offers_elt $elt]
		if {$new_elt != ""} {
			PIE_add_elt "msg" $new_elt
		}
	}
	return $msg
}

###########################################################################
# Update a forward message to forward
# 
# raw_msg : initial forward msg
#
###########################################################################
proc PIE_update_forward_msg { raw_msg } {
	set msg ""
	foreach elt [PIE_stream_elt_split raw_msg] {
		set new_elt [PIE_update_forward_elt $elt]
		if {$new_elt != ""} {
			PIE_add_elt "msg" $new_elt
		}
	}
	return $msg
}

###########################################################################
# Update an offer element to forward
# 
# raw_msg : initial forward msg
#
###########################################################################
proc PIE_update_offers_elt { elt } {
	set nick [PIE_elt_splitstr $element $::PIE_msg_key_hb_nick]
	set id [PIE_elt_splitstr $element $::PIE_msg_key_hb_id]
	set distance [PIE_elt_splitstr $element $::PIE_msg_key_hb_dist]
	if {[string compare $nick [ MainUser.user.nickname ]] != 0 && [string compare $id [ MainUser.car_id ]] } {
		set new_distance [expr $distance + 1]
	} else {
		set new_distance 0
	}
	return [PIE_gen_hbeat_elt $id $nick $new_distance]
}

###########################################################################
# Update a forward element to forward
# 
# raw_msg : initial forward msg
#
###########################################################################
proc PIE_update_forward_elt { elt } {
	set nick [PIE_elt_splitstr $element $::PIE_msg_key_hb_nick]
	set id [PIE_elt_splitstr $element $::PIE_msg_key_hb_id]
	set distance [PIE_elt_splitstr $element $::PIE_msg_key_hb_dist]
	if { [storage.issubscribed $id $nick] } {
		set new_distance 0
	} else {
		set new_distance [expr $distance + 1]
	}
	return [PIE_gen_hbeat_elt $id $nick $new_distance]
}

###########################################################################
### Timers Procedures #####################################################
###########################################################################

###########################################################################
# Launch HeartBeat Timer
#
#
###########################################################################
proc PIE_start_hbeat {} {
	if { !$::PIE_hbeat_timer_active } {
		if { [info exist ::PIE_hbeat_timer_id] } {
			after cancel $::PIE_hbeat_timer_id
		}
		set ::PIE_hbeat_timer_active 1
		set ::PIE_hbeat_timer_id [after $::PIE_hbeat_delay { PIE_hbeat_timer }]
	}
}

###########################################################################
# Stop HeartBeat Timer
#
#
###########################################################################
proc PIE_stop_hbeat {} {
	after cancel $::PIE_hbeat_timer_id
	set ::PIE_hbeat_timer_active 0
}

###########################################################################
# HeartBeat Timer
#
#
###########################################################################
proc PIE_hbeat_timer {} {
	if { $::PIE_hbeat_timer_active } {
		PIE_send_hbeat
		set ::PIE_hbeat_timer_id [after $::PIE_hbeat_delay { PIE_hbeat_timer }]
	}
}

###########################################################################
# Launch Garbage Timer
#
#
###########################################################################
proc PIE_start_garbage {} {
	if { !$::PIE_garbage_timer_active } {
		if { [info exist ::PIE_garbage_timer_id] } {
			after cancel $::PIE_garbage_timer_id
		}
		set ::PIE_garbage_timer_active 1
		set ::PIE_garbage_timer_id [after $::PIE_garbage_delay { PIE_garbage_timer }]
	}
}

###########################################################################
# Stop Garbage Timer
#
#
###########################################################################
proc PIE_stop_garbage {} {
	after cancel $::PIE_garbage_timer_id
	set ::PIE_garbage_timer_active 0
}

###########################################################################
# Garbage Timer
#
#
###########################################################################
proc PIE_garbage_timer {} {
	if { $::PIE_garbage_timer_active } {
		PIE_garbage_collect_stream
		set ::PIE_garbage_timer_id [after $::PIE_garbage_delay { PIE_garbage_timer }]
	}
}

###########################################################################
# Send HeartBeat message
#
#
###########################################################################
proc PIE_send_hbeat {} {
	set msg [ PIE_gen_heartbeat ]

	PIE_send_what $msg
	PIE_log_send_hbeat $msg
}

###########################################################################
# No operation procedure
#
###########################################################################
proc nop {} {
}
