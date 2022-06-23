/// @description Show debug overlay (if debug mode)

if (DEBUG_MODE_ACTIVE) {
	global.__DEBUG_SHOWN = !global.__DEBUG_SHOWN;
	show_debug_overlay(global.__DEBUG_SHOWN);
}
