/// @description event
event_inherited();

if (!is_null(__x_button)) {
	instance_destroy(__x_button);
	__x_button = undefined;
}

if (eq(self, __RAPTOR_FOCUS_WINDOW)) {
	__RAPTOR_FOCUS_WINDOW = undefined;
	__focus_next_in_chain();
}
