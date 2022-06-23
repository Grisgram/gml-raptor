/// @description DOCS inside!

event_inherited();

/*
	IMPORTANT!
	Right beneath this comment block you find the array variable forbidden_characters.
	Add (array_push) any characters you want to be forbidden to this array, best from outside,
	not by modifying the source code of this control (library updates would nullify your modifications).
	
	By default, those characters are forbidden: CR/LF, TAB and BACKSPACE and internal control characters.
	The Inputbox will react normally on keypress of BACKSPACE, but it will not allow to ADD
	a backspace character to the string (that's an important difference!)
	
*/

forbidden_characters = [chr(13), chr(10), chr(8), chr(127), "[", "]", "\"", "\\"];

cursor_pos = 0;
selection_length = 0;
selected_text = "";

__last_selection_length = 0;
__selection_rect = new Rectangle();
__selection_start = 0;

__cursor_frame = 0;
__cursor_visible = true;
__last_cursor_visible = false;

__has_focus = false;

__cursor_x = 0;
__cursor_y = 0;
__cursor_height = 0;
__first_draw = true;
__backup_color_text = c_white;

__key_repeat_frame = 0;
__wait_for_key_repeat = false;
__repeat_interval_mode = false;
__repeating_key = undefined;

/// @function					set_focus()
/// @description				Set input focus to this
set_focus = function(from_tab = false) {
	if (__has_focus) 
		return;
	
	with (InputBox) lose_focus();
	log(MY_NAME + ": got focus");
	__has_focus = true;
	text_color = text_color_focus;
	if (from_tab) set_cursor_pos(string_length(text));
	selection_length = 0;
	__last_selection_length = -1;
	force_redraw();
}

/// @function					lose_focus()
/// @description				Remove input focus from this
lose_focus = function() {
	if (!__has_focus) 
		return;
	
	log(MY_NAME + ": lost focus");
	__has_focus = false;
	text_color = __backup_color_text;
	selection_length = 0;
	__last_selection_length = -1;
	force_redraw();
}

/// @function					__reset_cursor_blink
/// @description				ensure, cursor stays visible
__reset_cursor_blink = function() {
	__cursor_frame = 0;
	__cursor_visible = true;
	__last_cursor_visible = false;
}

/// @function					set_cursor_pos(pos)
/// @description				set the cursor at character pos and ensure cursor is instantly visible
/// @param {int} pos 			
/// @param {bool=false} force_extend_selection 			
set_cursor_pos = function(pos, force_extend_selection = false) {
	if (keyboard_check(vk_shift) || force_extend_selection)
		selection_length -= (pos - cursor_pos);
	else
		selection_length = 0;
	cursor_pos = pos;
	__reset_cursor_blink();
}

/// @function					__start_wait_for_key_repeat(key)
/// @param {constant} key
__start_wait_for_key_repeat = function(key) {
	if (!__wait_for_key_repeat || key != __repeating_key) {
		__wait_for_key_repeat = true;
		__repeat_interval_mode = false;
		__key_repeat_frame = 0;
		__repeating_key = key;
	}
}

/// @function					__stop_wait_for_key_repeat
__stop_wait_for_key_repeat = function() {
	__wait_for_key_repeat = false;
	__repeat_interval_mode = false;
	__key_repeat_frame = 0;
	__repeating_key = undefined;
}

/// @function					scribble_add_text_effects(scribbletext)
/// @description				called when a scribble element is created to allow adding custom effects.
///								overwrite (redefine) in child controls
/// @param {struct} scribbletext
scribble_add_text_effects = function(scribbletext) {
	// We do not add any effects but we use this callback to set the cursor pos
	// to the end of the string, if called first time
	if (__first_draw) {
		__first_draw = false;
		__backup_color_text = text_color;
		cursor_pos = string_length(text);
	}
}

/// @function					draw_scribble_text()
/// @description				draw the text - redefine for additional text effects
draw_scribble_text = function() {
	if (string_length(text) > max_string_length_characters) {
		text = string_copy(text, 1, max_string_length_characters);
		force_redraw();
		__draw_self();
		return;
	}
	if (__has_focus) {
		if (selection_length != __last_selection_length) {
			__last_selection_length = selection_length;
			if (selection_length != 0) {
				var startpos = cursor_pos;
				var endpos = cursor_pos + selection_length;
				if (startpos > endpos) {
					var exc = startpos;
					startpos = endpos;
					endpos = exc;
				}
				var substr = string_copy(text, 1, startpos);
				var xleft = __create_scribble_object("[fa_left]", substr).get_width();
				__selection_start = startpos + 1;
				selected_text = string_copy(text, __selection_start, abs(selection_length));
				var xwidth = __create_scribble_object("[fa_left]", selected_text).get_width() - 1;
				var bbox = __scribble_text.get_bbox(__text_x, __text_y);
				var txstart = bbox.left;
				__selection_rect.set(txstart + xleft, bbox.top, xwidth, __scribble_text.get_height());
			} else 
				__selection_rect.set(0,0,0,0);
		}
		if (selection_length != 0) {
			draw_set_color(text_color_focus);
			draw_set_alpha(0.5);
			draw_rectangle(__selection_rect.left, __selection_rect.top, __selection_rect.get_right(), __selection_rect.get_bottom(), false);
			draw_set_alpha(1);
			draw_set_color(c_white);
		}
	}
	__scribble_text.draw(__text_x, __text_y);
}

/// @function					__set_cursor_pos_from_click()
/// @description				set cursor pos inside text after left click
/// @param {bool=false} force_extend_selection 			
__set_cursor_pos_from_click = function(force_extend_selection = false) {
	var full_box = __scribble_text.get_bbox(__text_x, __text_y);
	var xinside = GUI_MOUSE_X - full_box.left;
	if (xinside < 0) {
		set_cursor_pos(0, force_extend_selection);
		return;
	}
	if (xinside > full_box.width) {
		set_cursor_pos(string_length(text), force_extend_selection);
		return;
	}
	var last_right = 0;
	var i = 1; repeat(string_length(text)) {
		var substr = string_copy(text, 1, i++);
		var scrib = scribble("[fa_left]" + substr).starting_format(
				font_to_use == "undefined" ? global.__scribble_default_font : font_to_use, text_color);
		var bbox = scrib.get_bbox(full_box.left, full_box.top);
		var box_inside = bbox.right - full_box.left;
		if (box_inside < xinside)
			last_right = box_inside;
		else
			break;
	}
	set_cursor_pos(max(0, i - 2), force_extend_selection);
}