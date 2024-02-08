/// @description setup button

event_inherited();

sprite_index = if_null(sprite_to_use, sprite_index);

message_window = undefined;

__window_right = 0;
__window_top = 0;
__nine_slice_calculated = false;
__nine_right = 0;
__nine_top = 0;

/// @function attach_to_window(_window)
attach_to_window = function(_window) {
	message_window = _window;
	if (is_null(message_window) || !is_child_of(message_window, RaptorWindow))
		instance_destroy(self);
}

