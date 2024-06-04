/// @description onLoadingScreen
event_inherited();

// as long as the game returns true, we stay on this screen
wait_for_loading_screen = (onLoadingScreen(loading_screen_task, loading_screen_frame) == true);
if (wait_for_loading_screen) loading_screen_frame++;
