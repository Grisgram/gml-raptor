/*
	MsgBox - Simple MessageBox implementation
	
	This script allows you to create Windows-Style MessageBoxes with a title, text, an optional icon
	and any number of buttons.
	Buttons are always bottom-aligned and centered.
	Window dimension is calculated automatically based on the text to display.
	LG() is fully supported for title and text. Just supply a string that starts with "=" like in any other
	text property.
	
*/

#macro ACTIVE_MESSAGE_BOX		global.__active_message_box

enum msgbox_key {
	none, enter, escape
}

// init undefined on game load
ACTIVE_MESSAGE_BOX = undefined;

function __msgbox_button(obj, btn_text, cb, layer_name, react_on_key) constructor {
	object = obj;
	callback = cb;
	button_text = string_starts_with(btn_text, "=") ? LG(string_skip_start(btn_text, 1)) : btn_text;
	__layer_name = layer_name;
	hotkey = react_on_key;
	__button = undefined;
	static create_instance = function() {
		__button = instance_create_layer(0, 0, __layer_name, object);
		with (__button) {
			text = other.button_text;
			on_left_click = __msgbox_callback_wrapper;
		}
	}
}

// "self" is the button here - its called from the button
function __msgbox_callback_wrapper() {
	log(MY_NAME + ": Invoking callback.");
	var btnstruct = undefined;
	for (var i = 0; i < array_length(ACTIVE_MESSAGE_BOX.__buttons); i++) {
		if (ACTIVE_MESSAGE_BOX.__buttons[i].__button.id == id) {
			btnstruct = ACTIVE_MESSAGE_BOX.__buttons[i];
			break;
		}
	}
	if (btnstruct != undefined) {
		if (btnstruct.callback != undefined)
			btnstruct.callback();
	} else
		log("*ERROR* Could not find MessageBox Button in __buttons array!");
	ACTIVE_MESSAGE_BOX.close();
}

function __msgbox_x_button_default_callback() {
	if (ACTIVE_MESSAGE_BOX.x_button_uses_escape_callback) {
		var esc = ACTIVE_MESSAGE_BOX.__find_button_with_hotkey(msgbox_key.escape);
		if (esc != undefined && esc.callback != undefined) {
			log("MessageBox closed through X-Button redirect to escape-key-callback.");
			esc.callback();
		}
	} else if (ACTIVE_MESSAGE_BOX.x_button_callback != undefined) {
		log("MessageBox closed through X-Button callback.");
		ACTIVE_MESSAGE_BOX.x_button_callback();
	}
	ACTIVE_MESSAGE_BOX.close();
}

