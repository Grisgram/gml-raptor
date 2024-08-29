/*
    An audio-token is pre-defined set of these values, which are the common
	parameters for all play_sound/play_ui_sound/play_voice commands.
	
	It makes launching an audio easier to write
	
	gain		  = 1.0, 
	loop		  = false, 
	pitch		  = AUDIO_VOICE_DEFAULT_PITCH, 
	offset		  = 0, 
	listener_mask = AUDIO_VOICE_DEFAULT_LISTENER_MASK, 
	priority	  = AUDIO_VOICE_DEFAULT_PRIORITY
	
	All these values offer builder-pattern setter function and there is also
	a reset() function available, which reverts all changes to the original state
	when the token was created.
	
	In addition, playing your audio through tokens offers these settings:
	* Cooldown (avoid repeating a sound too often)
	* Max concurrent plays (how often can a sound run in parallel)
	
*/

/// @func __AudioToken(_channel_func, _sound_asset, _gain = 1.0, _loop = false, _pitch = 1.0, _offset = 0, _listener_mask = -1, _priority = 7)
function __AudioToken(
		_channel_func,
		_sound_asset, 
		_gain		   = 1.0, 
		_loop		   = false, 
		_pitch		   = AUDIO_SOUND_DEFAULT_PITCH, 
		_offset		   = 0, 
		_listener_mask = AUDIO_SOUND_DEFAULT_LISTENER_MASK, 
		_priority	   = AUDIO_SOUND_DEFAULT_PRIORITY
	) constructor {

	__channel_func		= _channel_func;
	__sound_id			= [];
	__removers			= [];
	__cooldown			= 0;
	__max_concurrent	= -1;
	
	// holds the GAME_FRAME when this sound token is available again
	__cooldown_runner	= 0;
	
	_original_sound_asset	= _sound_asset;
	_original_gain			= _gain;
	_original_loop			= _loop;
	_original_pitch			= _pitch;
	_original_offset		= _offset;
	_original_listener_mask = _listener_mask;
	_original_priority		= _priority;
	reset();

	/// @func reset()
	static reset = function() {
		sound_asset		= _original_sound_asset;
		gain			= _original_gain;
		loop			= _original_loop;
		pitch			= _original_pitch;
		offset			= _original_offset;
		listener_mask	= _original_listener_mask;
		priority		= _original_priority;
		return self;
	}
	
	static __cleanup_finished_plays = function() {
		for (var i = 0, len = array_length(__sound_id); i < len; i++)
			if (!audio_is_playing(__sound_id[@i])) array_push(__removers, i);
			
		while (array_length(__removers) > 0) 
			array_delete(__sound_id, array_pop(__removers), 1);
	}

	/// @func play()
	static play = function() {
		__cleanup_finished_plays();
		if (__max_concurrent == -1 || array_length(__sound_id) < __max_concurrent) {
			if (__cooldown == 0 || GAME_FRAME >= __cooldown_runner) {
				array_push(__sound_id, __channel_func(sound_asset, gain, loop, pitch, offset, listener_mask, priority));
				__cooldown_runner = (__cooldown > 0 ? GAME_FRAME + __cooldown : 0);
			} else
				dlog($"Ignored play of sound '{audio_get_name(sound_asset)}', it is on cooldown for {(__cooldown_runner - GAME_FRAME)} more frames");
		} else
			dlog($"Ignored play of sound '{audio_get_name(sound_asset)}', max_concurrent is set to {__max_concurrent} and {array_length(__sound_id)} already playing");
		
		return self;
	}
	
	/// @func stop()
	/// @desc stops ALL playing copies of this token
	static stop = function() {
		for (var i = 0, len = array_length(__sound_id); i < len; i++)
			stop_sound(__sound_id[@i]);
		

		__sound_id = [];
		return self;
	}

	#region setter functions
	/// @func set_cooldown(_cooldown_frames)
	static set_cooldown = function(_cooldown_frames) {
		__cooldown = _cooldown_frames;
		return self;
	}

	/// @func set_max_concurrent(_max_concurrent = -1_to_disable)
	static set_max_concurrent = function(_max_concurrent) {
		__max_concurrent = _max_concurrent;
		return self;
	}

	/// @func set_gain(_gain)
	static set_gain = function(_gain) {
		gain = _gain;
		return self;
	}

	/// @func set_loop(_loop)
	static set_loop = function(_loop) {
		loop = _loop;
		return self;
	}

	/// @func set_pitch(_pitch)
	static set_pitch = function(_pitch) {
		pitch = _pitch;
		return self;
	}

	/// @func set_offset(_offset)
	static set_offset = function(_offset) {
		offset = _offset;
		return self;
	}

	/// @func set_listener_mask(_listener_mask)
	static set_listener_mask = function(_listener_mask) {
		listener_mask = _listener_mask;
		return self;
	}

	/// @func set_priority(_priority)
	static set_priority = function(_priority) {
		priority = _priority;
		return self;
	}
	#endregion
	
}

/// @func UiSoundToken(_sound_asset, _gain = 1.0, _pitch = 1.0, _offset = 0, _listener_mask = -1, _priority = 7)
function UiSoundToken(
	_sound_asset, 
	_gain		   = 1.0, 
	_pitch		   = AUDIO_UI_DEFAULT_PITCH, 
	_offset		   = 0, 
	_listener_mask = AUDIO_UI_DEFAULT_LISTENER_MASK, 
	_priority	   = AUDIO_UI_DEFAULT_PRIORITY
) : __AudioToken(
	play_ui_sound	,
	_sound_asset	,
	_gain		  	,
	false		  	,
	_pitch		  	,
	_offset		  	,
	_listener_mask	,
	_priority	  	
) constructor {
}

/// @func SoundToken(_sound_asset, _gain = 1.0, _loop = false, _pitch = 1.0, _offset = 0, _listener_mask = -1, _priority = 7)
function SoundToken(
	_sound_asset, 
	_gain		   = 1.0, 
	_loop		   = false,
	_pitch		   = AUDIO_SOUND_DEFAULT_PITCH, 
	_offset		   = 0, 
	_listener_mask = AUDIO_SOUND_DEFAULT_LISTENER_MASK, 
	_priority	   = AUDIO_SOUND_DEFAULT_PRIORITY
) : __AudioToken(
	play_sound		,
	_sound_asset	,
	_gain		  	,
	_loop		  	,
	_pitch		  	,
	_offset		  	,
	_listener_mask	,
	_priority	  	
) constructor {
}

/// @func VoiceToken(_sound_asset, _gain = 1.0, _loop = false, _pitch = 1.0, _offset = 0, _listener_mask = -1, _priority = 7)
function VoiceToken(
	_sound_asset, 
	_gain		   = 1.0, 
	_loop		   = false,
	_pitch		   = AUDIO_VOICE_DEFAULT_PITCH, 
	_offset		   = 0, 
	_listener_mask = AUDIO_VOICE_DEFAULT_LISTENER_MASK, 
	_priority	   = AUDIO_VOICE_DEFAULT_PRIORITY
) : __AudioToken(
	play_voice		,
	_sound_asset	,
	_gain		  	,
	_loop		  	,
	_pitch		  	,
	_offset		  	,
	_listener_mask	,
	_priority	  	
) constructor {
}
