# --- storage_stream.tcl ---

# Author(s) :
#		Jonathan Roudiere <joe.roudiere@gmail.com>
#
# Copyright : 
#		Copyright (C) 2010 Jonathan Roudiere <joe.roudiere@gmail.com>

# =============================== Storage API =============================
#
# Storage system store all streams of the system. Streams are held in four
# lists : available, forwarded, subscribed, forgotten. Storage API offers
# a high level interface to manipulate stream and list. All stream known
# are in the available list
#
# A stream is an object with several fields : stream_id, car_id, time_lastmsg,
# time_lasthello, time_available, nb_mesg, in plus it contains a user object
# which has several fields too : id, stream, dest, nickname, email, fullname,
# firstname, phone_nb, age, sex, desc.
#
# Finaly, a stream is just characterized by some fields : stream_id, car_id,
# id (user) and nickname (user). When a new stream is created stream_id and
# id (user) fields are set automatically but car_id and nickname (user) must
# be specified by user (at creation time). The values of other fields should
# be filled be obtained by sending a special packet (type GetUserInfo) and 
# set through a storage's API primitive.
# 
# A new stream starts by being available and could be forwarded or subscribed
# after. Each stream state change is performed by its adding or its deletion
# in the lists of the storage system. When a stream is no longer available it
# must be remove from all storage's lists; in order to minimize network usage
# and stream management, it will be move in the forgotten list (specialy 
# interesting when the stream or user informations have been get earlier);
# if the stream is created again later - when it becomes available again - all
# previous informations will be restored.
#
#
# API : Storage interface
# ------------------------

# storage_init								: create storage's lists (available, forwarded, subscribed and forgotten)
# storage.isinit							: return true(1) if storage is initialised, false(0) else
# storage.reset 							: reset all the system and existing list
#
# storage.new_stream $car_id $nickname 		: create a new stream by configuring it and return reference, or nothing if it already exist
# storage.istream $s						: search a stream and return true/false if it exists
# storage.stream_search $car_id $nickname	: search a stream and it if it exist
# storage.stream_list $s					: return a list of the lists where stream is available
# storage.stream_delete_list $l $s			: delete the stream $s in the list $l
# storage.stream_delete $s					: delete the stream in all list (and put in the forgotten list)
# storage.stream_destroy $s					: remove from the storage system the stream $s (in forgotten list too)
# storage.addstream $l $s					: add an existing stream $s (so present in the available list) to the list $l (just a wrapper)
#
# storage.stream.search_bymember $m $v		: search the stream for which its member $m is eq. to $v (Warning a list is returned, if you are lucky with an only element ;)
# storage.search_stream.user.bymember $m $v : search the stream for which its user.member $m is eq. to $v (Warning a list is returned, if you are lucky with an only element ;)
#
# get/modify stream/user field value :
#	- first get the stream object with a search funtion of the storage interface
# 	- then use the stream interface, get value of a field with : $stream.$fieldname
#	  and modify its value with $stream.$fieldname.set $val (use $stream.user.$fieldname
#	  $stream.user.$fieldname.set for a field of the stream's user)
#	- see storage_stream.tcl file for more information about set and get possibilities
#	- note : Warning : nickanme and car_id should likely not be modified !!!
#
# storage.stream.isavailable $s    		: return true(1) if stream is in the available list, false(0) else
# storage.isavailable $car_id $nickname : search if the stream ($car_id,$nickname) exist in the collection of stream (and return it)
# storage.available $s 					: add the stream $s in the available list if not already present and returnn true(1), false(0) else
# storage.unavailable $s				: remove stream $s from the available list if it is present and return true(1) or false(0)
#
# storage.stream.isforwarded $s    		: return true(1) if stream is in the forwarded list, false(0) else
# storage.isforwarded car_id nickname	: search if the stream ($car_id,$nickname) exist in the forwarded list (and return it)
# storage.forwarded $s					: add the stream $s in the forwarded list if not already present and returnn true(1), false(0) else
# storage.unforwarded $s				: remove stream $s from the subscribed list if it is present and return true(1) or false(0)
#
# storage.stream.issubscribed $s    	: return true(1) if stream is in the subscribed list, false(0) else
# storage.issubscribed car_id nickname	: search if the stream ($car_id,$nickname) exist in thesubscribed list (and return it)
# storage.subscribed $s 				: add the stream $s in the subscribed list if not already present and returnn true(1), false(0) else
# storage.unsubscribed $s				: remove stream $s from the subscribed list if it is present and return true(1) or false(0)
#
# storage.stream.isforgotten $s			: return true(1) if stream is in the forgotten list, false(0) else
# storage.isforgotten $car_id $nickname	: search if the stream ($car_id,$nickname) exist in the forgotten list (and return it)
# storage.forgotten $s					: add the stream $s in the forgotten list if not already present and returnn true(1), false(0) else
# storage.unforgotten $s				: remove stream $s from the forgotten list if it is present and return true(1) or false(0)
#
# time/stat functs :
# 
# storage.time_available $s				: returns the time from which this stream is available  
# storage.time_available.set $s			: update to now the time from which this stream is available (dont't touch, set at stream creation !!)
# storage.time_available.get $s			: returns the time difference from which this stream is available
#
# storage.time_lastmsg $s 				: returns the time of last mesg of the stream $s (hh:mm:ss)
# storage.time_lastmsg.set $s			: update to now the time of the last mesg of the stream $s (run for each new mesg) (hh:mm:ss)
# storage.time_lastmsg.get $s			: get the time difference from which the stream $s has sent its last mesg
#
# storage.time_lasthello $s				: returns the time of last hello of the stream $s (hh:mm:ss)
# storage.time_lasthello.set $s			: update to now the time of the last mesg of the stream $s (run for each new hello) (hh:mm:ss)
# storage.time_lasthello.get $s			: get the time difference from which the stream $s has sent its last hello (hh:mm:ss)
#
# storage.nb_mesg $s					: get the number of mesg sent by the stream $s
# storage.newmesg $s					: increment the number of mesg sent by the stream $s
#
# note : time/stat functs return nothing on error (unknown stream, ...)
#
# =========================================================================

