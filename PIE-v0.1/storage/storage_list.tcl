# --- storage_list.tcl ---

# Author(s) :
#		Jonathan Roudiere <joe.roudiere@gmail.com>
#
# Copyright : 
#		Copyright (C) 2010 Jonathan Roudiere <joe.roudiere@gmail.com>

# =========================== List API ===========================
#
# Storage system maintain list of streams, here is defined the list structure.
# A list is just a list of stream reference, and that those references which
# are organize between lists (add, delete, remove, ...).
#
# API : List interface
# --------------------
# 
# list_init					: Initialise list's management interface
# list.new $listname		: Create a new list called $listname
# list.exist $listname		: Return true(1) if list exist
# list.delete $listname		: Delete the list called $listname
# list.delete_withcontent $listname		: Delete the list called $listname and its content
# list.nb $listname			: Returne the number of element (stream) of the list $listname 
# list.destroy				: Delete all lists and clean List's interface commands
# list.destroy_whitcontent	: Delete all lists, streams and clean List's interface commands
#
# API : List "objects"
# -------------------- 
#
# $listname					: Return the list (a list object)
# $listname.nb				: Return the number of element (eq.to list.nb $listname)
# $listname.add $e			: Add element $e if not exist in the list
# $listname.show			: Display the list content
# $listname.search $e		: Return true(1) if $e exist in this list, false(0) else
# $listname.remove $e		: Remove $e if it exist in this list
# $listname.destroy			: Delete the list (eq. to list.delete $listname)
# $listname.destroy_withcontent		: Delete the list and its content
# $listname.search.stream $e : Equiv to $listname.search
# $listname.search.stream.bymember $e $v : Return (if exist) the stream for which a memeber $m is equal to $v
# $listname.search.user.bymember $e $v	 : Return (if exist) the stream for which a user member $m is equal to $v
#
# ================================================================

# --------------------------- Requirement --------------------------------
package require Itcl
namespace import itcl::*

# Provide display functions
source $PATH/core/low_proc.tcl
# --------------------- End : Requirement --------------------------------

# --------------------- User management functions ------------------------
proc list_init {} {
	interp alias {} list.new {} list_new
	interp alias {} list.isempty {} list_isempty
	interp alias {} list.exist {} list_exist
	interp alias {} list.delete {} list_delete 
	interp alias {} list.delete_withcontent {} list_delete_withcontent 
	interp alias {} list.nb {} list_nb
	interp alias {} list.destroy {} list_destroy
	interp alias {} list.destroy_whitcontent {} list_destroy_whitcontent
	if { [ itcl::find classes stre ] == "" } {
		pdebug "List management initialization : load Stream storage interface"
		source $::PATH/storage/storage_stream.tcl
	}
	pdebug "List's management interface initialization : end"
}

