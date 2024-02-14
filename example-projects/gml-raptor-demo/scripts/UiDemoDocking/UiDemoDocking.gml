/*
    sizeable window control tree demo
*/

function UiDemoDockableTreeChild(_control) : ControlTree(_control) constructor {
	
	reorder_docks = false;
	
	static __add_docked_label = function(_caption, _dock, _rot = 0, _draw = APP_THEME_MAIN, _drawmo = APP_THEME_BRIGHT) {
		return add_control(Label, { 
				text: _caption,
				remove_sprite_at_runtime: false,
				scribble_text_align: "[fa_middle][fa_center]",
				draw_color: _draw,
				draw_color_mouse_over: _drawmo,
				text_angle: _rot
			}).set_dock(_dock);
	}
	
	static add_left = function() {
		return __add_docked_label("LEFT-DOCK", dock.left, 90);
	}
	
	static add_right = function() {
		return __add_docked_label("RIGHT-DOCK", dock.right, -90);
	}

	static add_top = function() {
		return __add_docked_label("TOP-DOCK", dock.top);
	}

	static add_bottom = function() {
		return __add_docked_label("BOTTOM-DOCK", dock.bottom);
	}
	
	static add_fill = function() {
		return 
			add_control(Panel, {control_tree: UiDemoDockableTreeChild}).set_dock(dock.fill);
	}

}

function CreateUiDemoDocking(_control) {
	return new UiDemoDockableTreeChild(_control)
		.set_margin_all(2).set_padding_all(2)
		.add_top()
		.add_right()
		.add_bottom()
		.add_right()
		.add_bottom()
		.add_left()
		.add_bottom()
		.add_right()
		.add_bottom()
		.add_fill()
			.add_control(TextButton, {
				text: "=ui_demo/add_dock_plus",
				startup_width: 32, min_width: 32,
				on_left_click: function() { get_parent_tree().add_left(); }
			}).set_dock(dock.left).set_padding_all(2)
			.add_control(TextButton, {
				text: "=ui_demo/add_dock_plus",
				startup_width: 32, min_width: 32,
				on_left_click: function() { get_parent_tree().add_right(); }
			}).set_dock(dock.right).set_padding_all(2)
			.add_control(TextButton, {
				text: "=ui_demo/add_dock_plus",
				startup_height: 32,
				on_left_click: function() { get_parent_tree().add_top(); }
			}).set_dock(dock.top).set_padding_all(2)
			.add_control(TextButton, {
				text: "=ui_demo/add_dock_plus",
				startup_height: 32,
				on_left_click: function() { get_parent_tree().add_bottom(); }
			}).set_dock(dock.bottom).set_padding_all(2)
			.step_out();
		;
}