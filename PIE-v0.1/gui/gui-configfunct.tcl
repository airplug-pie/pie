# --- gui-configfunct.tcl ---

# Author(s) :
#		Jonathan Roudiere <joe.roudiere@gmail.com>
#
# Copyright : 
#		Copyright (C) 2010 Jonathan Roudiere <joe.roudiere@gmail.com>
#

# What include or source, How all that works ??
#       ==> see README.API in order to obtain more information

# =========================================================================

# --------------------------- Requirement --------------------------------
package require BWidget
package require Tk 
package require Itcl
namespace import itcl::*
# ------------------------ End : Requirement -----------------------------

# ------------------------ Config management -----------------------------

# Global config variables
#	default_user
#	pie_mode
#	show_current_conf_tab
#	show_global_conf_tab
#	show_nettraces_tab
#	show_pietraces_tab
#	show_outputs_tab
#	show_inputs_tab
#	show_forwarded_tab
#	show_subscribed_tab
#	show_localmesg_tab

# User config variables
#	nickname
#	car_id
#	fullname
#	firstname
#	age
#	sex
#	email
#	phone_nb
#	dest
#	desc

proc gui_isconfdir {} {
	global gui
	if { [file exists $gui(configdir)] } {
		if { ![file isdirectory $gui(configdir)] } {
			gui_exit_on_error "gui_is_configdir" "$gui(configdir) is not a directory !!"
			gui_apps_traces "gui_is_configdir : $gui(configdir) is not a directory !!"
			set gui(configdir_exist) -1
			return 0
		}

		# else look in dir and search global/user config
		set gui(configdir_exist) 1
		set files [glob "$gui(configdir)/*.conf"]

		gui_apps_traces "gui_isconfdir : configuration direcotry ($gui(configdir)) found"
		# Look for global.conf
		if { [lsearch $files $gui(globalconffile)] >= 0} {
			set gui(globalconffile_exist) 1
			gui_apps_traces "gui_isconfdir : configuration file ($gui(globalconffile)) found"
		} else {
			set gui(globalconffile_exist) 0
			gui_apps_traces "gui_isconfdir : configuration file ($gui(globalconffile)) not found"
		}

		# Look for user config, add it in list if several
		set yep 0
		set gui(username_conffile) [list]

		foreach f $files {
			if { "$f" != "$gui(globalconffile)" } {
			;# then that is a user configuration (I hope)
				lappend gui(username_conffile) $f
				gui_apps_traces "gui_isconfdir : profile configuration file found : $f"
				set n [regsub "$gui(configdir)/" $f ""]
				set n [regsub ".conf" $n ""]
				lappend gui(usernames) $n
				unset n
				incr yep 1
			}
		}

		# if ok
		if {$yep > 0} {
			set gui(userconf_exist)	1
		} else {
			set gui(userconf_exist) 0
		}

		return 1
	} else {
		set gui(configdir_exist) 0
		return 0
	}
}

