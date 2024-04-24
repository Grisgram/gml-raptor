/// @description click and data
event_inherited();

on_left_click = function() {
	panel.listbox.__item_clicked(itemdata);
}

assign_data = function(_itemdata) {
	itemdata = _itemdata;
	text = _itemdata.get_display_string();
	tooltip_text = (_itemdata.shortened ? _itemdata.displaymember : "");	
}