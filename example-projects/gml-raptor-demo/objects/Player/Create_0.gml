/// @description Player StateMachine

// Inherit the parent event
event_inherited();

#macro MOVE_SPEED		4

states
.add_state("appear",
	function(sdata) {
		x = VIEW_CENTER_X;
		y = 150;
		return "moving";
	}
)
.add_state("moving",,  // notice 2 commas here - the function below is the "step" function!
	function() {
		vspeed = MOVE_SPEED * keyboard_check(ord("S")) - MOVE_SPEED * keyboard_check(ord("W"));
		hspeed = MOVE_SPEED * keyboard_check(ord("D")) - MOVE_SPEED * keyboard_check(ord("A"));
		x = clamp(x, 0, VIEW_WIDTH);
		y = clamp(y, 0, VIEW_HEIGHT);
	}
)
.add_state("pause")
.add_state("ev:key_press_vk_escape",
	function(sdata, prev_state) {
		// based on the previous state, which was either moving or pause, we return the other of those two states
		// with that we toggle between the two states
		return (prev_state == "pause" ? "moving" : "pause");
	}
)
.set_state("appear");

