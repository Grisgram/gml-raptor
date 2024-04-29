/*
    Raptor Demo red theme (live switch)
*/

function PurpleTheme() : UiTheme("purple") constructor {

	// "Your" colors
	main	= #4F00C5;
	bright	= #C396FF;
	dark	= #160099;
	accent	= #9249FF;

	// Greyscales
	white	= #DDBBFF;
	black	= CI_GLOBAL_BLACK;
	shadow	= CI_GLOBAL_SHADOW;

	// UI controls
	control_back			= CI_GLOBAL_CONTROL_BACK;
	control_back_dark		= CI_GLOBAL_CONTROL_BACK_DARK;
	control_back_bright		= CI_GLOBAL_CONTROL_BACK_BRIGHT;
	control_text			= dark;
	control_window_back		= CI_GLOBAL_CONTROL_WINDOW_BACK;
	control_window_focus	= CI_GLOBAL_CONTROL_WINDOW_FOCUS;

}
