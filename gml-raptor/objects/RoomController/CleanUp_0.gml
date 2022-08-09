/// @description unset global variable

if (ROOMCONTROLLER == self) ROOMCONTROLLER = undefined;
if (PARTSYS != undefined)	PARTSYS.cleanup();

event_inherited();
