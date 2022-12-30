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
function __savegame_remove_pointers(struct) {
	return new __savegame_deep_copy_remove(struct).copy;
}

/// @function		__savegame_deep_copy_remove
/// @description	Derived from SNAP deep_copy this takes cares of methods (skip)
///					and instance id's that will not be copied but replaced with their id only
function __savegame_deep_copy_remove(source) constructor {
    copy = undefined;

	static replace_ref = function(_value) {
		// so IN THEORY this could be an object, but yoyo's finite wisdom decided
		// to make objects undetectable in gml, so we look deeper and proceed in a 
		// "best guess" manner, if this could REALLY be an object.
		var rv = {};
		rv.value = _value;
		rv.success = false;
		try {
			// if it's the ref type it looks like this: "ref 100008" (length = 10)
			var strid = string(_value);
			
			if (string_length(strid) == 10 && string_starts_with(strid, "ref ")) {
				strid = string(real(_value));
				//log("Found top level instance id in struct: " + strid);
				rv.value = __SAVEGAME_REF_MARKER + strid;
				rv.success = true;
			} else {			
				var refstr = string(_value[$ "id"]);
				if (string_starts_with(refstr, "ref ")) {
					log("Found instance id in struct: " + strid);
					rv.value = __SAVEGAME_REF_MARKER + strid;
					rv.success = true;
				}
			}
		} catch(ignored) {
			// not an object...
			log("*WARNING* False positive object reference detected. Assuming normal real value.");
		}
		return rv;
	}

    static copy_struct = function(_source)
    {
        var _copy = {};
        
        var _names = variable_struct_get_names(_source);
        var _i = 0;
        repeat(array_length(_names))
        {
            var _name = _names[_i];
            var _value = variable_struct_get(_source, _name);
			
            if (is_method(_value)) {
				_i++;
				continue;
			} 
            else if (typeof(_value) == "ref" || 
					(!is_real(_value) && !is_struct(_value) && typeof(_value) == "struct") || 
					(is_real(_value) && real(_value) > 100000 && instance_exists(_value)))
			{
				var idval = variable_instance_get(_value, "id");
				if (_name != __SAVEGAME_OBJ_PROP_ID && idval != undefined && real(idval) > 100000) {
					var res = replace_ref(idval);
					if (res.success)
						_value = res.value;
				}
			} 
			else if (is_array(_value))
            {
                _value = copy_array(_value);
            }
            else if (is_struct(_value))
            {
                _value = copy_struct(_value);
            }
            
            variable_struct_set(_copy, _name, _value);
            
            ++_i;
        }
        
        return _copy;
    };

    static copy_array = function(_source)
    {
        var _length = array_length(_source);
        var _copy = array_create(_length,);
        
        var _i = 0;
        repeat(_length)
        {
            var _value = _source[_i];
            
			if (typeof(_value) == "ref" || 
				(!is_real(_value) && !is_struct(_value) && typeof(_value) == "struct") || 
				(is_real(_value) && real(_value) > 100000 && instance_exists(_value)))
			{
				var idval = variable_instance_get(_value, "id");
				if (idval != undefined && real(idval) > 100000) {
					var res = replace_ref(idval);
					if (res.success)
						_value = res.value;
				}
			} 
            //if (is_real(_value) && instance_exists(_value)) 
			//{
			//	if (_value > 100000) {
			//		var res = replace_ref(_value);
			//		if (res.success)
			//			_value = res.value;
			//	}
			//} 
			else if (is_struct(_value))
            {
                _value = copy_struct(_value);
            }
            else if (is_array(_value))
            {
                _value = copy_array(_value);
            }
            
            _copy[@ _i] = _value;
            
            ++_i;
        }
        
        return _copy;
    };

    if (is_struct(source))
    {
        copy = copy_struct(source);
    }
    else if (is_array(source))
    {
        copy = copy_array(source);
    }
    else
    {
        copy = source;
    }

}