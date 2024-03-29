/*
	Utility methods to work with savegame files.
	All objects that have [Saveable] as their parent in the inheritance chain will be
	saved to the save game as long as the declared instance variable [add_to_savegame] is true (which is the default).
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

/// @function					savegame_load_game(filename, cryptkey = "")
/// @description				Loads a previously saved game state (see savegame_save_game).
/// @param {string} filename	Relative path inside the working_folder where to find the file
/// @param {string=""} cryptkey	Optional. The same key that has been used to encrypt the file.
///								If not provided, the file is expected to be plain text (NOT RECOMMENDED!).
/// @param {bool=false} data_only	If set to true, no instances will be loaded, only GLOBALDATA, structs and race tables
/// @returns {bool}				True, if the game loaded successfully or false, if not.
function savegame_load_game(filename, cryptkey = "", data_only = false) {
	
	if (!string_is_empty(SAVEGAME_FOLDER) && !string_starts_with(filename, SAVEGAME_FOLDER)) filename = __ensure_savegame_folder_name() + filename;
	ilog($"[----- LOADING GAME FROM '{filename}' ({(cryptkey == "" ? "plain text" : "encrypted")}) {(data_only ? "(data only) " : "")}-----]");
	
	var savegame = file_read_struct(filename, cryptkey);
	if (savegame == undefined) {
		elog($"*ERROR* Could not load savegame '{filename}'!");
		return false;
	}

	SAVEGAME_LOAD_IN_PROGRESS = true;

	// prepare refstack
	var refstack = vsget(savegame, __SAVEGAME_REFSTACK_HEADER);
	refstack.savegame = savegame;
	refstack.recover = method(refstack, function(_name, _from = undefined) {
		_from = _from ?? savegame;
		var rv = _from[$ _name];
		if (is_string(rv) && string_starts_with(rv, __SAVEGAME_STRUCT_REF_MARKER)) {
			rv = self[$ rv];
			_from[$ _name] = rv;
			var names = struct_get_names(rv);
			for (var i = 0, len = array_length(names); i < len; i++) 
				recover(names[@i], rv);
		}
		return rv;
	});

	// load engine data
	var engine = refstack.recover(__SAVEGAME_ENGINE_HEADER);
	random_set_seed(struct_get(engine, __SAVEGAME_ENGINE_SEED));
	var loaded_version = vsgetx(engine, __SAVEGAME_ENGINE_VERSION, 1);
	
	// restore room
	var current_room_name = room_get_name(room);
	var room_name = vsgetx(engine, __SAVEGAME_ENGINE_ROOM_NAME, current_room_name);
	if (room_name != current_room_name) {
		ilog($"Switching to room '{room_name}'");
		room_goto(asset_get_index(room_name));
	}
	
	// load global data
	GLOBALDATA = refstack.recover(__SAVEGAME_GLOBAL_DATA_HEADER);
	
	// load all race tables
	var race = refstack.recover(__SAVEGAME_RACE_HEADER);
	var racetablenames = struct_get_names(race);
	for (var i = 0; i < array_length(racetablenames); i++) {
		race_add_table(racetablenames[i], struct_get(race, racetablenames[i]));
	}
	
	// load the structs
	__savegame_clear_structs();
	__SAVEGAME_STRUCTS = refstack.recover(__SAVEGAME_STRUCT_HEADER);
	
	// If data_only is specified, we do skip over the instance part
	if (!data_only) {
		// recreate object instances
		with (Saveable) if (add_to_savegame) instance_destroy();
	
		var restorestack = {};
		var instances = refstack.recover(__SAVEGAME_OBJECT_HEADER);
		var names = struct_get_names(instances);
		for (var i = 0, len = array_length(names); i < len; i++) {
			var inst	= vsget(instances, names[i]);
			var obj		= vsget(inst, __SAVEGAME_OBJ_PROP_OBJ);
			// since 2023.1 there's an empty struct added silently to each serialized file.
			// we need to skip this empty mess
			if (obj == undefined || obj == -1) continue; 
			
			var lname	= vsget(inst, __SAVEGAME_OBJ_PROP_LAYER);
			var ldepth  = vsget(inst, __SAVEGAME_OBJ_PROP_DEPTH, 0);
			var xpos	= vsget(inst, __SAVEGAME_OBJ_PROP_X, 0);
			var ypos	= vsget(inst, __SAVEGAME_OBJ_PROP_Y, 0);
		
			var asset_idx = asset_get_index(obj);
		
			var created = (lname != -1 && !is_null(lname)) ? 
				instance_create_layer(xpos,ypos,lname,asset_idx) : 
				instance_create_depth(xpos,ypos,ldepth,asset_idx);
		
			with (created) {
				direction		= vsget(inst, __SAVEGAME_OBJ_PROP_DIR, 0);
				speed			= vsget(inst, __SAVEGAME_OBJ_PROP_SPD, 0);
				var sprname		= vsget(inst, __SAVEGAME_OBJ_PROP_SPRITE_NAME);
				sprite_index	= sprname != undefined ?
								  asset_get_index(sprname) :
								  vsget(inst, __SAVEGAME_OBJ_PROP_SPRITE);
				image_index		= vsget(inst, __SAVEGAME_OBJ_PROP_IMAGE, 0); 
				image_speed		= vsget(inst, __SAVEGAME_OBJ_PROP_ISPEED, 1);
				image_alpha		= vsget(inst, __SAVEGAME_OBJ_PROP_ALPHA, 1); 
				image_angle		= vsget(inst, __SAVEGAME_OBJ_PROP_ANGLE, 0); 
				image_blend		= vsget(inst, __SAVEGAME_OBJ_PROP_BLEND, c_white);
				image_xscale	= vsget(inst, __SAVEGAME_OBJ_PROP_XSCALE, 1); 
				image_yscale	= vsget(inst, __SAVEGAME_OBJ_PROP_YSCALE, 1);
				visible			= vsget(inst, __SAVEGAME_OBJ_PROP_VIS, true);
				persistent		= vsget(inst, __SAVEGAME_OBJ_PROP_PERS, false);
				solid			= vsget(inst, __SAVEGAME_OBJ_PROP_SOLID, false);

				// all instances add themselves to the instance list for link restore
				var cid = struct_get(inst, __SAVEGAME_OBJ_PROP_ID);
				struct_set(__SAVEGAME_INSTANCES, string(cid), self); // add me to the loaded list

				var loaded_data = struct_get(inst, __SAVEGAME_DATA_HEADER);
				__file_reconstruct_class(data, loaded_data, restorestack);
				
				// Savegame versioning
				if (SAVEGAME_FILE_VERSION > loaded_version) {
					for (var i = loaded_version + 1; i <= SAVEGAME_FILE_VERSION; i++) {
						var method_name = sprintf(SAVEGAME_UPGRADE_METHOD_PATTERN, i);
						if (variable_instance_exists(self, method_name) &&
							variable_instance_get(self, method_name) != undefined) {
							ilog($"{MY_NAME} Upgrading object to version {i}");
							self[$ method_name]();
						}
					}
				}
				
				if (vsget(self, __SAVEGAME_ONLOADING_NAME))
					__SAVEGAME_ONLOADING_FUNCTION();
				
			}		
		}
	
		// Now all instances are loaded... restore object links
		ilog($"Restoring object instance pointers...");
		struct_remove(savegame, __SAVEGAME_REFSTACK_HEADER);
		refstack = {};
		__savegame_restore_pointers(savegame, refstack);
	}
	
	SAVEGAME_LOAD_IN_PROGRESS = false;

	if (!data_only) {
		// invoke the post event
		var names = savegame_get_instance_names();
		for (var i = 0; i < array_length(names); i++) {
			var inst = savegame_get_instance_of(names[i]);
			with (inst) {
				if (variable_instance_exists(self, __SAVEGAME_ONLOADED_NAME)) 
					__SAVEGAME_ONLOADED_FUNCTION();
				event_user(savegame_event.onGameLoaded);
			}
		}
	}
	
	ilog($"[----- LOADING GAME FINISHED -----]");

	return true;
}
