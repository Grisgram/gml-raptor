/*
    sizeable window control tree demo
*/

function UiDemoSizableTreeChild(_control) : ControlTree(_control) constructor {
}

function CreateUiDemoSizableTree(_control) {
	return new UiDemoSizableTreeChild(_control)
		.set_margin_all(8).set_padding_all(4)
		.add_control(Label, { 
				text: "TOP-DOCK",
				remove_sprite_at_runtime: false,
				scribble_text_align: "[fa_middle][fa_center]"
			}).set_dock(dock.top)
		.add_control(Label, { 
				text: "BOTTOM-DOCK",
				remove_sprite_at_runtime: false,
				scribble_text_align: "[fa_middle][fa_center]"
			}).set_dock(dock.bottom)
		.add_control(Label, { 
				text: "RIGHT-DOCK",
				remove_sprite_at_runtime: false,
				scribble_text_align: "[fa_middle][fa_center]"
			}).set_dock(dock.right)
		.add_control(Label, { 
				text: "LEFT-DOCK",
				remove_sprite_at_runtime: false,
				scribble_text_align: "[fa_middle][fa_center]"
			}).set_dock(dock.left)
		.add_control(Panel).set_dock(dock.fill)
			.add_control(Label, {
				text: "CENTER-FILL-DOCK",
				remove_sprite_at_runtime: false,
				scribble_text_align: "[fa_middle][fa_center]"
			}).set_spread(1).set_margin_all(16)
			.step_out()
		;
}