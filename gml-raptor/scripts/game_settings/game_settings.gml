/*
    The settings structure of your game.
	Adapt as needed. A "new GameSettings()" gets called on load attempt of the settings file,
	if none exists.
*/

#macro GAMESETTINGS		global._game_settings
// load_settings gets called on game start before onGameStarting callback is invoked
// So, when your code in inGameStarting runs, this is already available
GAMESETTINGS = undefined;  

// Add everything you want to be part of the settings file in this struct.
// DO NOT ADD FUNCTIONS HERE! Only data!
function GameSettings() constructor {
	construct(GameSettings);
	
	audio = AUDIOSETTINGS;
	use_system_cursor = false;
	if (HIGHSCORES != undefined) {
		highscoredata = HIGHSCORES.data;
		last_highscore_name = "";
	}
}

function load_settings() {
	GAMESETTINGS = file_read_struct(GAME_SETTINGS_FILENAME,FILE_CRYPT_KEY) ?? new GameSettings();
	if (HIGHSCORES != undefined && variable_struct_exists(GAMESETTINGS, "highscoredata"))
		HIGHSCORES.assign_data(GAMESETTINGS.highscoredata);
	AUDIOSETTINGS = GAMESETTINGS.audio;
}

function save_settings() {
	if (HIGHSCORES != undefined)
		GAMESETTINGS.highscoredata = HIGHSCORES.data;
	file_write_struct(GAME_SETTINGS_FILENAME, GAMESETTINGS, FILE_CRYPT_KEY);
}