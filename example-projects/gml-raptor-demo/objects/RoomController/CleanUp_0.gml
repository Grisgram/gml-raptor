/// @description unset global variable

if (ROOMCONTROLLER == self) ROOMCONTROLLER = undefined;
__CAMERA_RUNTIME.clean_up();

event_inherited();
