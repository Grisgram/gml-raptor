/// @description run async_looper
event_inherited();

// as long as the game returns true, we stay on this screen
wait_for_loading_screen = (
	ASYNC_OPERATION_RUNNING || 
	async_looper(loading_screen_task, loading_screen_frame, async_looper_data) == true
);

loading_screen_frame++;
