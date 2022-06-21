/// @description Cursor control & add text

if (!__has_focus || HIDDEN_BEHIND_POPUP) exit;

__cut_selection = function() {
	if (selection_length == 0)
		return "";
		
	var rv = string_copy(text, __selection_start, abs(selection_length));
	text = string_copy(text, 1, __selection_start - 1) + 
		   string_copy(text, __selection_start + abs(selection_length), 
					   string_length(text) - __selection_start - string_length(selected_text) + 1);
	set_cursor_pos(max(0, __selection_start - 1));
	selected_text = "";
	selection_length = 0;
	return rv;
}

__backspace_char = function() {
	if (cursor_pos == 0)
		return;
		
	if (selection_length == 0) {
		text = string_copy(text, 1, cursor_pos - 1) + 
			   string_copy(text, cursor_pos + 1, string_length(text) - cursor_pos);
		set_cursor_pos(cursor_pos - 1);
	} else
		__cut_selection();
}

__delete_char = function() {
	if (cursor_pos == string_length(text) && selection_length == 0)
		return;
		
	if (selection_length == 0)
		text = string_copy(text, 1, cursor_pos) + 
			   string_copy(text, cursor_pos + 2, string_length(text) - cursor_pos);
	else
		__cut_selection();
}

__add_text = function() {
	if (keyboard_string == "")
		return;
		
	__cut_selection();
	if (string_length(text) >= max_string_length_characters)
		return;

	var i = 0; repeat(array_length(forbidden_characters)) {
		keyboard_string = string_replace(keyboard_string, forbidden_characters[i++], "");
	}
	
	if (keyboard_string != "") {
		var cb = keyboard_string;
		text = string_copy(text, 1, cursor_pos) + cb +
			string_copy(text, cursor_pos + 1, string_length(text) - cursor_pos - string_length(cb) + 1);
		cursor_pos += string_length(cb);
		__reset_cursor_blink();
		keyboard_string = "";
	}
}

__copy_text = function() {
	if (os_type != os_windows || selection_length == 0)
		return;
		
	clipboard_set_text(selected_text);
}

__paste_text = function() {
	if (os_type != os_windows || !clipboard_has_text())
		return;
		
	__cut_selection();
	var cb = clipboard_get_text();
	text = string_copy(text, 1, cursor_pos) + cb +
		string_copy(text, cursor_pos + 1, string_length(text) - cursor_pos);
	if (string_length(text) >= max_string_length_characters)
		text = string_copy(text, 1, max_string_length_characters);
	set_cursor_pos(min(max_string_length_characters, cursor_pos + string_length(cb)));
}

__cut_text = function() {
	if (os_type != os_windows || selection_length == 0)
		return;
	
	var cut = __cut_selection();
	clipboard_set_text(cut);
}

__find_next_input_box = function(shift_tab = false) {
	if (__TEXT_NAV_TAB_LOCK != 0)
		return;

	__TEXT_NAV_TAB_LOCK = id;
	__stop_wait_for_key_repeat();
	lose_focus();
	var look_for_tab_index = tab_index + (shift_tab ? -1 : 1);
	var closest_tab_index_so_far = -2;
	var closest_candidate = undefined;
	var lowest_candidate = undefined;
	var lowest_tab_index_so_far = -2;
	with (InputBox) {
		if (self == other)
			continue;
		
		if (tab_index == look_for_tab_index) {
			set_focus();
			return;
		}
		
		if (shift_tab) {
			if (tab_index > look_for_tab_index &&	
			   (lowest_tab_index_so_far == -2 || tab_index > lowest_tab_index_so_far)) {
					lowest_tab_index_so_far = tab_index;
					lowest_candidate = self;
			}
		
			if (tab_index < look_for_tab_index &&
			   (closest_tab_index_so_far == -2 || tab_index > closest_tab_index_so_far)) {
				   closest_tab_index_so_far = tab_index;
				   closest_candidate = self;
			}
		} else {
			if (tab_index < look_for_tab_index &&	
			   (lowest_tab_index_so_far == -2 || tab_index < lowest_tab_index_so_far)) {
					lowest_tab_index_so_far = tab_index;
					lowest_candidate = self;
			}
		
			if (tab_index > look_for_tab_index &&
			   (closest_tab_index_so_far == -2 || tab_index < closest_tab_index_so_far)) {
				   closest_tab_index_so_far = tab_index;
				   closest_candidate = self;
			}
		}
	}
	
	if      (closest_candidate != undefined) with (closest_candidate) set_focus(true);
	else if (lowest_candidate  != undefined) with (lowest_candidate)  set_focus(true);
}

__select_all = function() {
	selection_start = string_length(text);
	selection_length = -string_length(text);
	set_cursor_pos(string_length(text), true);
}

__do_key_action = function() {
	if (!__has_focus) 
		return;
	
	keyboard_string = string_copy(keyboard_string, string_length(keyboard_string), 1);

	if (keyboard_check(vk_tab))
		__find_next_input_box(keyboard_check(vk_shift));
	else if (keyboard_check(vk_backspace))
		__backspace_char();
	else if (keyboard_check(vk_shift) && keyboard_check(vk_delete))
		__cut_text();
	else if (keyboard_check(vk_delete))
		__delete_char();
	else if (keyboard_check(vk_home) || keyboard_check(vk_pageup))
		set_cursor_pos(0);
	else if (keyboard_check(vk_end) || keyboard_check(vk_pagedown))
		set_cursor_pos(string_length(text));
	else if (keyboard_check(vk_left))
		set_cursor_pos(max(0, cursor_pos - 1));
	else if (keyboard_check(vk_right))
		set_cursor_pos(min(string_length(text), cursor_pos + 1));
	else if (keyboard_check(vk_control) && keyboard_check(ord("A")))
		__select_all();
	else if (keyboard_check(vk_control) && keyboard_check(ord("X")))
		__cut_text();
	else if (keyboard_check(vk_control) && keyboard_check(ord("C")))
		__copy_text();
	else if (keyboard_check(vk_control) && keyboard_check(ord("V")))
		__paste_text();
	else if (keyboard_check(vk_control) && keyboard_check(vk_insert))
		__copy_text();
	else if (keyboard_check(vk_shift)   && keyboard_check(vk_insert))
		__paste_text();
	else
		__add_text();

	keyboard_string = "";
	__start_wait_for_key_repeat(keyboard_key);
}

if (__has_focus && __TEXT_NAV_TAB_LOCK == 0)
	__do_key_action();