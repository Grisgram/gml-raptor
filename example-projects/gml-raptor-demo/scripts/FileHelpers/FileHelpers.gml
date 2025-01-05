/*
	Small file and directory helper functions
*/

#region DIRECTORY FUNCTIONS
/// @func	directory_list_files(_folder = "", _wildcard = "*.*", _recursive = false, attributes = 0)
/// @desc	List all matching files from a directory in an array, optionally recursive
///			_attributes	is one of the attr constants according to yoyo manual
///         https://manual-en.yoyogames.com/#t=GameMaker_Language%2FGML_Reference%2FFile_Handling%2FFile_System%2Ffile_attributes.htm
function directory_list_files(_folder = "", _wildcard = "*.*", _recursive = false, _attributes = 0) {
	if (IS_HTML) {
		wlog($"** WARNING ** The function directory_list_files does not work in html target! Avoid calling it with \"if (!IS_HTML) ...\"");
		return [];
	}
	_folder = __clean_file_name(_folder);
	
	var closure = {
		mask:	_wildcard,
		rec:	_recursive,
		attr:	_attributes,
		rv:		[],
		reader:	function(root, p) {
			
			if (root != "" && !string_ends_with(root, "/")) root += "/";
			var look_in = $"{working_directory}{root}";
			
			if (p.rec) {
				var dirs = [];
				var f = file_find_first($"{look_in}*", fa_directory);
				while (f != "") {
					if (file_attributes($"{look_in}{f}", fa_directory))
						array_push(dirs, $"{root}{f}/");
					f = file_find_next();
				}
				file_find_close();
				for (var i = 0, len = array_length(dirs); i < len; i++)
					p.reader(dirs[@i], p);
			}
			
			var f = file_find_first($"{look_in}{p.mask}", p.attr);
			while (f != "") {
				array_push(p.rv, $"{root}{f}");
				f = file_find_next();
			}
			file_find_close();		
		}
	}
	
	closure.reader(_folder, closure);
	return closure.rv;
}

/// @function	directory_list_directories(_folder = "", _recursive = false)
/// @desc		Lists all sub directories from the given directory
function directory_list_directories(_folder = "", _recursive = false) {
	return directory_list_files(_folder, "*", _recursive, fa_directory);
}

/// @function	directory_list_data_files(_folder = "", _recursive = false)
/// @desc		Lists all files with the current DATA_FILE_EXTENSION from the given directory
function directory_list_data_files(_folder = "", _recursive = false) {
	return directory_list_files(_folder, string_concat("*", DATA_FILE_EXTENSION), _recursive, fa_none);
}

/// @func	directory_read_data_tree_async(_folder, _file_task_callback = undefined)
/// @desc	Reads an entire tree of data files (DATA_FILE_EXTENSION) into a single
///			struct. Duplicate names are merged, not replaced, so you can freely split
///			your larger data volumes into multiple files containing the same root object (like LG)
///			The _file_task_callback is invoked for every single file load that is enqueued, so you
///			may attach your own on_finished callbacks or whatever you need for each file.
function directory_read_data_tree_async(_folder, _file_task_callback = undefined) {
	var rv = {};
	var gamefiles = directory_list_data_files("game", true);
	for (var i = 0, len = array_length(gamefiles); i < len; i++) {
		var fn = gamefiles[@i];
		var membername = file_get_filename(fn, false);
		var sa = string_split(fn, "/");
		array_shift(sa); // remove "first" folder name, this is the root
		array_pop(sa);   // remove the filename, we need structure only
		var child = rv;
		for (var j = 0, jen = array_length(sa); j < jen; j++) {
			var next = sa[@j];
			child[$ next] ??= {};
			child = child[$ next];
		}
		
		var file_task = file_read_struct_async(fn, FILE_CRYPT_KEY)
			.set_data("member", membername)
			.set_data("child", child)
			.on_finished(function(content, data) {
				var into = vsgetx(data.child, data.member, {});
				struct_join_into(into, content);
			}
		);
		
		if (_file_task_callback != undefined)
			_file_task_callback(file_task);
	}
	return rv;
}

#endregion

