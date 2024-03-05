/*
    The SkinManager holds all loaded ui skins in a ds_map and you can switch your ui on-the-fly.
	This is especially useful if your game has... epoches or other permanently changing states that
	demand different graphics for your ui.
	
	*** NOTE *** UI SKINS are a future plan for raptor! This is work in progress 
	and will not be finished with the initial raptor3.0 release! ***
	
*/

#macro ENSURE_SKINS			if (!variable_global_exists("__ui_skins")) UI_SKINS = new UiSkinManager();
#macro UI_SKINS				global.__ui_skins
UI_SKINS = new UiSkinManager();

#macro __DEFAULT_UI_SKIN_NAME	"default"

function UiSkinManager() constructor {
	construct("UiSkinManager");
	
	_skins = {
	};
	
	active_skin = undefined;
	
	/// @function add_skin(_skin, _activate_now = false)
	static add_skin = function(_skin, _activate_now = false) {
		_skins[$ _skin.name] = _skin;
		ilog($"UiSkinManager registered skin '{_skin.name}'");
		if (_activate_now)
			activate_skin(_skin.name);
	}
	
	/// @function activate_skin(_skin_name)
	static activate_skin = function(_skin_name) {
		var sk = vsget(_skins, _skin_name);
		if (sk != undefined) {
			active_skin = sk;
			ilog($"UiSkinManager activated skin '{sk.name}'");
		} else {
			elog($"** ERROR ** UiSkinManager could not activate skin '{_skin_name}' (SKIN-NOT-FOUND)");
		}
	}
	
	/// @function remove_skin(_skin_name)
	static remove_skin = function(_skin_name) {
		if (_skin_name == __DEFAULT_UI_skin_NAME) {
			elog($"** ERROR ** UiSkinManager can not remove the '{__DEFAULT_UI_SKIN_NAME}' skin!");
			return;
		}
		if (vsget(_skins, _skin_name) != undefined) {
			variable_struct_remove(_skins, _skin_name);
			ilog($"UiSkinManager removed skin '{_skin_name}'");
		}
	}
	
	/// @function get_skin(_skin_name)
	static get_skin = function(_skin_name) {
		return vsget(_skins, _skin_name);
	}

}

ENSURE_LOGGER;
ENSURE_SKINS;
UI_SKINS.add_skin(new UiDefaultTheme(), true);
