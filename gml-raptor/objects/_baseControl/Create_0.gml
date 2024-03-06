/// @description scribblelize text

#macro __CONTROL_NEEDS_LAYOUT (__force_redraw || x != xprevious || y != yprevious || \
							__last_text != text || sprite_index != __last_sprite_index || \
							sprite_width != __last_sprite_width || sprite_height != __last_sprite_height)

#macro __CONTROL_DRAWS_SELF (data.control_tree_layout == undefined || \
							(data.control_tree != undefined && data.control_tree.parent_tree == undefined))

event_inherited();
// undocumented feature to control the frame color when DEBUG_SHOW_OBJECT_FRAMES is true
vigetx(self, "__raptor_debug_frame_color", c_green);

gui_mouse = new GuiMouseTranslator();
mouse_is_over = false;
__mouse_text_scale = 1.0;
__mouse_events_locked = false; // if rendered in a container, container draws first

edges = new Edges(self);
nine_slice_data = new Rectangle(0, 0, sprite_width, sprite_height);

if (!SAVEGAME_LOAD_IN_PROGRESS) {
	// layout data is part of the savegame, if this one gets saved
	data.control_tree = undefined;
	data.control_tree_layout = undefined;
	data.client_area = new Rectangle(0, 0, sprite_width, sprite_height);
}

/// @function update_client_area()
update_client_area = function() {
	data.client_area.set(0, 0, sprite_width, sprite_height);
}

/// @function set_startup_size()
/// @description Set the initial size of the control based on the max value of
///				 startup_width/height, min_width/height and designer width/height (room editor)
set_startup_size = function() {
	if (sprite_index == -1) return;
	scale_sprite_to(
		max(startup_width , sprite_width , min_width),
		max(startup_height, sprite_height, min_height)
	);
}

/// @function set_client_area(_width, _height, _is_also_min_size = true)
set_client_area = function(_width, _height, _is_also_min_size = true) {
	scale_sprite_to(_width, _height);
	if (_is_also_min_size) {
		min_width = sprite_width;
		min_height = sprite_height;
	}
	update_startup_coordinates();
	update_client_area();
	force_redraw();
	on_client_area_changed();
}

/// @function on_client_area_changed()
on_client_area_changed = function() {}

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
__text_anim_running			= false;
animated_text_color			= text_color;
animated_draw_color			= draw_color;

__force_redraw				= true;	 // first draw is forced
__force_redraw_text_only	= false; // flag for mouse_enter/leave event which just trigger coloring

__disabled_surface			= undefined;
__disabled_surface_width	= 0;
__disabled_surface_height	= 0;

__animate_draw_color = function(_to) {
	if (draw_color_anim_frames == 0) {
		animated_draw_color = _to;
		return;
	}

	animation_abort(self, "__raptor_draw_color_anim", false);
	animation_run(self, 0, draw_color_anim_frames, __raptorAcControlDraw,,,{
			fromcol: animated_draw_color,
			tocol: _to
		})
		.set_name("__raptor_draw_color_anim")
		.set_function("anim_draw", function(value) {
			owner.animated_draw_color = merge_color(data.fromcol, data.tocol, value);
		})
		.add_finished_trigger(function(_data) {
			animated_draw_color = _data.tocol;
		});
}

__animate_text_color = function(_to) {
	if (text_color_anim_frames == 0) {
		animated_text_color = _to;
		return;
	}
	
	__text_anim_running = true;
	animation_abort(self, "__raptor_text_color_anim", false);
	animation_run(self, 0, draw_color_anim_frames, __raptorAcControlDraw,,,{
			fromcol: animated_text_color,
			tocol: _to
		})
		.set_name("__raptor_text_color_anim")
		.set_function("anim_draw", function(value) {
			owner.animated_text_color = merge_color(data.fromcol, data.tocol, value);
		})
		.add_finished_trigger(function(_data) {
			animated_text_color = _data.tocol;
			__text_anim_running = false;
		});
}

cleanup_disabled_surface = function() {
	if (__disabled_surface == undefined) return;
	
	__disabled_surface.Free();
	__disabled_surface			= undefined;
	__disabled_surface_width	= 0;
	__disabled_surface_height	= 0;
}

__container = undefined; // if this is part of a window, it's the parent container
/// @function get_window()
/// @description If this control is embedded in a window, this function returns
///				 the window instance, otherwise undefined
get_window = function() {
	if (__container != undefined)
		return __container.control_tree.get_root_control();
	return undefined;
}

