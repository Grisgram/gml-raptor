/// @description activate/deactivate functions

event_inherited();

__active = false;
__frame_countdown = -1;
__last_activation_delay_frames = -1;
__counting_up = false;

/// @function					update_tooltip_text()
/// @description				Invoked when the tooltip becomes visible. Returns own text by default.
///								Override, if you need to check for changed text on every shown-event
update_tooltip_text = function() {
	return text;
}

/// @function					activate(func)
/// @description				activate the tooltip to invoke func when shown 
/// @param {int=-1} delay_frames override GUI_RUNTIME_CONFIG.tooltip_delay_frames if needed
activate = function(delay_frames = -1) {
	if (__frame_countdown <= -1) {
		__frame_countdown = (delay_frames >= 0 ? delay_frames : GUI_RUNTIME_CONFIG.tooltip_delay_frames);
	}
	if (!__counting_up)
		__last_activation_delay_frames = __frame_countdown;
	log(MY_NAME + sprintf(": Tooltip activated: delay_frames={0};", __frame_countdown));
	__counting_up = false;
	__active = true;
}

/// @function					deactivate()
/// @description				reset tooltip and hide
deactivate = function() {
	__active = false;
	visible = false;
	text = "";
	// force zero-text redraw for correct positioning when re-activated
	__draw_self();
	__callback = undefined;
}