/*
    One lootet item
*/


/// @function RaceItem(_item = undefined, _item_name = undefined, _table_name = undefined, _instance = undefined)
function RaceItem(_item = undefined, _item_name = undefined, _table_name = undefined, _instance = undefined) constructor {
	construct(RaceItem);

	instance	= _instance;
	table_name	= _table_name;
	item_name	= _item_name;
	item		= _item;
	
	if (item != undefined) // if we come from savegame, no item is given
		vsgetx(item, "attributes", {});

}