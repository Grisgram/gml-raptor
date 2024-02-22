/*
    This is a chainable, hierarchical tree of controls that are
	anchored and docked to each other.
*/

enum dock {
	none, right, top, left, bottom, fill
}

enum anchor {
	none		= 0,
	right		= 1,
	top			= 2,
	left		= 4,
	bottom		= 8,
	all_sides	= 15
}

function ControlTree(_control = undefined, _parent_tree = undefined, _margin = undefined, _padding = undefined) constructor {
	construct("ControlTree");
	
	// This is the control, the tree is bound to. Gets set in Create of _baseContainerControl
	control			= _control;

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

	render_area		= new Rectangle(); // client area minus all applied dockings (= free undocked render space)
	reorder_docks	= true;

	// holds rendering coordinates
	runner  = {
		left:	0,
		top :	0,
		right:	0,
		bottom: 0
	}
	
	__on_opened		= undefined;
	__on_closed		= undefined;
	__last_instance	= undefined;
	__last_entry	= undefined;
	__last_layout	= undefined;
	__root_tree		= self;
	__force_next	= false;
	__layout_done	= false;

	/// @function bind_to(_control)
	static bind_to = function(_control) {
		if (!is_child_of(_control, _baseContainerControl))
			throw("Binding target of a ControlTree must be a _baseContainerControl (Window, Panel, ...)!");
			
		control = _control;
		return self;
	}
	
	/// @function get_root_control()
	static get_root_control = function() {
		return __root_tree.control;
	}
	
	/// @function get_root_tree()
	static get_root_tree = function() {
		return __root_tree;
	}
	
	/// @function is_root_tree()
	static is_root_tree = function() {
		return (__root_tree == self);
	}
	
	/// @function get_instance()
	static get_instance = function() {
		return __last_instance;
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
	
	/// @function add_control(_objtype, _init_struct = undefined)
	static add_control = function(_objtype, _init_struct = undefined) {
		// a new control can affect the whole render tree, so force redraw next frame
		__force_next = true;
		
		var inst = instance_create(-100000, -100000, layer_of(control), _objtype, _init_struct);
		//var inst = instance_create(control.x, control.y, layer_of(control), _objtype, _init_struct);
		if (!is_child_of(inst, _baseControl)) {
			instance_destroy(inst);
			throw("ControlTree accepts only raptor controls (child of _baseControl) as children!");
		}
		inst.__container = control;
		inst.draw_on_gui = control.draw_on_gui;
		inst.autosize = false;
		inst.data.control_tree_layout = new ControlTreeLayout();

		__last_entry = new ControlTreeEntry(inst);
		array_push(children, __last_entry);
		
		__last_instance = inst;
		if (is_child_of(inst, _baseContainerControl)) {
			inst.data.control_tree.parent_tree = self;
			inst.data.control_tree.__root_tree = __root_tree;
			inst.data.control_tree.__last_layout = inst.data.control_tree_layout;
			inst.data.control_tree.__last_entry = __last_entry;
			return inst.data.control_tree;
		} else {
			__last_layout = inst.data.control_tree_layout;
			return self;
		}
	}
	
	static remove_control = function(_control) {
		for (var i = 0, len = array_length(children); i < len; i++) {
			if (eq(_control, children[@i].instance)) {
				array_delete(children, i, 1);
				vlog($"Removed {name_of(_control)} from tree of {name_of(control)}");
				break;
			}
		}
		return self;
	}
	
	/// @function set_position(_xpos, _ypos)
	/// @description Sets an absolute position in the client area of the parent control,
	///              unless you set _relative to true, then the values are just added to the
	///				 currently set xpos and ypos
	static set_position = function(_xpos, _ypos, _relative = false) {
		if (_relative) {
			__last_layout.xpos += _xpos;
			__last_layout.ypos += _ypos;
		} else {
			__last_layout.xpos = _xpos;
			__last_layout.ypos = _ypos;
		}
		return self;
	}
	
	/// @function set_position_from_align(_valign, _halign, _xoffset = 0, _yoffset = 0)
	static set_position_from_align = function(_valign, _halign, _xoffset = 0, _yoffset = 0) {
		__last_layout.xpos += _xoffset;
		__last_layout.ypos += _yoffset;
		__last_layout.xpos_align = _halign;
		__last_layout.ypos_align = _valign;
		return self;
	}
	
	/// @function set_spread(_spreadx = -1, _spready = -1)
	static set_spread = function(_spreadx = -1, _spready = -1) {
		__last_layout.spreadx = _spreadx;
		__last_layout.spready = _spready;
		return self;
	}
	
	/// @function set_dock(_dock)
	static set_dock = function(_dock) {
		__last_layout.docking = _dock;
		__last_layout.docking_reverse = (_dock == dock.right || _dock == dock.bottom);
		return self;
	}
	
	/// @function set_reorder_docks(_reorder)
	/// @description True by default. Reorder dock means a more "natural" feeling of
	///				 adding right- and bottom docked elements.
	///				 When you design a form, you think "left-to-right" and "top-to-bottom",
	///				 so you likely want to appear the first bottom added ABOVE the second bottom
	///				 If you do not want that, just turn reorder off.
	static set_reorder_docks = function(_reorder) {
		reorder_docks = _reorder;
		return self;
	}
	
	/// @function set_align(_valign = fa_top, _halign = fa_left, _xoffset = 0, _yoffset = 0)
	static set_align = function(_valign = fa_top, _halign = fa_left, _xoffset = 0, _yoffset = 0) {
		__last_layout.xpos += _xoffset;
		__last_layout.ypos += _yoffset;
		__last_layout.valign	 = _valign;
		__last_layout.halign	 = _halign;
		__last_layout.have_align = true;
		return self;
	}
	
	/// @function remove_align()
	static remove_align = function() {
		__last_layout.have_align = false;
		return self;
	}
	
	/// @function set_anchor(_anchor)
	static set_anchor = function(_anchor) {
		__last_layout.anchoring = _anchor;
		return self;
	}
	
	/// @function set_name(_name)
	/// @description Give a child control a name to retrieve it later through get_element(_name)
	static set_name = function(_name) {
		__last_entry.element_name = _name;
		return self;
	}

	/// @function select_element(_control)
	/// @description Searches through the tree for the specified control
	///				 and sets it as the active element, if found.
	///				 "Active element" means, all ".set_*" function will apply to it
	///				 NOTE: This function throws an exception if the control is not in the tree!
	static select_element = function(_control_or_name) {
		var found = false;
		var strcompare = is_string(_control_or_name);
		for (var i = 0, len = array_length(children); i < len; i++) {			
			var child		= children[@i];
			var inst		= child.instance;
			var ilayout		= inst.data.control_tree_layout;
			
			if ((strcompare && eq(_control_or_name, child.name)) ||
				(!strcompare && eq(_control_or_name, inst))) {
				found = true;
				__last_instance = inst;
				__last_layout	= ilayout;
				__last_entry	= child;
				vlog($"Selected control {name_of(inst)}{(child.name != "" ? $" ({child.name})" : "")} as active tree control");
				break;
			}
		}
		if (!found) 
			throw($"Control '{name_of(_control)}' not found in tree of '{name_of(control)}'!");
	}

	/// @function get_element(_name)
	/// @description Retrieve a child control by its name. Returns the instance or undefined
	static get_element = function(_name) {
		var rv = undefined;
		for (var i = 0, len = array_length(children); i < len; i++) {
			var child = children[@i];
			if (child.element_name == _name)
				rv = child.instance;
			else if (is_child_of(child.instance, _baseContainerControl))
				rv = child.instance.control_tree.get_element(_name);
			if (rv != undefined) 
				return rv;
		}
		return undefined;
	}
	
	/// @function step_out()
	static step_out = function() {
		return parent_tree;
	}
		
	/// @function on_window_opened(_callback)
	static on_window_opened = function(_callback) {
		__on_opened = _callback;
		return self;
	}
	
	/// @function on_window_closed(_callback)
	static on_window_closed = function(_callback) {
		__on_closed = _callback;
		return self;
	}

	/// @function invoke_on_opened()
	static invoke_on_opened = function() {
		if (__on_opened != undefined)
			__on_opened(control);
		return self;
	}
	
	/// @function invoke_on_closed()
	static invoke_on_closed = function() {
		if (__on_closed != undefined)
			__on_closed(control);
		return self;
	}

	/// @function layout(_forced = false)
	/// @description	performs layouting of all child controls. invoked when the control
	///					changes its size or position.
	///					also calls layout() on all children
	static layout = function(_forced = false) {
		update_render_area();
		
		runner.left		= render_area.left;
		runner.top		= render_area.top ;
		runner.right	= render_area.get_right();
		runner.bottom	= render_area.get_bottom();
		
		var child		= undefined;
		var inst		= undefined;
		var ilayout		= undefined;
		var oldinstx	= 0;
		var oldinsty	= 0;
		var oldsizex	= 0;
		var oldsizey	= 0;
		
		_forced |= __force_next;
		__force_next = false;

		for (var i = 0, len = array_length(children); i < len; i++) {			
			child		= children[@i];
			inst		= child.instance;
			ilayout		= inst.data.control_tree_layout;
			oldinstx	= inst.x;
			oldinsty	= inst.y;
			oldsizex	= inst.sprite_width;
			oldsizey	= inst.sprite_height;
			
			if (_forced) inst.force_redraw();
			
			if (is_child_of(inst, _baseContainerControl)) {
				inst.data.control_tree.layout(_forced);
				inst.update_client_area();
			}

			ilayout.apply_positioning(render_area, inst, control);
			ilayout.apply_docking	 (render_area, inst, control);
			ilayout.apply_spreading  (render_area, inst, control);
			ilayout.apply_alignment  (render_area, inst, control);
			ilayout.apply_anchoring  (render_area, inst, control);
		}
						
		if (reorder_docks) {
			__reorder_bottom_dock();
			__reorder_right_dock();
		}
		
		// if anything in our size or position changed, force update of the text display to avoid rubberbanding
		if (inst != undefined && 
			(inst.x != oldinstx || inst.y != oldinsty || 
			 inst.sprite_width != oldsizex || inst.sprite_height != oldsizey)) {
				inst.force_redraw();
				inst.__draw_self();
		}
		return self;
	}

	/// @function update_render_area()
	static update_render_area = function() {
		render_area.set(
			control.x + control.data.client_area.left, 
			control.y + control.data.client_area.top , 
			control.data.client_area.width, 
			control.data.client_area.height
		);
	}

	static __reorder_bottom_dock = function() {
		var dtop = render_area.get_bottom();
		var bottoms = [];
		for (var i = 0, len = array_length(children); i < len; i++) {			
			var child		= children[@i];
			var inst		= child.instance;
			if (inst.data.control_tree_layout.docking == dock.bottom)
				array_push(bottoms, inst);
		}
		while (array_length(bottoms) > 0) {
			var inst = array_shift(bottoms);
			inst.y = dtop + margin_top + padding_top;
			dtop += inst.sprite_height + margin_bottom + padding_bottom;
		}
	}
	
	static __reorder_right_dock = function() {
		var dright = render_area.get_right();
		var rights = [];
		for (var i = 0, len = array_length(children); i < len; i++) {			
			var child		= children[@i];
			var inst		= child.instance;
			if (inst.data.control_tree_layout.docking == dock.right)
				array_push(rights, inst);
		}
		while (array_length(rights) > 0) {
			var inst = array_shift(rights);
			inst.x = dright + margin_left + padding_left;
			dright += inst.sprite_width + margin_right + padding_right;
		}
	}

	static draw_children = function() {
		if (__force_next) {
			layout();
			__layout_done = true;
			__force_next = false;
		}
		for (var i = 0, len = array_length(children); i < len; i++) {
			var child = children[@i];
			child.instance.__draw_instance();
			child.instance.depth = __root_tree.control.depth - 1; // set AFTER first draw! (gms draw chain... trust me)
		}
	}
	
	/// @function move_children(_by_x, _by_y)
	static move_children = function(_by_x, _by_y) {
		for (var i = 0, len = array_length(children); i < len; i++) {
			var child = children[@i];
			var inst = child.instance;
			inst.x += _by_x;
			inst.y += _by_y;
			inst.__text_x += _by_x;
			inst.__text_y += _by_y;
			if (is_child_of(inst, _baseContainerControl))
				inst.data.control_tree.move_children(_by_x, _by_y);
		}
	}

	/// @function move_children_after_sizing()
	static move_children_after_sizing = function(_force) {
		if (_force && is_root_tree()) layout(_force);
		for (var i = 0, len = array_length(children); i < len; i++) {
			var child = children[@i];
			with(child.instance) {
				__text_x += SELF_MOVE_DELTA_X;
				__text_y += SELF_MOVE_DELTA_Y;
				if (is_child_of(self, _baseContainerControl))
					data.control_tree.move_children_after_sizing();
			}
		}
		if (_force)
			control.force_redraw(false);
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

