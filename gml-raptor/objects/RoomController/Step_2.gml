/// @description update active camera actions

/*
	END STEP: All objects are placed, now move the camera
*/

for (var i = 0; i < array_length(__CAMERA_RUNTIME.active_camera_actions); i++) {
	if (__CAMERA_RUNTIME.active_camera_actions[@ i] != undefined) {
		with (__CAMERA_RUNTIME.active_camera_actions[@ i]) {
			if (current_frame == 0 && started_callback != undefined)
				started_callback(self);
				
			__step();
			callback(self);
			
			if (completed) 
				abort();
		}
	}
}

if (__ACTIVE_TRANSITION != undefined) {
	with (__ACTIVE_TRANSITION) {
		frame_counter++;
		if (__ACTIVE_TRANSITION_STEP == 0) out_step(); else 
		if (__ACTIVE_TRANSITION_STEP == 1) in_step();
	}
}
