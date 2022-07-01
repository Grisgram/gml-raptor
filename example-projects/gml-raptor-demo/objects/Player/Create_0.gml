/// @description Player StateMachine

// Inherit the parent event
event_inherited();

KEY_W = ord("W");
KEY_A = ord("A");
KEY_S = ord("S");
KEY_D = ord("D");

#macro MOVE_SPEED		4
#macro ACCEL_DURATION	30

states.data.is_alive = false;

states
.add_state("appear",
	function(sdata) {
		sdata.is_alive = true;
		x = VIEW_CENTER_X;
		y = 150;
		return "moving";
	}
)
.add_state("moving",,  // notice 2 commas here - the function below is the "step" function!
	function() {
		vspeed = MOVE_SPEED * keyboard_check(ord("S")) - MOVE_SPEED * keyboard_check(ord("W"));
		hspeed = MOVE_SPEED * keyboard_check(ord("D")) - MOVE_SPEED * keyboard_check(ord("A"));
		x = clamp(x, sprite_xoffset, VIEW_WIDTH  - sprite_xoffset);
		y = clamp(y, sprite_yoffset, VIEW_HEIGHT - sprite_yoffset);
	}
)
.add_state("die",
	function(sdata) {
		sdata.is_alive = false;
		animation_run(self,0,30,acLinearRotate)
			.set_rotation_distance(720)
			.play_backwards();
		animation_run(self,0,30,acLinearScale)
			.play_backwards()
			.add_finished_trigger(function() {
				instance_destroy(self);
				ROOMCONTROLLER.game_over();
			});
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

