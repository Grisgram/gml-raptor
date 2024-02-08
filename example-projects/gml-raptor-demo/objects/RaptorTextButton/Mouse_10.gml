/// @description set mouse_over_image_index
vlog($"BUTTON popup: {depth} {GUI_POPUP_LAYER_GROUP}, match: {string_match(layer_get_name(layer), GUI_POPUP_LAYER_GROUP)} on {layer_get_name(layer)}");

GUI_EVENT;

event_inherited();
__set_over_image();