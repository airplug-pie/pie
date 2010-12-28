#    pie
#    a twitter-like app for airplug
#    authors: Christophe Boudet, Julien Castaigne, Jonathan Roudière,
#             Christophe Roquette, Jérémy Subtil
#    license type: free of charge license for academic and research purpose
#    see license.txt

### MODULE HEARTBEAT ######################################################
set PIE_field_eq "-"
set PIE_field_delim ","
set PIE_elt_delim "|"
set PIE_not_found -1

set PIE_hbeat_delay 10000
set PIE_hbeat_timer_active 0
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
# Update a stream from the element
#
# element : element from the payload
###########################################################################
proc PIE_process_element { element } {
	set nick [PIE_elt_splitstr $element $::PIE_msg_key_hb_nick]
	set id [PIE_elt_splitstr $element $::PIE_msg_key_hb_id]
	set distance [PIE_elt_splitstr $element $::PIE_msg_key_hb_dist]
	
	set stream [ storage.stream_search $car_id $nickname ]
	if { $stream == "" } {
		set stream [storage.new_stream $id $nick]
		$stream.distance.set $distance
	} else {
		$stream.distance.set $distance
		$stream.priority.inc
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
	PIE_send_what [PIE_gen_heartbeat]
}

###########################################################################
# No operation procedure
#
###########################################################################
proc nop {} {
}
