/// @description event
event_inherited();
exit;

UI_ROOT
	.set_margin(0, 32, 32, 0)
	.add_control(Label, {
		startup_width: 40,
		text_angle: -90,
		text: "WELCOME TO THE UI DEMO",
		remove_sprite_at_runtime: false
	})
	.set_padding_all(8)
	.set_dock(dock.left)
	.add_control(DemoAnchoringWindow, { 
		window_is_movable: false,
		window_is_sizable: false,
		center_on_open: false
	})
	.set_margin_all(32)
	.set_align(fa_top, fa_right)
;