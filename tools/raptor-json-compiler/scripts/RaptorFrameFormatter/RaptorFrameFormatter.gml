/*
    short description here
*/

function RaptorFrameFormatter() : RaptorLogFormatterBase() constructor {

	format_event = function(_level, _message) {
		return $"{GAMEFRAME}: {_level} {_message}";
	}
}