# --------------------------- Requirement --------------------------------
package require Itcl
namespace import itcl::*

# Provide display functions
source $PATH/core/low_proc.tcl

# --------------------- End : Requirement --------------------------------

# ----------------- Storage's Management Interface ------------------------

## storage_init	: create storage's lists (available, forwarded, subscribed and forgotten)
proc storage_init {} {	
	pdebug "Storage's management interface initialization"
	uplevel #0 set storage_initialised 1
	# if not exist create list (? ou alors si on init c'est que l'on veut reseter tout ?)
	foreach lists [ list available forwarded subscribed forgotten ] {
		pdebug "Storage management : creation of the \"$lists\" list"
		list.new $lists "stream_compare"
	}
	pdebug "Storage's management interface initialization"
}

## storage.isinit	: return true(1) if storage is initialised, false(0) else
proc storage.isinit {} {
	pdebug "Storage management : storage.isinit : Storage is initialised ?"
	if { $::storage_initialised == 1 } {
		pdebug "Storage management : storage.isinit : Storage initialised (true)" 
		return 1
	} else {
		pdebug "Storage management : storage.isinit : Storage initialised (false)" 
		return 0
	}
}

## storage.reset : reset all the system and existing list
proc storage.reset {} {
	pdebug "Storage management : storage.reset : remove all list"
	# All existing stream are either available or forgotten
	# so we must destroy content (stream objects)
	foreach lists [ list available forgotten ] {
		if { [ list.exist $lists ] } {
			pdebug "Storage management : storage.reset : destroy list $lists"
			$lists.destroy_withcontent
		}
	}
	# we just need to destroy lists themselves (objects have already been destroy)
	foreach lists [ list forwarded subscribed ] {
		if { [ list.exist $lists ] } {
			pdebug "Storage management : storage.reset : destroy list $lists"
			$lists.destroy
		}
	}
	uplevel #0 set storage_initialised 0
	pdebug "Storage management : storage.reset : system has been reseted"
}

