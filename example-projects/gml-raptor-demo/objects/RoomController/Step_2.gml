/// @description update active camera actions

/*
	END STEP: All objects are placed, now move the camera
*/

for (var i = 0; i < array_length(__active_camera_actions); i++) {
	if (__active_camera_actions[i] != undefined) {
		with (__active_camera_actions[i]) {
			if (current_frame == 0 && started_callback != undefined)
				started_callback(self);
				
			step();
			callback(self);
			
			if (completed) 
				abort();
		}
	}
}

