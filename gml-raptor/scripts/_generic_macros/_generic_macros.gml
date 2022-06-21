/*
	Utility macros that make life a bit easier.
	
	(c)2022 Mike Barthold, indievidualgames, aka @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

/// this macro ends the game if the platform supports it
#macro EXIT_GAME	if (os_type == os_windows || os_type == os_android || os_type == os_macosx || os_type == os_linux) game_end();

// detect if running the html5 target
#macro IS_HTML		(os_browser != browser_not_a_browser)

// detect if the scribble library is loaded
#macro IS_SCRIBBLE_LOADED	script_exists(asset_get_index("scribble"))
#macro SCRIBBLE_COLORS		global.__scribble_colours

/// better human readable version of this instance's name (for logging mostly)
#macro MY_NAME object_get_name(object_index) + "(" + string(id) + ")"

/// shorter to write debug output
#macro log	show_debug_message
#macro logd var __log__d_=function(){var line="***VALUE DUMP***";for(var i=0;i<argument_count;i++)line+="|"+string(argument[i]);show_debug_message(line);}__log__d_

// HTMLBUG - DECLARED IN GAMECONTROLLER.onCreate!!
//#macro SECONDS_TO_FRAMES		* room_speed
//#macro FRAMES_TO_SECONDS		/ room_speed

