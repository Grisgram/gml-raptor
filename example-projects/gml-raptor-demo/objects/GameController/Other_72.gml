/// @description invoke callback
event_inherited();

__invoke_async_callback(
	ds_map_find_value(async_load, "id"),
    ds_map_find_value(async_load, "status")
);
