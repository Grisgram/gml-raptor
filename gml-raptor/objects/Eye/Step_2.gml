/// @description align own position & camera

if (data.active) {
	if (data.is_attached) {
		x = data.attached_to.x;
		y = data.attached_to.y;
	}
	camera_set_view_pos(my_cam, x - my_cam_width, y - my_cam_height);
}