/// @function get_window_tree()
/// @description If this control is embedded in a window, this function returns
///				 the root tree of the control hierarchy
get_window_tree = function() {
	if (__container != undefined)
		return __container.control_tree.__root_tree;
	return undefined;
}

/// @function get_parent()
/// @description If this control is embedded in a control tree, this function returns
///				 the parent control of this one (i.e. a Panel or something similar)
get_parent = function() {
	if (__container != undefined)
		return __container;//.control_tree.control;
	return undefined;
}

/// @function get_parent_tree()
/// @description If this control is embedded in a control tree, this function returns
///				 the parent control tree of this one
get_parent_tree = function() {
	if (__container != undefined)
		return __container.control_tree;//.parent_tree;
	return undefined;
}

/// @function is_topmost()
/// @description True, if this control is the topmost (= lowest depth) at the specified position
///				 NOTE: This is an override of the method in _raptorBase, which compares against _raptorBase!
///				 This method here shall only check controls (_baseControl) to be more specific in finding topmost
__topmost_list = ds_list_create();
is_topmost = function(_x, _y) {
	ds_list_clear(__topmost_list);
	if (instance_position_list(_x, _y, _baseControl, __topmost_list, false) > 0) {
		var mindepth = depth;
		var w = undefined;
		for (var i = 0, len = ds_list_size(__topmost_list); i < len; i++) {
			w = __topmost_list[|i];
			if (!__can_touch_this(w)) continue;
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
	var have_one = false;
	
	ds_list_clear(__topmost_list);
	if (instance_position_list(CTL_MOUSE_X, CTL_MOUSE_Y, _baseControl, __topmost_list, false) > 0) {
		// pass 1: find topmost depth at this position
		var mindepth = DEPTH_BOTTOM_MOST;
		for (var i = 0, len = ds_list_size(__topmost_list); i < len; i++) {
			var w = __topmost_list[|i];
			if (!__can_touch_this(w)) continue;
			if (!eq(w, self))
				mindepth = min(mindepth, w.depth);
		}
		// pass 2: launch the mouse enter event on all the topmost's
		for (var i = 0, len = ds_list_size(__topmost_list); i < len; i++) {
			var w = __topmost_list[|i];
			if (!__can_touch_this(w)) continue;
			if (w.depth == mindepth && !w.mouse_is_over) {
				with(w) {
					vlog($"{MY_NAME}: onMouseEnter (topmost)");
					mouse_is_over = true;
					force_redraw(false);
					have_one = true;
					break;
				}
			}
		}
	} 
	if (!have_one)
		vlog($"{MY_NAME}: onMouseLeave");
}

/// @function on_skin_changed(_skindata)
/// @description	Invoked, when the skin changed
on_skin_changed = function(_skindata) {
	if (!skinnable) return;
	integrate_skin_data(_skindata);
	animated_text_color = text_color;
	animated_draw_color = draw_color;
	update_startup_coordinates();
	force_redraw();
}

/// @function					force_redraw(_redraw_all = true)
/// @description				force recalculate of all positions next frame
force_redraw = function(_redraw_all = true) {
	__force_redraw = _redraw_all;
	__force_redraw_text_only = !_redraw_all;
	return self;
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
	if (__scribble_text != undefined)
		__scribble_text.draw(__text_x, __text_y);
}

/// @function					__create_scribble_object(align, str)
/// @description				setup the initial object to work with
/// @param {string} align			
/// @param {string} str			
__create_scribble_object = function(align, str) {
	return scribble($"{align}{str}", MY_NAME)
			.starting_format(font_to_use == "undefined" ? scribble_font_get_default() : font_to_use, 
							 animated_text_color);
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
	if (__force_redraw_text_only || __text_anim_running) {
		__scribble_text
			.starting_format(font_to_use == "undefined" ? scribble_font_get_default() : font_to_use, 
							 animated_text_color);
		__force_redraw_text_only = false;
	}
	__scribble_text.transform(__mouse_text_scale, __mouse_text_scale, text_angle);
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
	var was_forced = __force_redraw;
		
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

	if (was_forced || __CONTROL_DRAWS_SELF)
		__draw_instance(was_forced);
}

/// @function __draw_instance(_force = false)
__draw_instance = function(_force = false) {
	//update_client_area();
	
	if (sprite_index != -1) {
		if (!is_enabled) {
			__disabled_surface_width = sprite_width;
			__disabled_surface_height = sprite_height;
			shader_set(GrayScaleShader);
			draw_self();
			shader_reset();
		} else {
			image_blend = animated_draw_color;
			draw_self();
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
