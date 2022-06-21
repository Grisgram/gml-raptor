/// @description draw_self & then the cursor

event_inherited();

if (__has_focus && __cursor_visible) {
	if (__last_cursor_visible != __cursor_visible) {
		// make draw calculations only once, if visible changed in last frame
		__last_cursor_visible = __cursor_visible;
		var scrib = (text == "" ? __create_scribble_object(scribble_text_align, "A") : __scribble_text);
		__cursor_height = scrib.get_height();
		var bbox = __scribble_text.get_bbox(__text_x, __text_y);
		var ybox = scrib.get_bbox(__text_x, __text_y);
		__cursor_y = ybox.top;
		if (cursor_pos == 0) {
			__cursor_x = bbox.left;
		} else if (cursor_pos == string_length(text)) {
			__cursor_x = bbox.right;
		} else {
			var substr = string_copy(text, 1, cursor_pos);
			var scrib = __create_scribble_object("[fa_left]", substr);
			var subbox = scrib.get_bbox(__text_x, __text_y);
			__cursor_x = bbox.left + subbox.width - 1;
		}
	}
	draw_set_color(text_color);
	draw_line(__cursor_x, __cursor_y, __cursor_x, __cursor_y + __cursor_height);
	draw_set_color(c_white);
}