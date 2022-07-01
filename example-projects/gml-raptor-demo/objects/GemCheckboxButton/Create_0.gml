/// @description 

// Inherit the parent event
event_inherited();

toggle_checked = function() {
	is_checked = !is_checked;
	
	draw_color = (is_checked ? c_green : c_red);
	draw_color_mouse_over = draw_color;
}
