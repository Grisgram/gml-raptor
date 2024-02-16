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
	__current_line	= 0;
	
	__force_next	= false;
	__finished		= false;
	__line_counts	= [];

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
		return eq(__root_tree, self);
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
		// Finished is a flag telling the layouter, whether it needs to count lines before rendering
		// Every change of the structure forces this to false, to recalculation will happen
		__finished = false;
		
		var inst = instance_create(control.x, control.y, layer_of(control), _objtype, _init_struct);
		if (!is_child_of(inst, _baseControl)) {
			instance_destroy(inst);
			throw("ControlTree accepts only raptor controls (child of _baseControl) as children!");
		}
		inst.__container = control;
		inst.draw_on_gui = control.draw_on_gui;
		inst.autosize = false;
		inst.data.control_tree_layout = new ControlTreeLayout();

		__last_entry = new ControlTreeEntry(inst);
		__last_entry.line_index = __current_line;
		array_push(children, __last_entry);
		
		//vlog($"{name_of(control)} added {name_of(inst)} in line {__current_line}");
		
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
		if (_dock != dock.none) 
			__last_entry.line_index = -1;
			
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
	
	/// @function set_align(_valign = fa_top, _halign = fa_left)
	static set_align = function(_valign = fa_top, _halign = fa_left) {
		__last_layout.valign = _valign;
		__last_layout.halign = _halign;
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
	
	/// @function new_line()
	static new_line = function() {
		__last_entry.newline_after = true;
		__current_line++;
		return self;
	}
	
	/// @function step_out()
	static step_out = function() {
		__last_entry.stepout_after = true;
		return parent_tree;
	}
	
	static finish = function() {
		__force_next = true;
		__finished = true;
		__line_counts = [];
		var cnt = 0;
		var last_line = 0;
		for (var i = 0, len = array_length(children); i < len; i++) {			
			if (children[@i].line_index == last_line) {
				cnt++;
			} else {
				array_push(__line_counts, cnt);
				last_line++;
				cnt = 1;
			}
		}
		// push the last line too!
		array_push(__line_counts, cnt);
		
		if (parent_tree == undefined)
			vlog($"Finished layout of {name_of(control)} with line counts {__line_counts}");
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
		if (!__finished)
			finish();

		control_size.set(control.sprite_width, control.sprite_height);
		update_render_area();
		
		var startx		= render_area.left;
		var starty		= render_area.top ;
		
		runner.left		= startx;
		runner.top		= starty;
		runner.right	= render_area.get_right();
		runner.bottom	= render_area.get_bottom();
		
		var maxh		= 0;
		var maxw		= 0;
		var child		= undefined;
		var inst		= undefined;
		var ilayout		= undefined;
		var itemcount	= 0;
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
			itemcount	= (child.line_index >= 0 ? __line_counts[@child.line_index] : 0);
			oldinstx	= inst.x;
			oldinsty	= inst.y;
			oldsizex	= inst.sprite_width;
			oldsizey	= inst.sprite_height;
			
			if (_forced) inst.force_redraw();
			
			if (ilayout.docking == dock.none) {
				// if no alignment and no docking, place it "runner-style"
				if (ilayout.halign == fa_left)
					inst.x = runner.left + margin_left + padding_left + inst.sprite_xoffset;
				if (ilayout.valign == fa_top)
					inst.y = runner.top + margin_top  + padding_top  + inst.sprite_yoffset;
			}
			
			if (is_child_of(inst, _baseContainerControl)) {
				inst.data.control_tree.layout(_forced);
				inst.__update_client_area();
			}
			
			ilayout.apply_docking(render_area, inst, control);
			// apply_spreading will exit if anchor or dock is set, so no worries here
			ilayout.apply_spreading(itemcount, render_area, inst, control);
			// after spreading, alignment might need a calculation
			ilayout.apply_alignment(inst, control);
			
			maxh = max(maxh, inst.sprite_height + padding_bottom + margin_bottom);

			runner.left = inst.x + inst.sprite_width - inst.sprite_xoffset + padding_right + margin_right;
			maxw = max(maxw, runner.left - startx);
			if (child.newline_after) {
				runner.left = startx;
				runner.top += maxh;
				maxh = 0;
			}
			if (child.stepout_after && control.data.control_tree_layout.docking != dock.fill)
				runner.top += margin_bottom + padding_bottom;
		}
						
		if (reorder_docks) {
			__reorder_bottom_dock();
			__reorder_right_dock();
		}
		
		if ((_forced || control.__auto_size_with_content) &&
			control.data.control_tree_layout.docking != dock.fill) {
			var newheight = runner.top + maxh - starty;
			with(control) scale_sprite_to(max(sprite_width, maxw), max(sprite_height, newheight));
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
		if (!__finished) layout();
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
	
	/// @function move_children_after_sizing(_by_x, _by_y)
	static move_children_after_sizing = function(_by_x, _by_y) {
		if (is_root_tree()) layout();
		for (var i = 0, len = array_length(children); i < len; i++) {
			var child = children[@i];
			var inst = child.instance;
			if (inst.data.control_tree_layout.docking != dock.left &&
				inst.data.control_tree_layout.docking != dock.top) {
				inst.__text_x += _by_x;
				inst.__text_y += _by_y;
				if (is_child_of(inst, _baseContainerControl))
					inst.data.control_tree.move_children_after_sizing(_by_x, _by_y);
			}
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

