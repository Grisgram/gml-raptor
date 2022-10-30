/// @description Watch browser window size changes

event_inherited();

__active = IS_HTML;

curr_width = browser_width;
curr_height = browser_height;

if (__active)
	browser_scrollbars_enable();

/// @function					update_canvas()
/// @description				Update the browser canvas
update_canvas = function() {
	if (!IS_HTML)
		return;
		
	curr_width = browser_width;
	curr_height = browser_height;

	var rw = browser_width;
	var rh = browser_height;

	var newwidth, newheight;
	var scale = min(rw / VIEW_WIDTH, rh / VIEW_HEIGHT);
	
	// find best-fit option
	newwidth = VIEW_WIDTH * scale;
	newheight = VIEW_HEIGHT * scale;
	if (newwidth > rw || newheight > rh) {
		scale = rh / VIEW_HEIGHT;
		newwidth = VIEW_WIDTH * scale;
		newheight = VIEW_HEIGHT * scale;
	}
	
	// resize application_surface, if needed
	if (application_surface_is_enabled()) {
		surface_resize(application_surface, newwidth, newheight);
	}

	// set window size to screen pixel size:
	window_set_size(newwidth, newheight);
	window_set_position(rw / 2 - newwidth / 2, rh / 2 - newheight / 2);

	// set canvas size to page pixel size:
	browser_stretch_canvas(newwidth, newheight);

	if (IS_HTML) {
		GUI_RUNTIME_CONFIG.gui_scale_set(scale, scale);
		GUI_RUNTIME_CONFIG.canvas_width  = newwidth;
		GUI_RUNTIME_CONFIG.canvas_height = newheight;
		GUI_RUNTIME_CONFIG.canvas_scale  = scale;
	}
}

