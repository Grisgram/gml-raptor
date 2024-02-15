/*
    sizeable window control tree demo
*/

function UiDemoDockableTreeChild(_control) : ControlTree(_control) constructor {
	construct("UiDemoDockableTreeChild");
	
	reorder_docks = false;
	
	static __add_docked_label = function(_caption, _dock, _rot = 0, _draw = APP_THEME_MAIN, _drawmo = APP_THEME_BRIGHT) {
		return add_control(TextButton, { 
				text: _caption,
				scribble_text_align: "[fa_middle][fa_center]",
				text_color: APP_THEME_WHITE,
				text_color_mouse_over: APP_THEME_WHITE,
				draw_color: _draw,
				draw_color_mouse_over: _drawmo,
				text_angle: _rot,
				min_width: 32,
				min_height: 32,
				on_left_click: function() {
					if (text_angle == 0) scale_sprite_to(sprite_width, sprite_height + 8);
					else scale_sprite_to(sprite_width + 8, sprite_height);
					get_parent_tree().layout();
				},
				on_right_click: function() {
					if (text_angle == 0) scale_sprite_to(sprite_width, max(min_height, sprite_height - 8));
					else scale_sprite_to(max(min_height, sprite_width - 8), sprite_height);
					get_parent_tree().layout();
				}
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
		.set_margin_all(2)
		.set_padding_all(2)
		.add_top()
		.add_bottom()
		.add_left()
		.add_right()
		.add_fill()
			.set_name("fill")
			.add_control(TextButton, {
				text: "=ui_demo/add_dock_plus",
				startup_width: 32, min_width: 32,
				on_left_click: function() { get_parent_tree().add_left(); }
			}).set_dock(dock.left).set_padding_all(2)
			//.add_control(TextButton, {
			//	text: "=ui_demo/add_dock_plus",
			//	startup_width: 32, min_width: 32,
			//	on_left_click: function() { get_parent_tree().add_right(); }
			//}).set_dock(dock.right).set_padding_all(2)
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
			.step_out()
		;
}