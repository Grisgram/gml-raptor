/// @description savegame versioning

// Inherit the parent event
event_inherited();

// Demo implementation of savegame versioning.
// These methods will be invoked when the game loads a savegame
// with a lower version.
savegame_upgrade_v2 = function() {
	log($"-- running upgrade 2 --");
}

savegame_upgrade_v4 = function() {
	log($"-- running upgrade 4 --");
}
