/*
	Helper methods for generating tooltips on any object.
	Includes a global tooltip instance management, so the same tooltip instance
	of each type gets reused when requested.
*/

#macro TOOLTIP_POOL_NAME		"##_raptor_##.__tooltips"

/// @func	tooltip_show(tooltip_object_index, tooltip_text, delay_frames = -1, for_object = self)
/// @desc	show a tooltip after x frames over a specified object
/// @param {asset} tooltip_object
/// @param {string} scribble-formatted-tooltip-text
/// @param {int=-1} delay
/// @param {instance=self} object to bind to
/// @returns {instance} tooltip instance
function tooltip_show(tooltip_object_index, tooltip_text, delay_frames = -1, for_object = self) {
	var inst = pool_get_instance(TOOLTIP_POOL_NAME, tooltip_object_index, DEPTH_TOP_MOST);
	with (inst) {
		depth = DEPTH_TOP_MOST;
		if (font_to_use == "undefined" && variable_instance_exists(for_object, "font_to_use")) 
			font_to_use = for_object.font_to_use;
		// reset all previous values so the instance thinks, it's the first time
		image_xscale = 1;
		image_yscale = 1;
		__last_text = "";
		update_startup_coordinates();
		text = tooltip_text;
		tooltip_parent = for_object;
		force_redraw();
		__draw_self();
		activate(delay_frames);
	}
	inst.__bound_to = self;
	return inst;
}

/// @func	tooltip_hide(tooltip)
/// @desc	hide / deactivate a tooltip
/// @param {int} tooltip_object_index
function tooltip_hide(tooltip) {
	if (instance_exists(tooltip))
		pool_return_instance(tooltip);
	return;
}

/// @func	tooltip_hide_all()
/// @desc	Hide/Deactivate all child objects of Tooltip
function tooltip_hide_all() {
	with(RaptorTooltip)
		tooltip_hide(self);
}
