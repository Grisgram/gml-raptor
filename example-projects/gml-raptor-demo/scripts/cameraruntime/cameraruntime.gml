/*
    internal runtime singleton implementation for the camera effects
*/

#macro __CAMERA_RUNTIME		__camera_runtime()

function __camera_runtime() {	
	static inst = undefined;
	
	if (inst == undefined) inst = {
		active_camera_actions: array_create(1, undefined),
		camera_action_queue: ds_list_create(),

		get_first_free_camera_action: function() {
			freeidx = -1;
			var i = 0; repeat(array_length(__active_camera_actions)) {
				if (__active_camera_actions[i] == undefined) {
					freeidx = i;
					break;
				}
				i++;
			}
			if (freeidx == -1) {
				freeidx = array_length(__active_camera_actions);
				array_push(__active_camera_actions, undefined);
			}
			if (freeidx == 0 && array_length(__active_camera_actions) > 1)
				__active_camera_actions = array_create(1, undefined); // shrink the array if necessary
			return freeidx;
		},

		has_camera_action_with:  function(script_to_call) {
			var i = 0; repeat(array_length(__active_camera_actions)) {
				var action = __active_camera_actions[i++];
				if (action != undefined && action.callback == script_to_call)
					return true;
			}
			return false;
		},
		
		clean_up: function() {
			ds_list_destroy(camera_action_queue);
		},
	};
	
	return inst;
}