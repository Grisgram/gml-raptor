/// @description set mouse_over_image_index

GUI_EVENT;

event_inherited();
__set_over_image();

log($"{__text_x}/{__text_y} off {text_xoffset} dist {distance_to_text} wi/he {sprite_width}/{sprite_height} un {unscaled} of {original_offset}");