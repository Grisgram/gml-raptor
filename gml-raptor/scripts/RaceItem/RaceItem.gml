/*
    One lootet item
*/


/// @function RaceItem(_item = undefined, _instance = undefined)
function RaceItem(_item = undefined, _instance = undefined) constructor {
	construct(RaceItem);

	item = _item;
	if (item != undefined) // if we come from savegame, no item is given
		vsgetx(item, "attributes", {});
	
	instance = _instance;

}