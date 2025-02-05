/// @desc Show debug overlay (if debug mode)

if (DEBUG_MODE_ACTIVE) {
	if (keyboard_check(vk_control)) {
		GAMESETTINGS.reset();
		msg_show_ok("Settings reset", "Settings have been reset!");
	} else {
		toggle_debug_view();
	}
}
