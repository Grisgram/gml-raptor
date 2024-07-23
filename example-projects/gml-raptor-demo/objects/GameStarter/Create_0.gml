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

/// @func	reinit_game(_target_room_after = undefined, _transition = undefined)
/// @desc	Returns to rmStartup and fires the entire async-startup chain again,
///			but NOT the onGameStart callback.
///			Use this for language swaps or larger async loading done in the
///			onLoadingScreen callback. This is the one, running again.
reinit_game = function(_target_room_after = undefined, _transition = undefined) {
	goto_room_after_init = _target_room_after != undefined ? _target_room_after : __original_first_room;
	wlog($"** GAME RE-INIT ** Target room after is '{room_get_name(goto_room_after_init)}'");
	__reset();
	first_step			= false;
	async_min_wait_time = 0;
	if (_transition != undefined) {
		_transition.target_room = rmStartup;
		ROOMCONTROLLER.transit(_transition);
	} else
		room_goto(rmStartup);
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

