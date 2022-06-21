/// @description set default_image_index

event_inherited();

__set_default_image = function() {
	if (sprite_index != -1 && image_number >= default_image_index)
		image_index = default_image_index;
}

__set_over_image = function() {
	if (sprite_index != -1 && image_number >= mouse_over_image_index)
		image_index = mouse_over_image_index;
}

__set_down_image = function() {
	if (sprite_index != -1 && image_number >= mouse_down_image_index)
		image_index = mouse_down_image_index;
}

__set_default_image();
