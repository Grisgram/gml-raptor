/*
    The SkinManager holds all loaded ui skins in a ds_map and you can switch your ui on-the-fly.
	This is especially useful if your game has... epoches or other permanently changing states that
	demand different graphics for your ui.
*/

#macro UI_SKINS				global.__ui_skins
UI_SKINS = new UiSkinManager();

function UiSkinManager() constructor {
	construct("UiSkinManager");
	
	loaded_skins = ds_map_create();
	
	static load_skin = function(_skin_filename) {
	}
	

	/// @function add_skin(_skin)
	/// @description Add a skin from the code class. This function is for compile-time linked skins,
	///				 where all the skin graphics already exist as sprites in the project.
	///				 NOTE: If you added one of the skin prefabs to the project, the prefab skin class
	///				 will add itself upon game start, you don't have to call this manually in this case!
	static add_skin = function(_skin) {
		loaded_skins[? _skin.name] = _skin;
	}

}

