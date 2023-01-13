/// @description event

x = translate_world_to_gui_x(mouse_x);
y = translate_world_to_gui_y(mouse_y);

if (companion != undefined) {
	companion.x = x + sprite_width + companion_offset_x + companion.sprite_xoffset;
	companion.y = y + sprite_height / 2 + companion_offset_y + companion.sprite_yoffset;
}