/*
    Helper functions for animcurves.
	
	animcurve_get_ext delivers an animcurve that is enriched by:
	- an array "channel_names" containing all names in the curve
	- a function "channel_exists" which queries the curve for a channel name
	- a function "get_channel" which returns a named channel or undefined (instead of throwing an error)
	- dynamically created methods for each of the named values in the curve, for example:
	  if your curve contains "x", "y" and "alpha" channels, you can access their current values by
	  invoking:
	  var curve = animcurve_get_ext(acSomething);
	  curve.values.x  curve.values.y  curve.values.alpha
	
	  NOTE: Named functions are created for FIRST EIGHT values in a curve. This is due to a limitation of GML itself. 
	  If you have more than 8 values in a curve, you have to access them via get_value(...) or get_value_by_name(...)
	
*/

/// @function		animcurve_get_ext(curve_id)
function animcurve_get_ext(curve_id) {
	var rv = animcurve_get(curve_id);
	with (rv) {
		channel_names = array_create(array_length(channels));
		channel_values = array_create(array_length(channels));
		values = {
			curve: rv
		};
	
		for (var i = 0; i < array_length(channels); i++) {
			channel_names[i] = channels[i].name;
			switch (i) {
				case 0: values[$ channel_names[i]] = method(values, function() {return curve.get_value(0);}); break;
				case 1: values[$ channel_names[i]] = method(values, function() {return curve.get_value(1);}); break;
				case 2: values[$ channel_names[i]] = method(values, function() {return curve.get_value(2);}); break;
				case 3: values[$ channel_names[i]] = method(values, function() {return curve.get_value(3);}); break;
				case 4: values[$ channel_names[i]] = method(values, function() {return curve.get_value(4);}); break;
				case 5: values[$ channel_names[i]] = method(values, function() {return curve.get_value(5);}); break;
				case 6: values[$ channel_names[i]] = method(values, function() {return curve.get_value(6);}); break;
				case 7: values[$ channel_names[i]] = method(values, function() {return curve.get_value(7);}); break;
			}
			//values[$ channel_names[i]] = method(values, function() {return curve.get_value(i);});
		}
	
		/// @function					channel_exists(name)
		channel_exists = function(name) {
			for (var i = 0; i < array_length(channel_names); i++)
				if (channel_names[i] == name)
					return true;
			return false;
		}
	
		/// @function					get_channel(name)
		get_channel = function(name) {
			for (var i = 0; i < array_length(channel_names); i++)
				if (channel_names[i] == name)
					return channels[i];
			return undefined;		
		}
		
		/// @function	get_channel_index(channel_name)
		get_channel_index = function(channel_name) {
			for (var i = 0, len = array_length(channels); i < len; i++) 
				if (channel_names[@ i] == channel_name)
					return i;
			return -1;
		}
		
		/// @function	get_value_by_name(channel_name)
		get_value_by_name = function(channel_name) {
			var idx = get_channel_index(channel_name);
			if (idx >= 0)
				return channel_values[@ channel_index];
			return -1;
		}
		
		/// @function	get_value(channel_index)
		get_value = function(channel_index) {
			return channel_values[@ channel_index];
		}

		/// @function		update(current_value, max_value)
		/// @description	update all channel values
		update = function(current_value, max_value) {
			var pit = clamp(current_value, 0, max_value) / max_value;
			for (var i = 0; i < array_length(channels); i++) 
				channel_values[i] = animcurve_channel_evaluate(channels[i], pit);
		}
	}
	
	return rv;
}

