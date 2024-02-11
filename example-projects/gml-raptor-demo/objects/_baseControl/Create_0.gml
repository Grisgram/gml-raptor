/// @description scribblelize text

#macro __CONTROL_NEEDS_LAYOUT (__force_redraw || x != xprevious || y != yprevious || \
							__last_text != text || sprite_index != __last_sprite_index || \
							sprite_width != __last_sprite_width || sprite_height != __last_sprite_height)

#macro __CONTROL_DRAWS_SELF (data.control_tree_layout == undefined || \
							(data.control_tree != undefined && data.control_tree.parent_tree == undefined))

event_inherited();
gui_mouse = new GuiMouseTranslator();
mouse_is_over = false;
edges = new Edges(self);

nine_slice_data = new Rectangle(0, 0, sprite_width, sprite_height);

if (!SAVEGAME_LOAD_IN_PROGRESS) {
	// layout data is part of the savegame, if this one gets saved
	data.control_tree = undefined;
	data.control_tree_layout = undefined;
}

/// @function set_startup_size()
/// @description Set the initial size of the control based on the max value of
///				 startup_width/height, min_width/height and designer width/height (room editor)
set_startup_size = function() {
	scale_sprite_to(
		max(startup_width , sprite_width , min_width),
		max(startup_height, sprite_height, min_height)
	);
}

/// @function update_startup_coordinates()
/// @description Invoke this if you did create the control dynamically at runtime 
///				 to set the current position as the startup position after placing it in the scene
update_startup_coordinates = function() {
	__startup_x				= x;
	__startup_y				= y;
	__startup_xscale		= image_xscale;
	__startup_yscale		= image_yscale;
	__startup_mycenterx		= SELF_VIEW_CENTER_X;
	__startup_mycentery		= SELF_VIEW_CENTER_Y;
	__startup_myright		= SELF_VIEW_RIGHT_EDGE;
	__startup_mybottom		= SELF_VIEW_BOTTOM_EDGE;
}
set_startup_size();
update_startup_coordinates();

__last_sprite_index			= undefined;
__last_sprite_width			= sprite_width;
__last_sprite_height		= sprite_height;
__last_text					= "";
__scribble_text				= undefined;
__text_x					= 0;
__text_y					= 0;
__text_width				= 0;
__text_height				= 0;
							
__force_redraw				= false;

__disabled_surface			= undefined;
__disabled_surface_width	= 0;
__disabled_surface_height	= 0;

cleanup_disabled_surface = function() {
	if (__disabled_surface == undefined) return;
	
	__disabled_surface.Free();
	__disabled_surface			= undefined;
	__disabled_surface_width	= 0;
	__disabled_surface_height	= 0;
}

/// @function set_enabled(_enabled)
/// @description if you set the enabled state through this function, the on_enabled_changed callback
///				 gets invoked, if the state is different from the current state
set_enabled = function(_enabled) {
	var need_invoke = (is_enabled != _enabled);
	is_enabled = _enabled;
	if (need_invoke && on_enabled_changed != undefined) {
		vlog($"Enabled changed for {MY_NAME}");
		on_enabled_changed(self);
	}
}

/// @function is_topmost_control()
/// @description True, if this control is the topmost (= lowest depth) at the specified position
__topmost_list = ds_list_create();
is_topmost_control = function(_x, _y) {
	ds_list_clear(__topmost_list);
	if (instance_position_list(_x, _y, _baseControl, __topmost_list, false) > 0) {
		var mindepth = DEPTH_BOTTOM_MOST;
		for (var i = 0, len = ds_list_size(__topmost_list); i < len; i++) {
			var w = __topmost_list[|i];
			mindepth = min(mindepth, w.depth);
		}
		return (mindepth == depth);
	}
	return false;
}

