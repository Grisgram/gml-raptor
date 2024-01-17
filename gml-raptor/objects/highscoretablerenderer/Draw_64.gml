/// @description 
event_inherited();

if (draw_on_gui && __ensure_surface_is_ready()) 
	draw_surface(__surface,x,y);
