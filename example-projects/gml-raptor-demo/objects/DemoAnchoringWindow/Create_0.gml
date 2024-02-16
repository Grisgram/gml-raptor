/// @description Build Window on create
event_inherited();

control_tree
	.set_margin_all(4)
	.add_control(Label, {
			text:"=ui_demo/anchor_top_message",
			scribble_text_align:"[fa_middle][fa_center]"
		}).set_dock(dock.top)
	.new_line()

	.add_control(Label, { remove_sprite_at_runtime: false, text: "TOP/LEFT" })
//		.set_anchor(anchor.top | anchor.left)
		.set_align(fa_bottom, fa_right)
	.add_control(Label, { remove_sprite_at_runtime: false, text: "TOP/LEFT/RIGHT" })
//		.set_anchor(anchor.top | anchor.left | anchor.right)
		.set_align(fa_bottom, fa_center)
	.add_control(Label, { remove_sprite_at_runtime: false, text: "TOP/RIGHT" })
//		.set_anchor(anchor.top | anchor.right)
		.set_align(fa_bottom, fa_left)
	.add_control(Label, { remove_sprite_at_runtime: false, text: "TOP/BOTTOM/LEFT" })
//		.set_anchor(anchor.top | anchor.bottom | anchor.left)
		.set_align(fa_middle, fa_right)
	.add_control(Label, { remove_sprite_at_runtime: false, text: "TOP/LEFT/RIGHT/BOTTOM" })
//		.set_anchor(anchor.all_sides)
		.set_align(fa_middle, fa_center)
	.add_control(Label, { remove_sprite_at_runtime: false, text: "TOP/BOTTOM/RIGHT" })
//		.set_anchor(anchor.top | anchor.bottom | anchor.right)
		.set_align(fa_middle, fa_left)
	.add_control(Label, { remove_sprite_at_runtime: false, text: "BOTTOM/LEFT" })
//		.set_anchor(anchor.bottom | anchor.left)
		.set_align(fa_top, fa_right)
	.add_control(Label, { remove_sprite_at_runtime: false, text: "BOTTOM/LEFT/RIGHT" })
//		.set_anchor(anchor.bottom | anchor.left | anchor.right)
		.set_align(fa_top, fa_center)
	.add_control(Label, { remove_sprite_at_runtime: false, text: "BOTTOM/RIGHT" })
//		.set_anchor(anchor.top | anchor.left)
		.set_align(fa_top, fa_left)
;
