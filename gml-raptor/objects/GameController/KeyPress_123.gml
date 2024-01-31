/// @description Show debug overlay (if debug mode)

if (DEBUG_MODE_ACTIVE) {
	global.__debug_shown = !global.__debug_shown;
	show_debug_overlay(global.__debug_shown);
	if (global.__debug_shown) onDebugViewStarted(); else onDebugViewClosed();
}
