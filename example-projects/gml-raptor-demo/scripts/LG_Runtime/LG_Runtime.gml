#macro LG_AVAIL_LOCALES			global.__lg_languages
#macro LG_OS_LANGUAGE			global.__lg_os
#macro LG_CURRENT_LOCALE		global.__lg_current

#macro __LG_FALLBACK			global.__lg_fallback_map
#macro __LG_STRINGS				global.__lg_string_map
#macro __LG_RESOLVE_CACHE		global.__lg_cache

#macro __LG_LOCALE_BASE_NAME	"locale_"

#macro __LG_INIT_ERROR_SHOWN	global.__lg_init_error_shown
#macro __LG_INITIALIZED			global.__lg_initialized
#macro __LG_HTML_NEED_CHECK		global.__lg_html_need_check
#macro __LG_HTML_INITIALIZED	(!__LG_HTML_NEED_CHECK || (variable_global_exists("__lg_languages") && is_array(LG_AVAIL_LOCALES) && array_length(LG_AVAIL_LOCALES) > 0))

__LG_INIT_ERROR_SHOWN = false;

/// @func	__LG_load_avail_languages()
/// @desc	Loads and fills an array of available languages. Normally you do not need to call this function,
///			as it gets called through the LG_init() process.
function __LG_load_avail_languages() {
	if (!directory_exists(working_directory + LG_ROOT_FOLDER)) {
		flog($"No locale folder found!");
		EXIT_GAME;
		return false;
	}
	LG_AVAIL_LOCALES = [];

	var substring_first = string_length(__LG_LOCALE_BASE_NAME) + 1;
	var f = file_find_first(
		string_concat(working_directory, LG_ROOT_FOLDER, __LG_LOCALE_BASE_NAME, "*", DATA_FILE_EXTENSION), 0);
	var i = 0;
	while (f != "") {
		array_push(LG_AVAIL_LOCALES, string_copy(f, substring_first, 2));
		LG_AVAIL_LOCALES[@ i++] = string_copy(f, substring_first, 2);
		ilog($"Found language: '{string_copy(f, substring_first, 2)}'");
		f = file_find_next();
	}
	file_find_close();
	ilog($"{array_length(LG_AVAIL_LOCALES)} language(s) found for this game");
	return true;
}

/// @func	__LG_get_locale_filename(localeName)
/// @desc	Builds the full filename of a language json resource file.
function __LG_get_locale_filename(localeName) {
	return string_concat(LG_ROOT_FOLDER, __LG_LOCALE_BASE_NAME, localeName, DATA_FILE_EXTENSION);
}

/// @func	__LG_locale_exists(localeName)
/// @desc	Checks, whether a file for the specified locale exists.
function __LG_locale_exists(localeName) {
	return IS_HTML ? array_contains(LG_AVAIL_LOCALES, localeName) : file_exists(__LG_get_locale_filename(localeName));
}

/// @func	__LG_load_file(localeName)
/// @desc	Checks, whether a file for the specified locale exists.
function __LG_load_file(localeName) {
	if (__LG_locale_exists(localeName)) {
		dlog($"Loading locale '{localeName}'...");
		__LG_STRINGS = file_read_struct(__LG_get_locale_filename(localeName), FILE_CRYPT_KEY);
		dlog($"Locale '{localeName}' loaded successfully");
		return true;
	}
	return false;
}

/// @func	LG_add_file_async(_filename)
/// @desc	Loads the specified file for the default locale AND the current locale
///			and merges the strings into the string map for each locale.
///			NOTE: As the function name says, this is an async function!
///			It returns an asyncReader, so you may add an .on_finished(...) callback.
///			This functions load TWO files in parallel (default locale + current)
///			The return value is the loader of the _default_ locale, as this always exists.
///			to the returned builder pattern of this function.
///			BEST USE FOR THIS FUNCTION IS "onLoadingScreen" in the Game_Configuration script!
function LG_add_file_async(_filename) {
	var deffile = string_concat(LG_ROOT_FOLDER, _filename, "_", LG_DEFAULT_LANGUAGE, DATA_FILE_EXTENSION);
	var curfile = string_concat(LG_ROOT_FOLDER, _filename, "_", LG_CURRENT_LOCALE, DATA_FILE_EXTENSION);
	var def = file_read_struct_async(deffile, FILE_CRYPT_KEY);
	if (def != undefined)
		def
		.__raptor_data("filename", deffile)
		.__raptor_finished(function(res, _buffer, _data) {
			if (res != undefined) {
				dlog($"LG successfully added strings from '{_data.filename}' to default locale ('{LG_DEFAULT_LANGUAGE}')");
				struct_join_into(__LG_FALLBACK, res);
			} else
				elog($"** ERROR ** Async load of locale file '{_data.filename}' failed!");
			return res;
		}).start();
	
	var cur = file_read_struct_async(curfile, FILE_CRYPT_KEY);
	if (cur != undefined)
		cur
		.__raptor_data("filename", curfile)
		.__raptor_finished(function(res, _buffer, _data) {
			if (res != undefined) {
				dlog($"LG successfully added strings from '{_data.filename}' to current locale ('{LG_CURRENT_LOCALE}')");
				struct_join_into(__LG_STRINGS, res);
			} else
				elog($"** ERROR ** Async load of locale file '{_data.filename}' failed!");
			return res;
		}).start();

	return def;
}

