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
	line_items	=  0;
	
	control_size = new Coord2();
	
	/// @function align_in_control(_inst, _control)
	static align_in_control = function(_element_count, _inst, _control) {
		update_control_size(_control);
		_control.__update_client_area();
		line_items = _element_count;
		
		if (spreadx != -1) {
			var sx = spreadx;
			
			var maxv = (_control.data.client_area.width / line_items) -
						_control.data.control_tree.margin_left -
						_control.data.control_tree.margin_right -
						_control.data.control_tree.padding_left -
						_control.data.control_tree.padding_right;
			
			var netto = min(maxv, _control.data.client_area.width * sx);

			with(_inst) 
				scale_sprite_to(netto, sprite_height);
		}
		if (spready != -1) {
			var sy = spready;
			var maxv = (_control.data.client_area.height / line_items) -
						_control.data.control_tree.margin_top -
						_control.data.control_tree.margin_bottom -
						_control.data.control_tree.padding_top -
						_control.data.control_tree.padding_bottom;
			
			var netto = min(maxv, _control.data.client_area.height * sy);
			
			with(_inst)
				scale_sprite_to(sprite_width, netto * sy);
		}
	}
	
	/// @function update_control_size(_control)
	static update_control_size = function(_control) {
		control_size.set(_control.sprite_width, _control.sprite_height);
	}
	
}
