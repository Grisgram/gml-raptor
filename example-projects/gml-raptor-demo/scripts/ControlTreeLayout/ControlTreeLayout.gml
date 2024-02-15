/*
    This class is attached to data._layout on each _baseControl when it gets added as a child
*/

/// @function ControlTreeLayout()
function ControlTreeLayout() constructor {
	construct("ControlTreeLayout");

	docking		= dock.none;
	anchoring	= anchor.none;
	valign      = fa_top;
	halign      = fa_left;
	spreadx		= -1;
	spready		= -1;
	line_items	=  0;
	
	control_size = new Coord2();
	__filler	 = new Coord2();
	
#region Docking
	/// @function apply_docking(_area, _inst, _control)
	static apply_docking = function(_area, _inst, _control) {
		var neww = _inst.sprite_width;
		var newh = _inst.sprite_height;
		var tree = _control.data.control_tree;
		
		switch (docking) {
			case dock.none:		return;
			case dock.left:		newh = __apply_dock_left	(_area, _inst, _control); break;
			case dock.right:	newh = __apply_dock_right	(_area, _inst, _control); break;
			case dock.top:		neww = __apply_dock_top		(_area, _inst, _control); break;
			case dock.bottom:	neww = __apply_dock_bottom	(_area, _inst, _control); break;
			case dock.fill:
				__apply_dock_fill(_area, _inst, _control, __filler);
				neww = __filler.x;
				newh = __filler.y;
				break;
		}
		
		with (_inst)
			scale_sprite_to(neww, newh);
	}
	
	static __apply_dock_top = function(_area, _inst, _control) {
		var tree = _control.data.control_tree;
		var runner = tree.runner;
		
		var neww = _area.width - 
				tree.margin_left - tree.margin_right -
				tree.padding_left - tree.padding_right;
						
		_inst.x = _area.left + tree.margin_left + tree.padding_left + _inst.sprite_xoffset;
		_inst.y = _area.top  + tree.margin_top  + tree.padding_top  + _inst.sprite_yoffset;
				
		var areadiff = _inst.sprite_height + 
			tree.margin_top + tree.margin_bottom +
			tree.padding_top + tree.padding_bottom;
				
		runner.top += areadiff;
		_area.top += areadiff;
		_area.height -= areadiff;
		if (_area.height < 0)
			wlog($"** WARNING ** Negative docking area vertical {_area.height}! Your controls take up too much space!");
		
		return neww;
	}
	
	static __apply_dock_bottom = function(_area, _inst, _control) {
		var tree = _control.data.control_tree;
		var runner = tree.runner;
		
		var neww = _area.width - 
				tree.margin_left - tree.margin_right -
				tree.padding_left - tree.padding_right;
						
		_inst.x = _area.left + tree.margin_left + tree.padding_left + _inst.sprite_xoffset;
		_inst.y = _area.get_bottom() - 
			tree.margin_top - tree.padding_top - 
			tree.margin_bottom - tree.padding_bottom - 
			_inst.sprite_height - _inst.sprite_yoffset;
				
		var areadiff = _inst.sprite_height + 
			tree.margin_top + tree.margin_bottom +
			tree.padding_top + tree.padding_bottom;
				
		runner.bottom -= areadiff;
		_area.height -= areadiff;
		if (_area.height < 0)
			wlog($"** WARNING ** Negative docking area vertical {_area.height}! Your controls take up too much space!");

		return neww;
	}

	static __apply_dock_left = function(_area, _inst, _control) {
		var tree = _control.data.control_tree;
		var runner = tree.runner;
		
		var newh = _area.height - 
				tree.margin_top - tree.margin_bottom -
				tree.padding_top - tree.padding_bottom;
						
		_inst.x = _area.left + tree.margin_left + tree.padding_left + _inst.sprite_xoffset;
		_inst.y = _area.top  + tree.margin_top  + tree.padding_top  + _inst.sprite_yoffset;
				
		var areadiff = _inst.sprite_width + 
			tree.margin_left + tree.margin_right +
			tree.padding_left + tree.padding_right;

		runner.left += areadiff;
		_area.left += areadiff;
		_area.width -= areadiff;
		if (_area.width < 0)
			wlog($"** WARNING ** Negative docking area horizontal {_area.width}! Your controls take up too much space!");

		return newh;
	}

	static __apply_dock_right = function(_area, _inst, _control) {
		var tree = _control.data.control_tree;
		var runner = tree.runner;

		var newh = _area.height - 
				tree.margin_top - tree.margin_bottom -
				tree.padding_top - tree.padding_bottom;
						
		_inst.x = _area.get_right() - 
			tree.margin_left - tree.padding_left - 
			tree.margin_right - tree.padding_right - 
			_inst.sprite_width - _inst.sprite_xoffset;
		_inst.y = _area.top + tree.margin_top + tree.padding_top + _inst.sprite_yoffset;
				
		var areadiff = _inst.sprite_width + 
			tree.margin_left + tree.margin_right +
			tree.padding_left + tree.padding_right;
		
		runner.right -= areadiff;
		_area.width -= areadiff;
		if (_area.width < 0)
			wlog($"** WARNING ** Negative docking area horizontal {_area.width}! Your controls take up too much space!");

		return newh;
	}
	
	static __apply_dock_fill = function(_area, _inst, _control, rv = undefined) {
		rv ??= new Coord2();
		var neww = _inst.sprite_width;
		var newh = _inst.sprite_height;
		var tree = _control.data.control_tree;
		
		// left
		var neww = _area.width - 
				tree.margin_left - tree.margin_right -
				tree.padding_left - tree.padding_right;
				
		var newh = _area.height - 
				tree.margin_top - tree.margin_bottom -
				tree.padding_top - tree.padding_bottom;
						
		_inst.x = _area.left + tree.margin_left + tree.padding_left + _inst.sprite_xoffset;
		_inst.y = _area.top  + tree.margin_top  + tree.padding_top  + _inst.sprite_yoffset;
				
		// dock fill does NOT modify the area!
		// it just sizes its content to the entire remaining area

		rv.set(neww, newh);

		return rv;
	}

#endregion

#region Alignment
	static apply_alignment = function(_inst, _control) {
		if (docking != dock.none || anchoring != anchor.none)
			return; // we can only align if we are the master of our size
			
		var tree = _control.data.control_tree;
		var runner = tree.runner;

		//_inst.x = runner.left + margin_left + padding_left + inst.sprite_xoffset;
		//_inst.y = runner.top + margin_top  + padding_top  + inst.sprite_yoffset;
		
		// The switches here ignore fa_top and fa_left because this is "runner-style" and
		// has already been set by the layout() function of the tree.
		// We only care about middle/center/right/bottom here as this function gets invoked
		// AFTER the final size of the instance is set
		switch (valign) {
			//case fa_top:
			//	_inst.y = runner.top + tree.margin_top  + tree.padding_top  + _inst.sprite_yoffset;
			//	break;
			case fa_middle:
				_inst.y = tree.render_area.top + tree.render_area.height / 2 - _inst.sprite_height / 2;
				break;
			case fa_bottom:
				var opp = (runner.bottom == tree.render_area.get_bottom() ? 0 :
							tree.margin_top + tree.padding_top);
				var dist = _inst.sprite_height + tree.margin_bottom + tree.padding_bottom + opp;
				runner.bottom -= dist;
				_inst.y = runner.bottom;
				break;
		}
		switch (halign) {
			//case fa_left:
			//	_inst.x = runner.left + tree.margin_left + tree.padding_left + _inst.sprite_xoffset;
			//	break;
			case fa_center:
				_inst.x = tree.render_area.left + tree.render_area.width / 2 - _inst.sprite_width / 2;
				break;
			case fa_right:
				var opp = (runner.right == tree.render_area.get_right() ? 0 :
							tree.margin_left + tree.padding_left);
				var dist = _inst.sprite_width + tree.margin_right + tree.padding_right + opp;
				runner.right -= dist;
				_inst.x = runner.right;
				break;
		}
	}
	
#endregion

#region Spreading
	/// @function apply_spreading(_element_count, _area, _inst, _control)
	static apply_spreading = function(_element_count, _area, _inst, _control) {
		if (docking != dock.none || anchoring != anchor.none)
			return; // we can only spread if we are the master of our size
			
		update_control_size(_control);
		_control.__update_client_area();
		line_items = _element_count;
		
		if (spreadx != -1) {
			var sx = spreadx;
			
			var maxv = (_area.width / line_items) -
						_control.data.control_tree.margin_left -
						_control.data.control_tree.margin_right -
						_control.data.control_tree.padding_left -
						_control.data.control_tree.padding_right;
			
			var netto = min(maxv, _area.width * sx);

			with(_inst) 
				scale_sprite_to(netto, sprite_height);
		}
		if (spready != -1) {
			var sy = spready;
			var maxv = (_area.height / line_items) -
						_control.data.control_tree.margin_top -
						_control.data.control_tree.margin_bottom -
						_control.data.control_tree.padding_top -
						_control.data.control_tree.padding_bottom;
			
			var netto = min(maxv, _area.height * sy);
			
			with(_inst)
				scale_sprite_to(sprite_width, netto * sy);
		}
	}
#endregion

	/// @function update_control_size(_control)
	static update_control_size = function(_control) {
		control_size.set(_control.sprite_width, _control.sprite_height);
	}
	
}
