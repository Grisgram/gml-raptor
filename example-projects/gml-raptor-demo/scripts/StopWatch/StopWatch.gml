/*
    short utility functions to measure time.
	Mostly used to track runtime of functions while developing and optimizing
	
	stopwatch_start([idx]) starts a stop watch
	stopwatch_stop([idx],[write_to_log],[convert_ms]) calculates the elapsed time
		and returns the value.
		By default, it will be converted to ms (from µs) and printed to the log.
*/

#macro __RAPTOR_STOPWATCH		global.___RAPTOR_STOPWATCH
__RAPTOR_STOPWATCH				= [];


/// @function		stopwatch_start(_index = 0)
function stopwatch_start(_index = 0) {
	__RAPTOR_STOPWATCH[@ _index] = get_timer();
}

/// @function		stopwatch_stop(_index = 0, _write_to_log = true, _convert_to_ms = true)
function stopwatch_stop(_index = 0, _write_to_log = true, _convert_to_ms = true) {
	var rv = get_timer() - __RAPTOR_STOPWATCH[@ _index];
	if (_convert_to_ms) rv /= 1000;
	if (_write_to_log)
		log($"Stopwatch {_index}: {rv}{(_convert_to_ms ? "m" : "µ")}s");
	return rv;
}