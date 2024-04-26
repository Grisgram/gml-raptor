/*
	Invoked in every end_draw event from the base room controller, if all of these conditions are met:
	
	- The current RoomController object is a child of RoomController and is visible
	- DEBUG_MODE_ACTIVE = true; (activates toggling debug info with the F12 key)
	- global.__debug_shown is true (toggled by the F12 key)
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

/// @function		drawDebugInfo()
function drawDebugInfo() {
	var knobs = "";
	//if (__SLIDER_IN_FOCUS != undefined)
	//	knobs=$"tiles: {__SLIDER_IN_FOCUS.__tilesize} {__SLIDER_IN_FOCUS.__knob_x} {__SLIDER_IN_FOCUS.__knob_min_x} {__SLIDER_IN_FOCUS.__knob_max_x}";
	// This is a demo debug output when you press F12 to print the size of the processing queues of the active RoomController
	draw_text(16, 160, $"{knobs}\nBindings: {BINDINGS.size()}\nAnimations: {ANIMATIONS.size()}\nStatemachines: {STATEMACHINES.size()}\nMouse:\nRM: {MOUSE_X}/{MOUSE_Y}\nUI: {GUI_MOUSE_X}/{GUI_MOUSE_Y}");
}

/// @function		onDebugViewStarted()
/// @description	Invoked when in Debug mode and the user presses F12
///					Often this method contains a "if (room == ...)" or a switch over the rooms
///					To show/hide specific debug elements for each room
function onDebugViewStarted() {
	//if (room == rmPlay) {
	//	layer_set_visible("DebugMode", true);
	//}
}

/// @function		onDebugViewClosed()
/// @description	Invoked when in Debug mode and the user presses F12
///					Often this method contains a "if (room == ...)" or a switch over the rooms
///					To show/hide specific debug elements for each room
function onDebugViewClosed() {
	//if (room == rmPlay) {
	//	layer_set_visible("DebugMode", false);
	//}
}

