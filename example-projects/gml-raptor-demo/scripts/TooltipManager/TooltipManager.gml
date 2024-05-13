/*
	Helper methods for generating tooltips on any object.
	Includes a global tooltip instance management, so the same tooltip instance
	of each type gets reused when requested.
*/

#macro TOOLTIP_INSTANCES		global.__tooltip_instances

TOOLTIP_INSTANCES	= {};

/// @func					tooltip_get_instance(tooltip_object_index)
/// @desc				get or create a new instance for a tooltip
/// @param {int} tooltip_object_index
/// @returns {instance} the tooltip
function tooltip_get_instance(tooltip_object_index) {
	var ttname = object_get_name(tooltip_object_index);
	var inst;
	if (variable_struct_exists(TOOLTIP_INSTANCES, ttname)) {
		inst = struct_get(TOOLTIP_INSTANCES, ttname);
		instance_activate_object(inst);
	} else {
		vlog($"{MY_NAME}: Creating new tooltip instance: tooltip='{ttname}';");
		inst = instance_create(x, y, DEPTH_TOP_MOST, tooltip_object_index);
		inst.visible = false;
		struct_set(TOOLTIP_INSTANCES, ttname, inst);
	}
	return inst;
}

/// @func					tooltip_show(tooltip_object_index, tooltip_text, delay_frames = -1, for_object = self)
/// @desc				show a tooltip after x frames over a specified object
/// @param {asset} tooltip_object
/// @param {string} scribble-formatted-tooltip-text
/// @param {int=-1} delay
/// @param {instance=self} object to bind to
/// @returns {instance} tooltip instance
function tooltip_show(tooltip_object_index, tooltip_text, delay_frames = -1, for_object = self) {
	var inst = tooltip_get_instance(tooltip_object_index);
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

/// @func					tooltip_hide(tooltip_object_index)
/// @desc				hide / deactivate a tooltip
/// @param {int} tooltip_object_index
function tooltip_hide(tooltip_object_index) {
	var ttname = object_get_name(tooltip_object_index);
	if (variable_struct_exists(TOOLTIP_INSTANCES, ttname)) {
		with (struct_get(TOOLTIP_INSTANCES, ttname)) {
			if (__bound_to == other && (visible || __active)) {
				vlog($"{MY_NAME}: Deactivating tooltip: tooltip='{ttname}';");
				deactivate();
				instance_deactivate_object(self);
			}
		}
	}
}

/// @func					tooltip_destroy(tooltip_object_index)
/// @desc				destroy a tooltip instance
/// @param {int} tooltip_object_index
function tooltip_destroy(tooltip_object_index) {
	var ttname = object_get_name(tooltip_object_index);
	if (variable_struct_exists(TOOLTIP_INSTANCES, ttname)) {
		var inst = struct_get(TOOLTIP_INSTANCES, ttname);
		vlog($"{MY_NAME}: Destroying tooltip instance: tooltip='{ttname}';");
		instance_activate_object(inst);
		instance_destroy(inst);
	}
}