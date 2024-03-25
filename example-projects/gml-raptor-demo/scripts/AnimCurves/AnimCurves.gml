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
	  curve.values.x()  curve.values.y()  curve.values.alpha()
		
*/

/// @function		animcurve_get_ext(curve_id)
function animcurve_get_ext(curve_id) {
	var rv = animcurve_get(curve_id);
	with (rv) {
		channel_names = array_create(array_length(channels));
		channel_values = array_create(array_length(channels));
		values = new Bindable(self);
	
		for (var i = 0, len = array_length(channels); i < len; i++) {
			channel_names[i] = channels[i].name;
			// create a dynamic method named by the value
			// so you can access values by curve.values.x()...
			values[$ channel_names[i]] = method({
				curve: rv,
				idx : i
			}, function() {return curve.get_value(idx);});
		}
	
		/// @function binder()
		/// @description Gets the PropertyBinder for the values of this animation
		static binder = function() {
			return values.binder();
		}
		
		/// @function					channel_exists(name)
		channel_exists = function(name) {
			for (var i = 0, len = array_length(channel_names); i < len; i++) 
				if (channel_names[i] == name)
					return true;
			return false;
		}
	
		/// @function					get_channel(name)
		get_channel = function(name) {
			for (var i = 0, len = array_length(channel_names); i < len; i++) 
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
			for (var i = 0, len = array_length(channels); i < len; i++) 
				channel_values[i] = animcurve_channel_evaluate(channels[i], pit);
		}
	}
	
	return rv;
}

