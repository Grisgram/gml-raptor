/*
	Utility methods to work with savegame files.
	All objects that have [Saveable] as their parent in the inheritance chain will be
	saved to the save game as long as the declared instance variable [add_to_savegame] is true (which is the default).
	
	(c)2022 Mike Barthold, indievidualgames, aka @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

// STATUS/PROGRESS GLOBALS
#macro SAVEGAME_SAVE_IN_PROGRESS		global.__savegame_save_in_progress
#macro SAVEGAME_LOAD_IN_PROGRESS		global.__savegame_load_in_progress

// The GLOBALDATA struct is persisted with the savegame
#macro GLOBALDATA			global.__game_data
GLOBALDATA = {};

// holds custom structs for the savegame
#macro __SAVEGAME_STRUCTS				global.__savegame_structs
#macro __SAVEGAME_INSTANCES				global.__savegame_instances

#macro __SAVEGAME_GLOBAL_DATA_HEADER	"global_data"
#macro __SAVEGAME_RACE_HEADER			"race_tables"
#macro __SAVEGAME_OBJECT_HEADER			"instances"
#macro __SAVEGAME_STRUCT_HEADER			"structs"
#macro __SAVEGAME_ENGINE_HEADER			"engine"
#macro __SAVEGAME_INSTANCE_PREFIX		"inst"
#macro __SAVEGAME_DATA_HEADER			"data"
										
#macro __SAVEGAME_OBJ_PROP_OBJ			"obj"
#macro __SAVEGAME_OBJ_PROP_ID			"id"
#macro __SAVEGAME_OBJ_PROP_X			"x"
#macro __SAVEGAME_OBJ_PROP_Y			"y"
#macro __SAVEGAME_OBJ_PROP_DIR			"direction"
#macro __SAVEGAME_OBJ_PROP_SPD			"speed"
#macro __SAVEGAME_OBJ_PROP_LAYER		"layer"
#macro __SAVEGAME_OBJ_PROP_DEPTH		"depth"
#macro __SAVEGAME_OBJ_PROP_VIS			"visible"
#macro __SAVEGAME_OBJ_PROP_PERS			"persistent"
#macro __SAVEGAME_OBJ_PROP_SOLID		"solid"
#macro __SAVEGAME_OBJ_PROP_SPRITE		"sprite_index"
#macro __SAVEGAME_OBJ_PROP_IMAGE		"image_index"
#macro __SAVEGAME_OBJ_PROP_ISPEED		"image_speed"
#macro __SAVEGAME_OBJ_PROP_ALPHA		"image_alpha"
#macro __SAVEGAME_OBJ_PROP_ANGLE		"image_angle"
#macro __SAVEGAME_OBJ_PROP_BLEND		"image_blend"
#macro __SAVEGAME_OBJ_PROP_XSCALE		"image_xscale"
#macro __SAVEGAME_OBJ_PROP_YSCALE		"image_yscale"
										
#macro __SAVEGAME_ENGINE_SEED			"seed"
										
#macro __SAVEGAME_ONSAVING_NAME			"onGameSaving"
#macro __SAVEGAME_ONSAVED_NAME			"onGameSaved"
#macro __SAVEGAME_ONLOADING_NAME		"onGameLoading"
#macro __SAVEGAME_ONLOADED_NAME			"onGameLoaded"
										
#macro __SAVEGAME_ONSAVING_FUNCTION		onGameSaving
#macro __SAVEGAME_ONSAVED_FUNCTION		onGameSaved
#macro __SAVEGAME_ONLOADING_FUNCTION	onGameLoading
#macro __SAVEGAME_ONLOADED_FUNCTION		onGameLoaded

enum savegame_event {
	onGameSaving = 14,
	onGameLoaded = 15,
}

#region LOAD GAME
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
#endregion

#region SAVE GAME
/// @function					savegame_save_game(filename, cryptkey = "")
/// @description				Saves the entire game state to a file.
///								See docu in Saveable object for full documentation.
/// @param {string} filename	Relative path inside the working_folder where to save the file
/// @param {string=""} cryptkey	Optional. The key to use to encrypt the file.
///								If not provided, the file is written in plain text (NOT RECOMMENDED!).
function savegame_save_game(filename, cryptkey = "") {

	log(sprintf("[----- SAVING GAME TO '{0}' ({1}) -----]", filename, cryptkey == "" ? "plain text" : "encrypted"));
	SAVEGAME_SAVE_IN_PROGRESS = true;
	var savegame = {};
	
	// First things first: The Engine data
	var engine = {};
	variable_struct_set(engine, __SAVEGAME_ENGINE_SEED, random_get_seed());
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
	with (Saveable) {
		if (add_to_savegame) {
			var instname = __SAVEGAME_INSTANCE_PREFIX + string(cnt);
			var obj = object_get_name(object_index);
			var instdata = {
				__SAVEGAME_OBJ_PROP_OBJ		: obj,
				__SAVEGAME_OBJ_PROP_ID		: real(id),
				__SAVEGAME_OBJ_PROP_X		: x,
				__SAVEGAME_OBJ_PROP_Y		: y,
				__SAVEGAME_OBJ_PROP_DIR		: direction,
				__SAVEGAME_OBJ_PROP_SPD		: speed,
				__SAVEGAME_OBJ_PROP_LAYER	: layer_get_name(layer),
				__SAVEGAME_OBJ_PROP_DEPTH	: depth,
				__SAVEGAME_OBJ_PROP_VIS		: visible,
				__SAVEGAME_OBJ_PROP_PERS	: persistent,
				__SAVEGAME_OBJ_PROP_SOLID	: solid,
				__SAVEGAME_OBJ_PROP_SPRITE	: sprite_index,
				__SAVEGAME_OBJ_PROP_IMAGE	: image_index,
				__SAVEGAME_OBJ_PROP_ISPEED	: image_speed,
				__SAVEGAME_OBJ_PROP_ALPHA	: image_alpha,
				__SAVEGAME_OBJ_PROP_ANGLE	: image_angle,
				__SAVEGAME_OBJ_PROP_BLEND	: image_blend,
				__SAVEGAME_OBJ_PROP_XSCALE	: image_xscale,
				__SAVEGAME_OBJ_PROP_YSCALE	: image_yscale,
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
				var cid = race_controller == noone ? noone : race_controller.id;
				variable_struct_set(instdata, "race_controller", cid);
			}
			
			event_user(savegame_event.onGameSaving);
			if (variable_instance_exists(self, __SAVEGAME_ONSAVING_NAME)) {
				var data = __SAVEGAME_ONSAVING_FUNCTION();
				if (data != undefined) {
					if (is_struct(data))
						variable_struct_set(instdata, __SAVEGAME_DATA_HEADER, data);
					else
						log("*ERROR* Function '" + __SAVEGAME_ONSAVING_FUNCTION + "' returned a non-struct data value!");
				}
			}

			variable_struct_set(instances,instname,instdata);
			cnt++;
		}
	}
	
	if (cryptkey == "")
		file_write_struct_plain(filename,savegame);
	else
		file_write_struct_encrypted(filename,savegame,cryptkey);
		
	SAVEGAME_SAVE_IN_PROGRESS = false;

	// invoke the post event
	with (Saveable) {
		if (add_to_savegame && variable_instance_exists(self, __SAVEGAME_ONSAVED_NAME))
			__SAVEGAME_ONSAVED_FUNCTION();
	}
	
	log("[----- SAVING GAME FINISHED -----]");

}
#endregion

#region STRUCTS
/// @function					savegame_add_struct(name, struct)
/// @description				Adds any custom struct to the save game.
///								Can be retrieved after loading through savegame_get_struct(name).
/// @param {string} name		The name to reference this struct.
/// @param {struct} struct		The struct to save.
function savegame_add_struct(name, struct) {
	variable_struct_set(__SAVEGAME_STRUCTS, name, struct);
}

/// @function					savegame_remove_struct(name)
/// @description				Removes any custom struct from the save game.
/// @param {string} name		The name of the struct. If it does not exist, it is silently ignored.
function savegame_remove_struct(name) {
	if (variable_struct_exists(__SAVEGAME_STRUCTS, name))
		variable_struct_remove(__SAVEGAME_STRUCTS, name);
}

/// @function					savegame_struct_exists(name)
/// @description				Checks whether a specified struct exists in the savegame.
/// @param {string} name		The name of the struct to find.
/// @returns {bool}				True, if the struct exists or false, if not.
function savegame_struct_exists(name) {
	return variable_struct_exists(__SAVEGAME_STRUCTS, name);
}

/// @function					savegame_get_struct(name)
/// @description				Retrieves the specified struct from the savegame.
/// @param {string} name		The name of the struct. If it does not exist, [undefined] is returned.
/// @returns {struct}			The struct or [undefined], if it does not exist.
function savegame_get_struct(name) {
	return variable_struct_get(__SAVEGAME_STRUCTS, name);
}

/// @function					savegame_get_struct_names()
/// @description				Gets all stored struct names in the savegame.
/// @returns {array}			All struct names in the savegame
function savegame_get_struct_names() {
	return variable_struct_get_names(__SAVEGAME_STRUCTS);
}

/// @function					__savegame_clear_structs()
/// @description				Clears ALL savegame structs (custom structs and instances)
function __savegame_clear_structs() {
	__SAVEGAME_STRUCTS = {};
	__SAVEGAME_INSTANCES = {}; 
}
#endregion

#region INSTANCES
/// @function					savegame_get_instance_names()
/// @description				Gets all stored instance names (= IDs) in the savegame.
/// @returns {array}			All instance names in the savegame
function savegame_get_instance_names() {
	return variable_struct_get_names(__SAVEGAME_INSTANCES);
}

/// @function						savegame_get_instance_of(old_instance_id)
/// @description					Retrieves the specified instance from the savegame.
/// @param {string} old_instance_id	The old id (when the game was saved) of the object.
/// @returns {struct}				The instance or [noone], if it does not exist.
function savegame_get_instance_of(old_instance_id) {
	if (!is_string(old_instance_id)) old_instance_id = string(old_instance_id);
	if (variable_struct_exists(__SAVEGAME_INSTANCES, old_instance_id))
		return variable_struct_get(__SAVEGAME_INSTANCES, old_instance_id);
	else
		return noone;
}

/// @function					savegame_get_instance_array_of(id_array)
/// @description				Maps an array of object ids to an array of instances.
///								NOTE: Only works with stored ids of savegames!
/// @param {array} id_array		An array of object ids.
/// @returns {array}			Returns an array containing the ids of the instances (in the same order).
function savegame_get_instance_array_of(id_array) {
	var rv = array_create(array_length(id_array));
	
	for (var i = 0; i < array_length(id_array); i++) {
		rv[i] = id_array[i] != undefined ? savegame_get_instance_of(id_array[i]) : undefined;
	}
	
	return rv;
}

/// @function					savegame_get_id_array_of(instance_array)
/// @description				Maps an array of object instances to an array of their id's only.
///								Useful if you want to persist linked objects in a savegame.
/// @param {array} instance_array	An array of object instances.
/// @returns {array}			Returns an array containing the instances (in the same order).
function savegame_get_id_array_of(instance_array) {
	var rv = array_create(array_length(instance_array));
	
	for (var i = 0; i < array_length(instance_array); i++) {
		rv[i] = instance_array[i] != undefined ? instance_array[i].id : undefined;
	}
	
	return rv;
}
#endregion

// initialize the structs and variables
SAVEGAME_LOAD_IN_PROGRESS = false;
SAVEGAME_SAVE_IN_PROGRESS = false;
__savegame_clear_structs();