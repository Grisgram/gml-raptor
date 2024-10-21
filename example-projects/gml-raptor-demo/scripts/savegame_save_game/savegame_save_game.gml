/*
	Utility methods to work with savegame files.
	All objects that have [Saveable] as their parent in the inheritance chain will be
	saved to the save game as long as the declared instance variable [add_to_savegame] is true (which is the default).
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

/// @func					savegame_save_game(filename, cryptkey = "")
/// @desc				Saves the entire game state to a file.
///								See docu in Saveable object for full documentation.
/// @param {string} filename	Relative path inside the working_folder where to save the file
/// @param {string=""} cryptkey	Optional. The key to use to encrypt the file.
///								If not provided, the file is written in plain text (NOT RECOMMENDED!).
/// @param {bool=false} data_only	If set to true, no instances will be saved, only GLOBALDATA and structs
function savegame_save_game(filename, cryptkey = "", data_only = false) {

	if (!string_is_empty(SAVEGAME_FOLDER) && !string_starts_with(filename, SAVEGAME_FOLDER)) filename = __ensure_savegame_folder_name() + filename;
	ilog($"[----- SAVING GAME TO '{filename}' ({(cryptkey == "" ? "plain text" : "encrypted")}) {(data_only ? "(data only) " : "")}-----]");
	ilog($"SaveGame File Version {SAVEGAME_FILE_VERSION}");
	SAVEGAME_SAVE_IN_PROGRESS = true;
	
	BROADCASTER.send(GAMECONTROLLER, __RAPTOR_BROADCAST_GAME_SAVING);
	
	if (vsget(GAMECONTROLLER, __SAVEGAME_ONSAVING_NAME)) with(GAMECONTROLLER) __SAVEGAME_ONSAVING_FUNCTION();
	if (vsget(ROOMCONTROLLER, __SAVEGAME_ONSAVING_NAME)) with(ROOMCONTROLLER) __SAVEGAME_ONSAVING_FUNCTION();
	
	var savegame = {};
	
	// First things first: The Engine data
	var engine = {};
	struct_set(engine,		__SAVEGAME_ENGINE_SEED		, random_get_seed());
	struct_set(engine,		__SAVEGAME_ENGINE_VERSION	, SAVEGAME_FILE_VERSION);
	struct_set(engine,		__SAVEGAME_ENGINE_ROOM_NAME	, room_get_name(room));
	struct_set(engine,		__SAVEGAME_ENGINE_COUNTUP_ID, global.__unique_count_up_id);
	struct_set(savegame,	__SAVEGAME_ENGINE_HEADER	, engine);
	
	// save global data
	struct_set(savegame, __SAVEGAME_GLOBAL_DATA_HEADER, GLOBALDATA);
	
	// Then add all custom structs that shall be saved
	struct_set(savegame, __SAVEGAME_STRUCT_HEADER, __SAVEGAME_STRUCTS);
	
	var instances = {};
	var cnt = 0;
	struct_set(savegame, __SAVEGAME_OBJECT_HEADER, instances);
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
					__SAVEGAME_OBJ_PROP_LAYER		: (layer == -1 ? -1 : layer_get_name(layer)),
					__SAVEGAME_OBJ_PROP_DEPTH		: depth,
					__SAVEGAME_OBJ_PROP_VIS			: visible,
					__SAVEGAME_OBJ_PROP_PERS		: persistent,
					__SAVEGAME_OBJ_PROP_SOLID		: solid,
					__SAVEGAME_OBJ_PROP_SPRITE_NAME : (sprite_index != -1 ? sprite_get_name(sprite_index) : undefined),
					__SAVEGAME_OBJ_PROP_SPRITE		: sprite_index,
					__SAVEGAME_OBJ_PROP_IMAGE		: (sprite_index != -1 ? (image_index??0) : 0),
					__SAVEGAME_OBJ_PROP_ISPEED		: image_speed,
					__SAVEGAME_OBJ_PROP_ALPHA		: image_alpha,
					__SAVEGAME_OBJ_PROP_ANGLE		: image_angle,
					__SAVEGAME_OBJ_PROP_BLEND		: image_blend,
					__SAVEGAME_OBJ_PROP_XSCALE		: image_xscale,
					__SAVEGAME_OBJ_PROP_YSCALE		: image_yscale,
				}
				
				vsgetx(self, __SAVEGAME_DATA_HEADER, {});
				
				event_user(savegame_event.onGameSaving);
				if (vsget(self, __SAVEGAME_ONSAVING_NAME))
					__SAVEGAME_ONSAVING_FUNCTION();
			
				if (is_struct(vsget(self, __SAVEGAME_DATA_HEADER)))
					instdata[$ __SAVEGAME_DATA_HEADER] = data;
				else
					instdata[$ __SAVEGAME_DATA_HEADER] = {};
				
				struct_set(instances,instname,instdata);
				cnt++;
			}
		}
	}
	
	ilog($"Removing object instance pointers...");
	var refstack = {};
	var struct_to_save = __savegame_remove_pointers(savegame, refstack);
	struct_to_save[$ __SAVEGAME_REFSTACK_HEADER] = refstack;
	
	return file_write_struct_async(filename, struct_to_save, cryptkey)
	.__raptor_data("only", data_only)
	.__raptor_finished(function(res, _buffer, _data) {
		SAVEGAME_SAVE_IN_PROGRESS = false;

		// invoke the post event
		if (!_data.only) {
			with (Saveable) {
				if (add_to_savegame && variable_instance_exists(self, __SAVEGAME_ONSAVED_NAME))
					__SAVEGAME_ONSAVED_FUNCTION(res);
			}
		}
	
		if (vsget(ROOMCONTROLLER, __SAVEGAME_ONSAVED_NAME)) with(ROOMCONTROLLER) __SAVEGAME_ONSAVED_FUNCTION(res);
		if (vsget(GAMECONTROLLER, __SAVEGAME_ONSAVED_NAME)) with(GAMECONTROLLER) __SAVEGAME_ONSAVED_FUNCTION(res);
	
		BROADCASTER.send(GAMECONTROLLER, __RAPTOR_BROADCAST_GAME_SAVED, { success: true });
		ilog($"[----- SAVING GAME FINISHED -----]");
	})
	.on_failed(function() {
		BROADCASTER.send(GAMECONTROLLER, __RAPTOR_BROADCAST_GAME_SAVED, { success: false });
		elog($"[----- SAVING GAME **FAILED** -----]");
	});

}
