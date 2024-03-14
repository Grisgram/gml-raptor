/// @description 


// Inherit the parent event
event_inherited();

data.camera_index = camera_index;
data.is_attached = false;
data.attached_to = noone;

__update_camera = function() {
	my_cam			= view_camera[data.camera_index];
	my_cam_width	= camera_get_view_width(CAM) / 2;
	my_cam_height	= camera_get_view_height(CAM) / 2;
}

align_to_attached = function() {
	if (stop_at_room_borders) {
		x = min(room_width  - my_cam_width , max(my_cam_width , data.attached_to.x));
		y = min(room_height - my_cam_height, max(my_cam_height, data.attached_to.y));
	} else {
		x = data.attached_to.x;
		y = data.attached_to.y;
	}
	camera_set_view_pos(my_cam, x - my_cam_width, y - my_cam_height);
}

/// @function		attach_to(_instance)
/// @description	Attach the eye to an object (or noone).
///					As long as the eye is attached, the eye (and so the camera)
///					will follow the attached object, keeping it in the center of the screen.
attach_to = function(_instance) {
	data.attached_to = _instance;
	data.is_attached = (_instance != undefined && _instance != noone);
	if (is_enabled && data.is_attached) align_to_attached();
}

/// @function	set_camera_index(_index)
set_camera_index = function(_index) {
	data.camera_index = _index;
	__update_camera();
}

/// @function	get_camera_index()
get_camera_index = function() {
	return data.camera_index;
}

__update_camera();
