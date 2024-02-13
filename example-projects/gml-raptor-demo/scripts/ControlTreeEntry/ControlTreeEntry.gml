/*
    This class makes up the array of children in a ControlTree
*/

/// @function ControlTreeEntry(_instance = undefined)
function ControlTreeEntry(_instance = undefined) constructor {
	construct("ControlTreeEntry");
	
	instance		= _instance;
	newline_after	= false;
	element_name	= "";
	line_index		=  0;
	
}
