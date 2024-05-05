/*
    Management class for one single loot table of the Race system
*/


/// @func RaceLootTable(_race, _name, _table_struct)
function RaceLootTable(_race, _name, _table_struct) constructor {
	construct(RaceLootTable);
	
	race = _race;
	name = _name;
	data = _table_struct;
	
	
}