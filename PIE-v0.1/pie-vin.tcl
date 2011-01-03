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

