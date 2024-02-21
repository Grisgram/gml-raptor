/*
    The ControlTree for MessageboxWindows
*/

function MsgBoxControlTree(_control) : ControlTree(_control) constructor {
	construct("MsgBoxControlTree");
	
	add_control(RaptorPanel, {
			startup_height: ACTIVE_MESSAGE_BOX.__get_max_button_height()
		})
		.set_margin(MESSAGEBOX_INNER_MARGIN, 0, MESSAGEBOX_INNER_MARGIN, 0)
		.set_dock(dock.bottom)
		.add_control(RaptorPanel)
			.set_name("panButtons")
			.set_align(fa_middle, fa_center)
		.step_out()
	.step_out()
	.add_control(MESSAGEBOX_TEXT_LABEL, { 
		text: ACTIVE_MESSAGE_BOX.text,
		font_to_use: MESSAGEBOX_FONT,
		scribble_text_align: "[fa_top][fa_center]"
	})
	.set_margin_all(MESSAGEBOX_INNER_MARGIN)
	.set_name("lblText")
	.set_dock(dock.fill)
;

}