## storage.new_stream $car_id $nickname : create a new stream by configuring it and return reference, or nothing if it already exist
proc storage.new_stream { car_id nickname } {
	if { $car_id == "" || $nickname == "" } {
		pdebug "Storage management : storage.new_stream : car_id or nickname argument is empty, Exit"
		return
	}
	# test if stream already exist else create it
	set stream [ storage.stream_search $car_id $nickname ]
	if { $stream == "" } {
		pdebug "Storage management : storage.new_stream : stream ($car_id,$nickname) not found, create it"
		# stream creation
		set stream [ stream.new ]
		# set attribute
		$stream.car_id.set $car_id
		$stream.user.nickname.set $nickname
		# put stream in available list 
		storage.available $stream
		pdebug "Storage management : storage.new_stream : stream ($car_id,$nickname) added to the available list"
		return $stream
	} else {
		if { [ storage.stream.isforgotten $stream ] } {
			pdebug "Storage management : storage.new_stream : stream ($car_id,$nickname) already exist ($stream) in forgotten"
			pdebug "Storage management : storage.new_stream : so put it in available list and remove from forgotten"
			storage.unforgotten $stream
			storage.available $stream
			$stream.time_available_up
			$stream.time_lastmsg_up
			$stream.time_lasthello_up
			pdebug "Storage management : storage.new_stream : stream ($car_id,$nickname) restored (in available)"
			return $stream
		} else {
			pdebug "Storage management : storage.new_stream : stream ($car_id,$nickname) already exist ($stream), Exit!!"
			return ;# either return "nothing" or "0" ... in a test "nothing" is more easier to test ?
		}
	}
}

## storage.istream $s					: search a stream and return true/false if it exists
proc storage.istream { stream } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.istream : storage not initialised, Exit !!"
		return
	}
	foreach st1 [ available.show ] {
		if { "$stream" == "$st1" } {
			pdebug "Storage management : storage.istream : stream $stream exist in available list, found (true)"
			return 1
		}
	}
	foreach st2 [ forgotten.show ] {
		if { "$stream" == "$st2" } {
			pdebug "Storage management : storage.istream : stream $stream exist in forgotten list, found (true)"
			return 1
		}
	}
	pdebug "Storage management : storage.istream : stream $stream doesn't exist, not found (false)"
	return 0
}

## storage.stream_search $car_id $nickname	: search a stream and it if it exist
proc storage.stream_search { car_id nickname } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.stream_search : storage not initialised, Exit !!"
		return ""
	}
	if { $car_id == "" || $nickname == "" } {
		pdebug "Storage management : storage.stream_search : car_id or nickname argument is empty, Exit"
	} else {
		pdebug "Storage management : storage.stream_search : look for stream with car_id eq. to $car_id and nickname eq. to $nickname"
		foreach stream [ stream.search_by_member car_id $car_id ] {
		# it must be exist several stream with car_id eq. to $car_id but ones
		# with car_id eq. to $car_id and nickname eq. to $nickname
			if { [ $stream.user.nickname ] == "$nickname" } {
				pdebug "Storage management : storage.stream_search : stream with car_id eq. to $car_id and nickname eq. to $nickname found"
				return $stream
			}
		}
		pdebug "Storage management : storage.stream_search : stream with car_id eq. to $car_id and nickname eq. to $nickname NOT found"
	}
	return ""
}

## storage.stream_list $s					: return a list of the lists where stream is available
proc storage.stream_list { stream } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.stream_list : storage not initialised, Exit !!"
		return ""
	}
	set where [ list ]
	# a stream in forgotten list shouldn't exist in any other list
	foreach st [ forgotten.show ] {
		if { "$stream" == "$st" } {
			pdebug "Storage management : storage.istream : stream $stream exist in forgotten list, found (true)"
			lappend where forgotten
			return $where 
		}
	}
	foreach st [ available.show ] {
		if { "$stream" == "$st" } {
			pdebug "Storage management : storage.stream_list : stream $stream exist in available list, found"
			lappend where available
		}
	}
	foreach st [ forwarded.show ] {
		if { "$stream" == "$st" } {
			pdebug "Storage management : storage.stream_list : stream $stream exist in forwarded list, found"
			lappend where forwarded
		}
	}
	foreach st [ subscribed.show ] {
		if { "$stream" == "$st" } {
			pdebug "Storage management : storage.stream_list : stream $stream exist in subscribed list, found"
			lappend where subscribed
		}
	}
	return $where
}

