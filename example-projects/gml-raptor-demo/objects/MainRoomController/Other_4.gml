/// @description fill version label
event_inherited();
lblVersion.text = sprintf(LG("main_menu/version_str"), GAME_VERSION_STRING);
if (IS_HTML) instance_destroy(exitButton);