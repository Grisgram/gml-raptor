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

if (pulse_active)
	outliner.set_shader_pulse(pulse_min_strength, pulse_max_strength, pulse_color_1, pulse_color_2, pulse_frequency_frames);

mouse_is_over = false;

__draw = function() {
	if (outline_always || (outline_on_mouse_over && mouse_is_over))
		outliner.draw_object_outline();
	else
		draw_self();
}