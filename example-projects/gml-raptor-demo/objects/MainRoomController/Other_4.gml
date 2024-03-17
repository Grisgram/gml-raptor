/// @description fill version label
event_inherited();
lblVersion.text = sprintf(LG("main_menu/version_str"), GAME_VERSION_STRING);

gameversionInfo.x += scribble_measure_text(gameversionLabel.text).x - 16;
copyrightLabelInfo.x += scribble_measure_text(copyrightLabel.text).x - 16;

if (IS_HTML) instance_destroy(exitButton);

layer_set_background_color("Background", APP_THEME.main);
