/// @description fill version label
event_inherited();
lblVersion.text = sprintf(LG("main_menu/version_str"), GAME_VERSION_STRING);

gameversionInfo.x += scribble_measure_text(gameversionLabel.text).x - 16;
copyrightLabelInfo.x += scribble_measure_text(copyrightLabel.text).x - 16;

if (IS_HTML) instance_destroy(exitButton);

layer_set_background_color("Background", APP_THEME.main);

//repeat(100) {
// binding test
with (lblbroker) {
	internalstruct = { frame: 0 };
	_frame = 0;
	
	binder.bind_pull("_frame", GAMECONTROLLER, "image_index");
	binder.bind_push("_frame", internalstruct, "frame");
	
	binder.bind_push("_frame", self, "text", NUMBER_TO_STRING_CONVERTER);
}

with (lblpullbrokerstruct)
	binder.bind_pull("text", lblbroker.internalstruct, "frame", NUMBER_TO_STRING_CONVERTER);
//}