/// @desc debug_mode & GAMECONTROLLER

event_inherited();
#macro GAMECONTROLLER			global.__game_controller
#macro __FAKE_GAMECONTROLLER	if (!variable_global_exists("__game_controller")) GAMECONTROLLER=SnapFromJSON("{\"image_index\":0}");
GAMECONTROLLER = self;

#macro BROADCASTER		global.__broadcaster
BROADCASTER = new Sender();

#macro __RAPTOR_ASYNC_CALLBACKS	global.__raptor_async_callbacks
__RAPTOR_ASYNC_CALLBACKS = {};

add_async_callback = function(_async_id, _callback) {
	var cbn = $"RAC{_async_id}";
	__RAPTOR_ASYNC_CALLBACKS[$ cbn] = _callback;
}

__invoke_async_callback = function(_async_id, _result) {
	var cbn = $"RAC{_async_id}";
	invoke_if_exists(__RAPTOR_ASYNC_CALLBACKS, cbn, _result);
	struct_remove(__RAPTOR_ASYNC_CALLBACKS, cbn);
}
