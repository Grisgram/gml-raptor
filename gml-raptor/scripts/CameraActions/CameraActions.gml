/*
	internal camera action runtimes.
	Used by RoomController to create camera flights
*/

enum cam_align {
	top_left		= 0,
	top_center		= 1,
	top_right		= 2,
	middle_left		= 3,
	middle_center	= 4,
	middle_right	= 5,
	bottom_left		= 6,
	bottom_center	= 7,
	bottom_right	= 8,
}

function __get_target_for_cam_align(x_target, y_target, align = cam_align.top_left) {
	switch (align) {
		case cam_align.top_left		: return { x: x_target,					y: y_target };
		case cam_align.top_center	: return { x: x_target - CAM_WIDTH / 2, y: y_target };
		case cam_align.top_right	: return { x: x_target - CAM_WIDTH,     y: y_target };
		case cam_align.middle_left	: return { x: x_target,					y: y_target - CAM_HEIGHT / 2 };	
		case cam_align.middle_center: return { x: x_target - CAM_WIDTH / 2, y: y_target - CAM_HEIGHT / 2 };
		case cam_align.middle_right	: return { x: x_target - CAM_WIDTH,		y: y_target - CAM_HEIGHT / 2 };
		case cam_align.bottom_left	: return { x: x_target,					y: y_target - CAM_HEIGHT };	
		case cam_align.bottom_center: return { x: x_target - CAM_WIDTH / 2,	y: y_target - CAM_HEIGHT };
		case cam_align.bottom_right	: return { x: x_target - CAM_WIDTH,		y: y_target - CAM_HEIGHT };
	}
}

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
		
		if (actiondata.relative) {
			actiondata.width_delta = actiondata.width_delta > 0 ?
				min(actiondata.width_delta, actiondata.max_width - CAM_WIDTH) :
				-min(abs(actiondata.width_delta), CAM_WIDTH - actiondata.min_width);
			actiondata.new_width = CAM_WIDTH + actiondata.width_delta;
		}
		
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
	
	camera_set_view_pos(cam, 
		CAM_LEFT_EDGE - actiondata.step_delta_x / 2, 
		CAM_TOP_EDGE - actiondata.step_delta_y / 2);
		
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
		actiondata.cam_start_y = CAM_TOP_EDGE ;
		
		if (actiondata.relative) {
			actiondata.target_x = CAM_LEFT_EDGE + actiondata.distance_x;
			actiondata.target_y = CAM_TOP_EDGE  + actiondata.distance_y;
		}
		
		actiondata.distance_x = actiondata.target_x - CAM_LEFT_EDGE;
		actiondata.distance_y = actiondata.target_y - CAM_TOP_EDGE ;
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

