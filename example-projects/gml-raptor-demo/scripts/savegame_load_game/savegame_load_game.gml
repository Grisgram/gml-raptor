/*
	Utility methods to work with savegame files.
	All objects that have [Saveable] as their parent in the inheritance chain will be
	saved to the save game as long as the declared instance variable [add_to_savegame] is true (which is the default).
	
	(c)2022 Mike Barthold, indievidualgames, aka @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

/// @function					savegame_load_game(filename, cryptkey = "")
/// @description				Loads a previously saved game state (see savegame_save_game).
/// @param {string} filename	Relative path inside the working_folder where to find the file
/// @param {string=""} cryptkey	Optional. The same key that has been used to encrypt the file.
///								If not provided, the file is expected to be plain text (NOT RECOMMENDED!).
/// @returns {bool}				True, if the game loaded successfully or false, if not.
function savegame_load_game(filename, cryptkey = "") {
	
	var savegame = cryptkey == "" ? file_read_struct_plain(filename) : file_read_struct_encrypted(filename,cryptkey);
	if (savegame == undefined) {
		log("*ERROR* Could not load savegame '" + filename + "'!");
		return false;
	}
	
	log(sprintf("[----- LOADING GAME FROM '{0}' ({1}) -----]", filename, cryptkey == "" ? "plain text" : "encrypted"));
	SAVEGAME_LOAD_IN_PROGRESS = true;
	
	// load engine data
	var engine = variable_struct_get(savegame, __SAVEGAME_ENGINE_HEADER);
	random_set_seed(variable_struct_get(engine, __SAVEGAME_ENGINE_SEED));
	
	// load global data
	GLOBALDATA = variable_struct_get(savegame, __SAVEGAME_GLOBAL_DATA_HEADER);
	
	// load all race tables
	var race = variable_struct_get(savegame, __SAVEGAME_RACE_HEADER);
	var racetablenames = variable_struct_get_names(race);
	for (var i = 0; i < array_length(racetablenames); i++) {
		race_add_table(racetablenames[i], variable_struct_get(race, racetablenames[i]));
	}
	
	// load the structs
	__savegame_clear_structs();
	__SAVEGAME_STRUCTS = variable_struct_get(savegame, __SAVEGAME_STRUCT_HEADER);
	
	// recreate object instances
	with (Saveable) if (add_to_savegame) instance_destroy();
	
	var awaiting_race_controller_link = {};
	
	var instances = variable_struct_get(savegame, __SAVEGAME_OBJECT_HEADER);
	var names = variable_struct_get_names(instances);
	for (var i = 0; i < array_length(names); i++) {
		var inst	= variable_struct_get(instances, names[i]);
		var obj		= variable_struct_get(inst, __SAVEGAME_OBJ_PROP_OBJ);
		var lname	= variable_struct_get(inst, __SAVEGAME_OBJ_PROP_LAYER);
		var ldepth  = variable_struct_get(inst, __SAVEGAME_OBJ_PROP_DEPTH);
		var xpos	= variable_struct_get(inst, __SAVEGAME_OBJ_PROP_X);
		var ypos	= variable_struct_get(inst, __SAVEGAME_OBJ_PROP_Y);
		
		var asset_idx = asset_get_index(obj);
		
		var created = lname != -1 ? 
			instance_create_layer(xpos,ypos,lname,asset_idx) : 
			instance_create_depth(xpos,ypos,ldepth,asset_idx);
		
		with (created) {
			direction		= variable_struct_get(inst, __SAVEGAME_OBJ_PROP_DIR);
			speed			= variable_struct_get(inst, __SAVEGAME_OBJ_PROP_SPD);
			sprite_index	= variable_struct_get(inst, __SAVEGAME_OBJ_PROP_SPRITE); 
			image_index		= variable_struct_get(inst, __SAVEGAME_OBJ_PROP_IMAGE); 
			image_speed		= variable_struct_get(inst, __SAVEGAME_OBJ_PROP_ISPEED);
			image_alpha		= variable_struct_get(inst, __SAVEGAME_OBJ_PROP_ALPHA); 
			image_angle		= variable_struct_get(inst, __SAVEGAME_OBJ_PROP_ANGLE); 
			image_blend		= variable_struct_get(inst, __SAVEGAME_OBJ_PROP_BLEND); 
			image_xscale	= variable_struct_get(inst, __SAVEGAME_OBJ_PROP_XSCALE); 
			image_yscale	= variable_struct_get(inst, __SAVEGAME_OBJ_PROP_YSCALE);
			visible			= variable_struct_get(inst, __SAVEGAME_OBJ_PROP_VIS);
			persistent		= variable_struct_get(inst, __SAVEGAME_OBJ_PROP_PERS);
			solid			= variable_struct_get(inst, __SAVEGAME_OBJ_PROP_SOLID);

			// all instances add themselves to the instance list for link restore
			var cid = variable_struct_get(inst, __SAVEGAME_OBJ_PROP_ID);
			variable_struct_set(__SAVEGAME_INSTANCES, string(cid), self); // add me to the loaded list

			// auto-load variables of platform objects
			// RaceController
			if (obj == "RaceController" || object_is_ancestor(object_index, RaceController)) {
				log("Restoring RaceController...");
				race_table_file_name = variable_struct_get(inst, "race_table_file_name");
			}
				
			// RaceTable
			if (obj == "RaceTable" || object_is_ancestor(object_index, RaceTable)) {
				log("Restoring RaceTable...");
				race_table_name		= variable_struct_get(inst, "race_table_name");
				race_drop_on_layer	= variable_struct_get(inst, "race_drop_on_layer");
				set_table(race_table_name);
				// restore of the controller id is a bit tricky...
				// for now, just save the id and myself to a struct
				// when all instances are loaded, assign it
				var cid = variable_struct_get(inst, "race_controller");
				if (cid == noone)
					race_controller = noone;
				else {
					variable_struct_set(awaiting_race_controller_link, string(cid), self);
				}
			}

			if (variable_struct_exists(inst, __SAVEGAME_DATA_HEADER)) {
				if (variable_instance_exists(self, __SAVEGAME_ONLOADING_NAME)) {
					var data = variable_struct_get(inst, __SAVEGAME_DATA_HEADER);
					__SAVEGAME_ONLOADING_FUNCTION(data);
				} else
					log("*ERROR* Object '" + obj + "' has savegame data but does not offer a '" + __SAVEGAME_ONSAVING_FUNCTION + "' function!");
			}
		}		
	}
	
	// Now all instances are loaded... restore object links
	// RaceTable <-> RaceController
	log("Restoring RaceController links...");
	var tables = variable_struct_get_names(awaiting_race_controller_link);
	for (var tbl = 0; tbl < array_length(tables); tbl++) {
		var cid = tables[tbl];
		var tblinst = variable_struct_get(awaiting_race_controller_link, cid);
		if (variable_struct_exists(__SAVEGAME_INSTANCES, cid)) {
			tblinst.race_controller = variable_struct_get(__SAVEGAME_INSTANCES, cid);
			log("Successfully restored RaceController link.");
			tblinst.set_table(tblinst.race_table_name); // Ensure the table is set correct now
		} else {
			log("*ERROR* Could not restore RaceController link: ID " + cid + " not found!");
		}
	}

	log("Restoring object instance pointers...");
	__savegame_restore_pointers(savegame);

	SAVEGAME_LOAD_IN_PROGRESS = false;

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

	log("[----- LOADING GAME FINISHED -----]");

	return true;
}
