/// @description Controls GUI, Camera and Hotkeys
/*
	You can use a RoomController on its own or simply make it the parent
	of ONE of your other controller objects in the game.
	
	This object contains functionality for three main topics in a room:
	- GUI Control		Mouse Position translation from world to ui coordinates
	- Hotkey Control	Define global hotkeys for the entire room
	- Camera Control	Create cool Camera moves and effects
	
	GUI CONTROL
	-----------
	The GuiController is a passice object, that only does one single thing:
	Every step (exactly: in the BEGIN STEP event to make sure, coordinates are
	already updated when the controls enter their step event), 
	the mouse position is converted to GUI coordinates and stored
	in the global.gui_mouse_x and global.gui_mouse_y variables.
	These can also be accessed through the macros
	GUI_MOUSE_X and GUI_MOUSE_Y.
	
	Make sure to have a GuiController active in the room when using any control
	derived from _baseControl, as they rely on the existence of those globals.
	
	CAMERA CONTROL
	--------------
	This object allows a bit control over the camera by adding effects to it.
	There are flights to specific positions, rumble/screenshake and zoom effects.
	Note: A camera flight will maybe lead to unexpected results when the camera
	is following a specific instance in the viewport settings.

	HOTKEY CONTROL
	--------------
	tbd
	
*/

event_inherited();

#macro ROOMCONTROLLER			global.__room_controller
ROOMCONTROLLER = self;

/*
	-------------------
		GUI CONTROL
	-------------------
*/
#region GUI CONTROL
#macro GUI_MOUSE_X_PREVIOUS		global.__gui_mouse_xprevious
#macro GUI_MOUSE_Y_PREVIOUS		global.__gui_mouse_yprevious
#macro GUI_MOUSE_X				global.__gui_mouse_x
#macro GUI_MOUSE_Y				global.__gui_mouse_y
#macro GUI_MOUSE_DELTA_X		global.__gui_mouse_xmove
#macro GUI_MOUSE_DELTA_Y		global.__gui_mouse_ymove

#macro GUI_MOUSE_HAS_MOVED		global.__gui_mouse_has_moved
#macro MOUSE_HAS_MOVED			global.__gui_mouse_has_moved

GUI_MOUSE_X = device_mouse_x_to_gui(0);
GUI_MOUSE_Y = device_mouse_y_to_gui(0);

#macro WINDOW_SIZE_X_PREVIOUS	global.__window_size_xprevious
#macro WINDOW_SIZE_Y_PREVIOUS	global.__window_size_yprevious
#macro WINDOW_SIZE_X			global.__window_size_x
#macro WINDOW_SIZE_Y			global.__window_size_y
#macro WINDOW_SIZE_DELTA_X		global.__window_size_xmove
#macro WINDOW_SIZE_DELTA_Y		global.__window_size_ymove

#macro WINDOW_SIZE_HAS_CHANGED	global.__window_size_has_changed

WINDOW_SIZE_X = window_get_width();
WINDOW_SIZE_Y = window_get_height();

#endregion


/*
	----------------------
		CAMERA CONTROL
	----------------------
*/
#region CAMERA CONTROL

#region camera runtime
__active_camera_actions = array_create(1, undefined);
__camera_action_queue = ds_list_create();

__get_first_free_camera_action = function() {
	freeidx = -1;
	var i = 0; repeat(array_length(__active_camera_actions)) {
		if (__active_camera_actions[i] == undefined) {
			freeidx = i;
			break;
		}
		i++;
	}
	if (freeidx == -1) {
		freeidx = array_length(__active_camera_actions);
		array_push(__active_camera_actions, undefined);
	}
	if (freeidx == 0 && array_length(__active_camera_actions) > 1)
		__active_camera_actions = array_create(1, undefined); // shrink the array if necessary
	return freeidx;
}

__has_camera_action_with = function(script_to_call) {
	var i = 0; repeat(array_length(__active_camera_actions)) {
		var action = __active_camera_actions[i++];
		if (action != undefined && action.callback == script_to_call)
			return true;
	}
	return false;
}

