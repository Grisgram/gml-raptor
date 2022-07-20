function msg_show_ok(title, text, ok_callback = undefined) {
	var msg = __get_default_msgbox(title, text);
	msg.add_ok(MESSAGEBOX_BUTTON, ok_callback, msgbox_key.enter);
	return msg.show();
}

function msg_show_ok_cancel(title, text, ok_callback = undefined, cancel_callback = undefined) {
	var msg = __get_default_msgbox(title, text);
	msg.add_ok(MESSAGEBOX_BUTTON, ok_callback, msgbox_key.enter);
	msg.add_cancel(MESSAGEBOX_BUTTON, cancel_callback, msgbox_key.escape);
	return msg.show();
}

function msg_show_yes_no(title, text, yes_callback = undefined, no_callback = undefined) {
	var msg = __get_default_msgbox(title, text);
	msg.add_yes(MESSAGEBOX_BUTTON, yes_callback, msgbox_key.enter);
	msg.add_no(MESSAGEBOX_BUTTON, no_callback, msgbox_key.escape);
	return msg.show();
}

function msg_show_yes_no_cancel(title, text, yes_callback = undefined, no_callback = undefined, cancel_callback = undefined) {
	var msg = __get_default_msgbox(title, text);
	msg.add_yes(MESSAGEBOX_BUTTON, yes_callback, msgbox_key.enter);
	msg.add_no(MESSAGEBOX_BUTTON, no_callback, msgbox_key.none);
	msg.add_cancel(MESSAGEBOX_BUTTON, cancel_callback, msgbox_key.escape);
	return msg.show();
}

function __get_default_msgbox(title, text) {
	var msg = new MessageBox(MESSAGEBOX_WINDOW, MESSAGEBOX_LAYER, title, text);
	msg.draw_color				= MESSAGEBOX_WINDOW_BLEND;
	msg.draw_color_mouse_over	= MESSAGEBOX_WINDOW_BLEND;
	msg.title_color				= MESSAGEBOX_TITLE_BLEND;
	msg.text_color				= MESSAGEBOX_TEXT_BLEND;
	msg.text_color_mouse_over	= MESSAGEBOX_TEXT_BLEND;
	return msg;
}
