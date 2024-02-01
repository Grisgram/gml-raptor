/*
	Utility methods to work with savegame files.
	All objects that have [Saveable] as their parent in the inheritance chain will be
	saved to the save game as long as the declared instance variable [add_to_savegame] is true (which is the default).
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

/// @function					savegame_save_game(filename, cryptkey = "")
/// @description				Saves the entire game state to a file.
///								See docu in Saveable object for full documentation.
/// @param {string} filename	Relative path inside the working_folder where to save the file
/// @param {string=""} cryptkey	Optional. The key to use to encrypt the file.
///								If not provided, the file is written in plain text (NOT RECOMMENDED!).
/// @param {bool=false} data_only	If set to true, no instances will be saved, only GLOBALDATA, structs and race tables
function savegame_save_game(filename, cryptkey = "", data_only = false) {

	if (!string_is_empty(SAVEGAME_FOLDER) && !string_starts_with(filename, SAVEGAME_FOLDER)) filename = __ensure_savegame_folder_name() + filename;
	ilog($"[----- SAVING GAME TO '{filename}' ({(cryptkey == "" ? "plain text" : "encrypted")}) {(data_only ? "(data only) " : "")}-----]");
	
	SAVEGAME_SAVE_IN_PROGRESS = true;
	var savegame = {};
	
	// First things first: The Engine data
	var engine = {};
	variable_struct_set(engine, __SAVEGAME_ENGINE_SEED, random_get_seed());
	variable_struct_set(engine, __SAVEGAME_ENGINE_VERSION, SAVEGAME_FILE_VERSION);
	variable_struct_set(engine, __SAVEGAME_ENGINE_ROOM_NAME, room_get_name(room));
	variable_struct_set(savegame, __SAVEGAME_ENGINE_HEADER, engine);
	
	// save global data
	variable_struct_set(savegame, __SAVEGAME_GLOBAL_DATA_HEADER, GLOBALDATA);

	// Then, add all race tables to the save game
	var race = {};
	variable_struct_set(savegame, __SAVEGAME_RACE_HEADER, race);
	var racetablenames = race_get_table_names();
	for (var i = 0; i < array_length(racetablenames); i++) {
		variable_struct_set(race, racetablenames[i], race_get_table(racetablenames[i]));
	}
	
	// Then add all custom structs that shall be saved
	variable_struct_set(savegame, __SAVEGAME_STRUCT_HEADER, __SAVEGAME_STRUCTS);
	
	var instances = {};
	var cnt = 0;
	variable_struct_set(savegame, __SAVEGAME_OBJECT_HEADER, instances);
	if (!data_only) {
		with (Saveable) {
			if (add_to_savegame) {
				var instname = __SAVEGAME_INSTANCE_PREFIX + string(cnt);
				var obj = object_get_name(object_index);
				var instdata = {
					__SAVEGAME_OBJ_PROP_OBJ			: obj,
					__SAVEGAME_OBJ_PROP_ID			: real(id),
					__SAVEGAME_OBJ_PROP_X			: x,
					__SAVEGAME_OBJ_PROP_Y			: y,
					__SAVEGAME_OBJ_PROP_DIR			: direction,
					__SAVEGAME_OBJ_PROP_SPD			: speed,
					__SAVEGAME_OBJ_PROP_LAYER		: layer == -1 ? -1 : layer_get_name(layer),
					__SAVEGAME_OBJ_PROP_DEPTH		: depth,
					__SAVEGAME_OBJ_PROP_VIS			: visible,
					__SAVEGAME_OBJ_PROP_PERS		: persistent,
					__SAVEGAME_OBJ_PROP_SOLID		: solid,
					__SAVEGAME_OBJ_PROP_SPRITE_NAME : (sprite_index != -1 ? sprite_get_name(sprite_index) : undefined),
					__SAVEGAME_OBJ_PROP_SPRITE		: sprite_index,
					__SAVEGAME_OBJ_PROP_IMAGE		: (sprite_index != -1 ? image_index : 0),
					__SAVEGAME_OBJ_PROP_ISPEED		: image_speed,
					__SAVEGAME_OBJ_PROP_ALPHA		: image_alpha,
					__SAVEGAME_OBJ_PROP_ANGLE		: image_angle,
					__SAVEGAME_OBJ_PROP_BLEND		: image_blend,
					__SAVEGAME_OBJ_PROP_XSCALE		: image_xscale,
					__SAVEGAME_OBJ_PROP_YSCALE		: image_yscale,
				}
				// auto-save variables of platform objects
				// RaceController
				if (obj == "RaceController" || object_is_ancestor(object_index, RaceController))
					variable_struct_set(instdata, "race_table_file_name", race_table_file_name);
				
				// RaceTable
				if (obj == "RaceTable" || object_is_ancestor(object_index, RaceTable)) {
					variable_struct_set(instdata, "race_table_name",		race_table_name);
					variable_struct_set(instdata, "race_drop_on_layer",		race_drop_on_layer);
				
					// save the current instance id to find it later when loading
					var cid = race_controller == noone ? noone : real(race_controller.id);
					variable_struct_set(instdata, "race_controller", cid);
				}
			
			
				if (!variable_instance_exists(self, __SAVEGAME_DATA_HEADER))
					variable_instance_set(self, __SAVEGAME_DATA_HEADER, {});
				
				if (!variable_instance_exists(data, "__raptordata"))
					__RAPTORDATA = {};
			
				event_user(savegame_event.onGameSaving);
				if (variable_instance_exists(self, __SAVEGAME_ONSAVING_NAME) &&
					variable_instance_get(self, __SAVEGAME_ONSAVED_NAME) != undefined)
					__SAVEGAME_ONSAVING_FUNCTION();
			
				if (variable_instance_exists(self, __SAVEGAME_DATA_HEADER) &&
					is_struct(variable_instance_get(self, __SAVEGAME_DATA_HEADER)))
						variable_struct_set(instdata, __SAVEGAME_DATA_HEADER, data);
				else
					variable_struct_set(instdata, __SAVEGAME_DATA_HEADER, {});
				
				variable_struct_set(instances,instname,instdata);
				cnt++;
			}
		}
	}
	
	ilog($"Removing object instance pointers...");
	var struct_to_save = __savegame_remove_pointers(savegame);
	
	file_write_struct(filename, struct_to_save, cryptkey);		
	SAVEGAME_SAVE_IN_PROGRESS = false;

	// invoke the post event
	if (!data_only) {
		with (Saveable) {
			if (add_to_savegame && variable_instance_exists(self, __SAVEGAME_ONSAVED_NAME))
				__SAVEGAME_ONSAVED_FUNCTION();
		}
	}
	
	ilog($"[----- SAVING GAME FINISHED -----]");

}
