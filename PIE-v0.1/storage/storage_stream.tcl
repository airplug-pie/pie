# --- storage_stream.tcl ---

# Author(s) :
#		Jonathan Roudiere <joe.roudiere@gmail.com>
#
# Copyright : 
#		Copyright (C) 2010 Jonathan Roudiere <joe.roudiere@gmail.com>

# =============================== Stream API =============================
#
# A stream is primaly defined by a tuple of three entity stream_id, car_id
# and an user object but time_lastmsg, time_lasthello, time_available, nb_mesg
# are also available. Stream objects allow to acces to all user objects field
# (id, stream, dest, nickname, email, fullname, firstname, phone_nb, age, sex, desc)
#
# API : Stream interface
# ----------------------
#
#	stream_init 			: initialize some internals (cmd), run after stream.cleanall
# 	stream.new				: create a new stream and return reference
#	stream.list 			: return a list of all available stream objects
#	stream.nb 				: return the number of current stream objects
#	stream.destroy			: destroy all stream objects
# 	stream.exist $s			: return true(1) if the stream $s exists and false(0) otherwise
#	stream.delete $s		: delete the stream $s if exist and return true(1), return false(0) otherwise
#	stream.cleanall			: destroy all stream objects and remove cmds (clean Stream interface management)
#
#	stream.search_by_member $m $v : 
#		return list of stream object which have a member call $m with the value equal to $v
#		return nothing (empty list) if there is any stream obects instanciated, -2 if member don't exist
#
#	stream.user.search_by_member $m $v :
#		return list of stream object which have a user memeber call $m with the value equal to $v
#		return nothing (empty list) if there is any stream obects instanciated, -2 if member don't exist
#
#
# API : stream objects
# --------------------
#
# note : stream object member are : 
#	- stream_id, car_id, time_available, time_lastmsg, time_lasthello, nb_mesg, user (an user object)
# 
#	$obj.$member				: return value of the field called $member of the stream object $obj
#	$obj.$member.set $val		: change value of the field called $member of the stream object $obj to $val
#	$obj.all					: return a list of values of all stream's members (and its user object
#								  members, ordered as above for stream members and as below to users members) 
#	$obj.infos					: return a list of values of main stream's members
#								  (order : stream_id car_id user.id user.nickname) 
#	$obj.time_stat				: return a list of values of timestamp and stat fields of the stream $obj
#								  (order : time_available, time_lastmsg, time_lasthello, nb_mesg)
#	$obj.nbstream				: return the current number of stream objects (eq. to stream.nb)
#	$obj.destroy				: delete current stream object
#
# time/stat :
#
#	$obj.time_available_up		: set time_available field to the current time (hh:mm:ss - eq. to $obj.time_available.set hh:mm:ss)
#	$obj.time_lastmsg_up		: set time_lastmsg field to the current time (hh:mm:ss - eq. to $obj.time_available.set hh:mm:ss)
#	$obj.time_lasthello_up		: set time_lasthello field to the current time (hh:mm:ss - eq. to $obj.time_available.set hh:mm:ss)
#	$obj.nb_mesg_up				: increment the number of mesg send by this stream (eq. to [$obj.nb_mesg.set [expr [$obj.nb_mesg] + 1]])
#
#	$obj.time_available_get		: return the time difference between now and time from which the stream $obj is available (hh:mm:ss)
#	$obj.time_lastmsge_get		: return the time difference between now and time from which the stream $obj has send its last mesg (hh:mm:ss)
#	$obj.time_lasthello_get		: return the time difference between now and time from which the stream $obj has send its last hello (hh:mm:ss)
#
# note : user object member are : 
#	- id, nickname, email, fullname, firstname, phone_nb, age, sex, desc, dest
#
#	$obj.user.all				: return a list of values of all $obj's user member (ordered as above)
#	$obj.user.$member 			: allow to get value of any $obj's user field
#	$obj.user.$member.set $v	: allow to change value of any $obj's user field to $v value 
#	$obj.user					: return $obj's user object reference
#
# 
# ex : stream0.user.id 								: return user id of the stream0 object
#	   stream0.user.id.set 3					 	: modify user id of the stream0 object
#	   stream0.car_id								: return car_id of the stream0 object
#	   stream0.car_id.set 15						: modify car_id of the stream0 object
#	   stream.search_by_member car_id w1552 		: return list of stream objects which have their car_id member eq. to "w1552"
#	   stream.user.search_by_member nickname toto 	: return list of stream objects which have their user's nickname field eq. to "toto"
#
#
# Developers have to populate object fields, except the stream_id and user.id
# fields. Object creation initialize others fields with the "<undefined>" value
# for string and current date (format hh:mm:ss) for "numeric" time variable,
# nb_mesg is set to 0.
#
# ========================================================================


