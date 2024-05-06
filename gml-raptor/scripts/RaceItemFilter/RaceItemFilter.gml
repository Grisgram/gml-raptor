/*
    Filter class for the items list of a RaceTable.
	Follows the builder pattern with a final execute() method to launch the filter
	and retrieve the filtered item list.
*/

function RaceItemFilter(_items) constructor {

	__items				= _items;
	filter_type			= undefined;
	filter_always		= undefined;
	filter_unique		= undefined;
	filter_enabled		= undefined;
	filter_chance		= undefined;
	filter_attributes	= undefined;

	/// @func for_type(_type_string_pattern)
	static for_type = function(_type_string_pattern) {
		filter_type = _type_string_pattern;
		return self;
	}

	/// @func for_always(_always)
	static for_always = function(_always) {
		filter_always = _always;
		return self;
	}

	/// @func for_unique(_unique)
	static for_unique = function(_unique) {
		filter_unique = _unique;
		return self;
	}

	/// @func for_enabled(_enabled)
	static for_enabled = function(_enabled) {
		filter_enabled = _enabled;
		return self;
	}
	
	/// @func for_chance(_predicate)
	/// @desc The predicate receives the chance of the item
	static for_chance = function(_predicate) {
		filter_chance = _predicate;
		return self;
	}
	
	/// @func for_attribute(_predicate)
	/// @desc The predicate receives the entire attributes struct
	static for_attribute = function(_predicate) {
		filter_attributes = _predicate;
		return self;
	}

	/// @func execute()
	/// @desc Executes the filter and returns a struct with matching items
	static execute = function() {
		var rv = {};
		var names = struct_get_names(__items);
		for (var i = 0, len = array_length(names); i < len; i++) {
			var name = names[@i];
			var item = __items[$ name];
			if (
				(filter_type == undefined || string_match(item.type, filter_type) &&
				((filter_always  ?? item.always ) == item.always ) &&
				((filter_unique  ?? item.unique ) == item.unique ) &&
				((filter_enabled ?? item.enabled) == item.enabled) &&
				(filter_chance == undefined || filter_chance(item.chance)) &&
				(filter_attributes == undefined || filter_attributes(item.attributes))
			)
				struct_set(rv, name, item);
		}
		return rv;
	}
}