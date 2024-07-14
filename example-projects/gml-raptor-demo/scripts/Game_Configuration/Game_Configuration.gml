/*
	These callbacks get invoked from the GameStarter object in the
	GameStart and GameEnd events respectively.
	
	They have been created to encapsulate one-time-startup/-shutdown actions in
	an isolated script file, so you do not need to modify the GameStarter object directly
	in each game.
	
	onGameStart runs AFTER the ci_colors have been initialized.
	It is recommended, to set at least the app_theme in the onGameStart function, so 
	scribble gets initialized with the correct set of ci_colors.
	
	If the game is currently in HTML mode, HTML_LOCALES is used to set up the locale list.
	Note for locales: The first entry in the array is the fallback (default) language and
	should always contain 100% of all strings!
	
	------------------------------------------------------
	NOTE: HTML5 games never receive an onGameEnd callback!
	------------------------------------------------------

	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

// This macro is only used once in a html game when the game initalizes
#macro HTML_LOCALES			["en", "de"]

// You need to set a global prefix for each of the raptor-files generated, because
// in HTML, especially for itch.io games, you need a UNIQUE filename over all your products,
// as the html-file-engine uses local storage, which only has one folder with all files from
// all your products in it.
#macro GAME_FILE_PREFIX					"gml_raptor_demo"
#macro DATA_FILE_EXTENSION				".json"
#macro release:DATA_FILE_EXTENSION		".jx"

// Replace the production crypt key with a good salty key of your own!
#macro FILE_CRYPT_KEY					""
#macro release:FILE_CRYPT_KEY			"/�0^^4 0= 4!/! �-:-71!/!9_15I-I�|)-(4/�,!/!1^0/�,�-v|_/�,4551( 11=�=0/�,!v!"

// The name of your settings file. ATTENTION FOR ITCH.IO: This name must be UNIQUE across
// all your games! Do NOT reuse the same name over and over again!
#macro GAME_SETTINGS_FILENAME			$"{GAME_FILE_PREFIX}_{GML_RAPTOR_VERSION}_game_settings{DATA_FILE_EXTENSION}"

// Global functionality setup for the game

// Set fullscreen mode
// This is set by the GameStarter object upon game start,
// when the game STARTS FOR THE FIRST TIME.
// After that, this setting is taken from the GameSettings.
// This is to allow you easily changing the startup values through your
// Settings dialog in the window, so the user can choose, what he prefers.
#macro START_FULLSCREEN				false
#macro release:START_FULLSCREEN		true
#macro FULLSCREEN_IS_BORDERLESS		true

// If you set this to true, ROOMCONTROLLER will store the game window size
// 10 times a second in the WINDOW_SIZE_* variables, so you can track changes
// to the window size. 
// This normally only makes sense in tool apps, that run in windowed mode
#macro WATCH_FOR_WINDOW_SIZE_CHANGE	false

// Startup Room - The value of this constant is taken by the GameStarter object
// Set the constant to undefined to use the instance variable of GameStarter in rmStartup
// The min_wait_time constant is measured in frames. Default is 90 (1.5secs) to show loading spinner
// The fade_in time for the first room is also measured in frames
#macro ROOM_AFTER_STARTER			rmMain
#macro STARTER_ASYNC_MIN_WAIT_TIME	90
#macro STARTER_FIRST_ROOM_FADE_IN	0

/// @func function onGameStart()
/// @desc	When this runs, load_settings() has already been called and 
///			you can access your settings through the GAMESETTINGS macro.
function onGameStart() {

	// Debug/Dev configuration
	DEBUG_SHOW_OBJECT_FRAMES	= false;
	DEBUG_MODE_WINDOW_WIDTH		= 1280;
	DEBUG_MODE_WINDOW_HEIGHT	= 720;

	// Themes - the "default" theme always exists
	UI_THEMES.add_theme(new ColdrockTheme(), false );	// name = "coldrock"
	UI_THEMES.add_theme(new RaptorTheme()  , false );	// name = "raptor"
	UI_THEMES.add_theme(new PurpleTheme());
	
	UI_THEMES.activate_theme("coldrock");

	UI_SKINS.add_skin(new WoodSkin());

	// Load start data
	// Example lines to show that you can load your startup files here
	// ------------------------------------------------------------------
	//SOME_GLOBAL_THING = file_read_struct_plain(GLOBAL_THING_FILE_NAME);
	//global.loot_system = new Race(RACE_FILE_NAME);
	
	// Setup Scribble
	// ------------------------------------------------------------------
	//scribble_font_bake_outline_8dir("acme28","acme28out",c_black,true);
	//scribble_font_set_default("acme28");
	scribble_font_set_default("fntArial");

	// Custom named scribble colors - use the format that fits best for you!
	// In version 3.0 and later, the recommended way is to set up your THEME here
	// https://github.com/Grisgram/gml-raptor/wiki/App-Theming
	//SCRIBBLE_COLORS.awful_color = #FF972F; // #RRGGBB
	
	//SCRIBBLE_REFRESH;
	
	// Audio setup for rooms
	//set_room_default_audio(rmMain, mus_theme, amb_theme);
	//set_room_default_audio(rmPlay, mus_theme, amb_theme);

}

/// @func onLoadingScreen(task, frame)
/// @desc Use this function while the loading screen is visible 
///		  to perform "async-like" tasks. Store your state in the task
///		  struct, it will be sent to you every frame, as long as you 
///		  return true from this function.
///		  If you return false (or nothing), the GameStarter considers your
///		  startup-loading actions as finished.
///		  The frame parameter increases by 1 each time this is invoked and starts with 0.
function onLoadingScreen(task, frame) {

}

/// @func function onGameEnd()
function onGameEnd() {
	
}

