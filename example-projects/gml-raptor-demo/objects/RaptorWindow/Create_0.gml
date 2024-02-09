/// @description override draw_self (window)

/*
	Rules for the "size direction" variable are like the numpad on keyboard:
	
		7  8  9
		+-----+
		|     |
	  4 |     | 6
		|     |
		+-----+
		1  2  3
	
	if size direction != 0, then odd directions (1,3,7,9) cause the diagonal arrow to appear,
	4 and 6 the horizontal one and 2 and 8 the vertical one
*/

event_inherited();

#macro __WINDOW_RESIZE_BORDER_WIDTH		8

title = LG_resolve(title);

__last_title		= "";
__title_x			= 0;
__title_y			= 0;
__scribble_title	= undefined;

__x_button			= undefined;
__x_button_closing	= undefined;
__startup_depth		= depth;

__in_drag_mode		= false;
__drag_rect			= new Rectangle();

__size_rect_top		= new Rectangle();
__size_rect_bottom	= new Rectangle();
__size_rect_left	= new Rectangle();
__size_rect_right	= new Rectangle();
__in_size_mode		= false;
__size_direction	= 0;
// _rc = raptor cursor:Image index of the sizable sprite
__size_images_rc	= [-1,3,1,2,0,-1,0,2,1,3];
// _dc = default cursor (gamemaker cr_ constants)
__size_images_dc	= [cr_default,cr_size_nesw,cr_size_ns,cr_size_nwse,cr_size_we,-1,cr_size_we,cr_size_nwse,cr_size_ns,cr_size_nesw];

if (window_is_sizable && image_number > 1)
	image_index = 1;

if (window_x_button_visible && !is_null(window_x_button_object)) {
	__x_button = instance_create(0, 0, SELF_LAYER_OR_DEPTH, window_x_button_object);
	//__x_button.depth = depth - 1;
	__x_button.attach_to_window(self);
	__x_button_closing = __x_button.on_left_click;
	__x_button.on_left_click = function(sender) {
		// This is the original left click handler on the x button that might have been set
		// at design time but was overwritten by this function
		if (!is_null(__x_button_closing))
			__x_button_closing(__x_button);
		// Launch the closing callback set on the window
		if (!is_null(on_closing)) 
			on_closing(self);
		close();
	}
}

__do_sizing = function() {
	var recalc = true;
	switch (__size_direction) {
		case 1:
			scale_sprite_to(max(min_width,sprite_width - GUI_MOUSE_DELTA_X), max(min_height,sprite_height + GUI_MOUSE_DELTA_Y));
			x += GUI_MOUSE_DELTA_X;
			break;
		case 2:
			scale_sprite_to(max(min_width,sprite_width                    ), max(min_height,sprite_height + GUI_MOUSE_DELTA_Y));
			break;
		case 3:
			scale_sprite_to(max(min_width,sprite_width + GUI_MOUSE_DELTA_X), max(min_height,sprite_height + GUI_MOUSE_DELTA_Y));
			break;
		case 4:
			scale_sprite_to(max(min_width,sprite_width - GUI_MOUSE_DELTA_X), max(min_height,sprite_height                    ));
			x += GUI_MOUSE_DELTA_X;
			break;
		case 6:
			scale_sprite_to(max(min_width,sprite_width + GUI_MOUSE_DELTA_X), max(min_height,sprite_height                    ));			
			break;
		case 7:
			scale_sprite_to(max(min_width,sprite_width - GUI_MOUSE_DELTA_X), max(min_height,sprite_height - GUI_MOUSE_DELTA_Y));
			x += GUI_MOUSE_DELTA_X;
			y += GUI_MOUSE_DELTA_Y;
			break;
		case 8:
			scale_sprite_to(max(min_width,sprite_width                    ), max(min_height,sprite_height - GUI_MOUSE_DELTA_Y));
			y += GUI_MOUSE_DELTA_Y;
			break;
		case 9:
			scale_sprite_to(max(min_width,sprite_width + GUI_MOUSE_DELTA_X), max(min_height,sprite_height - GUI_MOUSE_DELTA_Y));
			y += GUI_MOUSE_DELTA_Y;
			break;
		default:
			recalc = false;
			break;
	}
	if (recalc) {
		__startup_xscale = image_xscale;
		__startup_yscale = image_yscale;
		__setup_drag_rect();
	}
}

