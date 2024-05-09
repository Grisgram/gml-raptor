// Control the debug mode of the game

#macro DEBUG_MODE_ACTIVE				true
#macro beta:DEBUG_MODE_ACTIVE			false
#macro release:DEBUG_MODE_ACTIVE		false
gml_release_mode(!DEBUG_MODE_ACTIVE);

#macro CONFIGURATION_DEV				true
#macro CONFIGURATION_BETA				false
#macro CONFIGURATION_RELEASE			false

#macro beta:CONFIGURATION_DEV			false
#macro beta:CONFIGURATION_BETA			true
#macro beta:CONFIGURATION_RELEASE		false

#macro release:CONFIGURATION_DEV		false
#macro release:CONFIGURATION_BETA		false
#macro release:CONFIGURATION_RELEASE	true

#macro CONFIGURATION_NAME				"dev"
#macro beta:CONFIGURATION_NAME			"beta"
#macro release:CONFIGURATION_NAME		"prod"

#macro DEBUG_SHOW_OBJECT_FRAMES	global.__debug_show_object_frames
#macro DEBUG_MODE_WINDOW_WIDTH	global.__debug_mode_window_width
#macro DEBUG_MODE_WINDOW_HEIGHT	global.__debug_mode_window_height

DEBUG_SHOW_OBJECT_FRAMES	= false;
DEBUG_MODE_WINDOW_WIDTH		= 1280;
DEBUG_MODE_WINDOW_HEIGHT	= 720;

global.__debug_shown		= false;
global.__debug_check_done	= false;

function check_debug_mode() {
	if (DEBUG_MODE_ACTIVE && !global.__debug_check_done) {
		global.__debug_check_done = true;
		if (code_is_compiled())
			show_message(string_concat(
				"*************************************************\n",
				"***                                              \n",
				"***  D E B U G   M O D E   I S   A C T I V E     \n",
				"***                                              \n",
				"*************************************************\n"));
	}
}

/// @func					assert_debug_if_false(condition, error_message)
/// @desc				Launches a messagebox if condition is false
/// @returns {bool}				true, if a message was shown, otherwise false
function assert_debug_if_false(condition, error_message) {
	if (DEBUG_MODE_ACTIVE && !condition) {
		msg_show_ok("Debug error message", error_message);
		return true;
	}
	return false;
}

/// @func					assert_debug_if_true(condition, error_message)
/// @desc				Launches a messagebox if condition is true
/// @returns {bool}				true, if a message was shown, otherwise false
function assert_debug_if_true(condition, error_message) {
	if (DEBUG_MODE_ACTIVE && condition) {
		msg_show_ok("Debug error message", error_message);
		return true;
	}
	return false;
}

