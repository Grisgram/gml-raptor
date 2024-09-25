/// @desc debug_mode & GAMECONTROLLER

// --- GLOBAL GAME THINGS ---
event_inherited();
#macro GAMECONTROLLER			global.__game_controller
#macro __FAKE_GAMECONTROLLER	if (!variable_global_exists("__game_controller")) GAMECONTROLLER=SnapFromJSON("{\"image_index\":0}");
GAMECONTROLLER = self;

#macro BROADCASTER				global.__broadcaster
#macro ENSURE_BROADCASTER		if (!variable_global_exists("__broadcaster")) BROADCASTER = new Sender();
ENSURE_BROADCASTER;

// --- ASYNC OPERATION MANAGEMENT ---
#macro ASYNC_OPERATION_RUNNING	(array_length(struct_get_names(__RAPTOR_ASYNC_CALLBACKS)) > 0)
#macro ASYNC_OPERATION_POLL_INT	30
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

/// @func	exit_game()
/// @desc	Ends the game as soon as all async operations are finished.
///			NOTE: This function can be reached also through the EXIT_GAME macro!
exit_game = function() {
	var async_cnt = array_length(struct_get_names(__RAPTOR_ASYNC_CALLBACKS));
	if (async_cnt > 0) {
		wlog($"Waiting for async operations to finish ({async_cnt} are running)...");
		run_delayed(self, ASYNC_OPERATION_POLL_INT, function() { GAMECONTROLLER.exit_game(); });
	} else {
		if (os_type == os_windows || os_type == os_android || os_type == os_macosx || os_type == os_linux) game_end();
	}
}
