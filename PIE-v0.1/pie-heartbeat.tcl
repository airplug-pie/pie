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

### MODULE VIN ############################################################

###########################################################################
# VIN Generator
# Generates a VIN (Vehicle Identification Number) according to the ISO 
# 3779 standard.
# 
# This unique number is composed as follow :
# | - - - | - - - - - - | - - - - - - - |
#   V M I   Vehicle       Vehicle Code
#           Composition   VIS
# WMI :
#  - Given by the SAE
#  - One code per manufacturer par country
# Vehicle composition : 
#  - Each manufacturer has its own calculation mode
#  - Not a reliable information, randomly generated for our testing purpose.
# Vehicle code :
#  - Each manufacturer has its own calculation mode
#  - Not a reliable information, randomly generated for our testing purpose.
#
# return : a valid VIN number (16 characters)
#
#
############################################################################
proc PIE_gen_car_vin { } {

	# WMI code array (209 codes)
	set wmi_code { 0A3 0JA 0JF 0JH 0JK 0JM 0JN 0JS 0JT 0KL KM8 KMH KNA 
	KNB KNC KNM L56 L5Y LDY LKL LSY LTV LVS LZM LZE LZG LZY MA3 NLE NM4 
	NMT SAL SAJ SCC SCE SDB SFD SHS SJN TMB TMT TRA TRU TSM UU1 VF1 VF3 
	VF6 VF7 VF8 VSS VSX VS6 VSG VSE VWV WAU WBA WBS WDB WDC WDD WF0 WMA 
	WMW WP0 W0L WVW WV1 WV2 XL9 XTA YK1 YS2 YS3 YV1 YV4 YV2 YV3 ZAM ZAP 
	ZAR ZCG ZDM ZDF ZD4 ZFA ZFC ZFF ZHW ZLA ZOM 1C3 1D3 1FA 1FB 1FC 1FD 
	1FM 1FT 1FU 1FV 1F9 01G 1GC 1GT 1G1 1G2 1G3 1G4 1G6 1GM 1G8 01H 1HD 
	1J4 01L 1ME 1M1 1M2 1M3 1M4 01N 1NX 1P3 1R9 1VW 1XK 1XP 1YV 2C3 2D3 
	2FA 2FB 2FC 2FM 2FT 2FU 2FV 2FZ 02G 2G1 2G2 2G3 2G4 2HG 2HK 2HM 02M 
	2P3 02T 2WK 2WL 2WM 3D3 3FE 03G 03H 03N 3P3 3VW 04F 04M 04S 04T 4US 
	4UZ 4V1 4V2 4V3 4V4 4V5 4V6 4VL 4VM 4VZ 05F 05L 5N1 5NP 05T 06F 6G2 
	06H 6MM 6T1 8AG 8GG 8AP 8AF 8AD 8GD 8A1 8A1 8AJ 8AW 93U 9BG 935 9BD 
	9BF 93H 9BM 936 93Y 9BS 93R 9BW 9FB }

	# Generates a random number in scale [0,209]
	set rndnum [ expr { round( rand()*209 ) } ]

	set vin [ lindex $wmi_code $rndnum ]

	# List of authorized characters
	set characters { A B C D E F G H I J K L M N P Q R S T U V W X Y Z 
	0 1 2 3 4 5 6 7 8 9 }

	for {set x 0} {$x < 13} {incr x} {
		# Generates a random number in scale [0,35]
		set number [ expr { round( rand()*35 ) } ]
		set character [ lindex $characters $number ]
		set vin "$vin$character"
	}

	return $vin

}

###########################################################################
# ID Generator
# Generates a unique id based on the VIN of a car.
# vin : VIN number (16 characters)
# return : md5 hash of the VIN given as argument (32 characters)
#
#
###########################################################################
proc PIE_gen_car_id { vin } {

	package require md5

	return [ ::md5::md5 -hex $vin ]

}

