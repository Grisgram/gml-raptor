/// @description Spawner StateMachine

/*
	Soo... what's happening here?
	
	- First, the object centers itself on the screen and sets itself invisible (alpha = 0)
	- Then I pre-declare a member in the data struct of the state machine (gets initialized in the "appear" state)
	
	- And then, all that is left to do is to create the states this spawner can have!
		- "appear" is the initial state (see the ".set_state" command as last of the chain at the end of the file)
		- "do_spawning" will just unpause the infinite rotation anim
		- if ESC is pressed, we receive the event because this is a StatefulObject
		    - on ESC press we toggle the pause state of the spawning
			
	- How do the enemies spawn?
		- Look at the "appear" state, where the sdata.running_anim is declared
		- It adds a frame trigger to trigger every 60 frames (2 seconds) to create an enemy through instance_create_layer.
		- The Enemy object itself has also a StateMachine similar to this one here and it is capable of doing its spawn-stuff by itself!
		- That's all! there isn't more to do if you combine "StateMachine" and "Animation" right!
*/

// Inherit the parent event
event_inherited();

#macro SPAWNER			global.spawner
SPAWNER = self;

x = VIEW_CENTER_X;
y = VIEW_CENTER_Y;
image_alpha = 0; // start hidden

spawn_enemy = function() {
	if (GLOBALDATA.enemy_count < MAX_ENEMY_COUNT)
		instance_create_layer(x,y, "Actors", Enemy);
}

// The ever-running spawn animation.
states.data.running_anim = undefined;

states
.add_state("appear",
	function(sdata) {
		// declare the infinit animation to be ready to go after spawn-animation finishes.
		sdata.running_anim = sdata.running_anim ?? 
			new Animation(self, 0, 480, acRotate360, -1) // rotate once per 8 seconds (480 frames), -1 repeats == infinite loop
				.add_frame_trigger(150, function() {
					// spawn a new enemy every 2.5 seconds (= 150 frames)
					spawn_enemy();
				}, true); // the "true" here sets this frame trigger to be an "interval" trigger every 150 frames
			
		sdata.running_anim.pause();

		// spawn animation
		// delay 2 seconds (120 frames), so it does not spawn in the moment the room becomes visible
		// spawn anim time 1.5 seconds (90 frames)
		// the frame trigger will spawn 3 enemies straight away
		animation_run(self, 120, 90, acSpawnerAppear)
			.set_rotation_distance(360)
			.add_frame_trigger(6, function() {
				if (GLOBALDATA.enemy_count < 3)
					spawn_enemy();
			}, true)
			.add_finished_trigger(function() {
				states.set_state("do_spawning");
			});
	}
)
.add_state("do_spawning",
	function(sdata) {
		sdata.running_anim.resume();
	}
)
.add_state("pause") // pause is an empty state, may continue through ESC
.add_state("ev:key_press_vk_escape",
	function(sdata) {
		sdata.running_anim.set_paused(!sdata.running_anim.is_paused());
		return (sdata.running_anim.is_paused() ? "pause" : "do_spawning");
	}
)
.set_state("appear");

