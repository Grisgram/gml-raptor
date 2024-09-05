/// @desc skins,audio,mouse

UI_THEMES.refresh_theme();
UI_SKINS.refresh_skin();

play_music(get_default_music_for_room());
play_ambience(get_default_ambience_for_room());

if (__ACTIVE_TRANSITION != undefined)
	__ACTIVE_TRANSITION.__create_fx_layer();
else
	onTransitFinished();

// Room mouse cursor management
if (MOUSE_CURSOR != undefined && vsgetx(GAMESETTINGS, "use_system_cursor", false, false))
	with(MOUSE_CURSOR) destroy();

if (hide_mouse_cursor) {
	if (MOUSE_CURSOR != undefined) MOUSE_CURSOR.visible = false; else window_set_cursor(cr_none);
	
	if (show_mouse_on_popups) {
		BROADCASTER.add_receiver(self, MY_NAME + "_popupmouseon", __RAPTOR_BROADCAST_POPUP_SHOWN,
			function(bc) {
				if (MOUSE_CURSOR != undefined) MOUSE_CURSOR.visible = true;
				else window_set_cursor(cr_default);
			}
		);
	
		BROADCASTER.add_receiver(self, MY_NAME + "_popupmouseoff", __RAPTOR_BROADCAST_POPUP_HIDDEN,
			function(bc) {
				if (MOUSE_CURSOR != undefined) MOUSE_CURSOR.visible = false;
				else window_set_cursor(cr_none);
			}
		);
	}
}

// Continue loading then game
if (__SAVEGAME_CONTINUE_LOAD_STATE != undefined) {
	var loadstate = __SAVEGAME_CONTINUE_LOAD_STATE;
	__SAVEGAME_CONTINUE_LOAD_STATE = undefined;
	
	ilog($"Continuing game load in new room...");
	TRY
		__continue_load_savegame(
			loadstate._savegame,
			loadstate._refstack,
			loadstate._engine,
			loadstate._data_only,
			loadstate._loaded_version
		);
	CATCH
		if (onGameLoadFailed != undefined)
			onGameLoadFailed(__exception);
	ENDTRY
}
