function msg_show_ok(title, text, ok_callback = undefined) {
	var msg = __get_default_msgbox(title, text);
	msg.add_ok(TextButton, ok_callback, msgbox_key.enter);
	msg.show();
}

function msg_show_ok_cancel(title, text, ok_callback = undefined, cancel_callback = undefined) {
	var msg = __get_default_msgbox(title, text);
	msg.add_ok(TextButton, ok_callback, msgbox_key.enter);
	msg.add_cancel(TextButton, cancel_callback, msgbox_key.escape);
	msg.show();
}

function msg_show_yes_no(title, text, yes_callback = undefined, no_callback = undefined) {
	var msg = __get_default_msgbox(title, text);
	msg.add_yes(TextButton, yes_callback, msgbox_key.enter);
	msg.add_no(TextButton, no_callback, msgbox_key.escape);
	msg.show();
}

function msg_show_yes_no_cancel(title, text, yes_callback = undefined, no_callback = undefined, cancel_callback = undefined) {
	var msg = __get_default_msgbox(title, text);
	msg.add_yes(TextButton, yes_callback, msgbox_key.enter);
	msg.add_no(TextButton, no_callback, msgbox_key.none);
	msg.add_cancel(TextButton, cancel_callback, msgbox_key.escape);
	msg.show();
}

function __get_default_msgbox(title, text) {
	var msg = new MessageBox(MessageBoxWindow, MESSAGEBOX_LAYER, title, text);
	msg.draw_color				= APP_THEME_BRIGHT;
	msg.draw_color_mouse_over	= APP_THEME_BRIGHT;
	msg.text_color				= APP_THEME_ACCENT;
	msg.text_color_mouse_over	= APP_THEME_ACCENT;
	msg.title_color				= APP_THEME_ACCENT;
	return msg;
}
