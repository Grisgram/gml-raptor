/// @description override draw_self (messagebox)

event_inherited();

buttons = [];
text_distance_top_bottom = 32;
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
		if (sprite_index != -1) {
			var nine = sprite_get_nineslice(sprite_index);
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
		}
		
		__text_x = SELF_VIEW_CENTER_X + text_xoffset;
		__text_y = SELF_VIEW_CENTER_Y + text_yoffset;
		// text offset behaves differently when right or bottom aligned
		if      (string_pos("[fa_left]",   scribble_text_align) != 0) __text_x = SELF_VIEW_LEFT_EDGE   + text_xoffset + nineleft;
		else if (string_pos("[fa_right]",  scribble_text_align) != 0) __text_x = SELF_VIEW_RIGHT_EDGE  - text_xoffset - nineright;
		if      (string_pos("[fa_top]",    scribble_text_align) != 0) __text_y = SELF_VIEW_TOP_EDGE    + text_yoffset + ninetop;
		else if (string_pos("[fa_bottom]", scribble_text_align) != 0) __text_y = SELF_VIEW_BOTTOM_EDGE - text_yoffset - ninebottom;

		__title_x = SELF_VIEW_CENTER_X + title_xoffset;
		__title_y = SELF_VIEW_CENTER_Y + title_yoffset;
		// title offset behaves differently when right or bottom aligned
		if      (string_pos("[fa_left]",   scribble_title_align) != 0) __title_x = SELF_VIEW_LEFT_EDGE   + title_xoffset + nineleft;
		else if (string_pos("[fa_right]",  scribble_title_align) != 0) __title_x = SELF_VIEW_RIGHT_EDGE  - title_xoffset - nineright;
		if      (string_pos("[fa_top]",    scribble_title_align) != 0) __title_y = SELF_VIEW_TOP_EDGE    + title_yoffset;
		else if (string_pos("[fa_bottom]", scribble_title_align) != 0) __title_y = SELF_VIEW_BOTTOM_EDGE - title_yoffset;

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
			image_xscale = max(image_xscale, (max(min_width, sumwidth) + distx) / sprite_get_width(sprite_index));
			image_yscale = max(image_yscale, (max(min_height, SELF_HEIGHT_UNSCALED + 2 * text_distance_top_bottom + maxh + button_offset_from_bottom) + disty) / sprite_get_height(sprite_index));

			// TODO: Warum hab ich das getan? Das ergibt keinen Sinn... Einfach löschen wenn Spiel fertig und es keine bekannten Bugs gibt
			//__startup_xscale = image_xscale;
			//__startup_yscale = image_yscale;
			//min_width  = sprite_width;
			//min_height = sprite_height;
		
			__setup_drag_rect(ninetop);
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
		
		// re-position the text to the new width and height
		var area_top = SELF_VIEW_TOP_EDGE + ninetop;
		if      (string_pos("[fa_center]", scribble_text_align) != 0) __text_x = SELF_VIEW_CENTER_X;
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
