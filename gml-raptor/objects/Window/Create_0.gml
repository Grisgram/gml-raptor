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
	if (draw_on_gui) {
		__drag_rect.set(SELF_UI_VIEW_LEFT_EDGE, SELF_UI_VIEW_TOP_EDGE, SELF_WIDTH, titlebar_height);
	} else
		__drag_rect.set(SELF_VIEW_LEFT_EDGE, SELF_VIEW_TOP_EDGE, SELF_WIDTH, titlebar_height);
}

/// @function					scribble_add_title_effects(titletext)
/// @description				called when a scribble element is created to allow adding custom effects.
///								overwrite (redefine) in child controls
/// @param {struct} titletext
scribble_add_title_effects = function(titletext) {
	// example: titletext.blend(c_blue, 1); // where ,1 is alpha
}

/// @function					__create_scribble_title_object(align, str)
/// @description				setup the initial object to work with
/// @param {string} align			
/// @param {string} str			
__create_scribble_title_object = function(align, str) {
	return scribble(align + str, MY_NAME)
			.starting_format(font_to_use == "undefined" ? global.__scribble_default_font : font_to_use, title_color);
}

/// @function					__draw_self()
/// @description				invoked from draw or drawGui
__draw_self = function() {
	if (__force_redraw || x != xprevious || y != yprevious || __last_text != text || __last_title != title || sprite_index != __last_sprite_index) {
		__force_redraw = false;
		
		__scribble_text = __create_scribble_object(scribble_text_align, text);
		scribble_add_text_effects(__scribble_text);

		__scribble_title = __create_scribble_title_object(scribble_title_align, title);
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
			// TODO: Warum hab ich das getan? Das ergibt keinen Sinn... Einfach löschen wenn Spiel fertig und es keine bekannten Bugs gibt
			//__startup_xscale = image_xscale;
			//__startup_yscale = image_yscale;
		
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
	}
	
	if (sprite_index != -1) {
		image_blend = draw_color;
		draw_self();
		image_blend = c_white;
	}
	if (text  != "") __scribble_text .draw(__text_x,  __text_y);
	if (title != "") __scribble_title.draw(__title_x, __title_y);
	
}
