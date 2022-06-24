/// @description self-remove from TOOLTIP_INSTANCES

var ttname = object_get_name(object_index);
if (variable_struct_exists(TOOLTIP_INSTANCES, ttname)) {
	log(MY_NAME + sprintf(": Removing tooltip instance: tooltip='{0};", ttname));
	variable_struct_remove(TOOLTIP_INSTANCES, ttname);
}

event_inherited();
