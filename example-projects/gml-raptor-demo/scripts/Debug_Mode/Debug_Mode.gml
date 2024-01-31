// Control the debug mode of the game

#macro DEBUG_MODE_ACTIVE				true
#macro beta:DEBUG_MODE_ACTIVE			false
#macro release:DEBUG_MODE_ACTIVE		false

#macro CONFIGURATION_DEV				true
#macro CONFIGURATION_BETA				false
#macro CONFIGURATION_RELEASE			false

#macro beta:CONFIGURATION_DEV			false
#macro beta:CONFIGURATION_BETA			true
#macro beta:CONFIGURATION_RELEASE		false

#macro release:CONFIGURATION_DEV		false
#macro release:CONFIGURATION_BETA		false
#macro release:CONFIGURATION_RELEASE	true

#macro DEBUG_MODE_WINDOW_WIDTH	global.__debug_mode_window_width
#macro DEBUG_MODE_WINDOW_HEIGHT	global.__debug_mode_window_height

#macro DEBUG_SHOW_OBJECT_FRAMES	global.__debug_show_object_frames
#macro DEBUG_LOG_OBJECT_POOLS	global.__debug_log_object_pools
#macro DEBUG_LOG_LIST_POOLS		global.__debug_log_list_pools
#macro DEBUG_LOG_STATEMACHINE	global.__debug_log_statemachine
#macro DEBUG_LOG_PARTICLES		global.__debug_log_particles
#macro DEBUG_LOG_RACE			global.__debug_log_race
#macro DEBUG_LOG_BROADCASTS		global.__debug_log_broadcasts

DEBUG_SHOW_OBJECT_FRAMES	= false;
DEBUG_LOG_BROADCASTS		= true;
DEBUG_LOG_OBJECT_POOLS		= true;
DEBUG_LOG_LIST_POOLS		= true;
DEBUG_LOG_STATEMACHINE		= true;
DEBUG_LOG_RACE				= true;
DEBUG_LOG_PARTICLES			= true;

DEBUG_MODE_WINDOW_WIDTH		= 1280;
DEBUG_MODE_WINDOW_HEIGHT	= 720;

global.__debug_shown		= false;
global.__debug_check_done	= false;

function check_debug_mode() {
	if (DEBUG_MODE_ACTIVE && !global.__debug_check_done) {
		global.__debug_check_done = true;
		if (code_is_compiled())
			show_message(
				"*************************************************\n" +
				"***                                              \n" +
				"***  D E B U G   M O D E   I S   A C T I V E     \n" +
				"***                                              \n" +
				"*************************************************\n");
	}
}

/// @function					assert_debug_if_false(condition, error_message)
/// @description				Launches a messagebox if condition is false
/// @returns {bool}				true, if a message was shown, otherwise false
function assert_debug_if_false(condition, error_message) {
	if (DEBUG_MODE_ACTIVE && !condition) {
		msg_show_ok("Debug error message", error_message);
		return true;
	}
	return false;
}

/// @function					assert_debug_if_true(condition, error_message)
/// @description				Launches a messagebox if condition is true
/// @returns {bool}				true, if a message was shown, otherwise false
function assert_debug_if_true(condition, error_message) {
	if (DEBUG_MODE_ACTIVE && condition) {
		msg_show_ok("Debug error message", error_message);
		return true;
	}
	return false;
}

