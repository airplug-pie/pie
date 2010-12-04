# --- storage_user.tcl ---

# Author(s) :
#		Jonathan Roudiere <joe.roudiere@gmail.com>
#
# Copyright : 
#		Copyright (C) 2010 Jonathan Roudiere <joe.roudiere@gmail.com>
#
# Licence : 
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation;  either version 2, or (at your option)
# any later version.
#
# See LICENSE file.


# =============================== User API ===============================
#
# User is primaly defined by two field : "id" and "nickname"
# User Object also provide other standard fields as : id, stream, nickname,
# email, fullname, firstname, phone_nb, age, sex, desc, dest.
#
# API : User interface
# --------------------
#
#	user_init		: initialize some internals (cmd), run after user.cleanall (if file is not sourced)
# 	user.new 		: create a new user and return reference
#	user.list 		: return a list of all available user objects
#	user.nb 		: return the number of current user objects
#	user.destroy	: destroy all user objects
#   user.exist $u   : return true(1) if the user $u exists and false(0) otherwise
#   user.delete $u  : delete the user $u if exist and return true(1), return false(0) otherwise
#	user.cleanall	: destroy all user objects and remove cmds (clean User interface management)
#
# API : user objects
# ------------------
#	$obj.$member			: return the field called $member owned to $obj
#	$obj.$member.set $val	: change the value of the field called $member owned to $obj to $val
#	$obj.all				: return a list of all members field (orderd as presented above) 
#	$obj.nbuser				: return the current number of user objects (eq. to user.nb)
#	$obj.destroy			: delete current user object
#
# ex : user0.id 		: return id of the user0 object
#	   user0.id.set 3 	: modify user0's id field
#
# Developers have to populate object fields, except the id field. Object
# creation initialize others fields with the "<undefined>" value.
#
# ========================================================================


# --------------------------- Requirement --------------------------------
package require Itcl
namespace import itcl::*

# Provide display functions
source $::PATH/core/low_proc.tcl
# --------------------- End : Requirement --------------------------------


# --------------------- User management functions ------------------------
proc user_init {} {
	interp alias {} user.new {} user #auto
	interp alias {} user.list {} itcl::find objects -class user
	interp alias {} user.nb {} eval { llength [ itcl::find objects -class user ] }
	interp alias {} user.destroy {} clean_allusers
	interp alias {} user.exist {} user_exist
	interp alias {} user.delete {} user_delete
	interp alias {} user.cleanall {} user_clean_all
	pdebug "User management initialization"
}

proc user_delete { obj } {
	if { [ lsearch [user.list] $obj ] != -1 } {
		$obj.destroy
		pdebug "user object : $obj found and removed"
	}
	pdebug "user object : $obj not found"
	return -1
}

proc user_exist { obj } {
	if { [ lsearch [user.list] $obj ] != -1 } {
		pdebug "user object : $obj found"
	}
	pdebug "user object : $obj not found"
	return -1
}

proc clean_allusers {} {
	catch { itcl::delete class user } ERROR
	pdebug "User management : remove all user objects"
}

proc user_clean_all {} {
	clean_allusers
	interp alias {} user.new {}
	interp alias {} user.list {}
	interp alias {} user.nb {}
	interp alias {} user.destroy {}
	interp alias {} user.exist {}
	interp alias {} user.delete {}
	interp alias {} user.cleanall {}
	pdebug "User management : clean up user interface (objects/cmds)"
}
# ---------------- End : User management functions -----------------------


# ----------------- User interface initialisation ------------------------
# Init : clean existing objects
if {[string compare [find classes user] "" ]} {
	pdebug "Init User"
	user_clean_all
}
user_init
# -------------- End : User interface initialisation ---------------------


# --------------------- User Object definition ---------------------------
class user {
	# current number of user object
	common nbuser
	# number of user object created
	common sid 0

	public {
		variable id
		variable stream
		variable nickname
		# Some information about user 
		# provide by a special request packet
		variable email
		variable fullname
		variable firstname
		variable phone_nb
		variable age
		variable sex
 		variable desc
		variable dest
	}

	constructor {} {
		incr nbuser
		incr sid
		set id $sid
		# initialize all public variable (exept id)
		foreach member [ $this info variable ] {
			if { ! [regexp {this|nbuser|id} $member] } {
				if { [string compare [ $this cget -$member ] ""] } {
					$this configure -$member "<undefined>"
				}
				# Define alias : getter (like $this.$member) and setter (like $this.$member.set)
				interp alias {} $this.[regsub {::user::} "$member" ""] {} $this cget -$member
				interp alias {} $this.[regsub {::user::} "$member" ""].set {} $this configure -$member
			}
		} ;# end foreach
		# last alias
		interp alias {} $this.id {} $this cget -id
		interp alias {} $this.id.set {} $this configure -id
		interp alias {} $this.nbuser {} $this nbu
		interp alias {} $this.destroy {} itcl::delete object $this
		interp alias {} $this.all {} $this show
		pdebug "User object $this created : id : $id"
	} ;# end constructor


	destructor {
		incr nbuser -1
		# remove alias
		foreach member [ $this info variable ] {
			if { ! [regexp {this|nbuser|sid} $member] } {
				interp alias {} $this.[regsub {::user::} "$member" ""] {}
				interp alias {} $this.[regsub {::user::} "$member" ""].set {}
			}
		}
		interp alias {} $this.nbuser {}
		interp alias {} $this.destroy {}
		interp alias {} $this.all {}
		pdebug "User object $this removed, current nb users object : $nbuser" 
	} ;# end destructor

	method show {} {
		return [list $id $stream $nickname $email $fullname $firstname \
			$phone_nb $age $sex $desc $dest ]
	} ;# end show

	method nbu {} { return $nbuser }
}
# ----------------- End : User Object definition -------------------------

