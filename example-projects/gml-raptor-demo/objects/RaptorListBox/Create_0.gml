/// @description event
event_inherited();

enum listbox_sort {
	none, ascending, descending
}

down_arrow_sprite ??= sprDefaultListBoxArrow;

is_open = false;
open_list = function() {
	if (is_open) return;
	
	invoke_if_exists(self, "on_list_opening");
	if (array_length(items) > 0) {
		// TODO: aquire panel and all items from pool
		
		invoke_if_exists(self, "on_list_opened");
		is_open = true;
	}
}

close_list = function() {
	if (!is_open) return;
	// TODO: return panel + all items to pool
	
	invoke_if_exists(self, "on_list_closed");
	is_open = false;
}

toggle_open_state = function() {
	if (is_open) close_list(); else open_list();
}

__draw_instance = function(_force = false) {
	__basecontrol_draw_instance(_force);
	
	if (!visible) return;
	
	draw_sprite_ext(down_arrow_sprite, 0, 
		SELF_VIEW_RIGHT_EDGE, 
		SELF_VIEW_CENTER_Y,
		1, 1, image_angle,
		mouse_is_over ? draw_color_mouse_over : draw_color,
		image_alpha);
}