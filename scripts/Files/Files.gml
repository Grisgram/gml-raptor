/*
	Utility methods to work with files.
	Requires juju's SNAP library and indieviduals Buffers scripts to work.
	
	(c)2022 Mike Barthold, indievidualgames, aka @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

#macro __FILE_CACHE		global.__file_cache
__FILE_CACHE = {};

/// @function					file_clear_cache()
/// @description				clears the entire file cache
function file_clear_cache() {
	__FILE_CACHE = {};
}

/// @function				__ensure_file_cache()	
/// @description			ensures, the global cache exists
function __ensure_file_cache() {
	if (!variable_global_exists("__file_cache"))
		__FILE_CACHE = {};
}

/// @function					file_read_text_file_absolute(filename)
/// @param {string} filename	The name (full path) of the file to read
/// @param {bool=true} remove_utf8_bom	If true (default) then the UTF8 ByteOrderMark will be removed (which is what you normally want)
/// @param {bool=false} add_to_cache	If true, the contents will be kept in a cache for later loads
/// @description				reads an entire file and returns the contents as string
///								checks whether the file exists, and if not, an empty string is returned.
///								crashes, if the file is not a text file
function file_read_text_file_absolute(filename, remove_utf8_bom = true, add_to_cache = false) {
	__ensure_file_cache();
	
	if (variable_struct_exists(__FILE_CACHE, filename)) {
		log(sprintf("Cache hit for file '{0}'", filename));
		return variable_struct_get(__FILE_CACHE, filename);
	}
	
    var _buffer = buffer_load(filename);
    
    if (remove_utf8_bom && (buffer_get_size(_buffer) >= 4) && (buffer_peek(_buffer, 0, buffer_u32) & 0xFFFFFF == 0xBFBBEF))
    {
        buffer_seek(_buffer, buffer_seek_start, 3);
    }
    
    var _string = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);
	
	if (add_to_cache) {
		log(sprintf("Added file '{0}' to cache", filename));
		variable_struct_set(__FILE_CACHE, filename, _string);
	}
	
    return _string;
}

/// @function					file_read_text_file(filename)
/// @param {string} filename	The name (relative path starting in working_directory) of the file to read
/// @param {bool=true} remove_utf8_bom	If true (default) then the UTF8 ByteOrderMark will be removed (which is what you normally want)
/// @param {bool=false} add_to_cache	If true, the contents will be kept in a cache for later loads
/// @description				reads an entire file and returns the contents as string
///								checks whether the file exists, and if not, an empty string is returned.
///								crashes, if the file is not a text file
function file_read_text_file(filename, remove_utf8_bom = true, add_to_cache = false) {
	return file_read_text_file_absolute(working_directory + filename, remove_utf8_bom);
}

/// @function					file_write_text_file(filename, text)
/// @param {string} filename	The name (relative path starting in working_directory) of the output file
/// @param {string} text		The string to write out to the file
/// @description				Saves a given text as a plain text file. Can write any string, not only json.
function file_write_text_file(filename, text) {
	__ensure_file_cache();
	var buffer = buffer_create(string_byte_length(text) + 1, buffer_fixed, 1);
	buffer_write(buffer, buffer_string, text);
	buffer_save(buffer, filename);
	buffer_delete(buffer);
	if (variable_struct_exists(__FILE_CACHE, filename)) {
		log(sprintf("Updated cache for file '{0}'", filename));
		variable_struct_set(__FILE_CACHE, filename, text);
	}
}

/// @function					file_write_struct_plain(filename, struct)
/// @param {string} filename	The name (relative path starting in working_directory) of the output file
/// @param {struct} struct		The struct to write out to a json file
/// @description				Saves a given struct as a plain text json file. This json is NOT "user friendly" formatted!
///								To create a user-friendly json use the SNAP library (https://github.com/JujuAdams/SNAP)
///								and the function snap_to_json with the second parameter (_pretty) set to true to get a json string
///								and then send this json string to file_write_text_file(...).
function file_write_struct_plain(filename, struct) {
	__ensure_file_cache();
	log("Saving plain text struct to " + filename);
	file_write_text_file(filename, snap_to_json(struct, true));
	if (variable_struct_exists(__FILE_CACHE, filename)) {
		log(sprintf("Updated cache for file '{0}' (struct)", filename));
		variable_struct_set(__FILE_CACHE, filename, snap_deep_copy(struct));
	}
}

/// @function			file_read_struct_plain(filename)
/// @description		Loads the contents of the file and tries to parse it as struct.
///						Load is done synchronously.
///						If you deal with large files here, consider using coroutines.
/// @param {string} filename	Relative path inside the working_folder where to find the file
/// @param {bool=false} add_to_cache	If true, the contents will be kept in a cache for later loads
/// @returns {struct}			The json_decoded struct.
function file_read_struct_plain(filename, add_to_cache = false) {
	__ensure_file_cache();
	if (file_exists(filename)) {
		if (variable_struct_exists(__FILE_CACHE, filename)) {
			log(sprintf("Cache hit for file '{0}'", filename));
			return snap_deep_copy(variable_struct_get(__FILE_CACHE, filename));
		}
		log("Loading plain text struct from " + filename);
		var rv = snap_from_json(file_read_text_file(filename));
		if (add_to_cache) {
			log(sprintf("Added file '{0}' to cache (struct)", filename));
			variable_struct_set(__FILE_CACHE, filename, snap_deep_copy(rv));
		}
		return rv;
	}
	return undefined;
}

/// @function			file_write_struct_encrypted(filename, struct, cryptkey)
/// @description		Encrypts the binary representation of the given struct with a key
///						and saves this to a file. Save is done synchronously.
///						If you deal with large files here, consider using coroutines.
/// @param {string} filename	Relative path inside the working_folder where to put the file
/// @param {struct}	struct		The struct to persist
/// @param {string} cryptkey	A (hopefully) long string that makes the crypt mask
/// @returns {bool}				true, if the save succeeded, otherwise false.
function file_write_struct_encrypted(filename, struct, cryptkey) {
	__ensure_file_cache();
	log("Saving encrypted struct to " + filename);
	var buffer = snap_to_binary(struct);
	encrypt_buffer(buffer, cryptkey);
	buffer_save(buffer, filename);
	buffer_delete(buffer);
	if (variable_struct_exists(__FILE_CACHE, filename)) {
		log(sprintf("Updated cache for file '{0}' (encrypted struct)", filename));
		variable_struct_set(__FILE_CACHE, filename, snap_deep_copy(struct));
	}
}

/// @function			file_read_struct_encrypted(filename, cryptkey)
/// @description		Decrypts the data in the specified file with the specified key.
///						Load is done synchronously.
///						If you deal with large files here, consider using coroutines.
/// @param {string} filename	Relative path inside the working_folder where to find the file
/// @param {string} cryptkey	The same key that has been used to encrypt the file.
/// @param {bool=false} add_to_cache	If true, the contents will be kept in a cache for later loads
/// @returns {struct}			The decrypted struct.
function file_read_struct_encrypted(filename, cryptkey, add_to_cache = false) {	
	__ensure_file_cache();
	if (file_exists(filename)) {
		if (variable_struct_exists(__FILE_CACHE, filename)) {
			log(sprintf("Cache hit for file '{0}' (buffer deep copy)", filename));
			return snap_deep_copy(variable_struct_get(__FILE_CACHE, filename));
		}
		log("Loading encrypted struct from " + filename);
		var buffer = buffer_load(filename);
		encrypt_buffer(buffer, cryptkey);	
		var rv = snap_from_binary(buffer, 0, true);
		buffer_delete(buffer);
		
		if (add_to_cache) {
			log(sprintf("Added file '{0}' to cache (encrypted struct)", filename));
			variable_struct_set(__FILE_CACHE, filename, snap_deep_copy(rv));
		}

		return rv;
	}
	return undefined;
}
