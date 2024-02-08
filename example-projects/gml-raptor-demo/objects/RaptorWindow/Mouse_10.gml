/// @description suppress parent event if dragging
vlog($"WINDOW popup: {GUI_POPUP_LAYER_GROUP}, match: {string_match(layer_get_name(layer), GUI_POPUP_LAYER_GROUP)} on {layer_get_name(layer)}");
if (!gui_mouse.event_redirection_active) exit;

if (!__in_drag_mode && !__in_size_mode)
	event_inherited();

