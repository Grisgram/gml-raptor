/*
	Handles popup messages through layer visibility
*/
#macro GUI_POPUP_VISIBLE		global.__popup_visible
#macro GUI_POPUP_LAYER_GROUP	global.__popup_layer_group

// Use this macro in all controls events that shall not react when a popup is open
// Code it like this (first line of event): if (__HIDDEN_BEHIND_POPUP) exit;
// HTMLBUG - DECLARED IN GAMECONTROLLER.onCreate!!
//#macro __HIDDEN_BEHIND_POPUP		(!visible || (GUI_POPUP_VISIBLE && !string_match(layer_get_name(layer), GUI_POPUP_LAYER_GROUP)))

GUI_POPUP_VISIBLE = false;

/// @function							show_popup(_layer_group_name = "popup_")
/// @description						shows all popup layers
/// @param {string="popup_"} _layer_group_name	starts_with for layers to show
function show_popup(_layer_group_name = "popup_*") {
	log("Showing popup view");
	if (!GUI_POPUP_VISIBLE) {
		layer_set_all_visible(_layer_group_name, true);
		GUI_POPUP_LAYER_GROUP = _layer_group_name;
		GUI_POPUP_VISIBLE = true;
		BROADCASTER.send(self, __RAPTOR_BROADCAST_POPUP_SHOWN, { layer_group_name: _layer_group_name });
	}
}

/// @function				hide_popup()
/// @description			hides all popup layers shown through show_popup
function hide_popup() {
	log("Hiding popup view");
	if (GUI_POPUP_VISIBLE) {
		layer_set_all_visible(GUI_POPUP_LAYER_GROUP, false);
		var _layer_group_name = GUI_POPUP_LAYER_GROUP;
		GUI_POPUP_LAYER_GROUP = undefined;
		GUI_POPUP_VISIBLE = false;
		BROADCASTER.send(self, __RAPTOR_BROADCAST_POPUP_HIDDEN, { layer_group_name: _layer_group_name });
	}
}