## storage.stream_delete_list $l $s			: delete the stream $s in the list $l
proc storage.stream_delete_list { list stream } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.stream_delete_list : storage not initialised, Exit !!"
		return 0
	}
	if { $list != "available" && $list != "forwarded" && $list != "subscribed" } {
		pdebug "Storage management : storage.stream_delete_list : error unknow list ($list), Exit(0)"
		return 0
	} else {
		# if remove in available then remove in all other list and place in forgotten list
		if { $list == "available" } {
			if { [ storage.stream.isavailable $stream ] } {
				storage.unavailable $stream
				storage.unsubscribed $stream
				storage.unforwarded $stream
				storage.forgotten $stream
				pdebug "Storage management : storage.stream_delete_list : stream $stream remove from all list and put in forgotten (true)"
				return 1
			} else {
				pdebug "Storage management : storage.stream_delete_list : stream $stream not found in available list, Exit(false)"
				return 0
			}
		# else just remove in the wanted list
		} else {
			if { [ storage.stream.is$list $stream ] } {
				storage.un$list $stream
				pdebug "Storage management : storage.stream_delete_list : stream $stream remove from $list (true)" 
				return 1
			} else {
				pdebug "Storage management : storage.stream_delete_list : stream $stream not found in $list, Exit(false)"
				return 0
			}
		}
	}
	# return false by default
	pdebug "Storage management : storage.stream_delete_list : DEFAULT EXIT (WHY ??)"
	return 0
}

## storage.stream_delete $s					: delete the stream in all list (and put in the forgotten list)
proc storage.stream_delete { stream } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.stream_delete : storage not initialised, Exit !!"
		return 0
	}
	# is just need to remove from available (available contains all known stream !!)
	pdebug "Storage management : storage.stream_delete : try to remove $stream"
	storage.stream_delete_list available $stream
}

## storage.stream_destroy $s	:	remove from the storage system the stream $s (in forgotten list too)
proc storage.stream_destroy { stream } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.stream_delete : storage not initialised, Exit !!"
		return 0
	}
	if { [ storage.istream $stream ] } {
		storage.stream_delete $stream
		storage.unforgotten $stream
		$stream.destroy
		pdebug "Storage management : storage.stream_destroy : stream $stream remove from storage and destroy (true)"
		return 1
	} else {
		pdebug "Storage management : storage.stream_destroy : stream $stream not found, Exit(false)"
		return 0
	}
}

## storage.addstream $l $s					: add an existing stream $s (so present in the available list) to the list $l (just a wrapper)
proc storage.addstream { list stream } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.addstream : storage not initialised, Exit !!"
		return 0
	}
	if { $list != "forgotten" && $list != "available" && $list != "forwarded" && $list != "subscribed" } {
		pdebug "Storage management : storage.addstream : error unknow list ($list), Exit(0)"
		return 0
	} else {
		pdebug "Storage management : storage.addstream : call storage.$list to add stream $stream"
		return [ storage.$list $stream ]
	}
}

## storage.search_stream.bymember $m $v  : search the stream for which its member $m is eq. to $v
proc storage.search_stream.bymember { member val } {
	if { [ storage.isinit ] } {
		set ret [ stream.search_by_member $member $val ]
		pdebug "Storage management : storage.search_stream.bymember : look for stream with a member $member eq. to $val" 
		if { $ret != -2 } {
			return $ret
		} else {
			pdebug "Storage management : storage.search_stream.bymember : stream hasn't a memeber call $member, Exit"
		}
	} else {
		pdebug "Storage management : storage.search_stream.bymember : storage not initialised, Exit !!"
	}
	return ""
}

## storage.search_stream.user.bymember $m $v : search the stream for which its user.member $m is eq. to $v
proc storage.search_stream.user.bymember { member val } {
	if { [ storage.isinit ] } {
		set ret [ stream.user.search_by_member $member $val ]
		pdebug "Storage management : storage.search_stream.user.bymember : look for stream's user with a member $member eq. to $val" 
		if { $ret != -2 } {
			return $ret
		} else {
			pdebug "Storage management : storage.search_stream.user.bymember : stream's user hasn't a memeber call $member, Exit"
		}
	} else {
		pdebug "Storage management : storage.search_stream.user.bymember : storage not initialised, Exit !!"
	}
	return ""
}

# available list functions
# ------------------------

## storage.stream.isavailable $s    : return true(1) if stream is in the available list, false(0) else
proc storage.stream.isavailable { stream } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.stream.isavailable : storage not initialised, Exit !!"
		return 0
	}
	if { [ available.search $stream ] } {
		pdebug "Storage management : storage.stream.isavailable : stream $stream found in the available list (true)"
		return 1
	} else {
		pdebug "Storage management : storage.stream.isavailable : stream $stream not found in the available list (false)"
		return 0
	}
}

