/// @description 


// Inherit the parent event
event_inherited();

data.active = active;
data.camera_index = camera_index;
data.is_attached = false;
data.attached_to = noone;

__update_camera = function() {
	my_cam			= view_camera[data.camera_index];
	my_cam_width	= camera_get_view_width(CAM) / 2;
	my_cam_height	= camera_get_view_height(CAM) / 2;
}

/// @function		attach_to(_instance)
/// @description	Attach the eye to an object (or noone).
///					As long as the eye is attached, the eye (and so the camera)
///					will follow the attached object, keeping it in the center of the screen.
attach_to = function(_instance) {
	data.attached_to = _instance;
	data.is_attached = (_instance != undefined && _instance != noone);
}

/// @function	set_active(_active)
set_active = function(_active) {
	data.active = _active;
}

/// @function	is_active()
is_active = function() {
	return data.active;
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
