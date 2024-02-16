/// @description Build Window on create
event_inherited();

control_tree
	.set_margin_all(8)
	.add_control(Label, {
			text:"=ui_demo/alignment_top_message",
			scribble_text_align:"[fa_middle][fa_center]"
		}).set_dock(dock.top)

	.add_control(Panel).set_dock(dock.fill).set_padding_all(4)
		.add_control(TextButton, { startup_width: 180, text: "TOP/LEFT"		}).set_align(fa_top,	fa_left)
		.add_control(TextButton, { startup_width: 180, text: "TOP/CENTER"	}).set_align(fa_top,	fa_center)
		.add_control(TextButton, { startup_width: 180, text: "TOP/RIGHT"	}).set_align(fa_top,	fa_right)
		.add_control(TextButton, { startup_width: 180, text: "MIDDLE/LEFT"	}).set_align(fa_middle, fa_left)
		.add_control(TextButton, { startup_width: 180, text: "MIDDLE/CENTER"}).set_align(fa_middle, fa_center)
		.add_control(TextButton, { startup_width: 180, text: "MIDDLE/RIGHT"	}).set_align(fa_middle, fa_right)
		.add_control(TextButton, { startup_width: 180, text: "BOTTOM/LEFT"	}).set_align(fa_bottom, fa_left)
		.add_control(TextButton, { startup_width: 180, text: "BOTTOM/CENTER"}).set_align(fa_bottom, fa_center)
		.add_control(TextButton, { startup_width: 180, text: "BOTTOM/RIGHT"	}).set_align(fa_bottom, fa_right)
;
