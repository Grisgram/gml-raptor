/// @description mouse_is_over=false

// mouse_is_over goes to false, regardless whether we are visible or not.
// this is for the case, that the mouse _entered_ the control, then became invisible
// (or a popup opened), and then it would never receive a leave and when the control
// reappears, it would still be in state "mouse_is_over", which is wrong.
// The "force_redraw()" call just buffers a redraw action for the next frame, when the
// control is visible, no matter WHEN that happens
if (mouse_is_over) {
	mouse_is_over = false;
	force_redraw(false);
	__mouse_enter_topmost_control();
}