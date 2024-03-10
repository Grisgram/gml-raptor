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
#macro GAME_FILE_PREFIX		$"gml_raptor_demo_{GML_RAPTOR_VERSION}"

// The crash dump handler can be found in the Game_Exception_Handler script
// It generates crash logs in the file specified below, when an unhandled exception occurs,
// that crashes your game
#macro USE_CRASHDUMP_HANDLER			false
#macro beta:USE_CRASHDUMP_HANDLER		true
#macro release:USE_CRASHDUMP_HANDLER	true
#macro CRASH_DUMP_FILENAME				$"{GAME_FILE_PREFIX}_crashdump.bin"

// The name of your settings file. ATTENTION FOR ITCH.IO: This name must be UNIQUE across
// all your games! Do NOT reuse the same name over and over again!
#macro GAME_SETTINGS_FILENAME			$"{GAME_FILE_PREFIX}_game_settings.json"
#macro FILE_CRYPT_KEY					""
// To avoid conflicts between encrypted and plaing settings files, give
// the file in release mode a different name
// Replace the production crypt key with a good salty key of your own!
#macro release:GAME_SETTINGS_FILENAME	$"{GAME_FILE_PREFIX}_game_settings.gsx"
#macro release:FILE_CRYPT_KEY			"/�0^^4 0= 4!/! �-:-71!/!9_15I-I�|)-(4/�,!/!1^0/�,�-v|_/�,4551( 11=�=0/�,!v!"

// Global functionality setup for the game

// Startup Room - The value of this constant is taken by the GameStarter object
// Set the constant to undefined to use the instance variable of GameStarter in rmStartup
#macro ROOM_AFTER_STARTER			rmMain

// Highscore setup for the game
#macro USE_HIGHSCORES				false
#macro HIGHSCORE_TABLE_NAME			"Highscores"
#macro HIGHSCORE_TABLE_LENGTH		10
#macro HIGHSCORE_TABLE_SCORING		scoring.score_high
#macro HIGHSCORES					global.__highscores
#macro HIGHSCORES_UI_LAYER			"ui_highscores"

if (USE_HIGHSCORES) {
	HIGHSCORES = new HighScoreTable(HIGHSCORE_TABLE_NAME, HIGHSCORE_TABLE_LENGTH, HIGHSCORE_TABLE_SCORING);
	repeat (HIGHSCORE_TABLE_LENGTH) HIGHSCORES.register_highscore("- no entry -",0);
} else {
	HIGHSCORES = undefined;
}

/// @function function onGameStart()
/// @description	When this runs, load_settings() has already been called and 
///					you can access your settings through the GAMESETTINGS macro.
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
	//race_load_file(RACE_FILE_NAME, false);

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

/// @function function onGameEnd()
function onGameEnd() {
	
}

