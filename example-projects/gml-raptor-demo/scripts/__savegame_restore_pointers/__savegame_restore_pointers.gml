/*
    This code is 95% identical with SNAP's deep_copy but it handles methods
	and instance ids differently as both can not be persisted to the savegame file.
	
	methods are simply skipped and instance ids are replaced with their real(id) value
	only but in a special syntax that can be detected by savegame_load_game when this
	file gets restored.
*/

/// @func		__savegame_remove_pointers()
/// @desc
/// @arg {struct} struct	The struct to clone and remove pointers
function __savegame_restore_pointers(struct, refstack) {        
    if (is_struct(struct))
    {
        __savegame_restore_struct_pointers(struct, refstack);
    }
    else if (is_array(struct))
    {
        __savegame_restore_array_pointers(struct, refstack);
    }
}

function __savegame_restore_struct_pointers(_source, refstack)
{
	var restorename = $"restore_{name_of(_source)}";
	var cached = vsget(refstack, restorename);
	if (cached != undefined)
		return _source;
		
    var _names = struct_get_names(_source);
    var _i = 0;
    repeat(array_length(_names))
    {
        var _name = _names[_i];
        var _value = struct_get(_source, _name);
            
        if (is_string(_value) && string_starts_with(_value, __SAVEGAME_REF_MARKER))
		{
			//_value = string_replace(_value, __SAVEGAME_REF_MARKER, "");
			//vlog($"Restoring instance id in struct: {_value}");
			struct_set(_source, _name, savegame_get_instance_of(_value));
		} 
		else if (is_array(_value))
        {
            _value = __savegame_restore_array_pointers(_value, refstack);
        }
        else if (is_struct(_value))
        {
			refstack[$ restorename] = _value;
            _value = __savegame_restore_struct_pointers(_value, refstack);
			refstack[$ restorename] = _value;
        }
            
        ++_i;
    }
};

function __savegame_restore_array_pointers(_source, refstack)
{
    var _length = array_length(_source);
    var _i = 0;
		
    repeat(_length)
    {
        var _value = _source[_i];
            
        if (is_string(_value) && string_starts_with(_value, __SAVEGAME_REF_MARKER))
		{
			_value = string_replace(_value, __SAVEGAME_REF_MARKER, "");
			//vlog($"Restoring instance id in array: {_value}");
			_source[@ _i] = savegame_get_instance_of(_value);
		} 
		else if (is_struct(_value))
        {
            _value = __savegame_restore_struct_pointers(_value, refstack);
        }
        else if (is_array(_value))
        {
            _value = __savegame_restore_array_pointers(_value, refstack);
        }
            
        ++_i;
    }
};
