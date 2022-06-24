/*
	Utility methods to work with strings.
	
	(c)2022 Mike Barthold, indievidualgames, aka @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

/// @function							string_split(str, delimiter = ",", skip_empty_strings = true, trim_parts = true)
/// @description						Splits a string by a specified delimiter and returns an array of the split parts. 
/// @param {string} str					The string to split
/// @param {string=","} delimiter			The delimiter character (default ","). MUST BE 1 character. Longer sequences will not be recognized.
/// @param {bool=true} skip_empty_strings	If true (the default), empty string parts will not be added to the result array
/// @param {bool=true} trim_parts			If true (the default), white spaces will be removed before adding to the array.
///										NOTE: If bot, skip_empty_strings AND trim_parts are true, the trim is applied BEFORE
///										checking for an empty string part. So, if trimming results in an empty string, it will
///										not be added to the result!
///	@returns {array}					A string array containing the split parts of the input string
function string_split(str, delimiter = ",", skip_empty_strings = true, trim_parts = true) {
	var inblock = false; // inside a block quote?
	var rv = [];										
	var tmp = "";
	var c = "";
	var idx = 0;

	static add_part = function(part, to, skip_empty_strings, trim_parts) {
		var idx = array_length(to);
		if (trim_parts) 
			part = string_trim(part);
		if (!skip_empty_strings || part != "") {
			to[@ idx++] = part;
		}
		return idx;
	}

	for (var i = 1; i <= string_length(str); i++) {
	    var c = string_char_at(str, i);            
	    if (string_char_at(str, i - 1)=="\\") {
	        tmp = string_copy(tmp, 1, string_length(tmp) - 1);
			tmp = tmp + c;
	    } else if (c == "\"") {                  
	        if (inblock) {                        
	            inblock = false;
	        } else {                             
	            inblock = true;
	        }
	    } else if (c == delimiter && !inblock) {
			idx = add_part(tmp, rv, skip_empty_strings, trim_parts);
			tmp = "";
	    } else {     
			tmp = tmp + c;
	    }
	}

	if (tmp != "")
		add_part(tmp, rv, skip_empty_strings, trim_parts);

	return rv;
}

/// @function			sprintf(str)
/// @description		Classic C# string.Format command. Up to 15 parameters allowed, use {0}, {1}...
///						Example: string_format("Hello {0}, you have {1} gold", name, balance);
/// @param {string} str	The string to format (+ followed by up to 16 formatargs
///	@returns {string}	The formatted string
function sprintf(str) {
	var rv = str;
	
	for (var i = 1; i < argument_count; i++) {
		rv = string_replace_all(rv, "{" + string(i - 1) + "}", string(argument[i]));
	}
	
	return rv;
}

/// @function			string_trim(str)
/// @description		Removes white spaces (tabs, cr, lf, ...) from the start and end of a string.
/// @param {string} str	The string to trim
///	@returns {string}	The trimmed string
function string_trim(str) {
	var l, r, o;
    l = 1;
    r = string_length(str);
    repeat (r) {
        o = ord(string_char_at(str,l));
        if ((o > 8) && (o < 14) || (o == 32)) l += 1;
        else break;
    }
    repeat (r-l) {
        o = ord(string_char_at(str,r));
        if ((o > 8) && (o < 14) || (o == 32)) r -= 1;
        else break;
    }
    return string_copy(str,l,r-l+1);
}

/// @function					string_starts_with(str)
/// @description				Checks whether the specified string starts with the specified start_with.
/// @param {string} str			The string to check
/// @param {string} start_with	The string to look for
///	@returns {bool}				true, if str starts with start_with, otherwise false
function string_starts_with(str, start_with) {
	return string_pos(start_with, str) == 1;
}

/// @function					string_ends_with(str, end_with)
/// @description				Checks whether the specified string ends with the specified end_with.
/// @param {string} str			The string to check
/// @param {string} end_with	The string to look for
///	@returns {bool}				true, if str ends with end_with, otherwise false
function string_ends_with(str, end_with) {
	var pos = string_pos(end_with, str);
	return pos > 0 && pos == (string_length(str) - string_length(end_with) + 1);
}

/// @function					string_skip_start(str, count)
/// @description				Returns a substring of str that skipped the first {count} characters
/// @param {string} str			The string
/// @param {integer} count		The number of characters to skip.
function string_skip_start(str, count) {
	var len = string_length(str);
	if (count > 0 && len > count)
		return string_copy(str, count + 1, len - count);
		
	return "";
}

/// @function					string_skip_end(str, count)
/// @description				Returns a substring of str that truncated the last {count} characters
/// @param {string} str			The string
/// @param {integer} count		The number of characters to skip/truncate.
function string_skip_end(str, count) {
	var len = string_length(str);
	if (count > 0 && len > count)
		return string_copy(str, 1, len - count);
		
	return "";
}

/// @function					string_contains(str, substr)
/// @description				returns whether the specified substr is contained in str.
/// @param {string} str
/// @param {string} substr
/// @returns {bool}	y/n
function string_contains(str, substr, startpos = 1) {
	return string_pos_ext(substr, str, startpos) > 0;
}

/// @function					string_match(str, wildcard_str)
/// @description				Checks whether a string matches a specific wildcard string.
///								Wildcard character is '*' and it can appear at the beginning,
///								the end, or both.
///								* at the beginning means "ends_with" (hello -> *llo)
///								* at the end means "starts_with" (hello -> he*)
///								* on both ends means "contains" (hello -> *ell*)
///								NOTE: if no '*' is in wildcard_str, then a == exact match counts!
///								Examples:
///								string_match("hello", "hel*") -> true
///								string_match("hello", "*hel*") -> true
///								string_match("hello", "*hel") -> false
/// @param {string} str
/// @param {string} wildcard_str
/// @returns {bool}	
function string_match(str, wildcard_str) {
	var startwith = false, endwith = false;
	if (string_starts_with(wildcard_str, "*")) {
		endwith = true;
		wildcard_str = string_skip_start(wildcard_str, 1);
	}
	if (string_ends_with(wildcard_str, "*")) {
		startwith = true;
		wildcard_str = string_skip_end(wildcard_str, 1);
	}
	
	var contain = startwith && endwith;
	var rv = false;

	if (contain)		rv = string_contains(str, wildcard_str);
	else if (startwith) rv = string_starts_with(str, wildcard_str);
	else if (endwith)	rv = string_ends_with(str, wildcard_str);
	else				rv = str == wildcard_str;

	return rv;
}

/// @function					string_is_empty(str)
/// @description				checks if a string is undefined or empty/blank characters only
/// @param {string} str			string to check
/// @returns {bool}				y/n
function string_is_empty(str) {
	return str == undefined || string_trim(str) == "";
}