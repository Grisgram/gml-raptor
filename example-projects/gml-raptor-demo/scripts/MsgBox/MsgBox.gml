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
		return __button;
	}
}

// "self" is the button here - its called from the button
function __msgbox_callback_wrapper() {
	vlog($"{MY_NAME}: Invoking callback.");
	var btnstruct = undefined;
	for (var i = 0; i < array_length(ACTIVE_MESSAGE_BOX.__buttons); i++) {
		if (ACTIVE_MESSAGE_BOX.__buttons[i].__button.id == id) {
			btnstruct = ACTIVE_MESSAGE_BOX.__buttons[i];
			break;
		}
	}
	ACTIVE_MESSAGE_BOX.close();
	if (btnstruct != undefined) {
		if (is_method(btnstruct.callback))
			btnstruct.callback();
	} else
		elog($"*ERROR* Could not find MessageBox Button in __buttons array!");
}

function __msgbox_x_button_default_callback() {
	var callback_to_use = undefined;
	if (ACTIVE_MESSAGE_BOX.x_button_uses_escape_callback) {
		var esc = ACTIVE_MESSAGE_BOX.__find_button_with_hotkey(msgbox_key.escape);
		if (esc != undefined && esc.callback != undefined) {
			vlog($"MessageBox closed through X-Button redirect to escape-key-callback.");
			callback_to_use = esc.callback;
		}
	} else if (ACTIVE_MESSAGE_BOX.x_button_callback != undefined) {
		vlog($"MessageBox closed through X-Button callback.");
		callback_to_use = ACTIVE_MESSAGE_BOX.x_button_callback;
	}
	ACTIVE_MESSAGE_BOX.close();
	if (callback_to_use != undefined)
		callback_to_use();
}

/// @function						MessageBox(window_object, layer_name, message_title, message_text)
/// @description					create a new messagebox window with a specified window object
/// @param {object} window_object	the object to create 			
/// @param {string} layer_name		the layer where the object shall be created
/// @param {string} message_title	title bar text
/// @param {string} message_text	text to show
/// @returns {struct}				the messagebox struct
function MessageBox(window_object, layer_name, message_title, message_text) constructor {
	if (!is_child_of(window_object, MessageBoxWindow)) {
		elog($"**ERROR** Invalid Window Object for MessageBox. MUST be a child of MessageBoxWindow!");
	}
	title = string_starts_with(message_title, "=") ? LG(message_title) : message_title;
	text  = string_starts_with(message_text, "=")  ? LG(message_text)  : message_text;
	
	distance_between_buttons	= undefined;
	button_offset_from_bottom	= undefined;
	text_distance_top_bottom	= undefined;
		
	x_button_uses_escape_callback = true;
	x_button_callback = undefined;
	
	__window_object = window_object;
	__layer_name = layer_name;
	__buttons = [];
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
		dlog($"Showing MessageBox");
		__prev_messagebox = ACTIVE_MESSAGE_BOX;
		ACTIVE_MESSAGE_BOX = self;
		
		for (var i = 0; i < array_length(__buttons); i++)
			with (__buttons[i]) create_instance();
		
		window = instance_create_layer(0, 0, __layer_name, __window_object);
		
		with (window) {
			text    = other.text;
			title   = other.title;
			buttons = other.__buttons;
			
			if (other.distance_between_buttons  != undefined) distance_between_buttons  = other.distance_between_buttons;
			if (other.button_offset_from_bottom != undefined) button_offset_from_bottom = other.button_offset_from_bottom;
			if (other.text_distance_top_bottom != undefined) text_distance_top_bottom = other.text_distance_top_bottom;
			
			force_redraw();
			__draw_self(); // force variable update...
			
			if (draw_on_gui) {
				x = UI_VIEW_CENTER_X - SELF_CENTER_X;
				y = UI_VIEW_CENTER_Y - SELF_CENTER_Y - UI_VIEW_HEIGHT / 6;
				y = min(max(y, 0), UI_VIEW_HEIGHT - sprite_height);
			} else {
				x = VIEW_CENTER_X - SELF_VIEW_CENTER_X;
				y = VIEW_CENTER_Y - SELF_VIEW_CENTER_Y - VIEW_HEIGHT / 6;
				y = min(max(y, 0), VIEW_HEIGHT - sprite_height);
			}
			x = max(x, 0);
			__startup_x = x;
			__startup_y = y;
			force_redraw();
		}
		show_popup(MESSAGEBOX_LAYER);
		BROADCASTER.send(self, __RAPTOR_BROADCAST_MSGBOX_OPENED);
		return self;
	}
	
	static close = function() {
		for (var i = 0; i < array_length(__buttons); i++)
			instance_destroy(__buttons[i].__button);
		window.close();
		ACTIVE_MESSAGE_BOX = __prev_messagebox;
		BROADCASTER.send(self, __RAPTOR_BROADCAST_MSGBOX_CLOSED);
		dlog($"MessageBox closed");
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
		return self;
	}
	/// @function					add_yes(yes_button_object, on_yes_callback)
	/// @description				add a yes-button to the window
	/// @param {object} yes_button_object 			
	/// @param {function} on_yes_callback
	/// @param {enum=msgbox_key.none} hotkey
	static add_yes = function(yes_button_object, on_yes_callback, hotkey = msgbox_key.none) {
		return add_button(yes_button_object, "=global_words/buttons/yes", on_yes_callback, hotkey);
	}
	/// @function					add_no(no_button_object, on_no_callback)
	/// @description				add a no-button to the window
	/// @param {object} no_button_object 			
	/// @param {function} on_no_callback
	/// @param {enum=msgbox_key.none} hotkey
	static add_no = function(no_button_object, on_no_callback, hotkey = msgbox_key.none) {
		return add_button(no_button_object, "=global_words/buttons/no", on_no_callback, hotkey);
	}
	/// @function					add_ok(ok_button_object, on_ok_callback)
	/// @description				add an ok-button to the window
	/// @param {object} ok_button_object 			
	/// @param {function} on_ok_callback
	/// @param {enum=msgbox_key.none} hotkey
	static add_ok = function(ok_button_object, on_ok_callback, hotkey = msgbox_key.none) {
		return add_button(ok_button_object, "=global_words/buttons/ok", on_ok_callback, hotkey);
	}
	/// @function					add_cancel(cancel_button_object, on_cancel_callback)
	/// @description				add a cancel-button to the window
	/// @param {object} cancel_button_object 			
	/// @param {function} on_cancel_callback
	/// @param {enum=msgbox_key.none} hotkey
	static add_cancel = function(cancel_button_object, on_cancel_callback, hotkey = msgbox_key.none) {
		return add_button(cancel_button_object, "=global_words/buttons/cancel", on_cancel_callback, hotkey);
	}
	/// @function					add_continue(continue_button_object, on_continue_callback)
	/// @description				add a continue-button to the window
	/// @param {object} continue_button_object 			
	/// @param {function} on_continue_callback
	/// @param {enum=msgbox_key.none} hotkey
	static add_continue = function(continue_button_object, on_continue_callback, hotkey = msgbox_key.none) {
		return add_button(continue_button_object, "=global_words/buttons/continue", on_continue_callback, hotkey);
	}
	
}
