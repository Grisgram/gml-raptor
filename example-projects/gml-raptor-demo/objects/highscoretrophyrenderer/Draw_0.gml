/// @description do nothing if draw_on_gui

if (!draw_on_gui && __ensure_surface_is_ready()) 
	draw_surface(__surface,x,y);
