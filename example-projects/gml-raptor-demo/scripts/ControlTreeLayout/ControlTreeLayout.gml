/*
    This class is attached to data._layout on each _baseControl when it gets added as a child
*/

/// @function ControlTreeLayout()
function ControlTreeLayout() constructor {
	construct("ControlTreeLayout");

	docking		= dock.none;
	anchoring	= anchor.none;
	spreadx		= -1;
	spready		= -1;
	
	control_size = new Coord2();

	/// @function set_layout_data(_dock, _anchor, _spreadx, _spready)
	static set_layout_data = function(_dock, _anchor, _spreadx, _spready) {
		docking		= _dock;
		anchoring	= _anchor;
		spreadx		= _spreadx;
		spready		= _spready;
		return self;
	}
	
	/// @function align_in_control(_inst, _control)
	static align_in_control = function(_inst, _control) {
		update_control_size(_control);
		if (spreadx != -1) {
			var sx = spreadx;
			with(_inst) 
				scale_sprite_to(_control.sprite_width * sx, sprite_height);
		}
		if (spready != -1) {
			var sy = spready;
			with(_inst)
				scale_sprite_to(sprite_width, _control.sprite_height * sy);
		}
	}
	
	/// @function update_control_size(_control)
	static update_control_size = function(_control) {
		control_size.set(_control.sprite_width, _control.sprite_height);
	}
	
}
