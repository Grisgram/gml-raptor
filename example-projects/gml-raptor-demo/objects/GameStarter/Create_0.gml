/// @description 

#macro GAMESTARTER		global._GAMESTARTER
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
async_min_wait_time		= 90;
draw_spinner			= false; // true while waiting for min-time
wait_for_async_tasks	= false;

trampoline_done			= false;

first_step				= true;

// Inherit the parent event
event_inherited();