/// @func	LG_get_stringmap()
/// @desc	Gets the string map of the currently active locale file.
///			This returns the entire string struct. Treat as read-only!
function LG_get_stringmap() {
	return __LG_STRINGS;
}

/// @func	LG_get_fallback_stringmap()
/// @desc	Gets the fallback string map (the default language if a key is not found in the string map).
///								This returns the entire string struct. Treat as read-only!
function LG_get_fallback_stringmap() {
	return __LG_FALLBACK;
}

/// @func	LG_init(locale_to_use = undefined)
/// @desc	Initializes the LG system. If LG_AUTO_INIT_ON_STARTUP is set to false, 
///			must be called at start of the game.
///			Subsequent calls will re-initialize and reload the language file 
///			of the current language.
///			To "hot-swap" the display language, use the LG_hotswap(...) function.
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
	
	__LG_INITIALIZED = loaded;
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
			flog($"** ERROR ** Neither default nor current OS locale exists! Aborting.");
			EXIT_GAME;
		}
	}	
}

/// @func	LG_hotswap(new_locale)
/// @desc	Reload the LG system with a new language. ATTENTION! This function will restart the current room.
function LG_hotswap(new_locale) {
	LG_init(new_locale);
	GAMESTARTER.reinit_game(room);
	//room_restart();
}

