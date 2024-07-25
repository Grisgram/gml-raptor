/// @desc 

#macro GAMESTARTER		global.__gamestarter
GAMESTARTER				= self;

__reset = function() {
	// spinner animation
	spinner_font			= undefined;
	spinner_sprite			= sprLoadingSpinner;
	spinner_frame_counter	= 0;
	spinner_rotation		= 0;
	spinner_x				= 0;
	spinner_y				= 0;
	spinner_w				= sprite_get_width(spinner_sprite);
	spinner_h				= sprite_get_height(spinner_sprite);
	spinner_text			= "Connecting to server...";

	async_looper			= onLoadingScreen;
	async_looper_data		= undefined;
	async_looper_finished	= undefined;
	async_wait_timeout		= -1;
	async_wait_counter		= 0;
	draw_spinner			= false; // true while waiting for min-time
	wait_for_async_tasks	= false;
	wait_for_loading_screen = false;
	loading_screen_task		= {};
	loading_screen_frame	= 0;

	trampoline_done			= false;

	first_step				= true;
}
__reset();

__original_first_room = goto_room_after_init; // backup for reinit

/// @func	run_async_loop(_looper = undefined, _finished_callback = undefined, _looper_data = undefined, _target_room_after = undefined, _transition = undefined)
/// @desc	Runs the specified (_looper) async loading loop, like the one at game start (onLoadingScreen).
///			If no _looper is specified, this function fires the entire async-startup chain 
///			(onLoadingScreen) again, but NOT the onGameStart callback.
///			Use this for language swaps or larger async loading done in the
///			onLoadingScreen callback.
///			Specify any data struct as _looper_data to have it sent to the looper function as
///			third argument. This way you can transport any information to the looper function.
///			If you supply any room, then this function will return to rmStartup, to show
///			the initial loading screen (black with spinner), before returning to the desired
///			room. If you specify nothing, the game stays in the current room and the spinner
///			is just shown as overlay while loading.
run_async_loop = function(
	_looper = undefined, 
	_finished_callback = undefined, 
	_looper_data = undefined, 
	_target_room_after = undefined, 
	_transition = undefined) {
		
	__reset();
	first_step				= false;
	async_min_wait_time		= 0;
	draw_spinner			= true;
	async_looper			= _looper ?? async_looper;
	async_looper_finished	= _finished_callback;
	async_looper_data		= _looper_data;
	visible					= true;
	
	if (_target_room_after != undefined || _transition != undefined) {		
		goto_room_after_init = _target_room_after != undefined ? _target_room_after : __original_first_room;
		wlog($"** GLOBAL ASYNC LOOP ** Target room after is '{room_get_name(goto_room_after_init)}'");
		if (_transition != undefined) {
			_transition.target_room = rmStartup;
			ROOMCONTROLLER.transit(_transition);
		} else
			room_goto(rmStartup);
	} else {
		goto_room_after_init = undefined;
		wlog($"** GLOBAL ASYNC LOOP ** Running async in current room");
	}
}

/// @func show_loading_text(_lg_string)
/// @desc Show a string left of the spinner on the game-start loading screen
show_loading_text = function(_lg_string) {
	spinner_text = LG_resolve(_lg_string);
}

// For the expensive cache, fake the GAMEFRAME content
__FAKE_GAMECONTROLLER;
// Inherit the parent event
event_inherited();

