/// @description start the game engine(s)

#macro GAME_VERSION_STRING	global.__game_version_string
#macro GAME_VERSION_MAJOR	global.__game_version_major
#macro GAME_VERSION_MINOR	global.__game_version_minor
#macro GAME_VERSION_BUILD	global.__game_version_build

if (!debug_mode)
	randomize();

// Look for version file
log("Starting up...");
if (file_exists(working_directory + "version.json")) {
	var verinfo = file_read_struct_plain("version.json");
	GAME_VERSION_STRING = verinfo.version;
	GAME_VERSION_MAJOR	= verinfo.major;
	GAME_VERSION_MINOR	= verinfo.minor;
	GAME_VERSION_BUILD	= verinfo.build;
	log("Game version: " + GAME_VERSION_STRING);
} else {
	log("WARNING: No version file found!");
	GAME_VERSION_STRING = "0.0.0";
	GAME_VERSION_MAJOR	= 0;
	GAME_VERSION_MINOR	= 0;
	GAME_VERSION_BUILD	= 0;
}

// Initialize LG on HTML frontend
if (IS_HTML) {
	browser_click_handler = open_link_in_new_tab;
	LG_AVAIL_LOCALES = HTML_LOCALES;
	LG_init();
}

log(sprintf("Game seed is {0}", random_get_seed()));
log(sprintf("Detecting scribble library: {0}found!", IS_SCRIBBLE_LOADED ? "" : "NOT "));

log("Checking for Debug mode: " + (DEBUG_MODE_ACTIVE ? "ACTIVE" : "DISABLED"));
check_debug_mode();

log("Invoking onGameStart()");
onGameStart();

if (DEBUG_MODE_ACTIVE)
	window_set_size(DEBUG_MODE_WINDOW_WIDTH, DEBUG_MODE_WINDOW_HEIGHT);

__RUN_UNIT_TESTS
