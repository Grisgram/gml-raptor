/// @description event
event_inherited();

enum listbox_sort {
	none, ascending, descending
}

down_arrow_sprite ??= sprDefaultListBoxArrow;

mypanel = undefined;

#region item functions

/// @function add_item(_displaymember, _valuemember)
/// @description Adds a new item to the list
add_item = function(_displaymember, _valuemember) {
	close_list();
	var idx = array_length(items);
	array_push(items, { 
		displaymember: _displaymember, 
		valuemember: _valuemember,
		index: idx,
		toString: function() { return displaymember; } 
	});
}

/// @function remove_item_by_value(_valuemember)
/// @description Removes an item by its value from the list
remove_item_by_value = function(_valuemember) {
	var idx = -1;
	
	for (var i = 0, len = array_length(items); i < len; i++) {
		if (items[@i].valuemember == _valuemember) {
			idx = i;
			break;
		}
	}
	
	if (idx != -1) {
		close_list();
		array_delete(items, idx, 1);
		if (selected_index >= idx) selected_index--;
	}
}

/// @function remove_item_by_name(_displaymember)
/// @description Removes an item by its name from the list
remove_item_by_name = function(_displaymember) {
	var idx = -1;
	
	for (var i = 0, len = array_length(items); i < len; i++) {
		if (items[@i].displaymember == _displaymember) {
			idx = i;
			break;
		}
	}
	
	if (idx != -1) {
		close_list();
		array_delete(items, idx, 1);
		if (selected_index >= idx) selected_index--;
	}
}

/// @function get_selected_value()
/// @description Gets the valuemember of the selected item or undefined, if nothing is selected
get_selected_value = function() {
	if (selected_index != -1)
		return items[@selected_index].valuemember;
	return undefined;
}

/// @function get_selected_item()
/// @description Gets the valuemember of the selected item or undefined, if nothing is selected
get_selected_item = function() {
	if (selected_index != -1)
		return items[@selected_index];
	return undefined;
}

/// @function clear_items()
/// @description Clear all items from the listview and set selected_index to -1.
///				 NOTE: This will NEVER trigger the on_item_selected callback!
clear_items = function() {
	items = [];
	selected_index = -1;
}

__item_clicked = function(_item) {
	if (_item != undefined) {
		text = _item.displaymember;
		selected_index = _item.index;
		invoke_if_exists(self, "on_item_selected", _item);
	}
	close_list();
}

#endregion

#region open/close functionality

is_open = false;
open_list = function() {
	if (is_open) return;
	
	invoke_if_exists(self, "on_list_opening");
	
	var len = array_length(items ?? []);
	if (len > 0) {
		vlog($"{MY_NAME} opening list panel with {len} item(s)");
		
		is_open = true;
		mypanel = instance_create(x, y, depth - 1, RaptorListBoxPanel);
		mypanel.attach_to(self);
		
		invoke_if_exists(self, "on_list_opened");
	}
}

close_list = function() {
	if (!is_open) return;
	is_open = false;
	
	vlog($"{MY_NAME} closing list panel");
	if (mypanel != undefined) {
		mypanel.close();
		mypanel = undefined;
	}
	invoke_if_exists(self, "on_list_closed");
}

toggle_open_state = function() {
	if (is_open) close_list(); else open_list();
}

__mouse_is_over_me_or_panel = function() {
	var overpanel = false;
	if (mypanel != undefined) {
		with(mypanel)
			overpanel = point_in_rectangle(CTL_MOUSE_X, CTL_MOUSE_Y,
				SELF_VIEW_LEFT_EDGE, SELF_VIEW_TOP_EDGE, SELF_VIEW_RIGHT_EDGE, SELF_VIEW_BOTTOM_EDGE);
	}
	return (mouse_is_over || overpanel);
}

#endregion

// analyze design-time items
if (array_length(items ?? []) > 0) {
	var newitems = items;
	items = [];
	vlog($"{MY_NAME} adding {array_length(newitems)} design time items to list");
	var sa;
	for (var i = 0, len = array_length(newitems); i < len; i++) {
		var it = newitems[@i];
		if (is_string(it) && string_contains(it, ":")) {
			sa = string_split(it, ":", false, 1);
			add_item(sa[1], sa[0]);
		} else
			throw("Designtime items for a listbox must follow the \"value:text\" pattern!");
	}
	
	if (selected_index > -1 && array_length(items) > selected_index)
		__item_clicked(items[@ selected_index]);
}

__draw_instance = function(_force = false) {
	__basecontrol_draw_instance(_force);
	
	if (!visible) return;
	
	draw_sprite_ext(down_arrow_sprite, 0, 
		SELF_VIEW_RIGHT_EDGE, 
		SELF_VIEW_CENTER_Y,
		1, 1, image_angle,
		mouse_is_over ? draw_color_mouse_over : draw_color,
		image_alpha);
}