/*
    Versioned Struct Base Class
	
	ALL data files (profiles, settings, achievements, save games)
	MUST derive from this class to handle game updates and new versions to upgrade.
	
	When loaded, a compare is done between the "file_version" and the SAVE_GAME_VERSION.
	If the SAVE_GAME_VERSION is higher, the upgrade script will be called, if it exists.

	Make sure, you read the documentation at
	https://github.com/Grisgram/gml-raptor/wiki/Savegame-Versioning
*/

function VersionedDataStruct() constructor {
	construct(VersionedDataStruct);
	
	// only add the receiver if we get loaded from a savegame currently
	if (SAVEGAME_LOAD_IN_PROGRESS)
		BROADCASTER.add_receiver(self, $"game_load_{name_of(self)}", __RAPTOR_BROADCAST_SAVEGAME_VERSION_CHECK, 
			function(bc) {
				var file_version = bc.data.file_version;
				if (SAVEGAME_FILE_VERSION > file_version) {
					for (var i = file_version + 1; i <= SAVEGAME_FILE_VERSION; i++) {
						var method_name = sprintf(SAVEGAME_UPGRADE_METHOD_PATTERN, i);
						if (vsget(self, method_name) != undefined) {
							ilog($"Upgrading struct {name_of(self)} to version {i}");
							invoke_if_exists(self, method_name);
						}
					}
				}
				return true; // remove the receiver, game load only happens once per instance lifetime
			}
		);
}