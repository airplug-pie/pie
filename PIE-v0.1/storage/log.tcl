# --- log.tcl ---

# TODO : should be move in the core directory of PIE.

set debug_mode 1

proc pstr { str } {
    puts "$::argv0 : $str"
}

proc pdebug { str } {
    if {$::debug_mode == 1} {
        puts "$::argv0 : DEBUG : $str"
    }
}
