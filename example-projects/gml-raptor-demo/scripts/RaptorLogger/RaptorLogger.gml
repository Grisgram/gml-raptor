/*
    A simple logging subsystem with a RingBuffer and formatted log-output.
*/

#macro __RAPTOR_LOGGER		global.__raptor_logger
__RAPTOR_LOGGER = new RaptorLogger();

#macro ENSURE_LOGGER		if (!variable_global_exists("__raptor_logger"))	global.__raptor_logger = new RaptorLogger();

#macro vlog	__RAPTOR_LOGGER.log_verbose
#macro dlog	__RAPTOR_LOGGER.log_debug
#macro ilog	__RAPTOR_LOGGER.log_info
#macro wlog	__RAPTOR_LOGGER.log_warning
#macro elog	__RAPTOR_LOGGER.log_error
#macro flog	__RAPTOR_LOGGER.log_fatal
#macro mlog	__RAPTOR_LOGGER.log_master

function RaptorLogger() constructor {

	__formatter = new RaptorSimpleFormatter();

	static set_formatter = function(_formatter) {
		__formatter = _formatter;
	}
	
	/// @function set_log_level(_new_level)
	static set_log_level = function(_new_level) {
		__formatter.change_log_level(_new_level);
	}
	
	static log_verbose = function(_message) {
		__formatter.write_log(0, _message);
	}
	
	static log_debug = function(_message) {
		__formatter.write_log(1, _message);
	}

	static log_info = function(_message) {
		__formatter.write_log(2, _message);
	}
	
	static log_warning = function(_message) {
		__formatter.write_log(3, _message);
	}
	
	static log_error = function(_message) {
		__formatter.write_log(4, _message);
	}
	
	static log_fatal = function(_message) {
		__formatter.write_log(5, _message);
	}
	
	// the master log function is kind of a special way to print out a line *always*
	// no matter, what log level is set. Could be done with fatal also, but it is used
	// to print the game version to the log, which shall not be marked as fatal error.
	static log_master = function(_message) {
		__formatter.write_log(6, _message);
	}

}