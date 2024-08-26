/// @description Enemy StateMachine
game_active = true;

// Inherit the parent event
event_inherited();

scanner = instance_create_layer(x,y,layer,EnemyScanner);
scanner.set_owner(self);

GLOBALDATA.enemy_count++;

states.data.spawn_anim = undefined;
states.data.is_alive = false;

states
.add_state("appear",
	function(sdata) {
		// Look (and move) in the direction of the spawner when appearing
		image_angle = SPAWNER.image_angle;
		direction	= image_angle;
		speed		= 8;
		sdata.spawn_anim = sdata.spawn_anim ??
			new Animation(self, 0, 30, acEnemySpawn)
				.add_finished_trigger(function() {
					states.set_state("search_for_player");
				});
	}
)
.add_state("search_for_player",
	function(sdata) {
		sdata.is_alive = true;
		sdata.rotate_lock_countdown = 30;
		speed = 3;
	},
	function(sdata) {
		// enemies are dumb
		// we just have a 1% chance (so every 100 frames it hits roughly) to make a turn
		// and when we touch the border of the room we turn random 90° left or right
		if (IS_PERCENT_HIT(1))
			return "rotate45";
		
		if (sdata.rotate_lock_countdown > 0) {
			sdata.rotate_lock_countdown--;
			return;
		}
		
		if (x < sprite_xoffset || x > VIEW_WIDTH - sprite_xoffset ||
			y < sprite_yoffset || y > VIEW_HEIGHT - sprite_yoffset)
			return "rotate180";
	}
)
.add_state("rotate45",
	function() {
		animation_run(self, 0, 30, acLinearRotate)
			.set_rotation_distance(random_range(-45,45))
			.add_finished_trigger(function() {
				states.set_state("search_for_player");
			});
	},
	function() {
		direction = image_angle;
	}
)
.add_state("rotate180",
	function() {
		speed = 0;
		animation_run(self, 0, 30, acLinearRotate)
			.set_rotation_distance(choose(180,-180))
			.add_finished_trigger(function() {
				states.set_state("search_for_player");
			});
	},
	function() {
		direction = image_angle;
	}
)
.add_state("die",
	function(sdata) {
		animation_abort_all(self);
		sdata.is_alive = false;
		animation_run(scanner,0,30,acLinearAlpha)
			.play_backwards()
			.add_finished_trigger(function() {
				instance_destroy(scanner);
			});
		animation_run(self,0,30,acLinearAlpha)
			.play_backwards()
			.add_finished_trigger(function() {
				instance_destroy(self);
			});
	}
)
.add_state("pause") // pause is an empty state, may continue through ESC
.add_state("ev:key_press_vk_escape",
	function(sdata, prev_state) {
		return (prev_state == "search_for_player" ? "pause" : "search_for_player");
	}
)
.set_state("appear");

