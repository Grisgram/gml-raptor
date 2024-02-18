/// @description Build Window on create
event_inherited();

set_client_area(800, 482);
center_on_screen();

var fxoff = 230;
var fyoff = 110;

control_tree
	//.set_margin_all(4)
	.add_control(Label, {
			text:"=ui_demo/anchor_top_message",
			scribble_text_align:"[fa_middle][fa_center]"
		}).set_dock(dock.top)

	.add_control(TextButton, { startup_width: 180, text: "TOP/BTM/LEFT" })
		.set_anchor(anchor.top | anchor.left | anchor.bottom)
		.set_position_from_align(fa_top, fa_left)
	.add_control(TextButton, { startup_width: 180, text: "ALL SIDES" })
		.set_anchor(anchor.all_sides)
		.set_position_from_align(fa_top, fa_center)
	.add_control(TextButton, { startup_width: 180, text: "TOP/BTM/RIGHT" })
		.set_anchor(anchor.top | anchor.right | anchor.bottom)
		.set_position_from_align(fa_top, fa_right)
	.add_control(TextButton, { startup_width: 180, text: "TOP/BTM/LEFT" })
		.set_anchor(anchor.top | anchor.bottom | anchor.left)
		.set_position_from_align(fa_middle, fa_left)
	.add_control(TextButton, { startup_width: 180, text: "ALL SIDES" })
		.set_anchor(anchor.all_sides)
		.set_position_from_align(fa_middle, fa_center)
	.add_control(TextButton, { startup_width: 180, text: "TOP/BTM/RIGHT" })
		.set_anchor(anchor.top | anchor.bottom | anchor.right)
		.set_position_from_align(fa_middle, fa_right)
	.add_control(TextButton, { startup_width: 180, text: "TOP/BTM/LEFT" })
		.set_anchor(anchor.top | anchor.bottom | anchor.left)
		.set_position_from_align(fa_bottom, fa_left)
	.add_control(TextButton, { startup_width: 180, text: "ALL SIDES" })
		.set_anchor(anchor.all_sides)
		.set_position_from_align(fa_bottom, fa_center)
	.add_control(TextButton, { startup_width: 180, text: "TOP/BTM/RIGHT" })
		.set_anchor(anchor.top | anchor.bottom | anchor.right)
		.set_position_from_align(fa_bottom, fa_right)
		
	.add_control(TextButton, { min_width: 32, startup_width: 32, text: "TL" })
		.set_anchor(anchor.top | anchor.left)
		.set_position_from_align(fa_top, fa_left, fxoff, fyoff)
	.add_control(TextButton, { min_width: 32, startup_width: 32, text: "TR" })
		.set_anchor(anchor.top | anchor.right)
		.set_position_from_align(fa_top, fa_right, -fxoff, fyoff)
	.add_control(TextButton, { min_width: 32, startup_width: 32, text: "BL" })
		.set_anchor(anchor.bottom | anchor.left)
		.set_position_from_align(fa_bottom, fa_left, fxoff, -fyoff)
	.add_control(TextButton, { min_width: 32, startup_width: 32, text: "BR" })
		.set_anchor(anchor.bottom | anchor.right)
		.set_position_from_align(fa_bottom, fa_right, -fxoff, -fyoff)
	.add_control(TextButton, { min_width: 32, startup_width: 32, text: "LC" })
		.set_align(fa_middle, fa_left, fxoff, 0)
	.add_control(TextButton, { min_width: 32, startup_width: 32, text: "RC" })
		.set_align(fa_middle, fa_right, -fxoff, 0)
;
