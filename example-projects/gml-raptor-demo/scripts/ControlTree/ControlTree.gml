/*
    This is a chainable, hierarchical tree of controls that are
	anchored and docked to each other.
*/

enum dock {
	none, right, top, left, bottom, fill
}

enum anchor {
	none	= 0,
	right	= 1,
	top		= 2,
	left	= 4,
	bottom	= 8
}

function ControlTree(_control = undefined, _parent_tree = undefined, _margin = undefined, _padding = undefined) constructor {
	construct("ControlTree");
	
	// This is the control, the tree is bound to. Gets set in Create of _baseContainerControl
	control			= _control;
	control_size	= new Coord2();

	// if the parent_tree is undefined, this means, it's the top-level tree
	// ONLY the top-level tree invokes layout() when the control moves or changes size,
	// so the hierarchy is processed only once
	parent_tree		= _parent_tree;
	children		= [];
	
	margin_left		= _margin ?? 0;
	margin_top		= _margin ?? 0;
	margin_right	= _margin ?? 0;
	margin_bottom	= _margin ?? 0;
	
	padding_left	= _padding ?? 0;
	padding_top		= _padding ?? 0;
	padding_right	= _padding ?? 0;
	padding_bottom	= _padding ?? 0;
	
	__last_instance	= undefined;
	__last_entry	= undefined;
	__last_layout	= undefined;
	
	/// @function bind_to(_control)
	static bind_to = function(_control) {
		if (!is_child_of(_control, _baseContainerControl))
			throw("Binding target of a ControlTree must be a _baseContainerControl (Window, Panel, ...)!");
			
		control = _control;
		return self;
	}
	
	/// @function set_margin_all(_margin)
	static set_margin_all = function(_margin) {
		set_margin(_margin, _margin, _margin, _margin);
		return self;
	}
	
	/// @function set_margin(_margin_left, _margin_top, _margin_right, _margin_bottom)
	static set_margin = function(_margin_left, _margin_top, _margin_right, _margin_bottom) {
		margin_left		= _margin_left;
		margin_top		= _margin_top;
		margin_right	= _margin_right;
		margin_bottom	= _margin_bottom;
		return self;
	}
	
	/// @function set_padding_all(_padding)
	static set_padding_all = function(_padding) {
		set_padding(_padding, _padding, _padding, _padding);
		return self;
	}
	
	/// @function set_padding(_padding_left, _padding_top, _padding_right, _padding_bottom)
	static set_padding = function(_padding_left, _padding_top, _padding_right, _padding_bottom) {
		padding_left	= _padding_left;
		padding_top		= _padding_top;
		padding_right	= _padding_right;
		padding_bottom	= _padding_bottom;
		return self;
	}
	
	/// @function add_control(_objtype, _dock, _anchor, _spreadx = -1, _spready = -1, _init_struct = undefined)
	static add_control = function(_objtype, _init_struct = undefined) {
		
		var inst = instance_create(control.x, control.y, layer_of(control), _objtype, _init_struct);
		if (!is_child_of(inst, _baseControl)) {
			instance_destroy(inst);
			throw("ControlTree accepts only raptor controls (child of _baseControl) as children!");
		}
		inst.draw_on_gui = control.draw_on_gui;
		inst.autosize = false;
		inst.data.control_tree_layout = new ControlTreeLayout();

		__last_entry = new ControlTreeEntry(inst);
		array_push(children, __last_entry);
		
		__last_instance = inst;
		if (is_child_of(inst, _baseContainerControl)) {
			inst.data.control_tree.parent_tree = self;
			inst.data.control_tree.__last_layout = inst.data.control_tree_layout;
			return inst.data.control_tree;
		} else {
			__last_layout = inst.data.control_tree_layout;
			return self;
		}
	}
	
	/// @function set_spread(_spreadx = -1, _spready = -1)
	static set_spread = function(_spreadx = -1, _spready = -1) {
		__last_layout.spreadx = _spreadx;
		__last_layout.spready = _spready;
		return self;
	}
	
	/// @function set_dock(_dock)
	static set_dock = function(_dock) {
		__last_layout.dock = _dock;
		return self;
	}
	
	/// @function set_anchor(_anchor)
	static set_anchor = function(_anchor) {
		__last_layout.anchor = _anchor;
		return self;
	}
	
	/// @function new_line()
	static new_line = function() {
		__last_entry.newline_after = true;
		return self;
	}
	
	/// @function step_out()
	static step_out = function() {
		return parent_tree;
	}
	
	/// @function layout()
	/// @description	performs layouting of all child controls. invoked when the control
	///					changes its size or position.
	///					also calls layout() on all children
	static layout = function() {
		control_size.set(control.sprite_width, control.sprite_height);
		var runx = control.x + control.data.client_area.left + margin_left;
		var runy = control.y + control.data.client_area.top  + margin_top;
		var maxh = 0;
		
		for (var i = 0, len = array_length(children); i < len; i++) {
			var child = children[@i];
			var inst = child.instance;
			maxh = max(maxh, inst.sprite_height + 1 + padding_bottom + margin_bottom);
			inst.x = runx + padding_left + inst.sprite_xoffset;
			inst.y = runy + padding_top  + inst.sprite_yoffset;
			inst.data.control_tree_layout.align_in_control(inst, control);
			if (is_child_of(inst, _baseContainerControl))
				inst.data.control_tree.layout();
			if (child.newline_after) {
				runx = control.x + control.data.client_area.left + margin_left;
				runy += maxh;
				maxh = 0;
			} else
				runx = inst.x + inst.sprite_width - inst.sprite_xoffset + 1 + i + padding_right + margin_right;
		}
	}
	
	static draw_children = function() {
		for (var i = 0, len = array_length(children); i < len; i++) {
			var child = children[@i];
			child.instance.__draw_instance();
		}
	}
	
	static clean_up = function() {
		for (var i = 0, len = array_length(children); i < len; i++) {
			var child = children[@i];
			var inst = child.instance;
			if (is_child_of(inst, _baseContainerControl))
				inst.data.control_tree.clean_up();
			else
				instance_destroy(inst);
		}
		instance_destroy(control);
	}
}

