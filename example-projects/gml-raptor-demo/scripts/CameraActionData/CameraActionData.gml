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
		By default, a linear interpolation happens (acLinearMove)
		Change it to whatever interpolation you desire.
		Adapt the channel names for x/y if the curve uses different channel names
		The anim_curve_step gets updated every step BEFORE the runtime of the
		camera action is invoked, and contains the current values for x/y of the curve
		SEE camera_action_move or _zoom for implementation examples.
	*/
	anim_curve = acLinearMove;
	anim_curve_channel_x = "x";
	anim_curve_channel_y = "y";
	anim_curve_step = {x: 0, y: 0, xprevious: 0, yprevious: 0};

	/// @function		set_anim_curve(curve, x_channel_name = "x", y_channel_name = "y")
	/// @description	Assigns a different AnimCurve than the default LinearCurve to this camera action.
	///			The curve must provide the channels named in the x_ and y_channel_name parameters and
	///			the value range must be 0..1, where 0 meanse "0%" and 1 means "100%" of distance done.
	///			This function returns self to make it chainable.
	/// @param {AnimCurve} curve 	The AnimCurve to use.
	/// @param {string} x_channel_name	Name of the channel for the x-coordinate
	/// @param {string} y_channel_name	Name of the channel for the y-coordinate
	/// @returns {camera_action_data} struct Self, to be chainable.
	static set_anim_curve = function(curve, x_channel_name = "x", y_channel_name = "y") {
		anim_curve = curve;
		anim_curve_channel_x = x_channel_name;
		anim_curve_channel_y = y_channel_name;
		return self;
	}

	static __add_or_enqueue = function(enqueue_if_running = false) {
		var rv = __CAMERA_RUNTIME.get_first_free_camera_action();
		var enqueue = (enqueue_if_running && __CAMERA_RUNTIME.has_camera_action_with(callback));

		if (enqueue) {
			ds_list_add(__CAMERA_RUNTIME.camera_action_queue, self);
			var queue_length = ds_list_size(__CAMERA_RUNTIME.camera_action_queue);
			rv = -1;
			enqueued = true;
			with(ROOMCONTROLLER)
				log(MY_NAME + sprintf(": Enqueued camera action: script='{0}'; frames={1}; queue_position={2};", 
					script_get_name(other.callback), other.total_frames, queue_length));
		} else {
			__CAMERA_RUNTIME.active_camera_actions[rv] = self;
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
		var i = 0; repeat(ds_list_size(__CAMERA_RUNTIME.camera_action_queue)) {
			var entry = ds_list_find_value(__CAMERA_RUNTIME.camera_action_queue, i);
			if (entry.callback == callback) {
				entry.__internal_index = entry.__add_or_enqueue();
				entry.enqueued = false;
				ds_list_delete(__CAMERA_RUNTIME.camera_action_queue, i);
				with(ROOMCONTROLLER)
					log(MY_NAME + sprintf(": Activated camera action from queue: script='{0}'; index={1};", 
						script_get_name(entry.callback), entry.__internal_index));
				break;
			}
			i++;
		}
	}
}

