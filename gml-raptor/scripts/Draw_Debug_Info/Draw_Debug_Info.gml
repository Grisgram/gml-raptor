/*
	Invoked in every end_draw event from the base room controller, if all of these conditions are met:
	
	- The current RoomController object is a child of RoomController and is visible
	- DEBUG_MODE_ACTIVE = true; (activates toggling debug info with the F12 key)
	- global.__DEBUG_SHOWN is true (toggled by the F12 key)
	
	(c)2022 Mike Barthold, risingdemons/indievidualgames, aka @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

/// @function		drawDebugInfo()
function drawDebugInfo() {
	// This is a demo debug output when you press F12 to print the size of the processing queues of the active RoomController
	draw_text(16,16, sprintf("Statemachines: {0}\nAnimations: {1}", STATEMACHINES.size(), ANIMATIONS.size()));
}