## storage.isavailable $car_id $nickname : search if the stream ($car_id,$nickname) exist in the collection of stream (and return it)
proc storage.isavailable { car_id nickname } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.isavailable : storage not initialised, Exit !!"
		return ""
	}
	pdebug "Storage management : storage.isavailable : look for stream eq. to ($car_id,$nickname)"
	set stream [ storage.stream_search $car_id $nickname ]
	if { $stream != "" } {
		if { [ available.search $stream ] } {
			pdebug "Storage management : storage.isavailable : stream with car_id eq. to $car_id and nickname eq. to $nickname found"
			return $stream
		}
	}
	pdebug "Storage management : storage.isavailable : stream with car_id eq. to $car_id and nickname eq. to $nickname NOT found"
	return ""
}

## storage.available $s : add the stream $s in the available list if not already present and returnn true(1), false(0) else
proc storage.available { stream } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.available : storage not initialised, Exit !!"
		return 0
	}
	if { ![ storage.stream.isavailable $stream ] } {
		# test if $stream is really an object
		if { [ find objects -class stream  $stream ] != "" } {
			available.add $stream
			pdebug "Storage management : storage.available : stream $stream add to the available list (true)"
			return 1
		} else {
			pdebug "Storage management : storage.available : stream $stream is not an object, Exit (false)"
			return 0
		}
	} else {
		pdebug "Storage management : storage.available : stream $stream already present in the available list (false)"
		return 0
	}
}

## storage.unavailable $s	: remove stream $s from the available list if it is present and return true(1) or false(0)
proc storage.unavailable { stream } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.unavailable : storage not initialised, Exit !!"
		return
	}
	if { [ storage.stream.isavailable $stream ] } {
		pdebug "Storage management : storage.unavailable : stream $stream found, remove it"
		available.remove $stream
		return 1
	} else {
		pdebug "Storage management : storage.unavailable : stream $stream not found"
		return 0
	}
}

# subscribed list functions
# --------------------------

## storage.stream.isforwarded $s    : return true(1) if stream is in the forwarded list, false(0) else
proc storage.stream.isforwarded { stream } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.stream.isforwarded : storage not initialised, Exit !!"
		return 0
	}
	if { [ forwarded.search $stream ] } {
		pdebug "Storage management : storage.stream.isforwarded : stream $stream found in the forwarded list (true)"
		return 1
	} else {
		pdebug "Storage management : storage.stream.isforwarded : stream $stream not found in the forwarded list (false)"
		return 0
	}
}

## storage.isforwarded car_id nickname	: search if the stream ($car_id,$nickname) exist in the forwarded list (and return it)
proc storage.isforwarded { car_id nickname } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.isforwarded : storage not initialised, Exit !!"
		return ""
	}
	pdebug "Storage management : storage.isforwarded : look for stream eq. to ($car_id,$nickname)"
	set stream [ storage.stream_search $car_id $nickname ]
	if { $stream != "" } {
		if { [ forwarded.search $stream ] } {
			pdebug "Storage management : storage.isforwarded : stream with car_id eq. to $car_id and nickname eq. to $nickname found"
			return $stream
		}
	}
	pdebug "Storage management : storage.isforwarded : stream with car_id eq. to $car_id and nickname eq. to $nickname NOT found"
	return ""
}

## storage.forwarded $s	: add the stream $s in the forwarded list if not already present and returnn true(1), false(0) else
proc storage.forwarded { stream } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.forwarded : storage not initialised, Exit !!"
		return 0
	}
	if { ![ storage.stream.isforwarded $stream ] } {
		# test if $stream is really an object
		if { [ find objects -class stream  $stream ] != "" } {
			forwarded.add $stream
			pdebug "Storage management : storage.forwarded : stream $stream add to the forwarded list (true)"
			return 1
		} else {
			pdebug "Storage management : storage.forwarded : stream $stream is not an object, Exit (false)"
			return 0
		}
	} else {
		pdebug "Storage management : storage.forwarded : stream $stream already present in the forwarded list (false)"
		return 0
	}
}


