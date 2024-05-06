/*
    Management class for one single loot table of the Race system
*/


/// @func RaceLootTable(_race, _name, _table_struct)
function RaceLootTable(_race = undefined, _name = "", _table_struct = undefined) constructor {
	construct(RaceLootTable);
	
	race = _race;
	name = _name;
	if (_table_struct != undefined) // if we come from savegame, no struct is given
		struct_join_into(self, RACE_LOOT_DATA_DEEP_COPY ? SnapDeepCopy(_table_struct) : _table_struct);
		
	
	
}