/// @desc event

x = GUI_MOUSE_X;
y = GUI_MOUSE_Y;

if (companion != undefined) {
	companion.x = x + sprite_width + companion_offset_x + companion.sprite_xoffset;
	companion.y = y + sprite_height / 2 + companion_offset_y + companion.sprite_yoffset;
}