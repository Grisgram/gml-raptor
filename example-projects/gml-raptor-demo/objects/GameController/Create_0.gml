/// @desc debug_mode & GAMECONTROLLER

event_inherited();
#macro GAMECONTROLLER			global.__game_controller
#macro __FAKE_GAMECONTROLLER	if (!variable_global_exists("__game_controller")) GAMECONTROLLER=SnapFromJSON("{\"image_index\":0}");
GAMECONTROLLER = self;

#macro BROADCASTER		global.__broadcaster
BROADCASTER = new Sender();

#macro __RAPTOR_ASYNC_CALLBACKS	global.__raptor_async_callbacks
__RAPTOR_ASYNC_CALLBACKS = {};

/// @func __add_async_file_callback(_async_id, _callback, _buffer, _data)
__add_async_file_callback = function(_owner, _async_id, _callback, _buffer, _data) {
	var cbn = $"RAC{_async_id}";
	__RAPTOR_ASYNC_CALLBACKS[$ cbn] = {
		owner:		_owner,
		callback:	_callback,
		buffer:		_buffer,
		data:		_data
	};
}

__invoke_async_callback = function(_async_id, _result) {
	TRY
		var cbn = $"RAC{_async_id}";
		var cb = vsget(__RAPTOR_ASYNC_CALLBACKS, cbn);
		if (cb != undefined) {
			var c = cb.callback;
			with(cb.owner)
				c(_result, cb.buffer, cb.data);
			struct_remove(__RAPTOR_ASYNC_CALLBACKS, cbn);
		}
	CATCH ENDTRY
}
