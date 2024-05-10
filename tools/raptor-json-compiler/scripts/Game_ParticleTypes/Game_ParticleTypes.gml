/*
    all particle types
	
	If the current RoomController has one or more layers defined in its
	"particle_layer_names" instance variable, then 	this function gets called 
	at room_start to set up particles used in this room.
	
	HINT: if you have lots of particles and only some of them are used in
	any specific room, you should use "if (room == rm...) " statements in this
	method to set up only those particles used in the active room you really need.
	
	How to set up "particle_layer_names":
	* If you need only one layer to render your particles, just set it to a string
	  value which holds the name of the layer, like "Particles_Layer".
	* If you have several layers of particles (like background and foreground particles),
	  you may also set the variable to a string array, like
	  ["Particles_Back", "Particles_Fore"]
	
	For more information, consult the raptor wiki about the particle system:
	
	
	In any case, all layers named here must exist at design time in the room or the game
	will crash!
*/
function setup_particle_types() {
	


}