/// @func	LG()
/// @desc	Retrieve a string from the loaded locale file.
///			NOTE: The key parameters support also "path" syntax, so it's the same, whether you call:
///			a) LG("key1", "subkey", "keybelow")
///			   OR
///			b) LG("key1/subkey/keybelow")
///			You may even mix the formats: LG("key", "subkey/keybelow") will work just fine!
///			LG supports string references. Use [?key] to reference a string from within another string.
///			Also works recursively!
///			EXAMPLE:
///			"author" : "Mike"
///			"credit" : "Written by [?author]." -> Will resolve to "Written by Mike."
///
///			RANDOM PICKS: If your path ends with an '*' as wildcard, LG will pick a random string from
///			all string that match the path. This is useful if you want to let your character say a random response
///			from a pool of possible resources (like different curses or greetings)
function LG() {
	var wildcard = false;
	
	if (!__LG_HTML_INITIALIZED) {
		if (!__LG_INIT_ERROR_SHOWN) {
			show_message(string_concat(
				"LG Error: On HTML Runtime you must declare the available locales\nin the array LG_AVAIL_LOCALES!\n\n",
				"Example: LG_AVAIL_LOCALES=[\"en\",\"de\",\"es\"]\n\n",
				"In the HTML runtime you also need to call LG_Init() manually after the initialization of LG_AVAIL_LOCALES"));
			__LG_INIT_ERROR_SHOWN = true;
		}
	} else if (!__LG_INITIALIZED) {
		if (!__LG_INIT_ERROR_SHOWN) {
			show_message(string_concat(
				"LG Error: Not initialized.\nIf you set LG_AUTO_INIT to false you MUST call LG_Init() before your first\n",
				"string can be resolved!"));
			__LG_INIT_ERROR_SHOWN = true;
		}
		return "LG-NOT-INITIALIZED";
	}
	
	// this inner function parses the path(s) and finds the string you're looking for
	static find = function(wildcard, array) {
		var key;
		var map = array[@ 0];
		var args = [];
		var len = 0;
		
		if (map == undefined)
			return undefined;
			
		for (var i = 1; i < array_length(array); i++) {
			var subarr = string_split(array[@ i], "/", true);
			var sublen = array_length(subarr);
			array_copy(args, len, subarr, 0, sublen);
			len += sublen;
		}

		for (var i = 0; i < len - 1; i++) {
			key = args[@ i];
			map = struct_get(map, key);
			if (map == undefined)
				break;
		}
		
		if (len == 0) 
			return undefined;
		
		if (map != undefined) {
			key = args[@ len - 1];
			if (wildcard) {
				var names;
				var pickany = false;
				var wildsubs = struct_get(map, key);
				if (wildsubs != undefined) {
					map = wildsubs;
					pickany = true;
				}
					
				var names = struct_get_names(map);
				var matchstr = string_concat(key, "*");
				var rnds = [];
				for (var i = 0; i < array_length(names); i++) {
					var nam = names[@ i];
					if (pickany || string_match(nam, matchstr))
						array_push(rnds, nam);
				}
				if (array_length(rnds) > 0) {
					var pick = irandom_range(0, array_length(rnds) - 1);
					return struct_get(map, rnds[@ pick]);
				} else
					return undefined;
			} else
				return struct_get(map, key);
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
	
	// this inner function looks for variable values [:...] and tries to resolve it
	static findvars = function(str) {
		static __resolve_variable = function(_scope, str) {
			var sa = string_split(string_substring(str, 1, string_pos("]", str) - 1), ".");
			TRY
				var next = struct_get(_scope, sa[0]);
				for (var i = 1, len = array_length(sa); i < len; i++) {
					next = struct_get(next, sa[@i]);
				}
				
				return string(next);
			CATCH
				return $"??? {str} ???";
			ENDTRY
		}
	
		var startpos = 1;
		while (startpos > 0) {
			// [:: access global.xxx
			startpos = string_pos("[::", str);
			if (startpos > 0) {
				var runner = string_copy(str, startpos, string_length(str) - startpos + 1);
				var endpos = string_pos("]", runner);
				if (endpos > 3)
					str = string_replace_all(str, 
							string_copy(runner, 1, endpos),
							__resolve_variable(global, string_substring(runner, 4))
						);
			} else {
				// [: access local variable
				startpos = string_pos("[:", str);
				if (startpos > 0) {
					var runner = string_copy(str, startpos, string_length(str) - startpos + 1);
					var endpos = string_pos("]", runner);
					if (endpos > 2)
						str = string_replace_all(str,
							string_copy(runner, 1, endpos),
							__resolve_variable(self, string_substring(runner, 3))
						);
				}
			}
		}
		return str;
	}
	
	var cacheKey = "";
	var args = [__LG_STRINGS];
	for (var i = 0; i < argument_count; i++) {
		if (string_is_empty(argument[i]))
			continue;
		var argconv = string_starts_with(argument[i], "=") ? string_skip_start(argument[i], 1) : argument[i];
		if (string_ends_with(argconv, "*")) {
			wildcard = true;
			argconv = string_skip_end(argconv, 1);
		}
		if (argconv != "") {
			array_push(args, argconv);
			cacheKey = string_concat(cacheKey, (argconv + (i < argument_count - 1 ? "/" : "")));
		}
	}
	
	if (!wildcard && variable_struct_exists(__LG_RESOLVE_CACHE, cacheKey)) {
		return struct_get(__LG_RESOLVE_CACHE, cacheKey);
	}
	
	var result = find(wildcard, args);
	var may_cache = true;
	if (result == undefined) {
		args[@ 0] = __LG_FALLBACK;
		result = find(wildcard, args);
	}
	if (result == undefined) {
		array_delete(args, 0, 1);
		result = string_concat("???", string_replace(string_replace(string(args),"[",""),"]",""), "???");
	} else {
		var ref = findref(result);
		while (ref != undefined) {
			var resolved = LG(string_trim(string_copy(ref, 3, string_length(ref) - 3)));
			result = string_replace(result, ref, resolved);
			ref = findref(result);
		}
		var before = result;
		result = findvars(result);
		may_cache = (before == result);
	}
	
	if (LG_SCRIBBLE_COMPATIBLE == false)
		string_replace_all(result, "[[", "[");
	
	if (may_cache && !wildcard) // we do not cache random picks
		struct_set(__LG_RESOLVE_CACHE, cacheKey, result);
		
	return result;
}

/// @func					LG_resolve(str)
/// @desc				Resolve a string in the format of object instance variables.
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

ENSURE_LOGGER

__LG_HTML_NEED_CHECK = IS_HTML;
__LG_INITIALIZED = IS_HTML; // for html, we start initialized, there is a second check __LG_HTML_INITIALIZED 
							// that takes care whether the required globals exist for HTML
if (LG_AUTO_INIT_ON_STARTUP) {
	show_debug_message("Initializing LG localization subsystem.");
	if (IS_HTML)
		show_debug_message(string_concat("LG is in HTML mode. Preset languages are ", string(HTML_LOCALES)));
	else
		LG_init();
}
	