/// @function __mouse_enter_topmost_control()
/// @description Private function invoked from the mouse_leave event
///				 to find other controls at that mouse position and let
///				 the topmost of them receive the enter event
__mouse_enter_topmost_control = function() {
	ds_list_clear(__topmost_list);
	if (instance_position_list(CTL_MOUSE_X, CTL_MOUSE_Y, _baseControl, __topmost_list, false) > 0) {
		// pass 1: find topmost depth at this position
		var mindepth = DEPTH_BOTTOM_MOST;
		for (var i = 0, len = ds_list_size(__topmost_list); i < len; i++) {
			var w = __topmost_list[|i];
			if (!eq(w, self))
				mindepth = min(mindepth, w.depth);
		}
		// pass 2: launch the mouse enter event on all the topmost's
		for (var i = 0, len = ds_list_size(__topmost_list); i < len; i++) {
			var w = __topmost_list[|i];
			if (w.depth == mindepth && !w.mouse_is_over) {
				with(w) {
					vlog($"{MY_NAME}: onMouseEnter");
					mouse_is_over = true;
					force_redraw();
				}
			}
		}
	} else
		vlog($"{MY_NAME}: onMouseLeave");
}

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
			.starting_format(font_to_use == "undefined" ? scribble_font_get_default() : font_to_use, 
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

/// @function __apply_autosize_alignment()
/// @description if autosize, this calculates the real text position
__apply_autosize_alignment = function() {
	if		(string_contains(scribble_text_align, "[fa_center]")) x = __startup_mycenterx - sprite_width  / 2;
	else if (string_contains(scribble_text_align, "[fa_right]" )) x = __startup_myright	  - sprite_width;
	if		(string_contains(scribble_text_align, "[fa_middle]")) y = __startup_mycentery - sprite_height / 2;
	else if (string_contains(scribble_text_align, "[fa_bottom]")) y = __startup_mybottom  - sprite_height;	
}

/// @function __apply_post_positioning()
/// @description invoked after text-positioning is calculated.
///				 if the control renders additional elements (checkbox, radio, etc)
///				 you can modify __text_x and __text_y in this function to finalize text positioning
__apply_post_positioning = function() {
}

/// @function					__draw_self()
/// @description				invoked from draw or drawGui
__draw_self = function() {
	if (__CONTROL_NEEDS_LAYOUT) {
		__force_redraw = false;

		if (sprite_index == -1)
			word_wrap = false; // no wrapping on zero-size objects
		
		__scribble_text = __create_scribble_object(scribble_text_align, text);
		__finalize_scribble_text();
		__text_width	= __scribble_text.get_width();
		__text_height	= __scribble_text.get_height();

		var nineleft = 0, nineright = 0, ninetop = 0, ninebottom = 0;
		var nine = -1;
		if (sprite_index != -1) {
			nine = sprite_get_nineslice(sprite_index);
			if (nine != -1 && nine.enabled) {
				nineleft	= nine.left;
				nineright	= nine.right;
				ninetop		= nine.top;
				ninebottom	= nine.bottom;
			}
			var distx		= nineleft + nineright;
			var disty		= ninetop + ninebottom;
		
			if (autosize) {
				image_xscale = max(__startup_xscale, (max(min_width, __text_width)  + distx) / sprite_get_width(sprite_index));
				image_yscale = max(__startup_yscale, (max(min_height,__text_height) + disty) / sprite_get_height(sprite_index));
				__apply_autosize_alignment(distx, disty);
			}
			edges.update(nine);

			nine_slice_data.set(nineleft, ninetop, sprite_width - distx, sprite_height - disty);
			
		} else {
			// No sprite - update edges by hand
			edges.left = x;
			edges.top = y;
			edges.width  = text != "" ? __text_width : 0;
			edges.height = text != "" ? __text_height : 0;
			edges.right = edges.left + edges.width - 1;
			edges.bottom = edges.top + edges.height - 1;
			edges.center_x = x + edges.width / 2;
			edges.center_y = y + edges.height / 2;
			edges.copy_to_nineslice();
		}
		
		__text_x = edges.ninesliced.center_x + text_xoffset;
		__text_y = edges.ninesliced.center_y + text_yoffset;

		// text offset behaves differently when right or bottom aligned
		if      (string_contains(scribble_text_align, "[fa_left]"  )) __text_x = edges.ninesliced.left   + text_xoffset;
		else if (string_contains(scribble_text_align, "[fa_right]" )) __text_x = edges.ninesliced.right  - text_xoffset;
		if      (string_contains(scribble_text_align, "[fa_top]"   )) __text_y = edges.ninesliced.top    + text_yoffset;
		else if (string_contains(scribble_text_align, "[fa_bottom]")) __text_y = edges.ninesliced.bottom - text_yoffset;

		__apply_post_positioning();

		__last_text				= text;
		__last_sprite_index		= sprite_index;
		__last_sprite_width		= sprite_width;
		__last_sprite_height	= sprite_height;
	} else
		__finalize_scribble_text();

	if (__CONTROL_DRAWS_SELF)
		__draw_instance();
}

__draw_instance = function() {
	if (sprite_index != -1) {
		if (!is_enabled) {
			__disabled_surface_width = sprite_width;
			__disabled_surface_height = sprite_height;
			shader_set(GrayScaleShader);
			draw_self();
			shader_reset();
		} else {
			image_blend = (mouse_is_over ? draw_color_mouse_over : draw_color);
			draw_self();
			image_blend = c_white;
		}
	}
	
	if (text != "") {
		if (is_enabled) {
			// cleanup so the next disable will create a new surface (contents might have changed)
			if (__disabled_surface != undefined) 
				cleanup_disabled_surface();
				
			draw_scribble_text();
		} else {
			if (__disabled_surface == undefined) {
				if (__disabled_surface_height == 0) {
					__disabled_surface_width = __scribble_text.get_width();
					__disabled_surface_height = __scribble_text.get_height();
				}
				__disabled_surface = new Canvas(__disabled_surface_width, __disabled_surface_height);
				var backx = __text_x;
				var backy = __text_y;
				__text_x -= x;
				__text_y -= y;
				__disabled_surface.Start();
				draw_scribble_text();
				__disabled_surface.Finish();
				__text_x = backx;
				__text_y = backy;
			}
			shader_set(GrayScaleShader);
			__disabled_surface.Draw(x - sprite_xoffset, y - sprite_yoffset);
			shader_reset();
		}
	}
}