## storage.unforwarded $s	remove stream $s from the subscribed list if it is present and return true(1) or false(0)
proc storage.unforwarded { stream } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.unforwarded : storage not initialised, Exit !!"
		return
	}
	if { [ storage.stream.isforwarded $stream ] } {
		pdebug "Storage management : storage.unforwarded : stream $stream found, remove it"
		forwarded.remove $stream
		return 1
	} else {
		pdebug "Storage management : storage.unforwarded : stream $stream not found"
		return 0
	}
}

# subscribed list functions
# --------------------------

## storage.stream.issubscribed $s    : return true(1) if stream is in the subscribed list, false(0) else
proc storage.stream.issubscribed { stream } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.stream.issubscribed : storage not initialised, Exit !!"
		return 0
	}
	if { [ subscribed.search $stream ] } {
		pdebug "Storage management : storage.stream.issubscribed : stream $stream found in the subscribed list (true)"
		return 1
	} else {
		pdebug "Storage management : storage.stream.issubscribed : stream $stream not found in the subscribed list (false)"
		return 0
	}
}

## storage.issubscribed car_id nickname	: search if the stream ($car_id,$nickname) exist in thesubscribed list (and return it)
proc storage.issubscribed { car_id nickname } {	
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.issubscribed : storage not initialised, Exit !!"
		return
	}
	pdebug "Storage management : storage.issubscribed : look for stream eq. to ($car_id,$nickname)"
	set stream [ storage.stream_search $car_id $nickname ]
	if { $stream != "" } {
		if { [ subscribed.search $stream ] } {
			pdebug "Storage management : storage.issubscribed : stream with car_id eq. to $car_id and nickname eq. to $nickname found"
			return $stream
		}
	}
	pdebug "Storage management : storage.issubscribed : stream with car_id eq. to $car_id and nickname eq. to $nickname NOT found"
	return ""
}

## storage.subscribed $s : add the stream $s in the subscribed list if not already present and returnn true(1), false(0) else
proc storage.subscribed { stream } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.subscribed : storage not initialised, Exit !!"
		return 0
	}
	if { ![ storage.stream.issubscribed $stream ] } {
		# test if $stream is really an object
		if { [ find objects -class stream  $stream ] != "" } {
			subscribed.add $stream
			pdebug "Storage management : storage.subscribed : stream $stream add to the subscribed list (true)"
			return 1
		} else {
			pdebug "Storage management : storage.subscribed : stream $stream is not an object, Exit (false)"
			return 0
		}
	} else {
		pdebug "Storage management : storage.subscribed : stream $stream already present in the subscribed list (false)"
		return 0
	}
}

## storage.unsubscribed $s	: remove stream $s from the subscribed list if it is present and return true(1) or false(0)
proc storage.unsubscribed { stream } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.unsubscribed : storage not initialised, Exit !!"
		return
	}
	if { [ storage.stream.issubscribed $stream ] } {
		pdebug "Storage management : storage.unsubscribed : stream $stream found, remove it"
		subscribed.remove $stream
		return 1
	} else {
		pdebug "Storage management : storage.unsubscribed : stream $stream not found"
		return 0
	}
}

# forgotten list functions
# ------------------------

## storage.stream.isforgotten $s	: return true(1) if stream is in the forgotten list, false(0) else
proc storage.stream.isforgotten { stream } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.stream.isforgotten : storage not initialised, Exit !!"
		return 0
	}
	if { [ forgotten.search $stream ] } {
		pdebug "Storage management : storage.stream.isforgotten : stream $stream found in the forgotten list (true)"
		return 1
	} else {
		pdebug "Storage management : storage.stream.isforgotten : stream $stream not found in the forgotten list (false)"
		return 0
	}
}

## storage.isforgotten $car_id $nickname	: search if the stream ($car_id,$nickname) exist in the forgotten list (and return it)
proc storage.isforgotten { car_id nickname } {	
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.isforgotten : storage not initialised, Exit !!"
		return ""
	}
	pdebug "Storage management : storage.isforgotten : look for stream eq. to ($car_id,$nickname)"
	set stream [ storage.stream_search $car_id $nickname ]
	if { $stream != "" } {
		if { [ forgotten.search $stream ] } {
			pdebug "Storage management : storage.isforgotten : stream with car_id eq. to $car_id and nickname eq. to $nickname found"
			return $stream
		}
	}
	pdebug "Storage management : storage.isforgotten : stream with car_id eq. to $car_id and nickname eq. to $nickname NOT found"
	return ""
}

