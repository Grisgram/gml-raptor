/// @description align to my window

event_inherited();
with (message_window) {
	if (!other.__nine_slice_calculated) {
		var nine = sprite_get_nineslice(sprite_index);
		if (nine != -1) {
			other.__nine_right = nine.right;
			other.__nine_top = nine.top;
		}
		other.__nine_slice_calculated = true;
	}
	other.__window_right = SELF_VIEW_RIGHT_EDGE - other.__nine_right;
	other.__window_top = SELF_VIEW_TOP_EDGE + other.__nine_right; // right for symmetry - NOT A BUG!
}

x = __window_right;
y = __window_top;
