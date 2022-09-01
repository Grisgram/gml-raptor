/*
    Convenience Audio functions.
*/

#region DEFAULT AUDIO FOR ROOMS
function __default_room_audio(_room, _room_music = undefined, _ambience_sound = undefined) constructor {
	for_room = _room;
	music = _room_music;
	ambience = _ambience_sound;
}

#macro __DEFAULT_ROOM_AUDIO		global.___DEFAULT_ROOM_AUDIO
__DEFAULT_ROOM_AUDIO			= [];

function set_room_default_audio(_room, _music, _ambience) {
	for (var i = 0; i < array_length(__DEFAULT_ROOM_AUDIO); i++) {
		if (__DEFAULT_ROOM_AUDIO[@ i].for_room == _room) {
			var aud = __DEFAULT_ROOM_AUDIO[@ i];
			aud.music = _music;
			aud.ambience = _ambience;
			return;
		}
	}
	array_push(__DEFAULT_ROOM_AUDIO, new __default_room_audio(_room, _music, _ambience));
}

function get_default_music_for_room(_room) {
	for (var i = 0; i < array_length(__DEFAULT_ROOM_AUDIO); i++)
		if (__DEFAULT_ROOM_AUDIO[@ i].for_room == _room)
			return __DEFAULT_ROOM_AUDIO[@ i].music;
	return undefined;
}

function get_default_ambience_for_room() {
	for (var i = 0; i < array_length(__DEFAULT_ROOM_AUDIO); i++)
		if (__DEFAULT_ROOM_AUDIO[@ i].for_room == room)
			return __DEFAULT_ROOM_AUDIO[@ i].ambience;
	return undefined;
}
#endregion

#macro __ACTIVE_MUSIC		global.___ACTIVE_MUSIC
__ACTIVE_MUSIC				= undefined;

#macro __ACTIVE_AMBIENCE	global.___ACTIVE_AMBIENCE
__ACTIVE_AMBIENCE			= undefined;

/// @function		play_ui_sound(snd, priority = 7, gain = 1.0)
/// @description	Plays a sound of type ui (attached to ui_volume setting)
function play_ui_sound(snd, priority = 7, gain = 1.0) {
	if (AUDIOSETTINGS.sound_enabled && snd != undefined) {
		var sid = audio_play_sound(snd, priority, false);
		audio_sound_gain(sid, gain * AUDIOSETTINGS.ui_volume * AUDIOSETTINGS.master_volume, 0);
		return sid;
	}
	return undefined;
}

/// @function		play_voice(snd, priority = 10, gain = 1.0, loop = false)
/// @description	Plays a sound of type voice (attached to voice_volume setting)
function play_voice(snd, priority = 10, gain = 1.0, loop = false) {
	if (AUDIOSETTINGS.sound_enabled && snd != undefined) {
		var sid = audio_play_sound(snd, priority, loop);
		audio_sound_gain(sid, gain * AUDIOSETTINGS.voice_volume * AUDIOSETTINGS.master_volume, 0);
		return sid;
	}
	return undefined;
}

/// @function		play_sound(snd, priority = 10, gain = 1.0, loop = false)
/// @description	Plays a sound of type sfx (attached to sound_volume setting)
function play_sound(snd, priority = 10, gain = 1.0, loop = false) {
	if (AUDIOSETTINGS.sound_enabled && snd != undefined) {
		var sid = audio_play_sound(snd, priority, loop);
		audio_sound_gain(sid, gain * AUDIOSETTINGS.sound_volume * AUDIOSETTINGS.master_volume, 0);
		return sid;
	}
	return undefined;
}

/// @function		stop_sound(sound_id)
/// @description	Stops any supplied playing sound_id
function stop_sound(sound_id) {
	if (sound_id != undefined)
		audio_stop_sound(sound_id);
}

/// @function		play_music(mus, priority = 9, gain = 1.0, loop = true)
/// @description	Plays a sound of type music (attached to music_volume setting)
function play_music(mus, priority = 9, gain = 1.0, loop = true) {
	stop_music();
	if (AUDIOSETTINGS.music_enabled && mus != undefined) {
		__ACTIVE_MUSIC = audio_play_sound(mus, 9, loop);
		audio_sound_gain(__ACTIVE_MUSIC, gain * AUDIOSETTINGS.music_volume * AUDIOSETTINGS.master_volume, 0);
	}
}

/// @function		stop_music()
/// @description	Stops the currently playing music
function stop_music() {
	if (__ACTIVE_MUSIC != undefined) {
		audio_stop_sound(__ACTIVE_MUSIC);
		__ACTIVE_MUSIC = undefined;
	}
}

/// @function		play_ambience(amb, priority = 8, gain = 1.0, loop = true)
/// @description	Plays a sound of type ambience (attached to ambience_volume setting)
function play_ambience(amb, priority = 8, gain = 1.0, loop = true) {
	stop_ambience();
	if (AUDIOSETTINGS.ambience_enabled && amb != undefined) {
		__ACTIVE_AMBIENCE = audio_play_sound(amb, priority, loop);
		audio_sound_gain(__ACTIVE_AMBIENCE, gain * AUDIOSETTINGS.ambience_volume * AUDIOSETTINGS.master_volume, 0);
	}
}

/// @function		stop_ambience()
/// @description	Stops the currently playing ambience sounds
function stop_ambience() {
	if (__ACTIVE_AMBIENCE != undefined) {
		audio_stop_sound(__ACTIVE_AMBIENCE);
		__ACTIVE_AMBIENCE = undefined;
	}
}

