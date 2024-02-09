/// @description build object hierarchy
event_inherited();

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

/// @function onLayoutStarting()
/// @description	Invoked when layouting the container starts.
//					Adapt any values for the layout, if needed, here (like the client_area)
onLayoutStarting = function() {
}

__original_draw_instance = __draw_instance;

__draw_instance = function() {
	__original_draw_instance();
	control_tree.draw_children();
}