# $listname exist (really) if it contain elements 
proc list_exist { listname } {
    if { [ uplevel #0 ::info exists $listname ] } {
        pdebug "List management : list.exist : list $listname exist"
        return 1
    } else {
        pdebug "List management : list.exist : list $listname doesn't exist"
        return 0
    }
}

# $listname has been created if its commands exist (but could be empty)
proc list_created { listname } {
	if { [ string compare [ info commands $listname ] "" ] } {
		pdebug "List management : list_created : list $listname already created"
		return 1
	} else {
		pdebug "List management : list_created : list $listname not created"
		return 0
	}
}

# $listname is created when its commands exist and exist (really) when it 's not empty
proc list_new { listname { sort 0 } } {
	if { ![ list_created $listname ] } {
		interp alias {} $listname {} uplevel #0 return $$listname
		if { $sort == 0 } {
			interp alias {} $listname.add {} list_add $listname
			interp alias {} $listname.sort {} nop
		} else {
			interp alias {} $listname.add {} list_sort_add $listname
			interp alias {} $listname.sort {} list_sort $listname $sort
		}
		interp alias {} $listname.show {} list_show $listname
		interp alias {} $listname.search {} list_search $listname
		interp alias {} $listname.nb {} list_nb $listname
		interp alias {} $listname.remove {} list_remove $listname
		interp alias {} $listname.isempty {} list_isempty $listname
		# signifie delete un element  ?? interp alias {} $listname.delete {} list_delete $listname
		interp alias {} $listname.destroy {} list_delete $listname
		interp alias {} $listname.destroy_withcontent {} list_delete_withcontent $listname
		interp alias {} $listname.search.stream {} list_search_stream $listname
		interp alias {} $listname.search.stream.bymember {} list_search_stream_bymember $listname
		interp alias {} $listname.search.user.bymember {} list_search_user_bymember $listname
		pdebug "List management : list.new : list $listname created"
	} else {
		pdebug "List management : list.new : list $listname already exist, Exit (0)!!"
		return 0
	}
}

# delete the list called $listname
proc list_delete { listname } {
	if { [ list_created $listname ] } {
		pdebug "List management : list.delete : list $listname deleted (cmds)"
		# and if list contain elements then destroy it
		if { [ list_exist $listname ] } {
			uplevel #0 unset $listname
			pdebug "List management : list.delete : list $listname deleted (value)"
		}
		# start with alias destruction 
		interp alias {} $listname {}
		interp alias {} $listname.nb {}
		interp alias {} $listname.add {}
		interp alias {} $listname.sort {}
		interp alias {} $listname.show {}
		interp alias {} $listname.search {}
		interp alias {} $listname.remove {}
		interp alias {} $listname.isempty {}
#		interp alias {} $listname.delete {}
		interp alias {} $listname.destroy {}
		interp alias {} $listname.destroy_withcontent {}
		interp alias {} $listname.search.stream {}
		interp alias {} $listname.search.stream.bymember {}
		interp alias {} $listname.search.user.bymember {}
		pdebug "List management : list.delete : list $listname deleted OK"
		return 1
	} else {
		pdebug "List management : list.delete : list $listname not found"
		return 0
	}
}

# delete the list called $listname and its content
proc list_delete_withcontent { listname } {
	if { [ list_created $listname ] } {
		pdebug "List management : list.delete : list $listname deleted (cmds)"
		# and if list contain elements then destroy it
		if { [ list_exist $listname ] } {
			foreach item [ $listname.show ] {
				pdebug "List management : list.delete : destroy stream $item"
				$item.destroy
			}
			uplevel #0 unset $listname
			pdebug "List management : list.delete : list $listname deleted (value)"
		}
		# start with alias destruction 
		interp alias {} $listname {}
		interp alias {} $listname.nb {}
		interp alias {} $listname.add {}
		interp alias {} $listname.show {}
		interp alias {} $listname.search {}
		interp alias {} $listname.remove {}
		interp alias {} $listname.isempty {}
#		interp alias {} $listname.delete {}
		interp alias {} $listname.destroy {}
		interp alias {} $listname.destroy_withcontent {}
		interp alias {} $listname.search.stream {}
		interp alias {} $listname.search.stream.bymember {}
		interp alias {} $listname.search.user.bymember {}
		pdebug "List management : list.delete : list $listname deleted OK"
		return 1
	} else {
		pdebug "List management : list.delete : list $listname not found"
		return 0
	}
}

# return the number of element of the list called $listname
proc list_nb { listname } {
	if { [ list_created $listname ] } {
		pdebug "List management : list.nb : list $listname found"
		if { [ list_exist $listname ] } {
			pdebug "List management : list.nb : list $listname is not empty"
			return [ uplevel #0 llength $$listname ]
		}
		pdebug "List management : list.nb : list $listname is empty"
		return 0
	} else {
		pdebug "List management : list.nb : list $listname not found, Exit"
		return 0
	}
}

proc list_isempty { listname } {
	if { [ list_nb $listname ] == 0 } {
		pdebug "List management : list.isempty : list $listname is empty"
		return 1
	}
	pdebug "List management : list.isempty : list $listname is not empty"
	return 0
}

# destroy all lists and list interface management (list.* cmds)
proc list_destroy {} {
	if { [ string compare [ info commands list.new ] "" ] } {
		interp alias {} list.new {}
		interp alias {} list.isempty {}
		interp alias {} list.exist {}
		interp alias {} list.delete {}
		interp alias {} list.delete_withcontent {}
		interp alias {} list.nb {}
		interp alias {} list.destroy {}
		interp alias {} list.destroy_whitcontent {} 
		# O(n) is likely not the better solution but I can't other now
		foreach cmd [ info commands ] {
			# each list has a command like $listname.search.user.bymember
			if { [regexp {\.search\.user\.bymember} $cmd ] } {
				regsub {(\.search\.user\.bymember)$} $cmd "" cmd
				list_delete $cmd
			}
		}
		pdebug "List's management interface destroyed (and all lists)"
	} else {
		pdebug "List's management interface is not initialised, so I can't destroy it (neither any lists)"
		return 0
	}
}

# destroy all lists AND CONTAINED STREAMs and list interface management (list.* cmds)
proc list_destroy_whitcontent {} {
	if { [ string compare [ info commands list.new ] "" ] } {
		interp alias {} list.new {}
		interp alias {} list.isempty {}
		interp alias {} list.exist {}
		interp alias {} list.delete {}
		interp alias {} list.nb {}
		interp alias {} list.destroy {}
		interp alias {} list.destroy_whitcontent {} 
		# O(n) is likely not the better solution but I don't know other
		foreach cmd [ info commands ] {
			# each list has a command like $listname.search.user.bymember
			if { [regexp {\.search\.user\.bymember} $cmd ] } {
				regsub {(\.search\.user\.bymember)$} $cmd "" cmd
				foreach stream [ $cmd.show ] {
					$stream.destroy
				}
				list_delete $cmd
			}
		}
		pdebug "List's management interface destroyed (and all lists)"
	} else {
		pdebug "List's management interface is not initialised, so I can't destroy it (neither any lists)"
		return 0
	}
}

# ---------------- End : List management functions -----------------------

## ----------------- List interface initialisation ------------------------
## Init : clean existing objects
if { [ regexp {list.new} [info commands] ] } {
	pdebug "List's management interface initialization"
	list_destroy_whitcontent
}
list_init
# -------------- End : List interface initialisation ---------------------


# --------------------- List "Object" manipulation ---------------------------

# lremove not exist in tcl and we need it so ...
proc lremove { listname val } {
	upvar #0 $listname l
	set l [ lsearch -all -inline -not -exact $l $val ]
}

proc list_search { listname val } {
	if { [ list_created $listname ] } {
		if { [ list_exist $listname ] } {
			upvar #0 $listname l
			if { [ string compare [ lsearch -all -inline -exact $l $val ] "" ] } {
				pdebug "List object : $listname.search : element $val found" 
				return 1
			}
			pdebug "List object : $listname.search : $val not found, Exit(0)!!"
		} ;# else list is empty
		return 0
	} else {
		pdebug "List object : $listname.search : list $listname not found, Exit(0)!!"
		return 0
	}
}

proc list_add { listname val } {
	# if empty value
	if { ! [ string compare $val "" ] } {
		pdebug "List object : $listname.add : empty value, Exit (0)!!"
		return 0
	}
	# if list already exist
	if { [ list_created $listname ] } {
		if { [ list_search $listname $val ] } {
			pdebug "List object : $listname.add : element $val already exist, Exit(0)!!"
			return 0
		}
		pdebug "List object : $listname.add : add value $val"
		uplevel #0 lappend $listname $val
		return 1
	} else {
		pdebug "List object : $listname.add : list $listname not found, Exit(0)!!"
		return 0
	}
}

proc list_remove { listname val } {
	if { [ list_created $listname ] } {
		if { [ list_exist $listname ] } {
			upvar #0 $listname l
			if { [ string compare [ lsearch -all -inline -exact $l $val ] "" ] } {
				pdebug "List object : $listname.remove : element $val found and remove" 
				lremove $listname $val
			} else {
				pdebug "List object : $listname.remove : element $val not found" 
			}
		} ;# else list is empty
	} else {
		pdebug "List object : $listname.remove : list $listname not found, Exit(0)!!"
		return 0
	}
}

proc list_show { listname } {
	if { [ list_created $listname ] } {
		if { [ list_exist $listname ] } {
			puts [ $listname ]
		} ;# else list is empty
	} else {
		pdebug "List object : $listname.show : list $listname not found, Exit(0)!!"
		return 0
	}
}

# just a call to an existing function ;)
proc list_search_stream { listname val } {
	return [ list_search $listname $val ]
}

# must return the stream name 
proc list_search_stream_bymember { listname member val } {
	# list must exist
	if { [ list_created $listname ] } { 
		# and not be empty
		if { ![ list_isempty $listname ] } {
			# member must be a valid member for stream object
			# WARNING list must contain stream object 
			catch { set ones [ lindex [ find object -class stream ] 0 ] } ERROR
			if { ![ regexp "::$member " [ $ones info variable] ] } {
        		pdebug "List object : $listname.search.stream.bymember : stream member $member not found, Exit (0)!!"
		        return 0
    		}
			# search for every stream member equal to $val
			set ret [ list ]
			foreach stream [ $listname.show ] {
				if { ![ string compare [ $stream.$member ] $val ] } {
                	pdebug "List object : $listname.search.stream.bymember : object $stream has $member eq. to $val"
                	lappend ret $stream
            	}
			}
			return $ret
		}
		pdebug "List object : $listname.search.stream.bymember : list $listname is empty, Exit(0)!!"
		return 0
	} else {
		pdebug "List object : $listname.search.stream.bymember : list $listname not found, Exit(0)!!"
		return 0
	}
}

# must return the stream name 
proc list_search_user_bymember { listname member val } {
	# list must exist
	if { [ list_created $listname ] } { 
		# and not be empty
		if { ![ list_isempty $listname ] } {
			# member must be a valid member for user object
			# WARNING list must contain user object
			catch { set ones [ lindex [ find object -class user ] 0 ] } ERROR
			if { ![ regexp "::$member " [ $ones info variable] ] } {
        		pdebug "List object : $listname.search.user.bymember : user member $member not found, Exit (0)!!"
		        return 0
    		}
			# search for every stream member equal to $val
			set ret [ list ]
			foreach stream [ $listname.show ] {
				if { ![ string compare [ $stream.user.$member ] $val ] } {
                	pdebug "List object : $listname.search.user.bymember : object $stream.user has $member eq. to $val"
                	lappend ret $stream
            	}
			}
			return $ret
		}
		pdebug "List object : $listname.search.user.bymember : list $listname is empty, Exit(0)!!"
		return 0
	} else {
		pdebug "List object : $listname.search.user.bymember : list $listname not found, Exit(0)!!"
		return 0
	}
}

# ------------------ End List Object manipulation ------------------------


proc list_sort_add { listname val } {
	if {[list_add $listname $val] == 1} {
		$listname.sort
		return 1
	}
	else {
		return 0
	}
}

proc list_sort {listname sort} {
	upvar #0 $listname l
	set l [ lsort -decreasing -command $sort $l ]
}


