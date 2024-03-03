/*
    holds one single bound property and its state
*/

function Binding(_control, _my_value, _to, _converter = undefined) constructor {

	control		= _control;
	my_value	= _my_value;
	to			= _to;
	converter	= _converter;

	__dirty		= false;
	
	static notify_changed = function(_new_value) {
		variable_instance_set(control, my_value, _new_value);
		with(control) force_redraw();
	}

}

