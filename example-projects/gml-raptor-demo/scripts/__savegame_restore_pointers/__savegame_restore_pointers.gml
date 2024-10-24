/*
    Restores all pointers of object instances through the entire savegame structure
*/

/// @func		__savegame_restore_pointers(struct, refstack)
/// @desc
/// @arg {struct} struct	The struct to restore pointers
function __savegame_restore_pointers(struct, refstack) {        
	var circstack = [];
    if (is_struct(struct))
    {
        __savegame_restore_struct_pointers(struct, refstack, circstack);
    }
    else if (is_array(struct))
    {
        __savegame_restore_array_pointers(struct, refstack, circstack);
    }
}

function __savegame_restore_struct_pointers(_source, refstack, circstack)
{
	var restorename = $"restored_{address_of(_source)}";
	//var restorename = $"restore_{name_of(_source)}";
	if (array_contains(circstack, restorename)) 
		return;
	array_push(circstack, restorename);
	
	var cached = vsget(refstack, restorename);
	if (cached != undefined)
		return cached;
	
    var _names = struct_get_names(_source);
    var _i = 0;
    repeat(array_length(_names))
    {
        var _name = _names[_i];
        var _value = struct_get(_source, _name);
        
		if (!is_method(_value)) {
	        if (is_string(_value) && string_starts_with(_value, __SAVEGAME_REF_MARKER))
			{
				_value = string_replace(_value, __SAVEGAME_REF_MARKER, "");
				//vlog($"Restoring instance id in struct: {_value}");
				struct_set(_source, _name, savegame_get_instance_of(_value));
			} 
			else if (is_array(_value))
	        {
	            __savegame_restore_array_pointers(_value, refstack, circstack);
	        }
	        else if (is_struct(_value))
	        {
				refstack[$ restorename] = _value;
				__savegame_restore_struct_pointers(_value, refstack, circstack);
				refstack[$ restorename] = _value;
	        }
		}
        ++_i;
    }
};

function __savegame_restore_array_pointers(_source, refstack, circstack)
{
    var _length = array_length(_source);
    var _i = 0;
		
    repeat(_length)
    {
        var _value = _source[_i];
		if (!is_method(_value)) {
	        if (is_string(_value) && string_starts_with(_value, __SAVEGAME_REF_MARKER))
			{
				_value = string_replace(_value, __SAVEGAME_REF_MARKER, "");
				//vlog($"Restoring instance id in array: {_value}");
				_source[@ _i] = savegame_get_instance_of(_value);
			} 
			else if (is_struct(_value))
	        {
	            _value = __savegame_restore_struct_pointers(_value, refstack, circstack);
	        }
	        else if (is_array(_value))
	        {
	            _value = __savegame_restore_array_pointers(_value, refstack, circstack);
	        }
		}
        ++_i;
    }

};
