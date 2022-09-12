/// @description declare __finished_callback

event_inherited();

onPoolActivate = function() {
	__finished_callback = undefined;
}

onPoolActivate();
