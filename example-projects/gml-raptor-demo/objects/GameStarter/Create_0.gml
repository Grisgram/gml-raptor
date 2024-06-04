/// @desc 

#macro GAMESTARTER		global.__gamestarter
GAMESTARTER				= self;

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

/// @func show_loading_text(_lg_string)
/// @desc Show a string left of the spinner on the game-start loading screen
show_loading_text = function(_lg_string) {
	spinner_text = LG_resolve(_lg_string);
}

// For the expensive cache, fake the GAMEFRAME content
__FAKE_GAMECONTROLLER;
// Inherit the parent event
event_inherited();

