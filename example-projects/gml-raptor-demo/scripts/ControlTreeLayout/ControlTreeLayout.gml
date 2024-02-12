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
	line_index	= 0;
	
	control_size = new Coord2();
	
	/// @function align_in_control(_inst, _control)
	static align_in_control = function(_line_idx, _inst, _control) {
		update_control_size(_control);
		line_index = _line_idx;
		
		if (spreadx != -1) {
			var sx = spreadx;
			var netto = _control.data.client_area.width -
						_control.data.control_tree.margin_left * (line_index + 1) -
						_control.data.control_tree.padding_left * (line_index + 1) -
						_control.data.control_tree.margin_right * (line_index + 1) -
						_control.data.control_tree.padding_right * (line_index + 1);
			with(_inst) 
				scale_sprite_to(netto * sx, sprite_height);
		}
		if (spready != -1) {
			var sy = spready;
			var netto = _control.data.client_area.width -
						_control.data.control_tree.margin_top -
						_control.data.control_tree.padding_top -
						_control.data.control_tree.margin_bottom -
						_control.data.control_tree.padding_bottom;
			with(_inst)
				scale_sprite_to(sprite_width, netto * sy);
		}
	}
	
	/// @function update_control_size(_control)
	static update_control_size = function(_control) {
		control_size.set(_control.sprite_width, _control.sprite_height);
	}
	
}
