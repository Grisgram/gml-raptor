/// @desc Show debug overlay (if debug mode)

if (DEBUG_MODE_ACTIVE) {
	if (keyboard_check(vk_control)) {
		GAMESETTINGS.reset();
		msg_show_ok("Settings reset", "Settings have been reset!");
	} else {
		global.__debug_shown = !global.__debug_shown;
		show_debug_overlay(global.__debug_shown);
		if (global.__debug_shown) onDebugViewStarted(); else onDebugViewClosed();
	}
}
