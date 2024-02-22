/// @description build object hierarchy
event_inherited();

__first_draw			 = true;
__auto_size_with_content = false;
__mouse_events_locked	 = true;

if (!SAVEGAME_LOAD_IN_PROGRESS) {
	// put the tree to save data
	if (!is_instanceof(control_tree, ControlTree)) {
		control_tree = construct_or_invoke(control_tree, self);
	}
	control_tree.bind_to(self);
	data.control_tree_layout = new ControlTreeLayout();
	data.control_tree = control_tree;
}

/// @function get_element(_name)
/// @description Retrieve a child control by its name. Returns the instance or undefined
get_element = function(_name) {
	return control_tree.get_element(_name);
}

if (!variable_instance_exists(self, "__original_draw_instance"))
	__original_draw_instance = __draw_instance;

__draw_instance = function(_force = false) {
	update_client_area();

	if (__first_draw || _force) {
		control_tree.layout();
	}

	__original_draw_instance(_force);
	control_tree.draw_children();
	
	if (__first_draw) {
		__first_draw = false;
		control_tree.invoke_on_opened();
	}
	
	// this code draws the client area in red, if one day there's a bug with alignment
	//draw_set_color(c_red);
	//draw_rectangle(x+data.client_area.left, y+data.client_area.top, x+data.client_area.get_right(), y+data.client_area.get_bottom(), true);
	//draw_set_color(c_white);
}