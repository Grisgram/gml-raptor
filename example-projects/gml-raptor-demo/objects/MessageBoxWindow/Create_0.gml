/// @description override draw_self (messagebox)

event_inherited();

buttons = [];
text_distance_top_bottom = 64;
distance_between_buttons = 12;
button_offset_from_bottom = 12;

/// @function					__draw_self()
/// @description				invoked from draw or drawGui
__draw_self = function() {
	if (__force_redraw || x != xprevious || y != yprevious || __last_text != text || __last_title != title || sprite_index != __last_sprite_index) {
		__force_redraw = false;
		
		__scribble_text = __create_scribble_object(scribble_text_align, text);
		scribble_add_text_effects(__scribble_text);

		__scribble_title = __create_scribble_object(scribble_title_align, title);
		scribble_add_title_effects(__scribble_title);
		
		var nineleft = 0, nineright = 0, ninetop = 0, ninebottom = 0, distx = 0, disty = 0;
		var nine = -1;
		if (sprite_index != -1) {
			nine = sprite_get_nineslice(sprite_index);
			if (nine != -1) {
				nineleft = nine.left;
				nineright = nine.right;
				ninetop = nine.top;
				ninebottom = nine.bottom;
			}
		
			distx = nineleft + nineright;
			disty = ninetop + ninebottom;
			image_xscale = max(__startup_xscale, (max(min_width, max(__scribble_text.get_width(),  __scribble_title.get_width()))  + distx) / sprite_get_width(sprite_index));
			image_yscale = max(__startup_yscale, (max(min_height,max(__scribble_text.get_height(), __scribble_title.get_height())) + disty) / sprite_get_height(sprite_index));
			button_offset_from_bottom = 12 + ninebottom;
			__setup_drag_rect(ninetop);
			edges.update(nine);
			nine_slice_data.set(nineleft, ninetop, sprite_width - distx, sprite_height - disty);
		} else {
			// No sprite - update edges by hand
			edges.left = x;
			edges.top = y;
			edges.width  = text != "" ? __scribble_text.get_width() : 0;
			edges.height = text != "" ? __scribble_text.get_height() : 0;
			edges.right = edges.left + edges.width - 1;
			edges.bottom = edges.top + edges.height - 1;
			edges.center_x = x + edges.width / 2;
			edges.center_y = y + edges.height / 2;
			edges.copy_to_nineslice();
		}
		
		__text_x = edges.ninesliced.center_x + text_xoffset;
		__text_y = edges.ninesliced.center_y + text_yoffset;
		// text offset behaves differently when right or bottom aligned
		if      (string_pos("[fa_left]",   scribble_text_align) != 0) __text_x = edges.ninesliced.left   + text_xoffset;
		else if (string_pos("[fa_right]",  scribble_text_align) != 0) __text_x = edges.ninesliced.right  - text_xoffset;
		if      (string_pos("[fa_top]",    scribble_text_align) != 0) __text_y = edges.ninesliced.top    + text_yoffset;
		else if (string_pos("[fa_bottom]", scribble_text_align) != 0) __text_y = edges.ninesliced.bottom - text_yoffset;

		__title_x = SELF_VIEW_CENTER_X + title_xoffset;
		__title_y = SELF_VIEW_TOP_EDGE + titlebar_height / 2 + title_yoffset; // title aligned to titlebar_height by default
		// title offset behaves differently when right or bottom aligned
		if      (string_pos("[fa_left]",   scribble_title_align) != 0) __title_x = edges.ninesliced.left   + title_xoffset;
		else if (string_pos("[fa_right]",  scribble_title_align) != 0) __title_x = edges.ninesliced.right  - title_xoffset;
		if      (string_pos("[fa_top]",    scribble_title_align) != 0) __title_y = SELF_VIEW_TOP_EDGE      + title_yoffset;
		else if (string_pos("[fa_bottom]", scribble_title_align) != 0) __title_y = titlebar_height         - title_yoffset;

		__last_text = text;
		__last_sprite_index = sprite_index;
		__last_title = title;
		
		var maxh = 0;
		var sumwidth = distance_between_buttons * (array_length(buttons) - 1);
		for (var i = 0; i < array_length(buttons); i++) {
			with (buttons[i]) {
				var btn = __button;
				with (btn) {
					maxh = max(maxh, sprite_height);
					sumwidth += sprite_width;
				}
			}
		}
		
		if (sprite_index != -1) {
			// adapt image scale if necessary after calculating the buttons
			var sumheight = __scribble_text.get_height() + maxh + button_offset_from_bottom + text_distance_top_bottom;
			
			image_xscale = max(image_xscale, (max(min_width, sumwidth) + distx) / sprite_get_width(sprite_index));
			image_yscale = max(image_yscale, (max(min_height, sumheight) + disty) / sprite_get_height(sprite_index));
		
			__setup_drag_rect(ninetop);
			edges.update(nine);
			nine_slice_data.set(nineleft, ninetop, sprite_width - distx, sprite_height - disty);
		}
		
		var xpos = SELF_VIEW_CENTER_X - sumwidth / 2;
		var ypos = SELF_VIEW_BOTTOM_EDGE - button_offset_from_bottom;
		var buttondist = distance_between_buttons;
		var button_min_y = ypos;
		for (var i = 0; i < array_length(buttons); i++) {
			with (buttons[i]) {
				with (__button) {
					y = ypos - sprite_height + sprite_yoffset;
					x = xpos + sprite_xoffset;
					xpos += sprite_width + buttondist;
					button_min_y = min(button_min_y, y);
					force_redraw();
					__draw_self();
				}
			}
		}
		
		// re-position the text and title to the new width and height
		var area_top = edges.ninesliced.top;
		if      (string_pos("[fa_center]", scribble_text_align) != 0) __text_x = SELF_VIEW_CENTER_X + text_xoffset;
		else if (string_pos("[fa_right]",  scribble_text_align) != 0) __text_x = SELF_VIEW_RIGHT_EDGE - text_xoffset - nineright;
		if      (string_pos("[fa_middle]", scribble_text_align) != 0) __text_y = area_top + (button_min_y - area_top) / 2 + text_yoffset;
		else if (string_pos("[fa_bottom]", scribble_text_align) != 0) __text_y = button_min_y - text_yoffset;
	}
	
	if (sprite_index != -1) {
		image_blend = draw_color;
		draw_self();
		image_blend = c_white;
	}
	
	if (text  != "") __scribble_text .draw(__text_x,  __text_y);
	if (title != "") __scribble_title.draw(__title_x, __title_y);

}
