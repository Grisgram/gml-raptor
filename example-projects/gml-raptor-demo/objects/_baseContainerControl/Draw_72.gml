/// @description layout if necessary
event_inherited();

if (!draw_on_gui && CONTROL_NEED_LAYOUT && is_null(control_tree.parent_tree))
	control_tree.layout();