# --------------------------- Requirement --------------------------------
package require Itcl
namespace import itcl::*

# Provide display functions
source $::PATH/core/low_proc.tcl

# storage_user.tcl must be loaded after Stream managment interface initialization
# --------------------- End : Requirement --------------------------------

# --------------------- Stream management functions ------------------------
proc stream_init {} {
	interp alias {} stream.new {} stream #auto
	interp alias {} stream.list {} itcl::find objects -class stream
	interp alias {} stream.nb {} eval { llength [ itcl::find objects -class stream ] }
	interp alias {} stream.destroy {} clean_allstream
	interp alias {} stream.exist {} stream_exist
	interp alias {} stream.search_by_member {} search_by_member
	interp alias {} stream.user.search_by_member {} user_search_by_member
	interp alias {} stream.delete {} stream_delete
	interp alias {} stream.cleanall {} stream_clean_all
#	if { ![ regexp "stream" [ find classes ] ] } {
#		define_class
#	}
	pdebug "Stream management initialization"
}

proc stream_delete { obj } {
	if { [ regexp "stream" [ find classes ] ] } {
		if { [ lsearch [stream.list] $obj ] != -1 } {
			$obj.destroy
			pdebug "Stream object : $obj found and removed"
			return 1
		}
		pdebug "Stream object : $obj not found"
		return 0
	} else { return -1 }
}

proc stream_exist { obj } {
	if { [ regexp "stream" [ find classes ] ] } {
		if { [ lsearch [stream.list] $obj ] != -1 } {
			pdebug "Stream object : $obj found"
			return 1
		}
		pdebug "Stream object : $obj not found"
		return 0
	} else { return -1 }
}

proc clean_allstream {} {
	catch { itcl::delete class stream } ERROR
	pdebug "Stream management : remove all stream objects"
}

proc search_by_member { member value } {
	# At least one stream object must exist
	if { [ find object -class stream ] != "" } {
		set ones [ lindex [ find object -class stream ] 0 ]
	} else {
		pdebug "Stream management : search_by_member : any stream object found !!"
		return 
	}
	# At least $member must be a valid member of stream object
	if { [ regexp "::$member " [ $ones info variable] ] } {
		pdebug "Stream management : search_by_member : $member exist"
		# ok, so look for stream for which $member == $value
		set ret [ list ]
		foreach stream [ find object -class stream ] {
			if { ![ string compare [ $stream.$member ] $value ] } {
				pdebug "Stream management : search_by_member : object $stream has $member eq. to $value"
				lappend ret $stream
			}
		}
		pdebug "Stream management : search_by_member : [ llength $ret ] object found" 
		return $ret
	} else {
		pdebug "Stream management : search_by_member : $member not found, Exit (-2)!!"
		return -2
	}
}

