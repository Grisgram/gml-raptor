/// @description Build Window on create
event_inherited();

set_client_area(640, 482);
center_on_screen();

control_tree
	//.set_margin_all(4)
	.add_control(Label, {
			text:"=ui_demo/anchor_top_message",
			scribble_text_align:"[fa_middle][fa_center]"
		}).set_dock(dock.top)

	.add_control(TextButton, { startup_width: 180, text: "TOP/LEFT" })
//		.set_position(460, 450)
		.set_anchor(anchor.top | anchor.left)
//		.set_align(fa_bottom, fa_right)
		.set_position_from_align(fa_bottom, fa_right)
	.add_control(TextButton, { startup_width: 180, text: "TOP/LEFT/RIGHT" })
//		.set_position(230, 450)
		.set_anchor(anchor.top | anchor.left | anchor.right)
//		.set_align(fa_bottom, fa_center)
		.set_position_from_align(fa_bottom, fa_center)
	.add_control(TextButton, { startup_width: 180, text: "TOP/RIGHT" })
//		.set_position(0, 450)
		.set_anchor(anchor.top | anchor.right)
//		.set_align(fa_bottom, fa_left)
		.set_position_from_align(fa_bottom, fa_left)
	.add_control(TextButton, { startup_width: 180, text: "TOP/BTM/LEFT" })
//		.set_position(460, 225)
		.set_anchor(anchor.top | anchor.bottom | anchor.left)
//		.set_align(fa_middle, fa_right)
		.set_position_from_align(fa_middle, fa_right)
	.add_control(TextButton, { startup_width: 180, text: "ALL SIDES" })
//		.set_position(230, 225)
		.set_anchor(anchor.all_sides)
//		.set_align(fa_middle, fa_center)
		.set_position_from_align(fa_middle, fa_center)
	.add_control(TextButton, { startup_width: 180, text: "TOP/BTM/RIGHT" })
//		.set_position(0, 225)
		.set_anchor(anchor.top | anchor.bottom | anchor.right)
//		.set_align(fa_middle, fa_left)
		.set_position_from_align(fa_middle, fa_left)
	.add_control(TextButton, { startup_width: 180, text: "BOTTOM/LEFT" })
//		.set_position(460, 0)
		.set_anchor(anchor.bottom | anchor.left)
//		.set_align(fa_top, fa_right)
		.set_position_from_align(fa_top, fa_right)
	.add_control(TextButton, { startup_width: 180, text: "BTM/LEFT/RIGHT" })
//		.set_position(230, 0)
		.set_anchor(anchor.bottom | anchor.left | anchor.right)
//		.set_align(fa_top, fa_center)
		.set_position_from_align(fa_top, fa_center)
	.add_control(TextButton, { startup_width: 180, text: "BOTTOM/RIGHT" })
//		.set_position(0, 0)
		.set_anchor(anchor.bottom | anchor.right)
//		.set_align(fa_top, fa_left)
		.set_position_from_align(fa_top, fa_left)
;
