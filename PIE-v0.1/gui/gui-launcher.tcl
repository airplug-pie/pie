#!/bin/sh
# the next line restarts using wish \
exec wish8.5 "$0" "$@"

# --- gui-launcher.tcl ---

# Author(s) :
#		Jonathan Roudiere <joe.roudiere@gmail.com>
#
# Copyright : 
#		Copyright (C) 2010 Jonathan Roudiere <joe.roudiere@gmail.com>
#

# =========================================================================

# This script is a simple exemple of how use PIE GUI interface, and to
# show GUI in a real life style. Just run from root directory of the 
# PIE archive : ./gui/gui-launcher.tcl

# --------------------------- Requirement --------------------------------

# Require : wish8.5/tclsh8.5

# use a example configuration
set PIE_configdir	"share/config/pie"

# Load GUI apps
source gui/gui-init.tcl

# --------------------- End : Requirement --------------------------------

# Here Pie is running, we just populate a little the GUI :

# Add some available stream

# Test1
for {set i 0} {$i <= 6} {incr i 1} {
	set st [stream.new]
	$st.user.nickname.set Test$i
	$st.car_id.set 0x2552662$i
	$st.user.sex.set "no sex for test"
	$st.user.fullname.set "Mr.Test$i"
	$st.user.firstname.set "test$i"
	$st.user.email.set "Test$i@pie.org"
	$st.user.dest.set "Paris 7500$i"
	$st.user.desc.set "test$i is a pie lover"
	gui_newavailable $st
}


# don't do that in real life (it's normaly a user action)
# puts "$gui(main.availablef) et $gui(main.subscribedf)"

gui_StreamDrop ".window.frame.stream1" $gui(main.subscribedf)
gui_StreamDrop ".window.frame.stream3" $gui(main.subscribedf)

gui_stream_recvmesg stream1 "hello tu vas ou !!"

for {set i 0} {$i < 25} {incr i 1} {
	gui_stream_recvmesg stream1 "je suis un spammeur ... "
}

gui_newforward stream4
gui_newforward stream5

gui_netmesg "\[normalement il y a ici les header du packet\] je suis un spammeur ... " input
gui_netmesg "\[normalement il y a ici les header du packet\] Moi aussi ... " output

