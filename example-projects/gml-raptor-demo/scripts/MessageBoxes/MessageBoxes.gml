function msg_show_ok(title, text, ok_callback = undefined) {
	var msg = __get_default_msgbox(title, text);
	msg.add_ok(MESSAGEBOX_BUTTON, ok_callback, msgbox_key.enter);
	msg.x_button_uses_escape_callback = false;
	msg.x_button_callback = ok_callback;
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
	return new MessageBox(MESSAGEBOX_WINDOW, MESSAGEBOX_LAYER, title, text);
}
