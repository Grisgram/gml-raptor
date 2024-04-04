/// @description default audio

UI_THEMES.refresh_theme();
UI_SKINS.refresh_skin();

play_music(get_default_music_for_room());
play_ambience(get_default_ambience_for_room());

if (__ACTIVE_TRANSITION != undefined)
	__ACTIVE_TRANSITION.__create_fx_layer();
else
	onTransitFinished();

if (MOUSE_CURSOR != undefined && vsgetx(GAMESETTINGS, "use_system_cursor", false, false))
	with(MOUSE_CURSOR) destroy();

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