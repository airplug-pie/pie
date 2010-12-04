# --- low_proc.tcl ---

# Author(s) :
#       Jonathan Roudiere <joe.roudiere@gmail.com>
#
# Copyright : 
#       Copyright (C) 2010 Jonathan Roudiere <joe.roudiere@gmail.com>
#

# TODO :
# - put debug to 0 after development (see ##DEBUG_DEVEL##)
# - put init in another place

set debug_mode 0

proc getargs {} {
	pstr "Start application : $::argv0 : getargs()"
	if { [ regexp {\-\-debug} $::argv ] } {
		uplevel #0 set debug_mode 1
		pstr "Debug activated"
	} else {
		pstr "Debug is not activated"
	}
	# look for another arguments here (if need)
}

proc pstr { str } {
    puts "$::argv0 : $str"
}

proc pdebug { str } {
    if {$::debug_mode == 1} {
        puts "$::argv0 : DEBUG : $str"
    }
}


# ---------------------------- Init ------------------------------
#
# Call getargs function :
getargs

# ##DEBUG_DEVEL##
set debug_mode 1
