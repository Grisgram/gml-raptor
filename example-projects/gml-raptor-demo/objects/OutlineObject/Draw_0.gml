/// @description draw outline if mouse is over
if (sprite_index == -1) exit;

if (outline_on_mouse_over && mouse_is_over)
	outliner.draw_object_outline();
else
	draw_self();
	
