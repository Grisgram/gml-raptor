/// @description unset global variable

if (ROOMCONTROLLER == self) ROOMCONTROLLER = undefined;
ds_list_destroy(__camera_action_queue);

event_inherited();
