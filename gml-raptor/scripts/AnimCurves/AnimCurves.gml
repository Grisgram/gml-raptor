/*
    Helper functions for animcurves.
	
	animcurve_get_ext delivers an animcurve that is enriched by:
	- an array "channel_names" containing all names in the curve
	- a function "channel_exists" which queries the curve for a channel name
	- a function "get_channel" which returns a named channel or undefined (instead of throwing an error)
	
*/
function animcurve_get_ext(curve_id) {
	var rv = animcurve_get(curve_id);
	
	with (rv) {
		channel_names = array_create(array_length(channels));
		channel_values = array_create(array_length(channels));
	
		for (var i = 0; i < array_length(channels); i++) {
			channel_names[i] = channels[i].name;
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
		
		/// @function					update_values(point_in_time)
		update_values = function(point_in_time) {
			for (var i = 0; i < array_length(channels); i++) 
				channel_values[i] = animcurve_channel_evaluate(channels[i], point_in_time);
		}
	}
	
	return rv;
}


