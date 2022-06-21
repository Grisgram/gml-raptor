/// @description override draw_self (window)

event_inherited();

#macro __WINDOW_RESIZE_BORDER_WIDTH		4

__last_title = "";
__title_x = 0;
__title_y = 0;
__scribble_title = undefined;

__in_drag_mode = false;
__drag_rect = new Rectangle();

/// @function					__setup_drag_rect(ninetop)
/// @description				setup drag and resize rects
/// @param {int} ninetop
__setup_drag_rect = function(ninetop) {
	__drag_rect.set(SELF_VIEW_LEFT_EDGE, SELF_VIEW_TOP_EDGE, SELF_WIDTH, ninetop);
}

/// @function					scribble_add_title_effects(titletext)
/// @description				called when a scribble element is created to allow adding custom effects.
///								overwrite (redefine) in child controls
/// @param {struct} titletext
scribble_add_title_effects = function(titletext) {
	// example: titletext.blend(c_blue, 1); // where ,1 is alpha
}

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
			// TODO: Warum hab ich das getan? Das ergibt keinen Sinn... Einfach löschen wenn Spiel fertig und es keine bekannten Bugs gibt
			//__startup_xscale = image_xscale;
			//__startup_yscale = image_yscale;
		
			__setup_drag_rect(ninetop);
			nine_slice_data.set(nineleft, ninetop, sprite_width - distx, sprite_height - disty);
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
	}
	
	if (sprite_index != -1) {
		image_blend = draw_color;
		draw_self();
		image_blend = c_white;
	}
	if (text  != "") __scribble_text .draw(__text_x,  __text_y);
	if (title != "") __scribble_title.draw(__title_x, __title_y);
	
}
