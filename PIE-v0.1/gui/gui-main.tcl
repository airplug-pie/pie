# --- storage_stream.tcl ---

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
# --------------------- End : Requirement --------------------------------

# -------------- Graphical User Interface : Menu  ------------------------

# Create menu description
set menudesc {
	"&File" all file 0 {
		{command "&Quit"				{} "Close PIE application" 					{Ctrl q} -accelerator "ctl-q" -command APG_int_btend}
	}
	"&Mode" {} {} 0 {
		{checkbutton "&Active"			{} "PIE Active mode"						{Ctrl a} -accelerator "ctl-a" -variable gui(state_active)  -command gui_menucmd_active}
		{checkbutton "&Passive"			{} "PIE Passive mode" 						{Ctrl p} -accelerator "ctl-p" -variable gui(state_passive) -command gui_menucmd_passive}
		{checkbutton "&Scan" 			{} "PIE Scan mode"							{Ctrl s} -accelerator "ctl-s" -variable gui(state_scan)    -command gui_menucmd_scan}
	}
	"&Preferences" all prefs 0 {
		{checkbutton "C&urrent profile"	{} "Configure settings of the current user" {Ctrl u} -accelerator "ctl-u" -variable gui(current) -command gui_menucmd_current}
		{checkbutton "&Global settings"	{} "Configure global settings" 				{Ctrl g} -accelerator "ctl-g" -variable gui(global) -command gui_menucmd_global}
	}
	"&Show" all logs 0 {
		{checkbutton "Subscribed mesg"	{} "Show messages of subscribed streams" 	{Ctrl m} -accelerator "ctl-m" -variable gui(subscribed)  -command gui_menucmd_subscribed}
		{checkbutton "Local mesg send"	{} "Show your messages"						{Ctrl l} -accelerator "ctl-l" -variable gui(traces_localsend) -command gui_menucmd_localsend}
		{separator}
		{checkbutton "Show Net &Traces"	{} "Show all PIE network traces"			{Ctrl n} -accelerator "ctl-n" -variable gui(traces_net)  -command gui_menucmd_nettraces}
		{checkbutton "Show PIE &Traces"	{} "Show all PIE traces (debug)"			{Ctrl d} -accelerator "ctl-d" -variable gui(traces_pie)  -command gui_menucmd_pietraces}
		{separator}
		{checkbutton "Show &Inputs"     {} "Show all messages received"				{Ctrl i} -accelerator "ctl-i" -variable gui(traces_in)   -command gui_menucmd_inputs}
		{checkbutton "Show &Outputs"    {} "Show all messages send and forwarded"	{Ctrl o} -accelerator "ctl-o" -variable gui(traces_out)  -command gui_menucmd_outputs}
		{checkbutton "Show &Forwarded"  {} "Show forwarded streams"					{Ctrl f} -accelerator "ctl-f" -variable gui(traces_fw)   -command gui_menucmd_forward}
	}
	"&Help" all help 0 {
		{command "&Help"				{} "Help of PIE"							{Ctrl h} -accelerator "ctl-h" -command gui_menucmd_help}
		{command "A&bout"				{} "About PIE" 								{Ctrl b} -accelerator "ctl-b" -command gui_menucmd_about}
	}
}
# ------------------------------------------------------------------------

# -------------- Graphical User Interface : Main window ------------------

# ------------- GUI base ------------------

# Version/Slogan/Indicator
set gui(apps_name)			"PIE"
set gui(pie_version)		"1.0"
set gui(pie_slogan)			"Stay connected with PIE"
set gui(pie_indic)			"PIE version: $gui(pie_version)"

## Statistics variable
#set gui(nbmesg_send)		0	;# Number of messages send (hello/txt/forwarded)
#set gui(nbmesg_recv)		0	;# Number of messages received (hello/txt/forwarded)
#set gui(nbhello_send)		0	;# Number of hello send
#set gui(nbhello_recv)		0	;# Number of hello received
#set gui(nbget_send)			0	;# Number of getinfos messages send
#set gui(nbget_recv)			0	;# Number of getinfos messages received
#set gui(nblocalmesg_snd)	0	;# Number of local (from user) messages

# Mainframe (with menu/indicator/....)
set gui(root) 				[MainFrame .window -menu $menudesc -textvariable gui(pie_slogan)]
$gui(root)					addindicator -text $gui(pie_indic)
set gui(mainframe)			[$gui(root) getframe]

# Base of apps window is a Notebook
set gui(nb)					[NoteBook $gui(mainframe).nb]

# -----------------------------------------

# ---------- Main window ------------------

# Main window is a notebook tab which contain a PanedWindow
set gui(main) 				[$gui(nb) insert end main -text "PIE's interface"]
set gui(main.p) 			[PanedWindow $gui(main).p]

# Two pane of the main PanedWindow, on the left there are the
# subscribed streams and text editor (in another PanedWindow),
# on right available streams (in a TitleFrame)
set gui(main.p.l)			[PanedWindow [$gui(main.p) add -weight 5 -minsize 300].l -side left]
set gui(main.p.r)			[TitleFrame  [$gui(main.p) add -weight 3 -minsize 200].r -text "Available streams"]
set gui(main.available) 	$gui(main.p.r)	;# just an alias for naming consistency

# Add two panes (which are TitleFrame) on the left pane, top pane
# will contain "subscribed streams" and bottom pane will contain
# text editor,
set gui(main.subscribed)	[TitleFrame [$gui(main.p.l) add -weight 15 -minsize 400].subscribed -text "Subscribed streams"]
set gui(main.texteditor)	[TitleFrame [$gui(main.p.l) add -weight 2  -minsize 100].texteditor -text "Message Publisher"]

