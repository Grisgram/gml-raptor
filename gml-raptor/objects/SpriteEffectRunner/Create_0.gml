/// @description declare __finished_callback

event_inherited();

__raptor_onPoolActivate = function() {
	__finished_callback = undefined;
}

__raptor_onPoolActivate();