proc gui_readconf_global {} {
	global gui
	set f [open "$gui(globalconffile)" r]
	while {[gets $f line] > -1} {
		if {$line != "" && ![ regexp {#} $line ] } {
		#puts $line
		set line [split $line =]
		set gui([lindex $line 0]) [lindex $line 1]
		}
	}
	gui_apps_traces "gui_readconf_global : read global config and update to \"false\" undefined items"
	foreach v [list default_user pie_mode show_current_conf_tab show_global_conf_tab show_nettraces_tab \
		show_pietraces_tab show_outputs_tab show_inputs_tab show_forwarded_tab show_subscribed_tab \
		show_localmesg_tab ] {
		if { [info vars $gui($v)] == "" } {
			set $gui($v) false
		}
	}
}

proc gui_readconf_user {} {
	global gui
	set f [open "$gui(username_conffile)" r]
	while {[gets $f line] > -1} {
		if {$line != "" && ![ regexp {#} $line ] } {
		#puts $line
		set line [split $line =]
		set gui([lindex $line 0]) [lindex $line 1]
		}
	}
	gui_apps_traces "gui_readconf_user : read profile configuration file"
	foreach v [list fullname firstname age sex email phone_nb dest desc ] {
		if { [info vars $gui($v)] == "" } {
			set $gui($v) false
		}
	}
	if { [info vars $gui($v)] == "" || [info vars $gui($v)] == "" } {
		gui_exit_on_error "gui_readconf_global" "Error configuration of nickname and car_id is necessary"
		gui_apps_traces "gui_readconf_global : Error configuration of nickname and car_id is necessary"
		return 0
	}
	return 1
}

proc gui_init_globalconfig {} {
	global gui
	global env
	if {$gui(configdir_exist) == 0} {
		file mkdir "$gui(configdir)"		
	}
	gui_apps_traces "gui_init_globalconfig : create (init) global configuration file, all items to false"
	# create file, gui(*) must exist
	set ufile [open "$gui(globalconffile)" w]
	foreach v [list default_user pie_mode show_current_conf_tab show_global_conf_tab show_nettraces_tab \
		show_pietraces_tab show_outputs_tab show_inputs_tab show_forwarded_tab show_subscribed_tab \
		show_localmesg_tab ] {
		set gui($v) "false"
		set line "$v=$gui($v)"
		puts $ufile "$line"
	}
	close $ufile
	return 1
}

proc gui_init_userconfig {} {
	global gui
	global env
	if {$gui(configdir_exist) == 0} {
		file mkdir "$gui(configdir)"		
	}
	gui_apps_traces "gui_init_globalconfig : create (init) user configuration file"
	# create file using variable def by user
	# gui(username) must be define
	set gui(username_conffile) "$gui(configdir)/$gui(username).conf"
	set ufile [open "$gui(username_conffile)" w]
	foreach v [list nickname car_id fullname firstname age sex email phone_nb dest desc ] {
		set line "$v=$gui($v)"
		puts $ufile $line
	}
	close $ufile
	return 1
}

proc gui_ask_user_its_profile_popup_ok {} {
	global gui
	set popup_guard 0
	set OldFocus [focus]
	set popup_ok [ toplevel .popup_ok ]
	wm title .popup_ok "Profile found !!"
	message $popup_ok.msg -aspect 5000 -justify center \
		-text "You have found a configuration file for user : $gui(username)\n\nTo change profile,\nuse menu Preferences -> current profile\nand save a new profile"
	button $popup_ok.exit -text "Close" -command { set popup_guard 1 }
	pack $popup_ok.msg $popup_ok.exit -pady 4
	gui_apps_traces "gui_ask_user_its_profile : popup_ok : inform user that only one profile has been found"
	grab $popup_ok
	focus $popup_ok
	tkwait variable popup_guard
	grab release $popup_ok
	destroy $popup_ok
	focus $OldFocus
}

proc gui_ask_user_its_profile_popup_who {} {
	global gui
	set popup_guard 0
	set OldFocus [focus]
	set popup_who [ toplevel .popup_who ]
	wm title .popup_who "Several profiles found !!"
	message $popup_who.msg -aspect 5000 -justify center \
		-text "You have found several configuration file for user profile\n\nClick on one to use\n\nYou can change later by using menu Preferences -> current profile"
	pack $popup_who.msg -pady 4
	foreach u $gui(usernames) {
		button $popup_who.[string tolower $u] -text "$u" -command "set gui(username) $u; set popup_guard 1"
		pack $popup_who.[string tolower $u] -fill x
	}
	gui_apps_traces "gui_ask_user_its_profile : popup_who : inform user that several profiles have been found, choose one"
	grab $popup_who
	focus $popup_who
	tkwait variable popup_guard
	grab release $popup_who
	destroy $popup_who
	focus $OldFocus
}

proc gui_ask_user_its_profile_popup_notfound {} {
	global gui
	set popup_guard 0
	set OldFocus [focus]
	set popup_notfound [ toplevel .popup_notfound ]
	wm title .popup_notfound "No profiles found !!"
	message $popup_notfound.msg -aspect 5000 -justify center \
		-text "Please define and save your rofile before use PIE"
	pack $popup_notfound.msg -pady 4
	button $popup_notfound.ok -text "Ok" -command { set popup_guard 1 }
	pack $popup_notfound.ok -pady 4
	gui_apps_traces "gui_ask_user_its_profile : popup_notfound : inform user that no profile found, create one"
	grab $popup_notfound
	focus $popup_notfound
	tkwait variable popup_guard
	grab release $popup_notfound
	destroy $popup_notfound
	focus $OldFocus
}

proc gui_ask_user_its_profile { ret } {
	global gui
	if { $ret == ""} {
		gui_exit_on_error "gui_ask_user_its_profile" "Bad args : empty"
		gui_apps_traces "gui_ask_user_its_profile : Bad args : empty"
		return 0
	}
	switch $ret {
		"ok" {
			gui_apps_traces "gui_ask_user_its_profile : no profile found, only one, so use it"
			set gui(username_conffile) "$gui(configdir)/$gui(username).conf"
			gui_ask_user_its_profile_popup_ok
		}
		"who" {
			gui_apps_traces "gui_ask_user_its_profile : no profile found but many, ask who use"
			gui_ask_user_its_profile_popup_who
			set gui(username_conffile) "$gui(configdir)/$gui(username).conf"
		}
		"no_config" {
			gui_apps_traces "gui_ask_user_its_profile : no profile found, so create it"
			gui_ask_user_its_profile_popup_notfound
			foreach v [list nickname car_id fullname firstname age sex email \
				phone_nb dest desc username] {
				set gui($v) "<undefined>"
			}
			set gui(username_conffile)	"$gui(configdir)/nickanme.conf"
			set gui(current) 1
			set gui(wait_user_change_profile) 0
			gui_menucmd_current
		}
	}
}

proc gui_init_config_and_profile {} {
	global gui
	gui_apps_traces "gui_init_config_and_profile : look for configuration file (global and profile)"
	# Look if config directory exist if it exists then look
	# for user and global config else create it, create 
	# default global config and ask user to save its profile
	if { [gui_isconfdir] > 0 } {
		;# read global config if exist
		if { $gui(globalconffile_exist) == 1 } { 
			gui_readconf_global
		} else {
			gui_apps_traces "gui_init_config_and_profile : init globam config"
			;# create it and read it
			gui_init_globalconfig
			gui_readconf_global
		}
		if { [llength $gui(username_conffile)] == 1 } {
			;# ok, we take this profile
			set gui(username) $gui(usernames)
			gui_apps_traces "gui_init_config_and_profile : username profile : $gui(username)"
			gui_ask_user_its_profile "ok"
			;# so read config
			gui_readconf_user
			;# change appli state
			set gui(user_profile_known) 1
		} else {
			if { [llength $gui(username_conffile)] > 0 } {
				;# say what we take
				gui_ask_user_its_profile "who" 
				;# now read config
				gui_readconf_user
				;# change appli state
				set gui(user_profile_known) 1
			}
		}
	}
	# if user profile is again unknown
	if { $gui(user_profile_known) == 0 } {
		gui_apps_traces "gui_init_config_and_profile : neither config files nor directory found, create all"
		;# create default global config file
		gui_init_globalconfig
		;# read it
		gui_readconf_global
		;# ask user to save its config
		gui_ask_user_its_profile "no_config"
		tkwait variable gui(wait_user_change_profile)
		;# read it again (not necessary but prefered to check funct)
		gui_readconf_user
		;# change appli state
		set gui(user_profile_known) 1
	}
}

proc gui_apply_globalconf {} {
	global gui
	gui_apps_traces "gui_apply_globalconf : update gui with user configuration"
	if {$gui(show_current_conf_tab) == "true"} {
		set gui(current) 1
		gui_menucmd_current
	}
	if {$gui(show_global_conf_tab) == "true"} {
		set gui(global) 1
		gui_menucmd_global
	}
	if {$gui(show_nettraces_tab) == "true"} {
		set gui(traces_net) 1
		gui_menucmd_nettraces
	}
	if {$gui(show_pietraces_tab) == "true"} {
		set gui(traces_pie) 1
		gui_menucmd_pietraces
	}
	if {$gui(show_outputs_tab) == "true"} {
		set gui(traces_out) 1
		gui_menucmd_outputs
	}
	if {$gui(show_inputs_tab) == "true"} {
		set gui(traces_in) 1
		gui_menucmd_inputs
	}
	if {$gui(show_forwarded_tab) == "true"} {
		set gui(traces_fw) 1
		gui_menucmd_forward
	}
	if {$gui(show_subscribed_tab) == "true"} {
		set gui(subscribed) 1
		gui_menucmd_subscribed
	}
	if {$gui(show_localmesg_tab) == "true"} {
		set gui(traces_localsend) 1
		gui_menucmd_localsend
	}
	;# change state
	switch $gui(pie_mode) {
		"active" {
			set gui(state_active) 1
			gui_menucmd_active
		}
		"passive" {
			set gui(state_passive) 1
			gui_menucmd_passive
		}
		"scan" {
			set gui(state_scan) 1
			gui_menucmd_scan
		}
		;# default is passive
		default {
			set gui(state_passive) 1
			gui_menucmd_passive
		}
	}
	;# default user ==> NOT IMPLEMENED TODO
}

# doit etre appellé a chaque changement de profile
proc gui_create_user_stream {} {
	global gui
	gui_apps_traces "gui_create_user_stream : create user stream (local user)"
	# creer flux et lui assigner les bonne valeurs !!
	if { [find objects -class stream MainUser] == ""} {
		gui_apps_traces "gui_create_user_stream : create user stream $gui(nickname),$gui(car_id),$gui(fullname),$gui(firstname),$gui(age),$gui(sex),$gui(email),$gui(phone_nb),$gui(dest),$gui(desc)" 
		set gui(MainUser) 			[stream MainUser]
		MainUser.car_id.set			$gui(car_id)
		MainUser.user.nickname.set	$gui(nickname)	
		MainUser.user.fullname.set	$gui(fullname)
		MainUser.user.firstname.set	$gui(firstname)
		MainUser.user.sex.set		$gui(age)
		MainUser.user.age.set		$gui(sex)
		MainUser.user.email.set		$gui(email)
		MainUser.user.phone_nb.set	$gui(phone_nb)
		MainUser.user.dest.set		$gui(dest)
		MainUser.user.desc.set		$gui(desc)
		wm title . "PIE - $gui(nickname)"
	} else {
		gui_apps_traces "gui_create_user_stream : user local user stream ($gui(fullname),$gui(firstname),$gui(age),$gui(sex),$gui(email),$gui(phone_nb),$gui(dest),$gui(desc))"
		MainUser.user.fullname.set	$gui(fullname)
		MainUser.user.firstname.set	$gui(firstname)
		MainUser.user.sex.set		$gui(age)
		MainUser.user.age.set		$gui(sex)
		MainUser.user.email.set		$gui(email)
		MainUser.user.phone_nb.set	$gui(phone_nb)
		MainUser.user.dest.set		$gui(dest)
		MainUser.user.desc.set		$gui(desc)
	}	
	return 1
}

# -----------------------------------------

proc gui_save_profile_global_popup_ok {} {
	global gui
	set popup_guard 0
	set OldFocus [focus]
	set popup_saveokg [ toplevel .popup_saveokg ]
	wm title .popup_saveokg "Configuration save"
	message $popup_saveokg.msg -aspect 5000 -justify center \
		-text "Configuration file : $gui(globalconffile)\n\nsave under $gui(configdir)"
	pack $popup_saveokg.msg -pady 4
	button $popup_saveokg.ok -text "Close" -command { set popup_guard 1 }
	pack $popup_saveokg.ok -pady 4
	gui_apps_traces "gui_save_profile_global : popup_ok : inform user that we save global config"
	grab $popup_saveokg
	focus $popup_saveokg
	tkwait variable popup_guard
	grab release $popup_saveokg
	destroy $popup_saveokg
	focus $OldFocus
}

proc gui_save_profile_user_popup_ok {} {
	global gui
	set popup_guard 0
	set OldFocus [focus]
	set popup_saveok [ toplevel .popup_saveok ]
	wm title .popup_saveok "Configuration save"
	message $popup_saveok.msg -aspect 5000 -justify center \
		-text "Configuration file : $gui(username_conffile)\n\nsave under $gui(configdir)"
	pack $popup_saveok.msg -pady 4
	button $popup_saveok.ok -text "Close" -command { set popup_guard 1 }
	pack $popup_saveok.ok -pady 4
	gui_apps_traces "gui_save_profile_user : popup_ok : inform user that we save his profile"
	grab $popup_saveok
	focus $popup_saveok
	tkwait variable popup_guard
	grab release $popup_saveok
	destroy $popup_saveok
	focus $OldFocus
}

proc gui_save_profile_user_popup_restart {} {
	global gui
	set popup_guard 0
	set OldFocus [focus]
	set popup_saveok [ toplevel .popup_saveok ]
	wm title .popup_saveok "Nickname and/or Car_id has changed !!"
	message $popup_saveok.msg -aspect 5000 -justify center \
		-text "Nickname and/or Car_id has changed\n\nSo you MUST restart Pie in order to apply\n changes (and choose new profile)"
	pack $popup_saveok.msg -pady 4
	button $popup_saveok.ok -text "Close" -command { set popup_guard 1 }
	pack $popup_saveok.ok -pady 4
	gui_apps_traces "gui_save_profile_user : popup_restart : user has changed nickanme/car_id so he must restart PIE"
	grab $popup_saveok
	focus $popup_saveok
	tkwait variable popup_guard
	grab release $popup_saveok
	destroy $popup_saveok
	focus $OldFocus
}

proc gui_save_profile { what } {
	global gui
	gui_apps_traces "gui_save_profile : save configuration"
	switch $what {
		"global" {
			gui_apps_traces "gui_save_profile : save configuration, global case"
			# get value
			set gui(default_user) 			[$gui(tab_globalf.txt.1v)  get 0.0 {1.0 lineend} ]
			set gui(pie_mode)				[$gui(tab_globalf.txt.2v)  get 0.0 {1.0 lineend} ] 
			set gui(show_current_conf_tab)	[$gui(tab_globalf.txt.3v)  get 0.0 {1.0 lineend} ]
			set gui(show_global_conf_tab)	[$gui(tab_globalf.txt.4v)  get 0.0 {1.0 lineend} ]
			set gui(show_nettraces_tab)		[$gui(tab_globalf.txt.5v)  get 0.0 {1.0 lineend} ]
			set gui(show_pietraces_tab)		[$gui(tab_globalf.txt.6v)  get 0.0 {1.0 lineend} ]
			set gui(show_outputs_tab)		[$gui(tab_globalf.txt.7v)  get 0.0 {1.0 lineend} ]
			set gui(show_inputs_tab)		[$gui(tab_globalf.txt.8v)  get 0.0 {1.0 lineend} ]
			set gui(show_forwarded_tab)		[$gui(tab_globalf.txt.9v)  get 0.0 {1.0 lineend} ]
			set gui(show_subscribed_tab)	[$gui(tab_globalf.txt.10v) get 0.0 {1.0 lineend} ]
			set gui(show_localmesg_tab)		[$gui(tab_globalf.txt.11v) get 0.0 {1.0 lineend} ]
			set ufile [open "$gui(globalconffile)" w]
			foreach v [list default_user pie_mode show_current_conf_tab show_global_conf_tab show_nettraces_tab \
				show_pietraces_tab show_outputs_tab show_inputs_tab show_forwarded_tab show_subscribed_tab \
				show_localmesg_tab ] {
				set line "$v=$gui($v)"
				puts $ufile "$line"
			}
			close $ufile
			gui_save_profile_global_popup_ok
			return 1
		}
		"current" {
			gui_apps_traces "gui_save_profile : save configuration, current case (user profile)"
			# get value
			set flag 0
			set nickname			[regsub -all { } [$gui(tab_currentf.txt.1v)  get 0.0 {1.0 lineend} ] ""]
			if { $gui(user_profile_known) != 0} {
				;# if not init time
				if {$gui(nickname) != $nickname} {
					set flag 1
				}
			}
			set gui(nickname)		[regsub -all { } [$gui(tab_currentf.txt.1v)  get 0.0 {1.0 lineend} ] ""]
			set gui(car_id)			[$gui(tab_currentf.txt.2v)  get 0.0 {1.0 lineend} ] 
			set gui(fullname)		[$gui(tab_currentf.txt.3v)  get 0.0 {1.0 lineend} ]
			set gui(firstname)		[$gui(tab_currentf.txt.4v)  get 0.0 {1.0 lineend} ]
			set gui(age)			[$gui(tab_currentf.txt.5v)  get 0.0 {1.0 lineend} ]
			set gui(sex)			[$gui(tab_currentf.txt.6v)  get 0.0 {1.0 lineend} ]
			set gui(email)			[$gui(tab_currentf.txt.7v)  get 0.0 {1.0 lineend} ]
			set gui(phone_nb)		[$gui(tab_currentf.txt.8v)  get 0.0 {1.0 lineend} ]
			set gui(dest)			[$gui(tab_currentf.txt.9v)  get 0.0 {1.0 lineend} ]
			set gui(desc)			[$gui(tab_currentf.txt.10v) get 0.0 {1.0 lineend} ]
			#set gui(userconf_conffile)	[$gui(tab_currentf.txt.11v) get 0.0 {1.0 lineend} ]
			if {$gui(nickname) == "<undefined>" || $gui(car_id) == "<undefined>"} {
				gui_exit_on_error "gui_save_profile" "Nickname and car_id MUST be different to \"<undefined>\""
				gui_apps_traces "gui_save_profile : Nickname and car_id MUST be different to \"<undefined>\""
				return 0
			}
			set gui(username_conffile)		"$gui(configdir)/[regsub -all { } $gui(nickname) ""].conf"
			set ufile [open "$gui(username_conffile)" w]
			foreach v [list nickname car_id fullname firstname age sex email phone_nb dest desc ] {
				set line "$v=$gui($v)"
				puts $ufile "$line"
			}
			close $ufile
			gui_save_profile_user_popup_ok
			# if user change after initialisation
			if {$flag == 1} {
				gui_save_profile_user_popup_restart
				gui_create_user_stream
			}
			# When user save its profile, its release writting ops
			set gui(wait_user_change_profile) 1
			return 1
		}
		default {
			gui_exit_on_error "gui_save_profile" "Bad args : unknown this case"
			gui_apps_traces "gui_save_profile : Bad args : unknown this case"
		}
	}
}

# ------------------------------------------------------------------------

