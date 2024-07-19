/// @desc debug_mode & GAMECONTROLLER

event_inherited();
#macro GAMECONTROLLER			global.__game_controller
#macro __FAKE_GAMECONTROLLER	if (!variable_global_exists("__game_controller")) GAMECONTROLLER=SnapFromJSON("{\"image_index\":0}");
GAMECONTROLLER = self;

#macro BROADCASTER				global.__broadcaster
BROADCASTER = new Sender();

#macro ASYNC_OPERATION_RUNNING	(array_length(struct_get_names(__RAPTOR_ASYNC_CALLBACKS)) > 0)
#macro __RAPTOR_ASYNC_CALLBACKS	global.__raptor_async_callbacks
__RAPTOR_ASYNC_CALLBACKS = {};

/// @func __add_async_file_callback(_async_id, _callback)
__add_async_file_callback = function(_owner, _async_id, _callback) {
	var cbn = $"RAC{_async_id}";
	__RAPTOR_ASYNC_CALLBACKS[$ cbn] = {
		owner:		_owner,
		callback:	_callback,
	};
}

__invoke_async_file_callback = function(_async_id, _result) {
	TRY
		var cbn = $"RAC{_async_id}";
		var cb = vsget(__RAPTOR_ASYNC_CALLBACKS, cbn);
		if (cb != undefined) {
			var c = cb.callback;
			with(cb.owner)
				c(_result);
			struct_remove(__RAPTOR_ASYNC_CALLBACKS, cbn);
		}
	CATCH ENDTRY
}

/// @func exit_game()
/// @desc Ends the game as soon as all async operations are finished.
exit_game = function() {
	if (ASYNC_OPERATION_RUNNING) {
		run_delayed(self, 30, function() { GAMECONTROLLER.exit_game(); });
	} else {
		if (os_type == os_windows || os_type == os_android || os_type == os_macosx || os_type == os_linux) game_end();
	}
}
