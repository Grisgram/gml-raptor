/// @description countdown & align to mouse if visible

event_inherited();

if (__active) {
	if (!visible) {
		__frame_countdown--;
		visible = (__frame_countdown <= 0);
		if (visible) text = update_tooltip_text();
	} 
	if (visible) {
		if (draw_on_gui) {
			x = max(0, min(GUI_MOUSE_X + mouse_xoffset, UI_VIEW_WIDTH_SCALED - SELF_WIDTH ));
			y = max(0, min(GUI_MOUSE_Y + mouse_yoffset, UI_VIEW_HEIGHT_SCALED - SELF_HEIGHT));
		} else {
			x = max(0, min(mouse_x + mouse_xoffset, VIEW_WIDTH  - SELF_WIDTH));
			y = max(0, min(mouse_y + mouse_yoffset, VIEW_HEIGHT - SELF_HEIGHT));
		}
	}
} else {
	if (__frame_countdown < __last_activation_delay_frames) {
		__counting_up = true;
		__frame_countdown++;
	} else
		__counting_up = false;
}