proc user_search_by_member { member value } {
	# At least one stream object must exist
	if { [ find object -class stream ] != "" } {
		set ones [ lindex [ find object -class stream ] 0 ]
	} else {
		pdebug "Stream management : user.search_by_member : any stream object found, Exit !!"
		return
	}
	# At least $member must be a valid member of user object
	if { [ regexp "::$member " [ $ones.user info variable] ] } {
		pdebug "Stream management : user.search_by_member user's member : $member exist"
		# ok, so look for stream.user for which $member == $value
		set ret [ list ]
		foreach stream [ find object -class stream ] {
			if { ![ string compare [ $stream.user.$member ] $value ] } {
				pdebug "Stream management : user.search_by_member : object $stream.user has $member eq. to $value"
				lappend ret $stream
			}
		}
		pdebug "Stream management : user.search_by_member : [ llength $ret ] object found" 
		return $ret
	} else {
		pdebug "Stream management : user.search_by_member : $member not found, Exit (-2)!!"
		return -2
	}
}

proc stream_clean_all {} {
	clean_allstream
	interp alias {} stream.new {}
	interp alias {} stream.list {}
	interp alias {} stream.nb {}
	interp alias {} stream.destroy {}
	interp alias {} stream.exist {}
	interp alias {} stream.delete {}
	interp alias {} stream.cleanall {}
	interp alias {} stream.search_by_member {}
	pdebug "Stream management : clean up stream interface (objects/cmds)"
}
# ---------------- End : Stream management functions -----------------------


# ----------------- Stream interface initialisation ------------------------

# Init : clean existing objects
if {[string compare [find classes stream] "" ]} {
	pdebug "Init Stream"
	stream_clean_all
}

# Must be load after Stream clean up
source $::PATH/storage/storage_user.tcl

# Initialize Stream management interface
stream_init

# -------------- End : Stream interface initialisation ---------------------


# --------------------- Stream Object definition ---------------------------
#proc define_class {} {
class stream {
	# current number of stream object
	common nbstream
	# number of stream object created
	common sid 0
	
	common priority_range 40

	public {
		variable stream_id
		variable user
		variable car_id
		variable time_available
		variable time_lastmsg
		variable time_lasthello
		variable nb_mesg
		variable distance
		variable priority
	}

