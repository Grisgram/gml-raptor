/// @desc activate/deactivate functions

event_inherited();

// this variable holds the object for which the tooltip is shown
tooltip_parent = undefined;

__active = false;
__frame_countdown = -1;
__last_activation_delay_frames = -1;
__counting_up = false;

__apply_autosize_alignment = function() {
}

__apply_post_positioning = function() {
}

/// @func	update_tooltip_text()
/// @desc	Invoked when the tooltip becomes visible. Returns own text by default.
///			Override, if you need to check for changed text on every shown-event
update_tooltip_text = function() {
	return text;
}

/// @func	activate(delay_frames = -1)
/// @desc	activate the tooltip to invoke func when shown 
activate = function(delay_frames = -1) {
	if (__frame_countdown <= -1) {
		__frame_countdown = (delay_frames >= 0 ? delay_frames : GUI_RUNTIME_CONFIG.tooltip_delay_frames);
	}
	if (!__counting_up)
		__last_activation_delay_frames = __frame_countdown;
	vlog($"{MY_NAME}: Tooltip activated: delay_frames={__frame_countdown};");
	__counting_up = false;
	__active = true;
}

/// @func	deactivate()
/// @desc	reset tooltip and hide
deactivate = function() {
	__active = false;
	visible = false;
	text = "";
	tooltip_parent = undefined;
	// force zero-text redraw for correct positioning when re-activated
	__draw_self();
	__callback = undefined;
}