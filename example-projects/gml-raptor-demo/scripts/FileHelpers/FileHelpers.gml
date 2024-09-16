/// @func	file_list_directory(_folder = "", _wildcard = "*.*", _recursive = false, attributes = 0)
/// @desc	List all matching files from a directory in an array, optionally recursive
///			_attributes	is one of the attr constants according to yoyo manual
///         https://manual-en.yoyogames.com/#t=GameMaker_Language%2FGML_Reference%2FFile_Handling%2FFile_System%2Ffile_attributes.htm
function file_list_directory(_folder = "", _wildcard = "*.*", _recursive = false, _attributes = 0) {
	if (IS_HTML) {
		wlog($"** WARNING ** The function file_list_directory does not work in html target! Avoid calling it with \"if (!IS_HTML) ...\"");
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
					if (file_attributes(f, fa_directory))
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

#region CONSTRUCTOR REGISTRATION
/// @func	__file_get_constructed_class(from)
/// @desc	Returns a struct with 'cached' and the instance
///			if 'cached' is true, it has been taken from cache, so
///			no further recursion needed from the caller side
function __file_get_constructed_class(from, restorestack) {
	var restorename = $"restored_{name_of(from)}";
	var rv = vsget(restorestack, restorename);
	if (rv != undefined) 
		return {
			cached: true,
			instance: rv
		};
	
	if (variable_struct_exists(from, __CONSTRUCTOR_NAME)) {
		var constname = from[$ __CONSTRUCTOR_NAME];
		//vlog($"Constructing '{constname}'");
		var class = asset_get_index(constname);
		rv = new class();
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

/// @func	__file_reconstruct_root(from)
function __file_reconstruct_root(from) {
	var restorestack = {};
	// The first instance here can't be from cache, as the restorestack is empty
	var rv = __file_get_constructed_class(from, restorestack).instance;
	__file_reconstruct_class(rv, from, restorestack);
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
			if (is_struct(member)) {
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

/// @function	file_get_filename(_path, _with_extension = true)
/// @desc		Little helper function to get the filename only out of a path
///				with the choice, to include or strip off the extension of the file
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