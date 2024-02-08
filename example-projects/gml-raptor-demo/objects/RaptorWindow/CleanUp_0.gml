/// @description event
event_inherited();

if (!is_null(__x_button)) {
	instance_destroy(__x_button);
	__x_button = undefined;
}
