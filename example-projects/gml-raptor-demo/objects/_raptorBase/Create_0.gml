/// @description Logging/Enabled/Skinning
if (log_create_destroy)
	vlog($"{MY_NAME} created.");

binder = new PropertyBinder(self);

#region skin
APP_SKIN.apply_skin(self); // apply sprites NOW...
run_delayed(self, 0, function() { APP_SKIN.apply_skin(self); }); //... and the full skin after all create code is done

/// @function integrate_skin_data(_skindata)
/// @description Copy all values EXCEPT SPRITE_INDEX to self
///				 Then, if we have a sprite, we replace it
integrate_skin_data = function(_skindata) {
	if (!skinnable) return;
	struct_foreach(_skindata, function(name, value) {
		if (name != "sprite_index") {
			if (is_method(value))
				self[$ name] = method(self, value);
			else
				self[$ name] = value;
		}
	});
	if (vsget(_skindata, "sprite_index") != undefined && sprite_index != -1)
		replace_sprite(_skindata.sprite_index);
}

/// @function on_skin_changed(_skindata)
/// @description	Invoked, when the skin changed
on_skin_changed = function(_skindata) {
	if (!skinnable) return;
	integrate_skin_data(_skindata);
}
#endregion

#region enabled
/// @function set_enabled(_enabled)
/// @description if you set the enabled state through this function, the on_enabled_changed callback
///				 gets invoked, if the state is different from the current state
set_enabled = function(_enabled) {
	var need_invoke = (is_enabled != _enabled);
	is_enabled = _enabled;
	if (need_invoke && on_enabled_changed != undefined) {
		vlog($"Enabled changed for {MY_NAME}");
		on_enabled_changed(self);
	}
}

#endregion

#region topmost
/// @function __can_touch_this(_instance)
__can_touch_this = function(_instance) {
	if (is_child_of(_instance, RaptorTooltip) ||
		is_child_of(_instance, RaptorUiRootPanel) ||
		is_child_of(_instance, MouseCursor)) return false;
	with(_instance) if (!__CONTROL_IS_ENABLED || __INSTANCE_UNREACHABLE) return false;
	
	return true;
}

/// @function is_topmost()
/// @description True, if this control is the topmost (= lowest depth) at the specified position
__topmost_object_list = ds_list_create();
is_topmost = function(_x, _y) {
	ds_list_clear(__topmost_object_list);
	if (instance_position_list(_x, _y, _raptorBase, __topmost_object_list, false) > 0) {
		var mindepth = depth;
		var w = undefined;
		for (var i = 0, len = ds_list_size(__topmost_object_list); i < len; i++) {
			w = __topmost_object_list[|i];
			if (!__can_touch_this(w)) continue;
			mindepth = min(mindepth, w.depth);
		}
		return (mindepth == depth);
	}
	return false;
}
#endregion
