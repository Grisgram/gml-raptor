/// @description onGameLoaded
/*
	The data variable has already been published with the loaded data.
	Use this event to restore all needed values from data (like instances).
*/
event_inherited();
is_enabled = __RAPTORDATA.is_enabled;
skinnable  = __RAPTORDATA.skinnable;

if (vsget(__RAPTORDATA, __POOL_SOURCE_NAME))	self[$ __POOL_SOURCE_NAME]	= __RAPTORDATA[$ __POOL_SOURCE_NAME];
if (vsget(__RAPTORDATA, __INTERFACES_NAME))		self[$ __INTERFACES_NAME]	= __RAPTORDATA[$ __INTERFACES_NAME];
