#macro LG_AVAIL_LOCALES			global.__lg_languages
#macro LG_OS_LANGUAGE			global.__lg_os
#macro LG_CURRENT_LOCALE		global.__lg_current

#macro __LG_FALLBACK			global.__lg_fallback_map
#macro __LG_STRINGS				global.__lg_string_map
#macro __LG_RESOLVE_CACHE		global.__lg_cache

#macro __LG_LOCALE_BASE_NAME	"locale_"

#macro __LG_HTML_NEED_CHECK		global.__lg_html_need_check
#macro __LG_HTML_INITIALIZED	(!__LG_HTML_NEED_CHECK || (variable_global_exists("__lg_languages") && is_array(LG_AVAIL_LOCALES) && array_length(LG_AVAIL_LOCALES) > 0))

/// @function		__LG_load_avail_languages()
/// @returns {bool} True, if at least one language was found, otherwise false.
/// @description	Loads and fills an array of available languages. Normally you do not need to call this function,
///					as it gets called through the LG_init() process.
function __LG_load_avail_languages() {
	if (!directory_exists(working_directory + LG_ROOT_FOLDER)) {
		log("No locale folder found!");
		EXIT_GAME;
		return false;
	}
	LG_AVAIL_LOCALES = [];

	var substring_first = string_length(__LG_LOCALE_BASE_NAME) + 1;
	var f = file_find_first(working_directory + LG_ROOT_FOLDER + __LG_LOCALE_BASE_NAME + "*.json", 0);
	var i = 0;
	while (f != "") {
		array_push(LG_AVAIL_LOCALES, string_copy(f, substring_first, 2));
		LG_AVAIL_LOCALES[@ i++] = string_copy(f, substring_first, 2);
		log("Found language: '" + string_copy(f, substring_first, 2) + "'");
		f = file_find_next();
	}
	file_find_close();
	log(string(array_length(LG_AVAIL_LOCALES)) + " language(s) found for this game.");
	return true;
}

/// @function					__LG_get_locale_filename(localeName)
/// @param {string} localeName	The two-letter name of the locale to find (i.e. "en", "de", "es",...)
/// @returns {string}			True or false, telling you, whether the file exists.
/// @description				Builds the full filename of a language json resource file.
function __LG_get_locale_filename(localeName) {
	return working_directory + LG_ROOT_FOLDER + __LG_LOCALE_BASE_NAME + localeName + ".json";
}

/// @function					__LG_locale_exists(localeName)
/// @param {string} localeName	The two-letter name of the locale to find (i.e. "en", "de", "es",...)
/// @returns {bool}				True or false, telling you, whether the file exists.
/// @description				Checks, whether a file for the specified locale exists.
function __LG_locale_exists(localeName) {
	return file_exists(__LG_get_locale_filename(localeName));
}

/// @function					__LG_load_file(localeName)
/// @param {string} localeName	The two-letter name of the locale to find (i.e. "en", "de", "es",...)
/// @returns {bool}				True or false, telling you, whether the file exists.
/// @description				Checks, whether a file for the specified locale exists.
function __LG_load_file(localeName) {
	if (__LG_locale_exists(localeName)) {
		log("Loading locale '" + localeName + "'...");
		var json = file_read_text_file_absolute(__LG_get_locale_filename(localeName));
		__LG_STRINGS = snap_from_json(json);
		log("Locale '" + localeName + " loaded successfully.");
		return true;
	}
	return false;
}

/// @function					LG_get_stringmap()
/// @description				Gets the string map of the currently active locale file.
///								This returns the entire string struct. Treat as read-only!
function LG_get_stringmap() {
	return __LG_STRINGS;
}

/// @function					LG_get_fallback_stringmap()
/// @description				Gets the fallback string map (the default language if a key is not found in the string map).
///								This returns the entire string struct. Treat as read-only!
function LG_get_fallback_stringmap() {
	return __LG_FALLBACK;
}

/// @function		LG_init(locale_to_use = undefined)
/// @param {string=undefined} locale_to_use	If not supplied or undefined, the OS language will be used.
///									You can supply here the locale from your game's settings files
///									that the user might have set in your game's options.
/// @description					Initializes the LG system. If LG_AUTO_INIT_ON_STARTUP is set to false, 
///									must be called at start of the game.
///									Subsequent calls will re-initialize and reload the language file 
///									of the current language.
///									To "hot-swap" the display language, use the LG_hotswap(...) function.
function LG_init(locale_to_use = undefined) {
	__LG_FALLBACK		= undefined;
	__LG_STRINGS		= undefined;
	__LG_RESOLVE_CACHE	= {};
	LG_OS_LANGUAGE		= os_get_language();
	LG_CURRENT_LOCALE	= (locale_to_use == undefined ? LG_OS_LANGUAGE : locale_to_use);
	
	var loaded = false;
	if (IS_HTML)
		loaded = __LG_HTML_INITIALIZED;
	else
		loaded = __LG_load_avail_languages();
	
	if (loaded) {
		var default_exists = __LG_locale_exists(LG_DEFAULT_LANGUAGE);
		var current_exists = __LG_locale_exists(LG_CURRENT_LOCALE);
		if (default_exists) {
			__LG_load_file(LG_DEFAULT_LANGUAGE);
			__LG_FALLBACK = __LG_STRINGS;
		}
		if (current_exists)
			__LG_load_file(LG_CURRENT_LOCALE);
		if (!default_exists && !current_exists) {
			log("*ERROR* Neither default nor current OS locale exists! Aborting.");
			EXIT_GAME;
		}
	}	
}

/// @function					LG_hotswap(new_locale)
/// @param {string} new_locale	The new locale to switch to.
/// @description				Reload the LG system with a new language. ATTENTION! This function will restart the current room.
function LG_hotswap(new_locale) {
	LG_init(new_locale);
	room_restart();
}

