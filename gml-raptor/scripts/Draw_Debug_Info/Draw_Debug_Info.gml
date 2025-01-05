/*
	Invoked in every end_draw event from the base room controller, if all of these conditions are met:
	
	- The current RoomController object is a child of RoomController and is visible
	- DEBUG_MODE_ACTIVE = true; (activates toggling debug info with the F12 key)
	- global.__debug_shown is true (toggled by the F12 key)
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/
// Feather ignore all in ./*

/// @func	drawDebugInfo()
/// @desc	Use this function to draw anything to the screen each frame.
///			Example: Use draw_text() to print some debug output (if you don't want to use a debug view)
///			NOTE: debug views are supported on windows only! 
///			This function is mainly used to print debug output to HTML/JavaScript/Mobile targets!
function drawDebugInfo() {
	// This is a demo debug output when you press F12 
	// to print the size of the processing queues of the active RoomController
	// in HTML mode only, as windows will open a debug view (see next method below)
	if (IS_HTML) {
		draw_text(16, 160, string_concat(
			"Bindings: ", BINDINGS.size(),
			"\nAnimations: ", ANIMATIONS.size(),
			"\nStatemachines: ", STATEMACHINES.size(),
			$"\nBroadcasts: {BROADCASTER.dump_to_string()}",
			$"\nMouse:\nRM: {MOUSE_X}/{MOUSE_Y}",
			$"\nUI: {GUI_MOUSE_X}/{GUI_MOUSE_Y}",
			//$"\nBC:\n{dump_array(BROADCASTER.receivers, false)}",
		));
	}
}

/// @func	onDebugViewStarted()
/// @desc	Invoked when in Debug mode and the user presses F12
///			Often this method contains a "if (room == ...)" or a switch over the rooms
///			To show/hide specific debug elements for each room
function onDebugViewStarted() {
	var DEBUG_VIEW_WIDTH	= 300;
	var DEBUG_VIEW_HEIGHT	= 274;
	var DEBUG_VIEW_EDGE		= 4;
	
	dlog("Creating 'raptor' debug view");
	global.__raptor_debug_view = dbg_view("raptor", true, DEBUG_VIEW_EDGE, WINDOW_SIZE_Y - DEBUG_VIEW_HEIGHT - DEBUG_VIEW_EDGE, DEBUG_VIEW_WIDTH, DEBUG_VIEW_HEIGHT);
	dbg_section("Object Frames", true);
	var frames = ref_create(global, "__debug_show_object_frames");
	dbg_checkbox(frames, "Show Object Frames");
	dbg_section("ListPools", true);
	dbg_text("Bindings:     "); dbg_same_line(); dbg_text(ref_create(BINDINGS, "__listcount"));
	dbg_text("Animations:   "); dbg_same_line(); dbg_text(ref_create(ANIMATIONS, "__listcount"));
	dbg_text("StateMachines:"); dbg_same_line(); dbg_text(ref_create(STATEMACHINES, "__listcount"));
	dbg_section("Broadcasts", true);
	dbg_text("Receivers:"); dbg_same_line(); dbg_text(ref_create(BROADCASTER, "__receivercount"));
	dbg_text("Sent:     "); dbg_same_line(); dbg_text(ref_create(global, "__raptor_broadcast_uid"));
	dbg_section("Mouse", true);
	dbg_text("World:"); dbg_same_line(); dbg_text(ref_create(global, "__world_mouse_xprevious")); dbg_same_line(); dbg_text("/"); dbg_same_line(); dbg_text(ref_create(global, "__world_mouse_yprevious"));
	dbg_text("UI   :"); dbg_same_line(); dbg_text(ref_create(global, "__gui_mouse_x"));	          dbg_same_line(); dbg_text("/"); dbg_same_line(); dbg_text(ref_create(global, "__gui_mouse_y"));
	
	// Another example: You may modify even the room, when debug view is opened
	//if (room == rmPlay) {
	//	layer_set_visible("DebugMode", true);
	//}
}

/// @func	onDebugViewClosed()
/// @desc	Invoked when in Debug mode and the user presses F12
///			Often this method contains a "if (room == ...)" or a switch over the rooms
///			To show/hide specific debug elements for each room
function onDebugViewClosed() {
	dlog("Deleting 'raptor' debug view");
	dbg_view_delete(global.__raptor_debug_view);
	
	//if (room == rmPlay) {
	//	layer_set_visible("DebugMode", false);
	//}
}