// Find the windows' sizing areas
// we need to check all 4 borders and in each of them the adjacent sides to find the diagonals
__find_sizing_area = function() {

	if (__size_rect_top.intersects_point(GUI_MOUSE_X, GUI_MOUSE_Y)) {
		
		if (__size_rect_left.intersects_point(GUI_MOUSE_X, GUI_MOUSE_Y)) __size_direction = 7;
		else if (__size_rect_right.intersects_point(GUI_MOUSE_X, GUI_MOUSE_Y)) __size_direction = 9;
		else
			__size_direction = 8;
			
	} else if (__size_rect_bottom.intersects_point(GUI_MOUSE_X, GUI_MOUSE_Y)) {
		
		if (__size_rect_left.intersects_point(GUI_MOUSE_X, GUI_MOUSE_Y)) __size_direction = 1;
		else if (__size_rect_right.intersects_point(GUI_MOUSE_X, GUI_MOUSE_Y)) __size_direction = 3;
		else 
			__size_direction = 2;
		
	} else if (__size_rect_left.intersects_point(GUI_MOUSE_X, GUI_MOUSE_Y)) {
		
		if (__size_rect_top.intersects_point(GUI_MOUSE_X, GUI_MOUSE_Y)) __size_direction = 7;
		else if (__size_rect_bottom.intersects_point(GUI_MOUSE_X, GUI_MOUSE_Y)) __size_direction = 1;
		else
			__size_direction = 4;

	} else if (__size_rect_right.intersects_point(GUI_MOUSE_X, GUI_MOUSE_Y)) {

		if (__size_rect_top.intersects_point(GUI_MOUSE_X, GUI_MOUSE_Y)) __size_direction = 9;
		else if (__size_rect_bottom.intersects_point(GUI_MOUSE_X, GUI_MOUSE_Y)) __size_direction = 3;
		else
			__size_direction = 6;

	} else
		__size_direction = 0;
	
	__set_sizing_cursor();
}

__set_sizing_cursor = function() {
	if (MOUSE_CURSOR != undefined)
		if (__size_direction == 0)
			MOUSE_CURSOR.set_cursor(mouse_cursor_type.pointer);
		else
			MOUSE_CURSOR.set_cursor(mouse_cursor_type.sizing, __size_images_rc[@__size_direction]);
	else
		window_set_cursor(__size_images_dc[@__size_direction]);
}

/// @function				__setup_drag_rect(ninetop)
/// @description			setup drag and resize rects
/// @param {int} ninetop
__setup_drag_rect = function() {
	var size_offset = (window_is_sizable ? __WINDOW_RESIZE_BORDER_WIDTH : 0);
	__drag_rect.set(
		SELF_VIEW_LEFT_EDGE + size_offset, 
		SELF_VIEW_TOP_EDGE + size_offset, 
		SELF_WIDTH - 2 * size_offset, 
		titlebar_height
	);
	
	__size_rect_top.set(
		SELF_VIEW_LEFT_EDGE, 
		SELF_VIEW_TOP_EDGE, 
		SELF_WIDTH, 
		__WINDOW_RESIZE_BORDER_WIDTH
	);
	
	__size_rect_bottom.set(
		SELF_VIEW_LEFT_EDGE, 
		SELF_VIEW_BOTTOM_EDGE - __WINDOW_RESIZE_BORDER_WIDTH,
		SELF_WIDTH, 
		__WINDOW_RESIZE_BORDER_WIDTH
	);

	__size_rect_left.set(
		SELF_VIEW_LEFT_EDGE,
		SELF_VIEW_TOP_EDGE,
		__WINDOW_RESIZE_BORDER_WIDTH,
		SELF_HEIGHT
	);

	__size_rect_right.set(
		SELF_VIEW_RIGHT_EDGE - __WINDOW_RESIZE_BORDER_WIDTH,
		SELF_VIEW_TOP_EDGE,
		__WINDOW_RESIZE_BORDER_WIDTH,
		SELF_HEIGHT
	);

	//if (draw_on_gui) {
	//	__drag_rect.set(SELF_VIEW_LEFT_EDGE, SELF_VIEW_TOP_EDGE, SELF_WIDTH, titlebar_height);
	//} else
	//	__drag_rect.set(SELF_VIEW_LEFT_EDGE, SELF_VIEW_TOP_EDGE, SELF_WIDTH, titlebar_height);
}

onLayoutStarting = function() {
	data.client_area.set(
		__WINDOW_RESIZE_BORDER_WIDTH, 
		titlebar_height + __WINDOW_RESIZE_BORDER_WIDTH / 2, 
		sprite_width - 2 * __WINDOW_RESIZE_BORDER_WIDTH,
		sprite_height - titlebar_height - 1.5 * __WINDOW_RESIZE_BORDER_WIDTH);
}

close = function() {
	instance_destroy(self);
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
			.starting_format(font_to_use == "undefined" ? scribble_font_get_default() : font_to_use, 
				mouse_is_over ? title_color_mouse_over : title_color);
}

/// @function					__draw_self()
/// @description				invoked from draw or drawGui
__draw_self = function() {
	if (CONTROL_NEED_LAYOUT || __last_title != title) {
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

			__setup_drag_rect();
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

		__last_text				= text;
		__last_sprite_index		= sprite_index;
		__last_sprite_width		= sprite_width;
		__last_sprite_height	= sprite_height;
		__last_title			= title;
	}

	if (data.control_tree_layout == undefined || 
		(data.control_tree != undefined && data.control_tree.parent_tree == undefined))
		__draw_instance();
	
}

__draw_instance = function() {
	if (sprite_index != -1) {
		image_blend = draw_color;
		draw_self();
		image_blend = c_white;
		if (!is_null(__x_button)) with(__x_button) __draw_self();
	}
	
	if (text  != "") __scribble_text .draw(__text_x,  __text_y );
	if (title != "") __scribble_title.draw(__title_x, __title_y);
	
	control_tree.draw_children();
}