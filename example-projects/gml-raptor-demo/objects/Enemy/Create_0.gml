/// @description Enemy StateMachine

// Inherit the parent event
event_inherited();

scanner = instance_create_layer(x,y,layer,EnemyScanner);
scanner.set_owner(self);

GLOBALDATA.enemy_count++;

states.data.spawn_anim = undefined;

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
					speed = 0;
					states.set_state("search_for_player");
				});
	}
)
.add_state("search_for_player")
.set_state("appear");

