/// @description scribblelize text

event_inherited();
gui_mouse = new GuiMouseTranslator();
mouse_is_over = false;
edges = new Edges(self);

nine_slice_data = new Rectangle(0, 0, sprite_width, sprite_height);

__startup_x			= x;
__startup_y			= y;
__startup_xscale	= image_xscale;
__startup_yscale	= image_yscale;

__last_sprite_index = undefined;
__last_text			= "";
__scribble_text		= undefined;
__text_x			= 0;
__text_y			= 0;

__force_redraw		= false;

// GMS HTML5 runtime can not do ui drawing properly
if (IS_HTML)
	draw_on_gui = false;

/// @function					force_redraw()
/// @description				force recalculate of all positions next frame
force_redraw = function() {
	__force_redraw = true;
}

/// @function					scribble_add_text_effects(scribbletext)
/// @description				called when a scribble element is created to allow adding custom effects.
///								overwrite (redefine) in child controls
/// @param {struct} scribbletext
scribble_add_text_effects = function(scribbletext) {
	// example: scribbletext.blend(c_blue, 1); // where ,1 is alpha
}

/// @function					draw_scribble_text()
/// @description				draw the text - redefine for additional text effects
draw_scribble_text = function() {
	__scribble_text.draw(__text_x, __text_y);
}

/// @function					__create_scribble_object(align, str)
/// @description				setup the initial object to work with
/// @param {string} align			
/// @param {string} str			
__create_scribble_object = function(align, str) {
	return scribble(align + str, MY_NAME)
			.starting_format(font_to_use == "undefined" ? global.__scribble_default_font : font_to_use, 
							 mouse_is_over ? text_color_mouse_over : text_color);
}

/// @function					__adopt_object_properties()
/// @description				copy blend, alpha, scale and angle from the object to the text
__adopt_object_properties = function() {
	if (adopt_object_properties == adopt_properties.alpha ||
		adopt_object_properties == adopt_properties.full) {
		__scribble_text.blend(image_blend, image_alpha);
	}
	if (adopt_object_properties == adopt_properties.full) {
		__scribble_text.transform(image_xscale, image_yscale, image_angle);
	}
}

/// @function					__finalize_scribble_text()
/// @description				add blend and transforms to the final text
__finalize_scribble_text = function() {
	if (adopt_object_properties != adopt_properties.none)
		__adopt_object_properties();
	scribble_add_text_effects(__scribble_text);
}

/// @function					__draw_self()
/// @description				invoked from draw or drawGui
__draw_self = function() {
	if (__force_redraw || x != xprevious || y != yprevious || __last_text != text || sprite_index != __last_sprite_index) {
		__force_redraw = false;

		if (sprite_index == -1)
			word_wrap = false; // no wrapping on zero-size objects
		
		__scribble_text = __create_scribble_object(scribble_text_align, text);
		__finalize_scribble_text();

		var nineleft = 0, nineright = 0, ninetop = 0, ninebottom = 0;
		if (sprite_index != -1) {
			var nine = sprite_get_nineslice(sprite_index);
			if (nine != -1) {
				nineleft = nine.left;
				nineright = nine.right;
				ninetop = nine.top;
				ninebottom = nine.bottom;
			}
			var distx = nineleft + nineright;
			var disty = ninetop + ninebottom;
		
			if (autosize) {
				image_xscale = max(__startup_xscale, (max(min_width, __scribble_text.get_width())  + distx) / sprite_get_width(sprite_index));
				image_yscale = max(__startup_yscale, (max(min_height,__scribble_text.get_height()) + disty) / sprite_get_height(sprite_index));
			}
			edges.update();

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
		}
		
		__text_x = edges.center_x + text_xoffset;
		__text_y = edges.center_y + text_yoffset;
		// text offset behaves differently when right or bottom aligned
		if      (string_pos("[fa_left]",   scribble_text_align) != 0) __text_x = edges.left   + text_xoffset + nineleft;
		else if (string_pos("[fa_right]",  scribble_text_align) != 0) __text_x = edges.right  - text_xoffset - nineright;
		if      (string_pos("[fa_top]",    scribble_text_align) != 0) __text_y = edges.top    + text_yoffset + ninetop;
		else if (string_pos("[fa_bottom]", scribble_text_align) != 0) __text_y = edges.bottom - text_yoffset - ninebottom;

		__last_text = text;
		__last_sprite_index = sprite_index;
	} else
		__finalize_scribble_text();

	if (sprite_index != -1) {
		image_blend = (mouse_is_over ? draw_color_mouse_over : draw_color);
		draw_self();
		image_blend = c_white;
	}
	
	if (text != "") draw_scribble_text();
}

