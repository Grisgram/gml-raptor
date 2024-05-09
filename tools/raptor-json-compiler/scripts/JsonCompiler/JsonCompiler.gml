/*
    short description here
*/

global.run_in = "";
global.config = "";

function get_commandline_arguments() {
	//if (parameter_count() != 3)
	//	return false;
	
	//global.run_in = parameter_string(1);
	//global.config = parameter_string(2);

	global.run_in = "c:\\work\\dev\\github\\gml-raptor\\gml-raptor\\";
	global.config = "release";
	
	return directory_exists(global.run_in);
}

function compile_jsons(filelist) {
}

function __find_macro(content, macro) {
	if (string_contains(content, macro)) {
		var pos = string_pos_ext(macro, content, 1);
		var posend = string_pos_ext("\n", content, pos);
		
		var line = string_copy(content, pos, posend - pos);
		return __grep_macro_value(line, macro);
	}
	return undefined;
}

function __grep_macro_value(line, macro) {
	return
		string_trim(
			string_replace_all(
				string_replace(line, macro, ""), "\"", "")
		);			
}

function read_project() {

	var content = file_read_text_file_absolute($"{global.run_in}scripts\\Game_Configuration\\Game_Configuration.gml");

	if (content == undefined) {
		show_message("Error loading Game_Configuration script. Is this really a raptor project?");
		game_end();
		return;
	}
		
	var forkey = ((string_is_empty(global.config) || global.config == "Default") ? "" : $"{global.config}:");

	var macro_default_ext = "#macro DATA_FILE_EXTENSION";
	var macro_config_ext = $"#macro {forkey}DATA_FILE_EXTENSION";
	var macro_cryptkey	= $"#macro {forkey}FILE_CRYPT_KEY";

	var default_ext = __find_macro(content, macro_default_ext);
	var config_ext	= __find_macro(content, macro_config_ext);
	var cryptkey	= __find_macro(content, macro_cryptkey);

	if (default_ext != undefined && config_ext != undefined && cryptkey != undefined) {
		if (default_ext != config_ext) {
			var filelist = [];
		
			compile_jsons(filelist);
		}
		show_message($"+{default_ext}+\n+{config_ext}+\n+{cryptkey}+");
	} else
		show_message("Error finding crypt key and extensions in Game_Configuration script. Is this really a raptor project?");
	
	game_end();
}

ENSURE_LOGGER;

if (!get_commandline_arguments()) {
	show_message("Parameter error:\n\nYou must supply 2 parameters: <project_folder> <configuration>\n\n<configuration> is normally the content of the\n%YYconfig% environment variable when running from a batch script.");
	game_end();
} else
	read_project();
