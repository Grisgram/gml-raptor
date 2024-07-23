/// @description onLoadingScreen
event_inherited();

// as long as the game returns true, we stay on this screen
wait_for_loading_screen = (ASYNC_OPERATION_RUNNING || onLoadingScreen(loading_screen_task, loading_screen_frame) == true);
loading_screen_frame++;
