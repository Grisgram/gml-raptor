/*
	Helper methods for generating tooltips on any object.
	Includes a global tooltip instance management, so the same tooltip instance
	of each type gets reused when requested.
*/

#macro TOOLTIP_INSTANCES		global.__tooltip_instances
#macro TOOLTIP_LAYER			global.__tooltip_layer

TOOLTIP_INSTANCES	= {};
TOOLTIP_LAYER		= undefined;

/// @function					tooltip_get_instance(tooltip_object_index)
/// @description				get or create a new instance for a tooltip
/// @param {int} tooltip_object_index
/// @returns {instance} the tooltip
function tooltip_get_instance(tooltip_object_index) {
	var ttname = object_get_name(tooltip_object_index);
	var inst;
	if (variable_struct_exists(TOOLTIP_INSTANCES, ttname))
		inst = variable_struct_get(TOOLTIP_INSTANCES, ttname);
	else {
		log(MY_NAME + sprintf(": Creating new tooltip instance: tooltip='{0}';", ttname));
		inst = instance_create_layer(x, y, TOOLTIP_LAYER ?? layer, tooltip_object_index);
		inst.visible = false;
		variable_struct_set(TOOLTIP_INSTANCES, ttname, inst);
	}
	return inst;
}

/// @function					tooltip_show(tooltip_object_index, tooltip_text, delay_frames = -1, for_object = self)
/// @description				show a tooltip after x frames over a specified object
/// @param {int} tooltip_object
/// @param {string} scribble-formatted-tooltip-text
/// @param {int=-1} delay
/// @param {instance=self} object to bind to
/// @returns {instance} tooltip instance
function tooltip_show(tooltip_object_index, tooltip_text, delay_frames = -1, for_object = self) {
	var inst = tooltip_get_instance(tooltip_object_index);
	with (inst) {
		if (TOOLTIP_LAYER == undefined)
			depth = for_object.depth - 1;
		if (font_to_use == "undefined" && variable_instance_exists(for_object, "font_to_use")) 
			font_to_use = for_object.font_to_use;
		text = tooltip_text;
		force_redraw();
		__draw_self();
		activate(delay_frames);
	}
	return inst;
}

/// @function					tooltip_hide(tooltip_object_index)
/// @description				hide / deactivate a tooltip
/// @param {int} tooltip_object_index
function tooltip_hide(tooltip_object_index) {
	var ttname = object_get_name(tooltip_object_index);
	if (variable_struct_exists(TOOLTIP_INSTANCES, ttname)) {
		with (variable_struct_get(TOOLTIP_INSTANCES, ttname)) {
			if (visible || __active) {
				log(MY_NAME + sprintf(": Deactivating tooltip: tooltip='{0}';", ttname));
				deactivate();
			}
		}
	}
}

/// @function					tooltip_destroy(tooltip_object_index)
/// @description				destroy a tooltip instance
/// @param {int} tooltip_object_index
function tooltip_destroy(tooltip_object_index) {
	var ttname = object_get_name(tooltip_object_index);
	if (variable_struct_exists(TOOLTIP_INSTANCES, ttname)) {
		var inst = variable_struct_get(TOOLTIP_INSTANCES, ttname);
		log(MY_NAME + sprintf(": Destroying tooltip instance: tooltip='{0}';", ttname));
		instance_destroy(inst);
	}
}