/// @function			LG()
/// @param {string} key	At least one key parameter must be supplied. You can add as many as you like for sub-key/sub-objects in the json.
/// @returns {string}	The resolved string or "??? [key] ???" if no string was found.
/// @description		Retrieve a string from the loaded locale file.
///						NOTE: The key parameters support also "path" syntax, so it's the same, whether you call:
///						a) LG("key1", "subkey", "keybelow")
///						   OR
///						b) LG("key1/subkey/keybelow")
///						You may even mix the formats: LG("key", "subkey/keybelow") will work just fine!
///						LG supports string references. Use [?key] to reference a string from within another string.
///						Also works recursively!
///						EXAMPLE:
///						"author" : "Mike"
///						"credit" : "Written by [?author]." -> Will resolve to "Written by Mike."
///
///						RANDOM PICKS: If your path ends with an '*' as wildcard, LG will pick a random string from
///						all string that match the path. This is useful if you want to let your character say a random response
///						from a pool of possible resources (like different curses or greetings)
function LG() {
	var wildcard = false;
	
	if (!__LG_HTML_INITIALIZED) {
		show_message(
			"LG Error: On HTML Runtime you must declare the available locales\nin the array LG_AVAIL_LOCALES!\n\n" +
			"Example: LG_AVAIL_LOCALES=[\"en\",\"de\",\"es\"]\n\n" +
			"In the HTML runtime you also need to call LG_Init() manually after the initialization of LG_AVAIL_LOCALES");
	}
	
	// this inner function parses the path(s) and finds the string you're looking for
	static find = function(wildcard, array) {
		var key;
		var map = array[0];
		var args = [];
		var len = 0;
	
		for (var i = 1; i < array_length(array); i++) {
			var subarr = string_split(array[i], "/");
			var sublen = array_length(subarr);
			array_copy(args, len, subarr, 0, sublen);
			len += sublen;
		}
		for (var i = 0; i < len - 1; i++) {
			key = args[i];
			map = variable_struct_get(map, key);
			if (map == undefined)
				break;
		}
		if (map != undefined) {
			key = args[len - 1];
			if (wildcard) {
				var names;
				var pickany = false;
				var wildsubs = variable_struct_get(map, key);
				if (wildsubs != undefined) {
					map = wildsubs;
					pickany = true;
				}
					
				var names = variable_struct_get_names(map);
				var matchstr = key + "*";
				var rnds = [];
				for (var i = 0; i < array_length(names); i++) {
					var nam = names[@ i];
					if (pickany || string_match(nam, matchstr))
						array_push(rnds, nam);
				}
				if (array_length(rnds) > 0) {
					var pick = irandom_range(0, array_length(rnds) - 1);
					return variable_struct_get(map, rnds[@ pick]);
				} else
					return undefined;
			} else
				return variable_struct_get(map, key);
		}
		return undefined;
	};
	
	// this inner function looks for a [?...] string reference and returns it
	static findref = function(str) {
		var startpos = string_pos("[?", str);
		if (startpos > 0) {
			var runner = string_copy(str, startpos, string_length(str) - startpos + 1);
			var endpos = string_pos("]", runner);
			if (endpos > 2)
				return string_copy(runner, 1, endpos);
		}
		return undefined;
	}
	
	var cacheKey = "";
	var args = [__LG_STRINGS];
	for (var i = 0; i < argument_count; i++) {
		var argconv = string_starts_with(argument[i], "=") ? string_skip_start(argument[i], 1) : argument[i];
		if (string_ends_with(argconv, "*")) {
			wildcard = true;
			argconv = string_skip_end(argconv, 1);
		}
		if (argconv != "") {
			array_push(args, argconv);
			cacheKey += (argconv + (i < argument_count - 1 ? "/" : ""));
		}
	}
	
	if (variable_struct_exists(__LG_RESOLVE_CACHE, cacheKey)) {
		return variable_struct_get(__LG_RESOLVE_CACHE, cacheKey);
	}
	
	var result = find(wildcard, args);
	if (result == undefined) {
		args[@ 0] = __LG_FALLBACK;
		result = find(wildcard, args);
	}
	if (result == undefined) {
		array_delete(args, 0, 1);
		result = "???" + string_replace(string_replace(string(args),"[",""),"]","") + "???";
	} else {
		var ref = findref(result);
		while (ref != undefined) {
			var resolved = LG(string_trim(string_copy(ref, 3, string_length(ref) - 3)));
			result = string_replace(result, ref, resolved);
			ref = findref(result);
		}
	}
	
	if (LG_SCRIBBLE_COMPATIBLE == false)
		string_replace_all(result, "[[", "[");
		
	variable_struct_set(__LG_RESOLVE_CACHE, cacheKey, result);
	return result;
}

/// @function					LG_resolve(str)
/// @description				Resolve a string in the format of object instance variables.
///								These strings either start with == or =.
///								If neither is true, str is returned 1:1
/// @param {string} str 		The string to resolve
/// @returns {string}			The resolved string or str unmodified if it didn't start with at least one "="
function LG_resolve(str) {
	if (string_starts_with(str, "==")) {
		return string_skip_start(str, 1);
	} else if (string_starts_with(str, "=")) {
		return LG(str);
	}
	return str;
}

if (LG_AUTO_INIT_ON_STARTUP) {
	show_debug_message("Welcome to LG localization subsystem! (c)indievidualgames.com");
	__LG_HTML_NEED_CHECK = IS_HTML;
	if (IS_HTML)
		show_debug_message("LG is in HTML mode. Preset languages are " + string(HTML_LOCALES));
	else
		LG_init();
}
	