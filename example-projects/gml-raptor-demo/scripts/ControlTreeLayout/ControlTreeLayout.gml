/*
    This class is attached to data._layout on each _baseControl when it gets added as a child
*/

/// @function ControlTreeLayout()
function ControlTreeLayout() constructor {
	construct("ControlTreeLayout");

	docking		= dock.none;
	valign      = fa_top;
	halign      = fa_left;
	spreadx		= -1;
	spready		= -1;
	xpos		=  0;
	ypos		=  0;
	line_items	=  0;
	
	anchoring	= anchor.none;
	anchor_data = {
		init		: false,
		dist_top	: 0,
		dist_left	: 0,
		dist_right	: 0,
		dist_bottom	: 0
	};
	anchor_now  = {
		delta_top	: 0,
		delta_left	: 0,
		delta_right	: 0,
		delta_bottom: 0,
		width		: 0,
		height		: 0,
		dock_top	: 0,
		dock_left	: 0,
		dock_right	: 0,
		dock_bottom	: 0
	};
		
	control_size = new Coord2();
	__filler	 = new Coord2();

#region Positioning
	/// @function apply_positioning(_area, _inst, _control)
	static apply_positioning = function(_area, _inst, _control) {
		if (docking != dock.none)
			return;
		
		var tree = _control.data.control_tree;
		
		if (halign == fa_left)
			_inst.x = _area.left + xpos + tree.margin_left + tree.padding_left + _inst.sprite_xoffset;
		if (valign == fa_top)
			_inst.y = _area.top + ypos + tree.margin_top  + tree.padding_top  + _inst.sprite_yoffset;
	}
#endregion

#region Docking
	/// @function apply_docking(_area, _inst, _control)
	static apply_docking = function(_area, _inst, _control) {
		var neww = _inst.sprite_width;
		var newh = _inst.sprite_height;
		
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
		
		var opp = (runner.bottom == _area.get_bottom() ? 0 :
					tree.margin_top + tree.padding_top);		
		_inst.y = _area.get_bottom() - opp -
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

		var opp = (runner.right == _area.get_right() ? 0 :
					tree.margin_left + tree.padding_left);
		_inst.x = _area.get_right() - opp -
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
		_control.__update_client_area();

		// The switches here ignore fa_top and fa_left because this is "runner-style" and
		// has already been set by the layout() function of the tree.
		// We only care about middle/center/right/bottom here as this function gets invoked
		// AFTER the final size of the instance is set
		switch (valign) {
			case fa_top:
				_inst.y = tree.render_area.top + tree.margin_top  + tree.padding_top  + _inst.sprite_yoffset;
				break;
			case fa_middle:
				_inst.y = tree.render_area.top + tree.render_area.height / 2 - _inst.sprite_height / 2;
				break;
			case fa_bottom:
				var dist = _inst.sprite_height + tree.margin_bottom + tree.padding_bottom;
				_inst.y = tree.render_area.get_bottom() - dist;
				break;
		}
		switch (halign) {
			case fa_left:
				_inst.x = tree.render_area.left + tree.margin_left + tree.padding_left + _inst.sprite_xoffset;
				break;
			case fa_center:
				_inst.x = tree.render_area.left + tree.render_area.width / 2 - _inst.sprite_width / 2;
				break;
			case fa_right:
				var dist = _inst.sprite_width + tree.margin_right + tree.padding_right;
				_inst.x = tree.render_area.get_right() - dist;
				break;
		}
	}
	
#endregion

#region Anchoring
	/// @function apply_anchoring(_area, _inst, _control)
	static apply_anchoring = function(_area, _inst, _control) {
		if (docking != dock.none || anchoring == anchor.none)
			return; // we can only align if we are the master of our size
			
		if (!anchor_data.init) 
			__initialize_anchoring(_area, _inst, _control);
		
		anchor_now.delta_top	= abs(_inst.y - _area.top)	  - anchor_data.dist_top;
		anchor_now.delta_left	= abs(_inst.x - _area.left)	  - anchor_data.dist_left;
		anchor_now.delta_right	= abs(_inst.x - _area.right)  - anchor_data.dist_right;
		anchor_now.delta_bottom	= abs(_inst.y - _area.bottom) - anchor_data.dist_bottom;
		anchor_now.width		= _control.sprite_width;
		anchor_now.height		= _control.sprite_height;
		anchor_now.dock_top		= (anchoring & anchor.top)		== anchor.top;	
		anchor_now.dock_left	= (anchoring & anchor.left)		== anchor.left;	
		anchor_now.dock_right	= (anchoring & anchor.right)	== anchor.right;
		anchor_now.dock_bottom	= (anchoring & anchor.bottom)	== anchor.bottom;
		
		// anchoring takes place AFTER alignment, so we never modify x/y here,
		// only width and height are in focus, BUT
		// we have to calculate the anchor based on the alignment, to find out,
		// which side of the instance needs to be adapted
		switch(valign) {
			case fa_top:
				if (anchor_now.dock_bottom) anchor_now.height += anchor_now.delta_bottom;
				break;
			case fa_middle:
				if (anchor_now.dock_top)	anchor_now.height += anchor_now.delta_top;
				if (anchor_now.dock_bottom) anchor_now.height += anchor_now.delta_bottom;
				if (anchor_now.dock_top || anchor_now.dock_bottom)
					_inst.y -= (anchor_now.delta_top + anchor_now.delta_bottom) / 2;
				break;
			case fa_bottom:
				if (anchor_now.dock_top) {
					anchor_now.height += anchor_now.delta_top;
					_inst.y -= anchor_now.delta_top;
				}
				break;
		}
		
		switch(halign) {
			case fa_left:
				if (anchor_now.dock_right) anchor_now.width += anchor_now.delta_right;
				break;
			case fa_center:
				if (anchor_now.dock_left) anchor_now.width += anchor_now.delta_left;
				if (anchor_now.dock_right) anchor_now.width += anchor_now.delta_right;
				if (anchor_now.dock_left || anchor_now.dock_right)
					_inst.x -= (anchor_now.delta_left + anchor_now.delta_right) / 2;
				break;
			case fa_right:
				if (anchor_now.dock_left) {
					anchor_now.width += anchor_now.delta_left;
					_inst.x -= anchor_now.delta_right;
				}
				break;
		}
		
		with(_inst) scale_sprite_to(other.anchor_now.width, other.anchor_now.height);
	}
	
	static __initialize_anchoring = function(_area, _inst, _control) {
		if (anchor_data.init) return;
		anchor_data.init = true;
		
		// Initialization means: Measure the distance to each border.
		// How much the size changes, is done by the apply_anchoring method
		// This one here just measures
		anchor_data.dist_top	= abs(_inst.y - _area.top);
		anchor_data.dist_left	= abs(_inst.x - _area.left);
		anchor_data.dist_right	= abs(_inst.x - _area.right);
		anchor_data.dist_bottom	= abs(_inst.y - _area.bottom);
	}
	
#endregion

#region Spreading
	/// @function apply_spreading(_element_count, _area, _inst, _control)
	static apply_spreading = function(_area, _inst, _control) {
		if (docking != dock.none || anchoring != anchor.none)
			return; // we can only spread if we are the master of our size
			
		update_control_size(_control);
		_control.__update_client_area();
		
		if (spreadx != -1) {
			var netto = max(_inst.min_width, _area.width * spreadx);
			with(_inst) 
				scale_sprite_to(netto, sprite_height);
		}
		if (spready != -1) {			
			var netto = max(_inst.min_height, _area.height * spready);
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
