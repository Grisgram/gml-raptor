/// @description scribblelize text

event_inherited();

/// @function					__activate_tooltip()
/// @description				start the tooltip countdown onMouseEnter
__activate_tooltip = function() {
	if (tooltip_text == "" || tooltip_object == undefined)
		return;

	tooltip_show(tooltip_object, LG_resolve(tooltip_text));
}

/// @function					__deactivate_tooltip()
/// @description				deactivate the tooltip on the control
__deactivate_tooltip = function() {
	if (tooltip_object == undefined)
		return;
		
	tooltip_hide(tooltip_object);
}

/// @function					__destroy_tooltip()
/// @description				kill the tooltip instance
__destroy_tooltip = function() {
	if (tooltip_object == undefined)
		return;

	tooltip_destroy(tooltip_object);
}
