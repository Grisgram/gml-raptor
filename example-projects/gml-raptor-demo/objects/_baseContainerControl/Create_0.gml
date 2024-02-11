/// @description build object hierarchy
event_inherited();

__first_draw = true;

if (!SAVEGAME_LOAD_IN_PROGRESS) {
	// put the tree to save data
	if (!is_instanceof(control_tree, ControlTree)) {
		control_tree = construct_or_invoke(control_tree, self);
	}
	control_tree.bind_to(self);
	data.control_tree_layout = new ControlTreeLayout();
	data.control_tree = control_tree;
	data.client_area = new Rectangle(0, 0, sprite_width, sprite_height);
}

__original_draw_instance = __draw_instance;

__draw_instance = function() {
	data.client_area.set(0, 0, sprite_width, sprite_height);
	__original_draw_instance();
	
	if (__first_draw) {
		control_tree.layout();
		__first_draw = false;
	}

	control_tree.draw_children();
	
	// this code draws the client area in red, if one day there's a bug with alignment
	//draw_set_color(c_red);
	//draw_rectangle(x+data.client_area.left, y+data.client_area.top, x+data.client_area.get_right(), y+data.client_area.get_bottom(), true);
	//draw_set_color(c_white);
}