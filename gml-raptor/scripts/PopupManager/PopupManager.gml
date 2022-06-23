/*
	Handles popup messages through layer visibility
*/
#macro GUI_POPUP_VISIBLE		global.__popup_visible
#macro GUI_POPUP_LAYER_GROUP	global.__popup_layer_group

// Use this macro in all controls events that shall not react when a popup is open
// Code it like this (first line of event): if (HIDDEN_BEHIND_POPUP) exit;
// HTMLBUG - DECLARED IN GAMECONTROLLER.onCreate!!
//#macro HIDDEN_BEHIND_POPUP		(!visible || (GUI_POPUP_VISIBLE && !string_match(layer_get_name(layer), GUI_POPUP_LAYER_GROUP)))

GUI_POPUP_VISIBLE = false;

/// @function							show_popup(layer_group_name = "popup_")
/// @description						shows all popup layers
/// @param {string="popup_"} layer_group_name	starts_with for layers to show
function show_popup(layer_group_name = "popup_*") {
	log("Showing popup view");
	if (!GUI_POPUP_VISIBLE) {
		layer_set_all_visible(layer_group_name, true);
		GUI_POPUP_LAYER_GROUP = layer_group_name;
		GUI_POPUP_VISIBLE = true;
	}
}

/// @function				hide_popup()
/// @description			hides all popup layers shown through show_popup
function hide_popup() {
	log("Hiding popup view");
	if (GUI_POPUP_VISIBLE) {
		layer_set_all_visible(GUI_POPUP_LAYER_GROUP, false);
		GUI_POPUP_LAYER_GROUP = undefined;
		GUI_POPUP_VISIBLE = false;
	}
}

