#    pie
#    a twitter-like app for airplug
#    authors: Christophe Boudet, Julien Castaigne, Jonathan Roudière,
#             Christophe Roquette, Jérémy Subtil
#    license type: free of charge license for academic and research purpose
#    see license.txt

### MODULE GET INFOS ##########################################################

###############################################################################
# Send a getinfos request for the stream owner
#
# stream : stream subscribed
#
###############################################################################
proc pie_send_getinfos_request { stream } {
	if {$stream != "" } {
		set ttl $::PIE_infos_TTL
		set tts $::PIE_infos_TTS
		set car_id [$stream.car_id]
		set nickname [$stream.user.nickname]
		set date [ clock seconds ]
  		set id [ PIE_gen_post_id $date "$car_id$nickname" ]
  		set msg [ PIE_gen_header $ttl $tts $::PIE_msg_type_infos_request ]
		APG_msg_addmsg msg $::PIE_msg_key_post_id $id
		APG_msg_addmsg msg $::PIE_msg_key_post_date $date
		APG_msg_addmsg msg $::PIE_msg_key_infos_dest_carid $car_id
		APG_msg_addmsg msg $::PIE_msg_key_infos_dest_nick $nickname
		
		PIE_send_what $msg
		PIE_log_send_info_req $msg
	}
}

###############################################################################
# Send a getinfos response
#
###############################################################################
proc pie_send_getinfos_response { } {
	set date [ clock seconds ]
  	set id [ PIE_gen_post_id $date "response" ]

	set email [MainUser.user.email]
	set fullname [MainUser.user.fullname]
	set firstname [MainUser.user.firstname]
	set phone [MainUser.user.phone_nb]
	set age [MainUser.user.age]
	set sex [MainUser.user.sex]
	set desc [MainUser.user.desc]
	set dest [MainUser.user.dest]
	
	set ttl $::PIE_infos_TTL
	set tts $::PIE_infos_TTS
	
	set msg [ PIE_gen_header $ttl $tts $::PIE_msg_type_infos_response ]
	APG_msg_addmsg msg $::PIE_msg_key_post_id $id
	APG_msg_addmsg msg $::PIE_msg_key_post_date $date
	APG_msg_addmsg msg $::PIE_msg_key_infos_mail $email
	APG_msg_addmsg msg $::PIE_msg_key_infos_name $fullname
	APG_msg_addmsg msg $::PIE_msg_key_infos_fname $firstname
	APG_msg_addmsg msg $::PIE_msg_key_infos_phone $phone
	APG_msg_addmsg msg $::PIE_msg_key_infos_age $age
	APG_msg_addmsg msg $::PIE_msg_key_infos_sexe $sex
	APG_msg_addmsg msg $::PIE_msg_key_infos_desc $desc
	APG_msg_addmsg msg $::PIE_msg_key_infos_dest $dest
	PIE_send_what $msg
	PIE_log_send_info_rep $msg
}

###############################################################################
# Process Request
#
# car_id : the car_id of the request
# nick : nickname of the request
# return : True if we send a response False otherwise
###############################################################################
proc pie_infos_process_request { car_id nick } {
	if { [string compare $car_id [MainUser.car_id]] == 0 && [string compare $nick [MainUser.user.nickname]] == 0} {
		pie_send_getinfos_response
		return 1
	}
		return 0
}


###############################################################################
# Process Response
#
# msg : Response message
###############################################################################
proc pie_infos_process_response { msg stream } {
	if { $stream != "" } {
		$stream.user.email.set [APG_msg_splitstr msg $::PIE_msg_key_infos_mail]
		$stream.user.fullname.set [APG_msg_splitstr msg $::PIE_msg_key_infos_name]
		$stream.user.firstname.set [APG_msg_splitstr msg $::PIE_msg_key_infos_fname]
		$stream.user.phone_nb.set [APG_msg_splitstr msg $::PIE_msg_key_infos_phone]
		$stream.user.age.set [APG_msg_splitstr msg $::PIE_msg_key_infos_age]
		$stream.user.sex.set [APG_msg_splitstr msg $::PIE_msg_key_infos_sexe]
		$stream.user.desc.set [APG_msg_splitstr msg $::PIE_msg_key_infos_desc]
		$stream.user.dest.set [APG_msg_splitstr msg $::PIE_msg_key_infos_dest]
		gui_stream_update $stream
	}
}
