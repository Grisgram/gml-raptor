/// @description item pooling
event_inherited();

on_left_click = function() {
	panel.listbox.__item_clicked(itemdata);
}

assign_data = function(_itemdata) {
	itemdata = _itemdata;
	text = LG_resolve(_itemdata.displaymember);
}