# Get associated frames of the 3 area of "PIE's interface" 
set gui(main.subscribedf)	[$gui(main.subscribed) getframe]
set gui(main.texteditorf)	[$gui(main.texteditor) getframe]
set gui(main.availablef)	[$gui(main.available)  getframe]

# Now build the text editor, it has two main elements a text area
# with a scrollbar (visible when its necessary), and a send button
# - text area allow text selection, copy/paste with 
#   ctrl-c/ctrl-v, undo/redo with ctrl-z and ctrl-y
set gui(editor_area)		[ScrolledWindow $gui(main.texteditorf).editz -auto both -scrollbar vertical]
set gui(text_area)			[text $gui(editor_area).txt -wrap word -width 2 -heigh 5 -bg white -undo yes]
set gui(send_button)		[Button $gui(main.texteditorf).snd -text "Send" -state disable -command gui_send_mesg]

# initialize text area and put in ScrolledWindow
$gui(editor_area)			setwidget $gui(text_area)

# ---------------------------- Drag and drop zone/action

bind $gui(main.subscribed) 	<<gui_StreamDrop>> [list gui_StreamDrop %d]
bind $gui(main.available)	<<gui_StreamDrop>> [list gui_StreamDrop %d]
bind DropTarget				<<gui_StreamDrop>> [list gui_StreamDrop %d %W]

bindtags $gui(main.subscribedf) [linsert [bindtags $gui(main.subscribedf)] 1 DropTarget]
bindtags $gui(main.availablef) 	[linsert [bindtags $gui(main.availablef)] 1 DropTarget]
bind DropSource <ButtonPress>   [list gui_pressOnStream   %W]
bind DropSource <ButtonRelease> [list gui_StreamRelease %W %X %Y %x %y]
bind DropSource <Motion>        [list gui_Motion        %W %X %Y %x %y]

# Sets "active" widget and colors it green.
proc gui_pressOnStream {w} {
    variable active $w
	gui_tab_pietraces "gui_pressOnStream : args $w, set green"
    $w configure -background green
}

# Generates a <<gui_StreamDrop>> event on the underlying widget
# Needs to generate another event first for the NoteBook
# to trigger correctly. In this case we use an <Enter> event. 
# The child will be colored red if an error occurs.
proc gui_StreamRelease {W X Y x y } {
	global gui
	variable active
	gui_tab_pietraces "gui_StreamRelease : agrs : $W $X $Y $x $y  :: [winfo containing $x $y] -> [winfo containing $X $Y]"
	if {[info exists active]} {
		set z [winfo containing $X $Y]
		$W configure -background red
		catch {
			set x [expr {$X - [winfo rootx $gui(main.available)]}]
			set y [expr {$Y - [winfo rooty $gui(main.available)]}]
			#Needs a primary event to allow correct trigger on virtual event.
			event generate $z <Enter> -x $x -y $y
			event generate $z <<gui_StreamDrop>> -x $x -y $y -data $W
			$W configure -background lightgray
		} m o
		if {[dict get $o -code] != 0} {puts stderr $m}
		unset -nocomplain active
	}
}

# Passes <Motion> events to underlying widgets while dragging children.
proc gui_Motion {W X Y x y} {
	catch { set w [winfo containing $X $Y] } errors
	if {$w == ""} {
		gui_tab_pietraces "gui_Motion : drop out of the window"
		return 0
	}
	# too verbose
	#puts "gui_Motion : agrs : $W $X $Y $x $y -> $w"
	if {$w ne $W} {
		set x [expr {$X - [winfo rootx $w]}]
		set y [expr {$Y - [winfo rooty $w]}]
		event generate $w <Motion> -x $x -y $y
	}
}

# Pack in appropriate frame of the notebook
proc gui_StreamDrop {child frame_or_tab} {
	global gui
	gui_tab_pietraces "gui_StreamDrop : $child  ->  $frame_or_tab"
	if { [lsearch [pack slave $frame_or_tab] $child] >= 0} {
		gui_tab_pietraces "gui_StreamDrop : Noting to do drop in same parent : $frame_or_tab contains $child"
	} else {
		;# subscribed or unsubscirbed
		set st [regsub {.window.frame.} $child ""]
		gui_tab_pietraces "gui_StreamDrop : Change state of the stream : $st"
		if { "$frame_or_tab" == "$gui(main.availablef)"} {
			gui_tab_pietraces "gui_StreamDrop : UNSUBSCRIBED to stream $st"
			gui_unsubscrib $st
			if { [llength $gui(subscribed_registered)] == 0 } {
				if {$gui(subscribed) == 1} {
					set gui(subscribed) 0
					gui_menucmd_subscribed
					gui_tab_pietraces "gui_StreamDrop : close subscribed window"
				}
			}
		} else {
			gui_tab_pietraces "gui_StreamDrop : SUBSCRIBED to stream $st"
			if {$gui(subscribed) == 0} {
				set gui(subscribed) 1
				gui_menucmd_subscribed
				gui_tab_pietraces "gui_StreamDrop : open subscribed window"
			}
			gui_subscrib $st
		}
	}
	if {[winfo exists $frame_or_tab]} {
	    pack $child -in $frame_or_tab
	} else {
	    pack $child -in [$gui(main.available) getframe $frame_or_tab]
	}
	raise $child
}
# ---------------------------- Drag and drop zone/action - End
# -----------------------------------------------------------------------------------------------------
