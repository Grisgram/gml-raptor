/// @desc Logging/Enabled/Skinning

if (log_create_destroy)
	vlog($"{MY_NAME} created.");

binder = new PropertyBinder(self);

#region skin
SKIN.apply_skin(self); // apply sprites NOW...
run_delayed(self, 0, function() { SKIN.apply_skin(self); }); //... and the full skin after all create code is done

/// @func integrate_skin_data(_skindata)
/// @desc Copy all values EXCEPT SPRITE_INDEX to self
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

/// @func on_skin_changed(_skindata)
/// @desc	Invoked, when the skin changed
on_skin_changed = function(_skindata) {
	if (!skinnable) return;
	integrate_skin_data(_skindata);
}
#endregion

#region enabled
/// @func set_enabled(_enabled)
/// @desc if you set the enabled state through this function, the on_enabled_changed callback
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
/// @func __can_touch_this(_instance)
__can_touch_this_child = undefined;
__can_touch_this = function(_instance) {
	with(_instance) {
		__can_touch_this_child ??= 
			is_child_of(self, RaptorTooltip) ||
			is_child_of(self, RaptorUiRootPanel) ||
			is_child_of(self, MouseCursor);
		if (__can_touch_this_child || !__CONTROL_IS_ENABLED || __INSTANCE_UNREACHABLE) return false;
	}
	return true;
}

/// @func is_topmost()
/// @desc True, if this control is the topmost (= lowest depth) at the specified position
__topmost_object_list = ds_list_create();
__topmost_count = 0;
__topmost_mindepth = depth;
__topmost_runner = undefined;
__topmost_cache = new ExpensiveCache();
is_topmost = function(_x, _y) {
	if (__topmost_cache.is_valid()) 
		return __topmost_cache.return_value;
		
	ds_list_clear(__topmost_object_list);
	__topmost_count = instance_position_list(_x, _y, _raptorBase, __topmost_object_list, false);
	if (__topmost_count > 0) {
		__topmost_mindepth = depth;
		__topmost_runner = undefined;
		for (var i = 0; i < __topmost_count; i++) {
			__topmost_runner = __topmost_object_list[|i];
			if (!__can_touch_this(__topmost_runner)) continue;
			__topmost_mindepth = min(__topmost_mindepth, __topmost_runner.depth);
		}
		return __topmost_cache.set(__topmost_mindepth == depth);
	}
	return __topmost_cache.set(true);
}
#endregion