## storage.forgotten $s	: add the stream $s in the forgotten list if not already present and returnn true(1), false(0) else
proc storage.forgotten { stream } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.forgotten : storage not initialised, Exit !!"
		return 0
	}
	if { ![ storage.stream.isforgotten $stream ] } {
		# test if $stream is really an object
		if { [ find objects -class stream  $stream ] != "" } {
			forgotten.add $stream
			pdebug "Storage management : storage.forgotten : stream $stream add to the forgotten list (true)"
			return 1
		} else {
			pdebug "Storage management : storage.forgotten : stream $stream is not an object, Exit (false)"
			return 0
		}
	} else {
		pdebug "Storage management : storage.forgotten : stream $stream already present in the forgotten list (false)"
		return 0
	}
}

## storage.unforgotten $s	: remove stream $s from the forgotten list if it is present and return true(1) or false(0)
proc storage.unforgotten { stream } {
	if { ![ storage.isinit ] } {
		pdebug "Storage management : storage.unforgotten : storage not initialised, Exit !!"
		return 0
	}
	if { [ storage.stream.isforgotten $stream ] } {
		pdebug "Storage management : storage.unforgotten : stream $stream found, remove it"
		forgotten.remove $stream
		return 1
	} else {
		pdebug "Storage management : storage.unforgotten : stream $stream not found"
		return 0
	}
}

# storage.time_available $s             : returns the time from which this stream is available  
proc storage.time_available { stream } {
	if { [ storage.isinit ] } {
		if { [ storage.istream $stream ] } {
			pdebug "Storage management : storage.time_available : stream $stream exist, time_available is : "
			return [ $stream.time_available ]
		} else {
			 pdebug "Storage management : storage.time_available : stream $stream no found, Exit"
		}
	} else {
		pdebug "Storage management : storage.time_available : storage not initialised, Exit !!"
	}
	return ""
}

# storage.time_available.get $s         : returns the time difference from which this stream is available
proc storage.time_available.get { stream } {
	if { [ storage.isinit ] } {
		if { [ storage.istream $stream ] } {
			pdebug "Storage management : storage.time_available.get : stream $stream exist, time diff. from available is : "
			return [ $stream.time_available_get ]
		} else {
			 pdebug "Storage management : storage.time_available.get : stream $stream no found, Exit"
		}
	} else {
		pdebug "Storage management : storage.time_available.get : storage not initialised, Exit !!"
	}
	return ""
}

# storage.time_available.set $s         : set the time from which this stream is available to now (dont't touch, set at stream creation)
proc storage.time_available.set { stream } {
	if { [ storage.isinit ] } {
		if { [ storage.istream $stream ] } {
			pdebug "Storage management : storage.time_available.set : stream $stream exist, update time_available "
			return [ $stream.time_available_up ]
		} else {
			 pdebug "Storage management : storage.time_available.set : stream $stream no found, Exit"
		}
	} else {
		pdebug "Storage management : storage.time_available.set : storage not initialised, Exit !!"
	}
	return ""
}
# storage.time_lastmsg $s               : returns the time of last mesg of the stream $s (hh:mm:ss)
proc storage.time_lastmsg { stream } {
	if { [ storage.isinit ] } {
		if { [ storage.istream $stream ] } {
			pdebug "Storage management : storage.time_lastmsg : stream $stream exist, time_lastmsg is : "
			return [ $stream.time_lastmsg ]
		} else {
			 pdebug "Storage management : storage.time_lastmsg : stream $stream no found, Exit"
		}
	} else {
		pdebug "Storage management : storage.time_lastmsg : storage not initialised, Exit !!"
	}
	return ""
}

# storage.time_lastmsg.set $s           : update to now the time of the last mesg of the stream $s (run for each new mesg) (hh:mm:ss)
proc storage.time_lastmsg.set { stream } {
	if { [ storage.isinit ] } {
		if { [ storage.istream $stream ] } {
			pdebug "Storage management : storage.time_lastmsg.set : stream $stream exist, update time_lastmsg"
			return [ $stream.time_lastmsg_up ]
		} else {
			 pdebug "Storage management : storage.time_lastmsg.set : stream $stream no found, Exit"
		}
	} else {
		pdebug "Storage management : storage.time_lastmsg.set : storage not initialised, Exit !!"
	}
	return ""
}

