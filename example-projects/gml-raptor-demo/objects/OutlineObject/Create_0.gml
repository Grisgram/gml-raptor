/// @description set up drawer
event_inherited();

outliner = new outline_drawer(
	0, 
	outline_color, 
	outline_alpha, 
	outline_strength, 
	outline_alpha_fading,
	use_bbox_of_sprite
);
	
mouse_is_over = false;

__draw = function() {
	if (outline_always || (outline_on_mouse_over && mouse_is_over))
		outliner.draw_object_outline();
	else
		draw_self();
}