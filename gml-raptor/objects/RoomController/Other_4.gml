/// @description default audio

play_music(get_default_music_for_room(room));
play_ambience(get_default_ambience_for_room(room));

if (__ACTIVE_TRANSITION != undefined)
	__ACTIVE_TRANSITION.__create_fx_layer();