#region CONSTRUCTOR REGISTRATION
/// @func	__file_get_constructed_class(from, restorestack)
/// @desc	Returns a struct with 'cached' and the instance
///			if 'cached' is true, it has been taken from cache, so
///			no further recursion needed from the caller side
function __file_get_constructed_class(from, restorestack) {
	if (is_null(from))
		return {
			cached: true,
			instance: undefined
		};

	var restorename = $"restored_{address_of(from)}";
	var rv = vsget(restorestack, restorename);
	if (rv != undefined) 
		return {
			cached: true,
			instance: rv
		};
		
	var constname = "";
	if (variable_struct_exists(from, __CONSTRUCTOR_NAME)) {
		constname = from[$ __CONSTRUCTOR_NAME];
		var class = asset_get_index(constname);
		rv = new class();
		//dlog($"Constructed '{constname}' {restorename} -> {address_of(rv)}");
		if (variable_struct_exists(rv, __INTERFACES_NAME)) {
			var interfaces = rv[$ __INTERFACES_NAME];
			for (var i = 0, len = array_length(interfaces); i < len; i++)
				with(rv) implement(interfaces[@i]);
		}
	} else {
		rv = {};
	}
	
	restorestack[$ restorename] = rv;
	return {
		cached: false,
		instance: rv
	};
}

/// @func	__file_reconstruct_root(from, _restorestack = undefined)
function __file_reconstruct_root(from, _restorestack = undefined) {
	var restorestack = _restorestack ?? {};
	// The first instance here can't be from cache, as the restorestack is empty
	var rv = __file_get_constructed_class(from, restorestack).instance;
	rv = __file_reconstruct_class(rv, from, restorestack);
	return rv;
}

/// @func	__file_reconstruct_class(into, from, restorestack)
/// @desc	reconstruct a loaded data struct through its constructor
///			if the constructor is known.
function __file_reconstruct_class(into, from, restorestack) {
	var names = struct_get_names(from);
	with (into) {
		for (var i = 0; i < array_length(names); i++) {
			var name = names[i];
			var member = from[$ name];
			if (is_method(member))
				self[$ name] = method(self, member);
			else if (is_struct(member)) {
				var restored = __file_get_constructed_class(member, restorestack);
				var classinst = restored.instance;
				self[$ name] = classinst;
				if (!restored.cached)
					__file_reconstruct_class(classinst, member, restorestack);
			} else if (is_array(member)) {
				for (var a = 0; a < array_length(member); a++) {
					var amem = member[@ a];
					if (is_struct(amem)) {
						var restored = __file_get_constructed_class(amem, restorestack);
						var classinst = restored.instance;
						member[@ a] = classinst;
						if (!restored.cached)
							__file_reconstruct_class(classinst, amem, restorestack);
					}
				}
				self[$ name] = from[$ name];
			} else
				self[$ name] = from[$ name];
		}
	}
	return into;
}

#endregion

/// @function	file_exists_html_safe(_filename, _return_code_or_function_for_html = true)
/// @desc		A small cheat to work around malfunctioning file_exists checks on
///				some web providers.
///				This function can't do much to make your life easier, but it will try
///				to open the file for read and try to close it again.
///				According to GameMaker docs, either file_text_open_read(...) returns -1
///				OR file_text_close(...) returns false if the file can't be read.
///				And this is, what this function does, when running HTML.
function file_exists_html_safe(_filename) {
	if (!IS_HTML)
		return file_exists(_filename);
	else {
		var fid = file_text_open_read(_filename);
		return (fid != -1 && !file_text_close(fid)) || fid == -1;
	}
}

/// @func	file_get_filename(_path, _with_extension = true)
/// @desc	Little helper function to get the filename only out of a path
///			with the choice, to include or strip off the extension of the file
function file_get_filename(_path, _with_extension = true) {
	var sa = string_split(string_replace_all(_path, "\\", "/"), "/");
	var fn = array_pop(sa);
	if (!_with_extension) {
		var dot = string_last_index_of(fn, ".");
		if (dot > 0)
			fn = string_substring(fn, 1, dot - 1);
	}
	return fn;
}

/// @func	file_get_pathname(_path, _with_final_slash = true)
/// @desc	Little helper function to get the path-part only out of a path
///			with the choice, to include or strip off the final slash
function file_get_pathname(_path, _with_final_slash = true) {
	return 
		string_replace_all(
			_with_final_slash ? filename_path(_path) : filename_dir(_path),
			"\\", "/"
		);
}