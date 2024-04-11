/// @description onGameSaving
/*
	Invoked before the data variable is written to the file.
	Use this event to store/map any data for the save file, like mapping instances to their id's only
*/
event_inherited();
__RAPTORDATA.is_enabled = is_enabled;
__RAPTORDATA.skinnable  = skinnable;

if (vsget(self, __POOL_SOURCE_NAME))	__RAPTORDATA[$ __POOL_SOURCE_NAME]	= self[$ __POOL_SOURCE_NAME];
if (vsget(self, __INTERFACES_NAME))		__RAPTORDATA[$ __INTERFACES_NAME]	= self[$ __INTERFACES_NAME];