	constructor {} {
		incr nbstream
		incr sid
		# Base config of stream object
		set stream_id $sid
		set user [user #auto]
		set car_id -1
		set priority 0
		set distance 0
		set time_available [ clock format [clock seconds] -format %H:%M:%S ]
		set time_lastmsg [ clock format [clock seconds] -format %H:%M:%S ]
		set time_lasthello [ clock format [clock seconds] -format %H:%M:%S ]
		set nb_mesg 0
		# User objects getters and setters
		foreach member [ list id nickname email fullname firstname phone_nb age sex desc dest stream ] {
			interp alias {} $this.user.$member {} ::stream::[$this cget -user].$member
			interp alias {} $this.user.$member.set {} ::stream::[$this cget -user].$member.set
		}
		interp alias {} $this.user.nbuser {} ::stream::[$this cget -user].nbuser
		interp alias {} $this.user.all {} ::stream::[$this cget -user].all
		# get user object
		interp alias {} $this.user {} ::stream::[$this cget -user]
		# some stream getters and setters
		foreach member [ list stream_id car_id time_available time_lastmsg time_lasthello nb_mesg distance priority] {
			interp alias {} $this.$member {} $this cget -$member
			interp alias {} $this.$member.set {} $this configure -$member
		}
		interp alias {} $this.priority.inc {} $this priority_inc
		interp alias {} $this.priority.dec {} $this priority_dec
			
		interp alias {} $this.nbstream {} $this nbu
		interp alias {} $this.all {} $this show
		interp alias {} $this.infos {} $this stream_info
		interp alias {} $this.time_stat {} $this time_stat
		interp alias {} $this.time_available_get {} $this get_timediff $this.time_available 
		interp alias {} $this.time_lastmsg_get {} $this get_timediff $this.time_lastmsg
		interp alias {} $this.time_lasthello_get {} $this get_timediff $this.time_lasthello
		interp alias {} $this.time_available_up {} $this setclock time_available
		interp alias {} $this.time_lastmsg_up {} $this setclock time_lastmsg
		interp alias {} $this.time_lasthello_up {} $this setclock time_lasthello
		interp alias {} $this.nb_mesg_up {} $this incrmesg
		interp alias {} $this.destroy {} itcl::delete object $this
		pdebug "Stream object $this created : stream_id : $stream_id"
	} ;# end constructor

	destructor {
		incr nbstream -1
		::stream::[$this cget -user].destroy
		# Destroy all stream object accessor
		foreach member [ list id nickname email fullname firstname phone_nb age sex desc dest stream ] {
			interp alias {} $this.user.$member {}
			interp alias {} $this.user.$member.set {} 
		}
		interp alias {} $this.user.nbuser {} 
		interp alias {} $this.user.all {}
		interp alias {} $this.user {}
		foreach member [ list stream_id car_id time_available time_lastmsg time_lasthello nb_mesg distance priority ] {
			interp alias {} $this.$member {}
			interp alias {} $this.$member.set {}
		}
		interp alias {} $this.priority.inc {}
		interp alias {} $this.priority.dec {}
		
		interp alias {} $this.time_available_get {}
		interp alias {} $this.time_lastmsg_get {}
		interp alias {} $this.time_lasthello_get {}
		interp alias {} $this.time_available_up {}
		interp alias {} $this.time_lastmsg_up {}
		interp alias {} $this.time_lasthello_up {}
		interp alias {} $this.nb_mesg_up {}
		interp alias {} $this.nbstream {} 
		interp alias {} $this.all {}
		interp alias {} $this.infos {}
		interp alias {} $this.time_stat {}
		interp alias {} $this.destroy {}
		pdebug "Stream object $this removed, current nb stream object : $nbstream" 
	} ;# end destructor

	method show {} {
		set attr [ list $stream_id $car_id $time_available $time_lastmsg $time_lasthello $nb_mesg $distance $priority]
		foreach i [ $this.user.all ] { lappend attr  $i }
		return $attr
	}

	method stream_info {} {
		return [ list $stream_id $car_id [ $this.user.id ] [ $this.user.nickname ] ]
	}

	method nbu {} { return $nbstream }

	method time_stat {} { return [ list $time_available $time_lastmsg $time_lasthello $nb_mesg ] } 

	method setclock { field } {
		$this.$field.set [ clock format [clock seconds] -format %H:%M:%S ]
	}

	method incrmesg {} {
		incr nb_mesg
	}
	
	method priority_inc {} {
		set that "stream"
		append that $stream_id
		if {[storage.stream.isforgotten $that] } {
			if { ![storage.stream.isavailable $that] } {
				storage.available $that
			}
			storage.unforgotten $that
			if { $priority <= [expr 0 - $priority_range] } {
				set priority 0
			}
			
		}
		if { $priority < $priority_range } {
			incr priority
		}
		foreach listname [storage.stream_list $that] {
			$listname.sort
		}
 	}
 	
 	method priority_dec {} {
 		set that "stream"
		append that $stream_id
 		incr priority -1
 		if { $priority <= [expr 0 - $priority_range] } {
 			storage.forgotten $that
 			storage.unavailable $that
 		}
 		foreach listname [storage.stream_list $that] {
			$listname.sort
		}
 	}
 	
	method get_timediff { field } {
		set d [clock scan [ $field ] ]
		set e [clock scan [ clock format [clock seconds] -format %H:%M:%S ]]
		return "[clock format [expr $e - $d] -gmt 1 -format %H:%M:%S]"
	}
}
# ----------------- End : Stream Object definition -------------------------

proc stream_compare { arg0 arg1 } {
	if {[$arg0.priority] > [$arg1.priority]} {
		return 1
	} elseif { [$arg0.priority] == [$arg1.priority] } {
		return 0
	} else {
		return -1
	}

}

