/*
	These callbacks get invoked from the GameStarter object in the
	GameStart and GameEnd events respectively.
	If the game is currently in HTML mode, HTML_LOCALES is used to set up the locale list.
	Note for locales: The first entry in the array is the fallback (default) language and
	should always contain 100% of all strings!
	
	They have been created to encapsulate one-time-startup/-shutdown actions in
	an isolated script file, so you do not need to modify the GameStarter object directly
	in each game.
	
	onGameStart runs AFTER the ci_colors have been initialized.
	It is recommended, to set at least the app_theme in the onGameStart function, so 
	scribble gets initialized with the correct set of ci_colors.
	
	------------------------------------------------------
	NOTE: HTML5 games never receive an onGameEnd callback!
	------------------------------------------------------

	(c)2022 Mike Barthold, risingdemons/indievidualgames, aka @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

// This macro is only used once in a html game when the game initalizes
#macro HTML_LOCALES			["en", "de"]

/// @function function onGameStart()
function onGameStart() {

	// Debug/Dev configuration
	DEBUG_SHOW_OBJECT_FRAMES	= false;
	DEBUG_MODE_ACTIVE			= true;
	DEBUG_MODE_WINDOW_WIDTH		= 1280;
	DEBUG_MODE_WINDOW_HEIGHT	= 720;
	
	DEBUG_LOG_LIST_POOLS		= true;
	DEBUG_LOG_STATEMACHINE		= true;
	DEBUG_LOG_RACE				= true;
	
	// set up named colors for the game
	// You can define your own CI_colors in the CI_Colors script
	set_app_theme(ci_theme.none);

	if (IS_HTML)
		browser_click_handler = open_link_in_new_tab;

	// Load start data
	// Example lines to show that you can load your startup files here
	// ------------------------------------------------------------------
	//SOME_GLOBAL_THING = file_read_struct_plain(GLOBAL_THING_FILE_NAME);
	//race_load_file(RACE_FILE_NAME, false);

	// Setup Scribble
	// ------------------------------------------------------------------
	scribble_font_set_default("fntArial");
	//scribble_font_bake_outline_8dir("fntArial","acme28out",c_black,true);

	// Custom named scribble colors 
	// (SCRIBBLE_COLORS is a macro pointing to global.__scribble_colours)
	//SCRIBBLE_COLORS.my_col		= #E5E5E5;
	SCRIBBLE_COLORS.ci_accent2		= #FF972F;

}

/// @function function onGameEnd()
function onGameEnd() {
}