#endregion

/// @function					screen_shake(frames, xinstensity, yintensity, camera_index = 0)
/// @description				lets rumble!
/// @param {int} frames 			
/// @param {real} xintensity
/// @param {real} yintensity
/// @param {int=0} camera_index
/// @returns {camera_action_data} struct
screen_shake = function(frames, xinstensity, yintensity, camera_index = 0) {
	var a = new camera_action_data(camera_index, frames, __camera_action_screen_shake);
	a.no_delta = {dx:0, dy:0}; // delta watcher if cam target moves while we animate
	a.xintensity = xinstensity;
	a.yintensity = yintensity
	a.xshake = 0;
	a.yshake = 0;
	a.xrumble = 0;
	a.yrumble = 0;
	camera_set_view_target(view_camera[camera_index], noone);

	// Return the action to our caller
	return a; 
}

/// @function					camera_zoom_to(frames, new_width, new_height, camera_index = 0)
/// @description				zoom the camera animated by X pixels
/// @param {int} frames 			
/// @param {real} new_width
/// @param {bool=true} enqueue_if_running
/// @param {int=0} camera_index
/// @returns {camera_action_data} struct
camera_zoom_to = function(frames, new_width, enqueue_if_running = true, camera_index = 0) {
	var a = new camera_action_data(camera_index, frames, __camera_action_zoom, enqueue_if_running);
	// as this is an enqueued action, the data calculation must happen in the camera action on first call
	a.first_call = true;
	a.relative = false; // not-relative tells the action to use a.new_width for calculation
	a.new_width = new_width;
	// Return the action to our caller
	return a; 
}

/// @function					camera_zoom_by(frames, width_delta, enqueue_if_running = true, camera_index = 0)
/// @description				zoom the camera animated by X pixels
/// @param {int} frames 			
/// @param {real} width_delta
/// @param {bool=true} enqueue_if_running
/// @param {int=0} camera_index
/// @returns {camera_action_data} struct
camera_zoom_by = function(frames, width_delta, enqueue_if_running = true, camera_index = 0) {
	var a = new camera_action_data(camera_index, frames, __camera_action_zoom, enqueue_if_running);
	// as this is an enqueued action, the data calculation must happen in the camera action on first call
	a.first_call = true;
	a.relative = true; // relative tells the action to use a.new_width for calculation
	a.width_delta = width_delta;
	// Return the action to our caller
	return a; 
}

/// @function					camera_move_to(frames, width_delta, new_height, camera_index = 0)
/// @description				move the camera animated to a specified position
/// @param {int} frames 			
/// @param {real} target_x
/// @param {real} target_y
/// @param {bool=true} enqueue_if_running
/// @param {int=0} camera_index
/// @returns {camera_action_data} struct
camera_move_to = function(frames, target_x, target_y, enqueue_if_running = true, camera_index = 0) {
	var a = new camera_action_data(camera_index, frames, __camera_action_move, enqueue_if_running);
	// as this is an enqueued action, the data calculation must happen in the camera action on first call
	a.first_call = true;
	a.relative = false; // not-relative tells the action to use a.target* for calculation
	a.target_x = target_x;
	a.target_y = target_y;
	// Return the action to our caller
	return a; 
}

/// @function					camera_move_by(frames, width_delta, new_height, camera_index = 0)
/// @description				move the camera animated by a specified distance
/// @param {int} frames 			
/// @param {real} distance_x
/// @param {real} distance_y
/// @param {bool=true} enqueue_if_running
/// @param {int=0} camera_index
/// @returns {camera_action_data} struct
camera_move_by = function(frames, distance_x, distance_y, enqueue_if_running = true, camera_index = 0) {
	var a = new camera_action_data(camera_index, frames, __camera_action_move, enqueue_if_running);
	// as this is an enqueued action, the data calculation must happen in the camera action on first call
	a.first_call = true;
	a.relative = true; // relative tells the action to use a.distance* for calculation
	a.distance_x = distance_x;
	a.distance_y = distance_y;
	// Return the action to our caller
	return a; 
}

#endregion
