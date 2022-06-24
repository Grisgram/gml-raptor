/*
	camera_action_data
	
	Controller class for all camera flights.
	Do not instantiate directly, use the methods in RoomController to launch camera effects:
	- screen_shake
	- zoom_to
	- zoom_by
	- move_to
	- move_by
	
*/

/// @function camera_action_data(cam_index, frames, script_to_call, enqueue_if_running = false)
/// @param {int} cam_index
/// @param {real} frames
/// @param {asset} script_to_call
/// @param {bool=false} enqueue_if_running
function camera_action_data(cam_index, frames, script_to_call, enqueue_if_running = false) constructor {
	camera_index	= cam_index;
	camera_xstart	= camera_get_view_x(view_camera[camera_index]);
	camera_ystart	= camera_get_view_y(view_camera[camera_index]);
	restore_target	= camera_get_view_target(view_camera[camera_index]);
	total_frames = frames;
	current_frame = 0;
	elapsed = 0;
	callback = script_to_call;
	started_callback = undefined;
	finished_callback = undefined;
	completed = false;
	enqueued = false;
	
	
	/*
		About AnimactionCurves:
		By default, a linear interpolation happens (CameraLinearCurve)
		Change it to whatever interpolation you design.
		Adapt the channel names for x/y if the curve uses different channel names
		The anim_curve_step gets updated every step BEFORE the runtime of the
		camera action is invoked, and contains the current values for x/y of the curve
		SEE camera_action_move or _zoom for implementation examples.
	*/
	anim_curve = CameraLinearCurve;
	anim_curve_channel_x = "x";
	anim_curve_channel_y = "y";
	anim_curve_step = {x: 0, y: 0, xprevious: 0, yprevious: 0};

	static __add_or_enqueue = function(enqueue_if_running = false) {
		var rv = other.__get_first_free_camera_action();
		var enqueue = (enqueue_if_running && ROOMCONTROLLER.__has_camera_action_with(callback));

		if (enqueue) {
			ds_list_add(ROOMCONTROLLER.__camera_action_queue, self);
			var queue_length = ds_list_size(ROOMCONTROLLER.__camera_action_queue);
			rv = -1;
			enqueued = true;
			with(ROOMCONTROLLER)
				log(MY_NAME + sprintf(": Enqueued camera action: script='{0}'; frames={1}; queue_position={2};", 
					script_get_name(other.callback), other.total_frames, queue_length));
		} else {
			other.__active_camera_actions[rv] = self;
			with(ROOMCONTROLLER)
				log(MY_NAME + sprintf(": Created camera action: script='{0}'; frames={1}; index={2};", 
					script_get_name(other.callback), other.total_frames, rv));
		}

		return rv;
	}

	__internal_index = __add_or_enqueue(enqueue_if_running);

	static step = function() {
		current_frame++;
		elapsed = min(1, current_frame / total_frames);
		
		var xcurve = animcurve_get_channel(anim_curve, anim_curve_channel_x);
		var ycurve = animcurve_get_channel(anim_curve, anim_curve_channel_y);
		anim_curve_step.xprevious = anim_curve_step.x;
		anim_curve_step.yprevious = anim_curve_step.y;
		anim_curve_step.x = animcurve_channel_evaluate(xcurve, elapsed);
		anim_curve_step.y = animcurve_channel_evaluate(ycurve, elapsed);
		
		completed = (elapsed >= 1);
	}

	static abort = function() { 
		with(ROOMCONTROLLER) {
			__active_camera_actions[other.__internal_index] = undefined;
			log(MY_NAME + sprintf(": Camera action {0}: index={1};", other.completed ? "finished" : "aborted", other.__internal_index));
		}
		// invoke finished_callback (if available)
		if (finished_callback != undefined)
			finished_callback(self);
		
		// start next from queue (if available)
		var i = 0; repeat(ds_list_size(ROOMCONTROLLER.__camera_action_queue)) {
			var entry = ds_list_find_value(ROOMCONTROLLER.__camera_action_queue, i);
			if (entry.callback == callback) {
				entry.__internal_index = entry.__add_or_enqueue();
				entry.enqueued = false;
				ds_list_delete(ROOMCONTROLLER.__camera_action_queue, i);
				with(ROOMCONTROLLER)
					log(MY_NAME + sprintf(": Activated camera action from queue: script='{0}'; index={1};", 
						script_get_name(entry.callback), entry.__internal_index));
				break;
			}
			i++;
		}
	}
}

