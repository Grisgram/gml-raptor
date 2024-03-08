/// @description event
event_inherited();

var _panel_height = { startup_height: 256 }

var _info_label = {
	text: "=ui_demo/label_made_with_tree",
	text_color: APP_THEME_WHITE,
	text_color_mouse_over: APP_THEME_WHITE
}

__button = function(_text, _click, _hk = "") {
	return {
		startup_width: 320,
		startup_height: 64,
		text: _text,
		on_left_click: _click,
		hotkey_left_click: _hk
	};
}

__button_save_load = function(_text, _click, _hk = "") {
	return {
		startup_width: 320,
		startup_height: 64,
		text: _text,
		on_left_click: _click,
		hotkey_left_click: _hk,
		on_middle_click: ui_demo_save,
		hotkey_middle_click: "F2",
		on_right_click: ui_demo_load,
		hotkey_right_click: "F3",
		hotkey_only_when_topmost: false
	};
}

UI_ROOT
	.set_margin(80,0,60,0)
	.add_control(Panel, _panel_height)
		.set_padding(0,50,0,50)
		.set_margin(0,0,32,0)
		.set_dock(dock.bottom)
		.add_control(Panel, _panel_height)
		.set_dock(dock.left)
			.add_control(TextButton, __button("=main_menu/show_message"		, messageboxButton_click))
			.set_align(fa_middle, fa_left)
			.step_out()
		.add_control(Panel, _panel_height)
		.set_dock(dock.left)
			.add_control(TextButton, __button("=ui_demo/show_alignment"		, ui_demo_sizable_window_click))
			.set_align(fa_top, fa_left)
			.add_control(TextButton, __button("=ui_demo/show_login"			, ui_demo_login_click))
			.set_align(fa_bottom, fa_left)
			.step_out()
		.add_control(Panel, _panel_height)
		.set_dock(dock.left)
			.add_control(TextButton, __button("=ui_demo/show_control_tree"	, ui_demo_control_tree_click))
			.set_align(fa_top, fa_left)
			.add_control(TextButton, __button("=ui_demo/show_anchoring"		, ui_demo_control_anchoring_click))
			.set_align(fa_bottom, fa_left)
			.step_out()
		.add_control(Label, _info_label)
		.set_dock(dock.left)
		.add_control(TextButton, __button_save_load("=play/ui/race_exit_button"	, ui_demo_exit_click, "vk_escape"))
		.set_align(fa_middle, fa_right)
		.step_out()
;
