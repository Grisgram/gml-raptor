/*
	Utility macros that make life a bit easier.
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

/// this macro ends the game if the platform supports it
#macro EXIT_GAME	if (os_type == os_windows || os_type == os_android || os_type == os_macosx || os_type == os_linux) game_end();

// detect if running the html5 target
#macro IS_HTML		(browser_not_a_browser != os_browser)

// detect if running on a mobile device - works even for html runtime (mobile browsers)!
#macro IS_MOBILE	(os_type == os_android || os_type == os_ios)

// detect if the scribble library is loaded
#macro IS_SCRIBBLE_LOADED	script_exists(asset_get_index("scribble"))
#macro SCRIBBLE_COLORS		__scribble_config_colours()
#macro SCRIBBLE_REFRESH		scribble_refresh_everything()

// detect if the canvas library is loaded
#macro IS_CANVAS_LOADED		script_exists(asset_get_index("Canvas"))
#macro CANVAS_SCREENSHOT	(IS_CANVAS_LOADED ? CanvasGetAppSurf(true) : undefined)

// detect if the SNAP library is loaded
#macro IS_SNAP_LOADED		script_exists(asset_get_index("SnapToJSON"))

/// better human readable version of this instance's name (for logging mostly)
#macro MY_ID	string(real(id))
#macro MY_NAME	$"{object_get_name(object_index)}({real(id)})@{depth}"

#macro SECONDS_TO_FRAMES		* room_speed
#macro FRAMES_TO_SECONDS		/ room_speed

#macro TODAY_ISO_STR	$"{current_year}-{(string_replace_all(string_format(current_month, 2, 0), " ", "0"))}-{(string_replace_all(string_format(current_day, 2, 0), " ", "0"))}"

// An empty function can be used in various places, like as a disabling override on enter/leave states in the statemachine
#macro EMPTY_FUNC		function(){}

// A simple counting-up unique id system
global.__unique_count_up_id	= 0;
#macro UID		(++global.__unique_count_up_id)
#macro SUID		string(++global.__unique_count_up_id)

// undocumented feature: a sprite-less object counts the frames - gamecontroller likely never has a sprite!
#macro GAMEFRAME	GAMECONTROLLER.image_index

// Comfortable detection whether the current instance has moved
#macro INSTANCE_HAS_MOVED			(x != xprevious || y != yprevious)

// Those macros define all situations that can lead to an invisible element on screen
#macro __LAYER_OR_OBJECT_HIDDEN		(!visible || (layer != -1 && !layer_get_visible(layer)))
#macro __HIDDEN_BEHIND_POPUP		(GUI_POPUP_VISIBLE && depth > GUI_POPUP_MIN_DEPTH)
#macro __GUI_MOUSE_EVENT_LOCK		((self[$ "draw_on_gui"] ?? false) && !gui_mouse.event_redirection_active)
#macro __INSTANCE_IS_ENABLED		(self[$ "is_enabled"] ?? true)
#macro __CONTROL_IS_ENABLED			(!is_child_of(self, RaptorPanel) && __INSTANCE_IS_ENABLED)
#macro __CONTROL_IS_TARGET_MOUSE	(__CONTROL_IS_ENABLED && is_topmost(CTL_MOUSE_X, CTL_MOUSE_Y))
#macro __CONTROL_IS_TARGET_XY		(__CONTROL_IS_ENABLED && is_topmost(x, y))

#macro __INSTANCE_UNREACHABLE		(__LAYER_OR_OBJECT_HIDDEN || __HIDDEN_BEHIND_POPUP)

// All controls skip their events, if this is true
#macro SKIP_EVENT_MOUSE				(__INSTANCE_UNREACHABLE || __GUI_MOUSE_EVENT_LOCK || !__CONTROL_IS_TARGET_MOUSE)
#macro SKIP_EVENT_NO_MOUSE			(__INSTANCE_UNREACHABLE || !__CONTROL_IS_TARGET_XY)
#macro SKIP_EVENT_UNTARGETTED		(__INSTANCE_UNREACHABLE || !__INSTANCE_IS_ENABLED)

// Instead of repeating the same if again and again in each mouse event, just use this macro;
#macro GUI_EVENT_MOUSE				if (SKIP_EVENT_MOUSE) exit;
#macro GUI_EVENT_NO_MOUSE			if (SKIP_EVENT_NO_MOUSE) exit;
#macro GUI_EVENT_UNTARGETTED		if (SKIP_EVENT_UNTARGETTED) exit;

#macro __DUMP_GUI_EVENT_MOUSE		ilog($"unreachable:{__INSTANCE_UNREACHABLE} event_lock:{__GUI_MOUSE_EVENT_LOCK} target:{!__CONTROL_IS_TARGET_MOUSE} enabled:{__CONTROL_IS_ENABLED} topmost={is_topmost(CTL_MOUSE_X, CTL_MOUSE_Y)}");\
									GUI_EVENT_MOUSE;

#macro __DUMP_GUI_EVENT_NO_MOUSE	ilog($"unreachable:{__INSTANCE_UNREACHABLE} target:{!__CONTROL_IS_TARGET_XY}");\
									GUI_EVENT_NO_MOUSE;

#macro __DUMP_GUI_EVENT_UNTARGETTED	ilog($"unreachable:{__INSTANCE_UNREACHABLE} enabled:{!__INSTANCE_IS_ENABLED}");\
									GUI_EVENT_NO_MOUSE;

#macro DEPTH_BOTTOM_MOST			 16000
#macro DEPTH_TOP_MOST				-15998

// Used by the MouseCursor object but must exist always, as the RoomController checks it
#macro MOUSE_CURSOR		global.__mouse_cursor
MOUSE_CURSOR = undefined;

// try/catch/finally support
#macro TRY		try {
#macro CATCH	} catch (__exception) { \
					elog(__exception.message); \
					elog(__exception.longMessage); \
					elog(__exception.script); \
					for (var __st_i = 0; __st_i < array_length(__exception.stacktrace);__st_i++) \
						elog(__exception.stacktrace[@ __st_i]); 
#macro FINALLY	} finally {
#macro ENDTRY   }

// Unit test automation
#macro __RUN_UNIT_TESTS					ilog("Unit tests disabled");
#macro unit_testing:__RUN_UNIT_TESTS	UnitTestAll();game_end();
