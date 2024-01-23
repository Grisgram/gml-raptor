/*
    If you have set USE_CRASHDUMP_HANDLER in your Game_Configuration file to true,
	this function will be called when you encounter an unhandled exception in your game.
	Instead of the default error window from yoyo, the crash will be written to the filename
	set in the CRASH_DUMP_FILENAME constant (can also be found in your Game_Configuration script).
	
	By default, raptor has USE_CRASHDUMP_HANDLER set to false for the default-Configuration, but for all
	other configurations (BETA, RELEASE) this is true by default.
	
	If file encryption is active, the dump will be encrypted.
	You don't want to make your crash dumps publicly visible. Those files are normally used to be
	transferred to your server at next startup, where you can decrypt them before sending.
*/

function Game_Exception_Handler(_unhandled) {
	try {
		// TODO: remove this in new runtime, maybe it works then
		if (IS_HTML) return 0;
		var error = string(_unhandled);
		file_write_text_file(CRASH_DUMP_FILENAME, error, FILE_CRYPT_KEY);
		log($"Crash dump written to disk!");
	} catch (_ignored) { 
		log("Crash dump could not be written to disk!");
	}
}