/// @function						MessageBox(window_object, layer_name, message_title, message_text)
/// @description					create a new messagebox window with a specified window object
/// @param {object} window_object	the object to create 			
/// @param {string} layer_name		the layer where the object shall be created
/// @param {string} message_title	title bar text
/// @param {string} message_text	text to show
/// @returns {struct}				the messagebox struct
function MessageBox(window_object, layer_name, message_title, message_text) constructor {
	if (window_object != MessageBoxWindow && !object_is_ancestor(window_object, MessageBoxWindow)) {
		log("*ERROR* Invalid Window Object for MessageBox. MUST be a child of MessageBoxWindow!");
	}
	title = string_starts_with(message_title, "=") ? LG(message_title) : message_title;
	text  = string_starts_with(message_text, "=")  ? LG(message_text)  : message_text;
	font  = undefined;
	text_color  = undefined;
	title_color = undefined;
	draw_color  = undefined;
	distance_between_buttons  = undefined;
	button_offset_from_bottom = undefined;
	text_distance_top_bottom  = undefined;
	
	allow_window_drag = true;
	
	scribble_text_align = undefined;
	text_xoffset = 0;
	text_yoffset = 0;

	scribble_title_align = undefined;
	title_xoffset = 0;
	title_yoffset = 0;
	
	x_button_visible = true;
	x_button_object = MessageBoxXButton;
	x_button_uses_escape_callback = true;
	x_button_callback = undefined;
	
	__window_object = window_object;
	__layer_name = layer_name;
	__buttons = [];
	__x_button = undefined;
	__prev_messagebox = undefined;
	
	window = undefined;

	/// @function					__find_button_with_hotkey(hotkey)
	/// @description				find the button that uses a specific hotkey
	/// @returns {struct}			the button with the hotkey
	static __find_button_with_hotkey = function(hotkey) {
		for (var i = 0; i < array_length(__buttons); i++) {
			if (__buttons[i].hotkey == hotkey) {
				return __buttons[i];
			}
		}
		return undefined;
	}

	static show = function() {
		__prev_messagebox = ACTIVE_MESSAGE_BOX;
		ACTIVE_MESSAGE_BOX = self;
		
		for (var i = 0; i < array_length(__buttons); i++)
			with (__buttons[i]) create_instance();
		
		if (x_button_visible) {
			__x_button = instance_create_layer(0, 0, __layer_name, x_button_object);
		}
		
		window = instance_create_layer(0, 0, __layer_name, __window_object);
		
		if (x_button_visible) {
			with (__x_button) {
				message_window = other.window;
				if (other.x_button_object == MessageBoxXButton)
					draw_color = other.title_color;
			}
		}

		with (window) {
			text    = other.text;
			title   = other.title;
			buttons = other.__buttons;
			
			window_is_movable = other.allow_window_drag;

			if (other.font		  != undefined) font_to_use = other.font;
			if (other.text_color  != undefined) text_color  = other.text_color;
			if (other.title_color != undefined) title_color = other.title_color;
			if (other.draw_color  != undefined) draw_color  = other.draw_color;
			
			if (other.distance_between_buttons  != undefined) distance_between_buttons  = other.distance_between_buttons;
			if (other.button_offset_from_bottom != undefined) button_offset_from_bottom = other.button_offset_from_bottom;
			if (other.text_distance_top_bottom != undefined) text_distance_top_bottom = other.text_distance_top_bottom;
			
			if (other.scribble_text_align  != undefined) scribble_text_align  = other.scribble_text_align;
			if (other.scribble_title_align != undefined) scribble_title_align = other.scribble_title_align;
			
			text_xoffset  = other.text_xoffset;
			text_yoffset  = other.text_yoffset;
			title_xoffset = other.title_xoffset;
			title_yoffset = other.title_yoffset;

			__draw_self(); // force variable update...
			x = UI_VIEW_CENTER_X - SELF_CENTER_X;
			y = UI_VIEW_CENTER_Y - SELF_CENTER_Y - UI_VIEW_HEIGHT / 6;
			__startup_x = x;
			__startup_y = y;
			force_redraw();
		}
		show_popup();
	}
	
	static close = function() {
		instance_destroy(window);
		for (var i = 0; i < array_length(__buttons); i++)
			instance_destroy(__buttons[i].__button);
		if (__x_button != undefined)
			instance_destroy(__x_button);
		ACTIVE_MESSAGE_BOX = __prev_messagebox;
		log("MessageBox closed.");
		if (ACTIVE_MESSAGE_BOX == undefined)
			hide_popup();
	}
	
	/// @function					add_button(button_object, button_text, on_click_callback)
	/// @description				add any custom button to the window
	/// @param {object} button_object
	/// @param {string} button_text
	/// @param {function} on_click_callback
	/// @param {enum=msgbox_key.none} hotkey
	static add_button = function(button_object, button_text, on_click_callback, hotkey = msgbox_key.none) {
		if (hotkey != msgbox_key.none) {
			// If the same hotkey is used multiple times, remove it from existing button (last one wins)
			var existing = __find_button_with_hotkey(hotkey);
			if (existing != undefined) existing.hotkey = msgbox_key.none;
		}
		array_push(__buttons, new __msgbox_button(button_object, button_text, on_click_callback, __layer_name, hotkey));
	}
	/// @function					add_yes(yes_button_object, on_yes_callback)
	/// @description				add a yes-button to the window
	/// @param {object} yes_button_object 			
	/// @param {function} on_yes_callback
	/// @param {enum=msgbox_key.none} hotkey
	static add_yes = function(yes_button_object, on_yes_callback, hotkey = msgbox_key.none) {
		add_button(yes_button_object, "=global_words/buttons/yes", on_yes_callback, hotkey);
	}
	/// @function					add_no(no_button_object, on_no_callback)
	/// @description				add a no-button to the window
	/// @param {object} no_button_object 			
	/// @param {function} on_no_callback
	/// @param {enum=msgbox_key.none} hotkey
	static add_no = function(no_button_object, on_no_callback, hotkey = msgbox_key.none) {
		add_button(no_button_object, "=global_words/buttons/no", on_no_callback, hotkey);
	}
	/// @function					add_ok(ok_button_object, on_ok_callback)
	/// @description				add an ok-button to the window
	/// @param {object} ok_button_object 			
	/// @param {function} on_ok_callback
	/// @param {enum=msgbox_key.none} hotkey
	static add_ok = function(ok_button_object, on_ok_callback, hotkey = msgbox_key.none) {
		add_button(ok_button_object, "=global_words/buttons/ok", on_ok_callback, hotkey);
	}
	/// @function					add_cancel(cancel_button_object, on_cancel_callback)
	/// @description				add a cancel-button to the window
	/// @param {object} cancel_button_object 			
	/// @param {function} on_cancel_callback
	/// @param {enum=msgbox_key.none} hotkey
	static add_cancel = function(cancel_button_object, on_cancel_callback, hotkey = msgbox_key.none) {
		add_button(cancel_button_object, "=global_words/buttons/cancel", on_cancel_callback, hotkey);
	}
	/// @function					add_continue(continue_button_object, on_continue_callback)
	/// @description				add a continue-button to the window
	/// @param {object} continue_button_object 			
	/// @param {function} on_continue_callback
	/// @param {enum=msgbox_key.none} hotkey
	static add_continue = function(continue_button_object, on_continue_callback, hotkey = msgbox_key.none) {
		add_button(continue_button_object, "=global_words/buttons/continue", on_continue_callback, hotkey);
	}
	
}
