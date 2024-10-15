/// @desc object debug frames

if (__ACTIVE_TRANSITION != undefined) {
	with (__ACTIVE_TRANSITION) {
		if (__ACTIVE_TRANSITION_STEP == 0) out_draw(); else 
		if (__ACTIVE_TRANSITION_STEP == 1) in_draw();
	}
}

if (!global.__debug_shown) exit;

if (DEBUG_SHOW_OBJECT_FRAMES)
	__draw_bbox_rotated();
