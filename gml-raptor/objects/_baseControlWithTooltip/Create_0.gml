/// @description scribblelize text
__my_active_tooltip = undefined;

event_inherited();

/// @function					__activate_tooltip()
/// @description				start the tooltip countdown onMouseEnter
__activate_tooltip = function() {
	if (tooltip_text == "" || __my_active_tooltip != undefined || tooltip_object == undefined)
		return;

	__my_active_tooltip = tooltip_show(tooltip_object, LG_resolve(tooltip_text),, self);
}

/// @function					__deactivate_tooltip()
/// @description				deactivate the tooltip on the control
__deactivate_tooltip = function() {
	if (tooltip_object == undefined)
		return;
		
	tooltip_hide(tooltip_object);
	__my_active_tooltip = undefined;
}

/// @function					__destroy_tooltip()
/// @description				kill the tooltip instance
__destroy_tooltip = function() {
	if (tooltip_object == undefined)
		return;

	tooltip_destroy(tooltip_object);
	__my_active_tooltip = undefined;
}
