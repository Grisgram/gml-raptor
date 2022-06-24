/*
	internal camera action runtimes.
	Used by RoomController to create camera flights
*/

function __camera_action_screen_shake(actiondata) {
	var ela = actiondata.elapsed;
	actiondata.xrumble = actiondata.xintensity * (1 - ela);
	actiondata.yrumble = actiondata.yintensity * (1 - ela);
	if (actiondata.current_frame % 2 == 0) {
		actiondata.xshake = (random_range(0,1) - 0.5) * 2 * xrumble;
		actiondata.yshake = (random_range(0,1) - 0.5) * 2 * yrumble;
	} else {
		actiondata.xshake = -actiondata.xshake;
		actiondata.yshake = -actiondata.yshake;
	}
	
	var delta = no_delta;
	if (restore_target != -1) {
		with(restore_target) {
			if (SELF_HAVE_MOVED)
				delta = {dx:(x - xprevious), dy:(y - yprevious)};
		}
	}
		
	camera_set_view_pos(
		view_camera[actiondata.camera_index], 
		camera_xstart + delta.dx + actiondata.xshake, 
		camera_ystart + delta.dy + actiondata.yshake);
		
	if (ela >= 1)
		camera_set_view_target(view_camera[actiondata.camera_index], actiondata.restore_target);
}

function __camera_action_zoom(actiondata) {
	var cam = view_camera[actiondata.camera_index];
	if (actiondata.first_call) {
		actiondata.first_call = false;
		
		macro_camera_viewport_index_switch_to(actiondata.camera_index);
		actiondata.cam_start_w = CAM_WIDTH;
		actiondata.cam_start_h = CAM_HEIGHT;
		
		if (actiondata.relative) 
			actiondata.new_width = CAM_WIDTH + actiondata.width_delta;
		
		var width_delta = actiondata.new_width - CAM_WIDTH;
		var new_height = CAM_HEIGHT + (width_delta / CAM_ASPECT_RATIO);
		actiondata.new_height = new_height;
		
		actiondata.distance_x = actiondata.new_width  - actiondata.cam_start_w;
		actiondata.distance_y = actiondata.new_height - actiondata.cam_start_h;
		macro_camera_viewport_index_switch_back();
	}
	
	actiondata.next_step_x = actiondata.distance_x * anim_curve_step.x;
	actiondata.next_step_y = actiondata.distance_y * anim_curve_step.y;

	actiondata.step_delta_x	 = actiondata.distance_x * (anim_curve_step.x - anim_curve_step.xprevious);
	actiondata.step_delta_y	 = actiondata.distance_y * (anim_curve_step.y - anim_curve_step.yprevious);
	
	camera_set_view_size(cam, 
		actiondata.cam_start_w + actiondata.next_step_x,
		actiondata.cam_start_h + actiondata.next_step_y);
	
	if (camera_get_view_target(cam) != -1) {
		// if there's a target set, align the borders of the view 
		camera_set_view_border(cam, 
			camera_get_view_border_x(cam) + floor(actiondata.step_delta_x / 2) + 1, 
			camera_get_view_border_y(cam) + floor(actiondata.step_delta_y / 2) + 1);
	}
		
	if (actiondata.completed) 
		camera_set_view_size(cam, actiondata.new_width, actiondata.new_height);
}

function __camera_action_move(actiondata) {
	var cam = view_camera[actiondata.camera_index];
	if (actiondata.first_call) {
		actiondata.first_call = false;
		
		macro_camera_viewport_index_switch_to(actiondata.camera_index);
		actiondata.cam_start_x = CAM_LEFT_EDGE;
		actiondata.cam_start_y = CAM_TOP_EDGE;
		
		if (actiondata.relative) {
			actiondata.target_x = CAM_CENTER_X + actiondata.distance_x;
			actiondata.target_y = CAM_CENTER_Y + actiondata.distance_y;
		}
		
		actiondata.distance_x = actiondata.target_x - CAM_CENTER_X;
		actiondata.distance_y = actiondata.target_y - CAM_CENTER_Y;
		macro_camera_viewport_index_switch_back();
	}
	
	actiondata.next_step_x = actiondata.distance_x * anim_curve_step.x;
	actiondata.next_step_y = actiondata.distance_y * anim_curve_step.y;
	
	camera_set_view_pos(cam, 
		actiondata.cam_start_x + actiondata.next_step_x, 
		actiondata.cam_start_y + actiondata.next_step_y);
			
	if (actiondata.completed) 
		camera_set_view_pos(cam, actiondata.target_x, actiondata.target_y);	
}

