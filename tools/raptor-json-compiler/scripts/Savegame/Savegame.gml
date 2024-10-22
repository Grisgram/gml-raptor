/*
	Utility methods to work with savegame files.
	All objects that have [Saveable] as their parent in the inheritance chain will be
	saved to the save game as long as the declared instance variable [add_to_savegame] is true (which is the default).
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

// STATUS/PROGRESS GLOBALS
#macro SAVEGAME_SAVE_IN_PROGRESS		global.__savegame_save_in_progress
#macro SAVEGAME_LOAD_IN_PROGRESS		global.__savegame_load_in_progress
#macro ENSURE_SAVEGAME					if (!variable_global_exists("__savegame_save_in_progress"))	global.__savegame_save_in_progress = false; \
										if (!variable_global_exists("__savegame_load_in_progress"))	global.__savegame_load_in_progress = false;

// Room change on load, state preserve
#macro __SAVEGAME_CONTINUE_LOAD_STATE	global.__savegame_load_state
__SAVEGAME_CONTINUE_LOAD_STATE			= undefined;

// The GLOBALDATA struct is persisted with the savegame
#macro GLOBALDATA			global.__global_data
#macro ENSURE_GLOBALDATA	if (!variable_global_exists("__global_data"))	global.__global_data = {};
ENSURE_GLOBALDATA;

// This macro is used internally on objects that push their own data
// into the savegame. __raptordata is the root of internal data structs
#macro ENSURE_RAPTORDATA	vsgetx(self, "data", {}); vsgetx(data, "__raptordata", {});
#macro __RAPTORDATA			data.__raptordata

// strings in this list will not be persisted in a savegame. see savegame_ignore(...)
#macro __SAVEGAME_IGNORE	"##_raptor_##.__savegame_ignored"

// holds custom structs for the savegame
#macro __SAVEGAME_STRUCTS				global.__savegame_structs
#macro __SAVEGAME_INSTANCES				global.__savegame_instances

#macro __SAVEGAME_GLOBAL_DATA_HEADER	"global_data"
#macro __SAVEGAME_OBJECT_HEADER			"instances"
#macro __SAVEGAME_STRUCT_HEADER			"structs"
#macro __SAVEGAME_REFSTACK_HEADER		"refstack"
#macro __SAVEGAME_ENGINE_HEADER			"engine"
#macro __SAVEGAME_INSTANCE_PREFIX		"inst"
#macro __SAVEGAME_DATA_HEADER			"data"
										
#macro __SAVEGAME_OBJ_PROP_OBJ			"obj"
#macro __SAVEGAME_OBJ_PROP_ID			"__raptor_savegame_ref_id"
#macro __SAVEGAME_OBJ_PROP_X			"x"
#macro __SAVEGAME_OBJ_PROP_Y			"y"
#macro __SAVEGAME_OBJ_PROP_DIR			"direction"
#macro __SAVEGAME_OBJ_PROP_SPD			"speed"
#macro __SAVEGAME_OBJ_PROP_LAYER		"layer"
#macro __SAVEGAME_OBJ_PROP_DEPTH		"depth"
#macro __SAVEGAME_OBJ_PROP_VIS			"visible"
#macro __SAVEGAME_OBJ_PROP_PERS			"persistent"
#macro __SAVEGAME_OBJ_PROP_SOLID		"solid"
#macro __SAVEGAME_OBJ_PROP_SPRITE_NAME	"__raptor_savegame_sprite_name"
#macro __SAVEGAME_OBJ_PROP_SPRITE		"sprite_index"
#macro __SAVEGAME_OBJ_PROP_IMAGE		"img_index"
#macro __SAVEGAME_OBJ_PROP_ISPEED		"image_speed"
#macro __SAVEGAME_OBJ_PROP_ALPHA		"image_alpha"
#macro __SAVEGAME_OBJ_PROP_ANGLE		"image_angle"
#macro __SAVEGAME_OBJ_PROP_BLEND		"image_blend"
#macro __SAVEGAME_OBJ_PROP_XSCALE		"image_xscale"
#macro __SAVEGAME_OBJ_PROP_YSCALE		"image_yscale"
										
#macro __SAVEGAME_ENGINE_SEED			"seed"
#macro __SAVEGAME_ENGINE_VERSION		"file_version"
#macro __SAVEGAME_ENGINE_ROOM_NAME		"room_name"
#macro __SAVEGAME_ENGINE_COUNTUP_ID		"countup_id"
										
#macro __SAVEGAME_ONSAVING_NAME			"onGameSaving"
#macro __SAVEGAME_ONSAVED_NAME			"onGameSaved"
#macro __SAVEGAME_ONLOADING_NAME		"onGameLoading"
#macro __SAVEGAME_ONLOADED_NAME			"onGameLoaded"

#macro __SAVEGAME_ONSAVING_FUNCTION		onGameSaving
#macro __SAVEGAME_ONSAVED_FUNCTION		onGameSaved
#macro __SAVEGAME_ONLOADING_FUNCTION	onGameLoading
#macro __SAVEGAME_ONLOADED_FUNCTION		onGameLoaded

#macro __SAVEGAME_REF_MARKER			"##_savegame_ref_##."
#macro __SAVEGAME_STRUCT_REF_MARKER		"##_savegame_structref_##."

enum savegame_event {
	onGameSaving = 14,
	onGameLoaded = 15,
}

#region STRUCTS
/// @func	savegame_ignore(_members...)
/// @desc	Mark members of this struct class to be ignored when saved.
///			Those members will not even persist their name in the savegame.
function savegame_ignore(_members) {
	for (var i = 0; i < argument_count; i++)
		self[$ __SAVEGAME_IGNORE] = string_concat(
			vsget(self, __SAVEGAME_IGNORE, "|"),
			argument[@i], "|"
		);
}

/// @func					savegame_add_struct(name, struct)
/// @desc				Adds any custom struct to the save game.
///								Can be retrieved after loading through savegame_get_struct(name).
/// @param {string} name		The name to reference this struct.
/// @param {struct} struct		The struct to save.
function savegame_add_struct(name, struct) {
	struct_set(__SAVEGAME_STRUCTS, name, struct);
}

/// @func					savegame_remove_struct(name)
/// @desc				Removes any custom struct from the save game.
/// @param {string} name		The name of the struct. If it does not exist, it is silently ignored.
function savegame_remove_struct(name) {
	if (variable_struct_exists(__SAVEGAME_STRUCTS, name))
		variable_struct_remove(__SAVEGAME_STRUCTS, name);
}

/// @func					savegame_struct_exists(name)
/// @desc				Checks whether a specified struct exists in the savegame.
/// @param {string} name		The name of the struct to find.
/// @returns {bool}				True, if the struct exists or false, if not.
function savegame_struct_exists(name) {
	return variable_struct_exists(__SAVEGAME_STRUCTS, name);
}

/// @func					savegame_get_struct(name)
/// @desc				Retrieves the specified struct from the savegame.
/// @param {string} name		The name of the struct. If it does not exist, [undefined] is returned.
/// @returns {struct}			The struct or [undefined], if it does not exist.
function savegame_get_struct(name) {
	return struct_get(__SAVEGAME_STRUCTS, name);
}

/// @func					savegame_get_struct_names()
/// @desc				Gets all stored struct names in the savegame.
/// @returns {array}			All struct names in the savegame
function savegame_get_struct_names() {
	return struct_get_names(__SAVEGAME_STRUCTS);
}

/// @func					__savegame_clear_structs()
/// @desc				Clears ALL savegame structs (custom structs and instances)
function __savegame_clear_structs() {
	__SAVEGAME_STRUCTS = {};
	__SAVEGAME_INSTANCES = {}; 
}
#endregion

#region INSTANCES
/// @func					savegame_get_instance_names()
/// @desc				Gets all stored instance names (= IDs) in the savegame.
/// @returns {array}			All instance names in the savegame
function savegame_get_instance_names() {
	return struct_get_names(__SAVEGAME_INSTANCES);
}

/// @func						savegame_get_instance_of(old_instance_id)
/// @desc					Retrieves the specified instance from the savegame.
/// @param {string} old_instance_id	The old id (when the game was saved) of the object.
/// @returns {struct}				The instance or [noone], if it does not exist.
function savegame_get_instance_of(old_instance_id) {
	if (!is_string(old_instance_id)) old_instance_id = string(old_instance_id);
	if (variable_struct_exists(__SAVEGAME_INSTANCES, old_instance_id))
		return struct_get(__SAVEGAME_INSTANCES, old_instance_id);
	else
		return noone;
}

/// @func					savegame_get_instance_array_of(id_array)
/// @desc				Maps an array of object ids to an array of instances.
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

/// @func					savegame_get_id_array_of(instance_array)
/// @desc				Maps an array of object instances to an array of their id's only.
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

/// @func savegame_exists(_filename)
/// @desc	Checks, whether the specified savegame exists. Takes the
///					SAVEGAME_FOLDER configuration path into account
function savegame_exists(_filename) {
	return file_exists_html_safe(string_concat(SAVEGAME_FOLDER, _filename));
}

function __ensure_savegame_folder_name() {
	var adder = "";
	if (!string_is_empty(SAVEGAME_FOLDER) && !string_ends_with(SAVEGAME_FOLDER, "/")) adder = "/";
	return string_concat(SAVEGAME_FOLDER, adder);
}

// initialize the structs and variables
SAVEGAME_LOAD_IN_PROGRESS = false;
SAVEGAME_SAVE_IN_PROGRESS = false;
__savegame_clear_structs();