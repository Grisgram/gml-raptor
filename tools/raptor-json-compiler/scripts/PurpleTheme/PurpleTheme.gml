/*
    Raptor Demo red theme (live switch)
*/

function PurpleTheme() : UiTheme("purple") constructor {

	// "Your" colors
	main			= #4F00C5;
	bright			= #C396FF;
	dark			= #160099;
	accent			= #9249FF;

	// Greyscales
	white			= #DDBBFF;
	black			= CI_GLOBAL_BLACK;
	shadow			= CI_GLOBAL_SHADOW;

	// UI controls
	control_back	= CI_GLOBAL_CONTROL_BACK;
	control_dark	= CI_GLOBAL_CONTROL_DARK;
	control_bright	= CI_GLOBAL_CONTROL_BRIGHT;
	control_text	= dark;
	window_back		= CI_GLOBAL_WINDOW_BACK;
	window_focus	= CI_GLOBAL_WINDOW_FOCUS;

}