# storage.time_lastmsg.get $s           : get the time difference from which the stream $s has sent its last mesg
proc storage.time_lastmsg.get { stream } {
	if { [ storage.isinit ] } {
		if { [ storage.istream $stream ] } {
			pdebug "Storage management : storage.time_lastmsg.get : stream $stream exist, time diff. from last msg is : "
			return [ $stream.time_lastmsg_get ]
		} else {
			 pdebug "Storage management : storage.time_lastmsg.get : stream $stream no found, Exit"
		}
	} else {
		pdebug "Storage management : storage.time_lastmsg.get : storage not initialised, Exit !!"
	}
	return ""
}

# storage.time_lasthello $s             : returns the time of last hello of the stream $s (hh:mm:ss)
proc storage.time_lasthello { stream } {
	if { [ storage.isinit ] } {
		if { [ storage.istream $stream ] } {
			pdebug "Storage management : storage.time_lasthello : stream $stream exist, time_lasthello is : "
			return [ $stream.time_lasthello ]
		} else {
			 pdebug "Storage management : storage.time_lasthello : stream $stream no found, Exit"
		}
	} else {
		pdebug "Storage management : storage.time_lasthello : storage not initialised, Exit !!"
	}
	return ""
}

# storage.time_lasthello.set $s         : update to now the time of the last mesg of the stream $s (run for each new hello) (hh:mm:ss)
proc storage.time_lasthello.set { stream } {
	if { [ storage.isinit ] } {
		if { [ storage.istream $stream ] } {
			pdebug "Storage management : storage.time_lasthello.set : stream $stream exist, update time_lasthello"
			return [ $stream.time_lasthello_up ]
		} else {
			 pdebug "Storage management : storage.time_lasthello.set : stream $stream no found, Exit"
		}
	} else {
		pdebug "Storage management : storage.time_lasthello.set : storage not initialised, Exit !!"
	}
	return ""
}

# storage.time_lasthello.get $s         : get the time difference from which the stream $s has sent its last hello (hh:mm:ss)
proc storage.time_lasthello.get { stream } {
	if { [ storage.isinit ] } {
		if { [ storage.istream $stream ] } {
			pdebug "Storage management : storage.time_lasthello.get : stream $stream exist, time diff. from last hello : "
			return [ $stream.time_lasthello_get ]
		} else {
			 pdebug "Storage management : storage.time_lasthello.get : stream $stream no found, Exit"
		}
	} else {
		pdebug "Storage management : storage.time_lasthello.get : storage not initialised, Exit !!"
	}
	return ""
}

# storage.nb_mesg $s                    : get the number of mesg sent by the stream $s
proc storage.nb_mesg { stream } {
	if { [ storage.isinit ] } {
		if { [ storage.istream $stream ] } {
			pdebug "Storage management : storage.nb_mesg : stream $stream exist, nb of mesg sent : "
			return [ $stream.nb_mesg ]
		} else {
			 pdebug "Storage management : storage.nb_mesg : stream $stream no found, Exit"
		}
	} else {
		pdebug "Storage management : storage.nb_mesg : storage not initialised, Exit !!"
	}
	return ""
}

# storage.newmesg $s 					: increment the number of mesg sent by the stream $s
proc storage.newmesg { stream } {
	if { [ storage.isinit ] } {
		if { [ storage.istream $stream ] } {
			pdebug "Storage management : storage.newmesg : stream $stream exist, incr nb of mesg sent"
			return [ $stream.nb_mesg_up ]
		} else {
			 pdebug "Storage management : storage.newmesg : stream $stream no found, Exit"
		}
	} else {
		pdebug "Storage management : storage.newmesg : storage not initialised, Exit !!"
	}
	return ""
}
# -------------------------------------------------------------------------

# ----------------------- Storage Initialisation --------------------------
# This is the top level interface of the system storage so we don't want
# load it several time but we want to able to source several time this file.
if { ![ regexp {list.new} [info commands] ] } {
	pdebug "Storage's management interface initialization"
	source $PATH/storage/storage_list.tcl
	storage_init
}
# -------------------------------------------------------------------------

