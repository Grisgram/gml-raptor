// Control the debug mode of the game

#macro DEBUG_MODE_ACTIVE			true
#macro release:DEBUG_MODE_ACTIVE	false

#macro DEBUG_MODE_WINDOW_WIDTH	global.__DEBUG_MODE_WINDOW_WIDTH
#macro DEBUG_MODE_WINDOW_HEIGHT	global.__DEBUG_MODE_WINDOW_HEIGHT

#macro DEBUG_SHOW_OBJECT_FRAMES	global.__DEBUG_SHOW_OBJECT_FRAMES
#macro DEBUG_LOG_LIST_POOLS		global.__DEBUG_LOG_LIST_POOLS
#macro DEBUG_LOG_STATEMACHINE	global.__DEBUG_LOG_STATEMACHINE
#macro DEBUG_LOG_PARTICLES		global.__DEBUG_LOG_PARTICLES
#macro DEBUG_LOG_RACE			global.__DEBUG_LOG_RACE

DEBUG_SHOW_OBJECT_FRAMES	= false;
DEBUG_LOG_LIST_POOLS		= true;
DEBUG_LOG_STATEMACHINE		= true;
DEBUG_LOG_RACE				= true;
DEBUG_LOG_PARTICLES			= true;

DEBUG_MODE_WINDOW_WIDTH		= 1280;
DEBUG_MODE_WINDOW_HEIGHT	= 720;

global.__DEBUG_SHOWN		= false;
global.__DEBUG_CHECK_DONE	= false;

function check_debug_mode() {
	if (DEBUG_MODE_ACTIVE && !global.__DEBUG_CHECK_DONE) {
		global.__DEBUG_CHECK_DONE = true;
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

