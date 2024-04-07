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
	already updated when the controls enter their step events), 
	the mouse position is converted to GUI coordinates and stored
	in the global.__gui_mouse_x and global.__gui_mouse_y variables.
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
	
	ROOM TRANSITION CONTROL
	-----------------------
	
*/

event_inherited();

#macro ROOMCONTROLLER			global.__room_controller
ROOMCONTROLLER = self;


/// @function onGameLoadFailed(_exception)
onGameLoadFailed = function(_exception) {
	elog($"**ERROR** Game load failed: {_exception.message}");
}

// Set up world UI system
#macro UI_ROOT					global.__ui_root
__ui_root_control = instance_create(0, 0, layer, RaptorUiRootPanel);
UI_ROOT = __ui_root_control.control_tree;

// Set up particle systems
#macro PARTSYS					global.__room_particle_system
if (particle_layer_names == undefined || (is_string(particle_layer_names) && string_is_empty(particle_layer_names))) {
	PARTSYS = undefined;
} else {
	if (is_string(particle_layer_names)) {
		PARTSYS = new ParticleManager(particle_layer_names);
	} else if (is_array(particle_layer_names)) {
		PARTSYS = array_create(array_length(particle_layer_names));
		for (var i = 0; i < array_length(PARTSYS); i++)
			PARTSYS[@ i] = new ParticleManager(particle_layer_names[@ i], i);
	} else
		PARTSYS = undefined;
	
	if (PARTSYS != undefined)
		setup_particle_types();

}


/*
	-------------------
		GUI CONTROL
	-------------------
*/
#region GUI CONTROL

/// @function set_gui_size(_gui_width, _gui_height)
/// @description Set the gui to a new size. This will also rescale the UI_ROOT
set_gui_size = function(_gui_width, _gui_height) {
	display_set_gui_size(_gui_width, _gui_height);
	__ui_root_control.align_to_gui_layer();
}
set_gui_size(CAM_WIDTH, CAM_HEIGHT);

#macro GUI_MOUSE_X_PREVIOUS		global.__gui_mouse_xprevious
#macro GUI_MOUSE_Y_PREVIOUS		global.__gui_mouse_yprevious
#macro GUI_MOUSE_X				global.__gui_mouse_x
#macro GUI_MOUSE_Y				global.__gui_mouse_y
#macro GUI_MOUSE_DELTA_X		global.__gui_mouse_xmove
#macro GUI_MOUSE_DELTA_Y		global.__gui_mouse_ymove
#macro GUI_MOUSE_HAS_MOVED		global.__gui_mouse_has_moved

#macro MOUSE_X_PREVIOUS			global.__world_mouse_xprevious
#macro MOUSE_Y_PREVIOUS			global.__world_mouse_yprevious
#macro MOUSE_X					mouse_x
#macro MOUSE_Y					mouse_y
#macro MOUSE_DELTA_X			global.__world_mouse_xmove
#macro MOUSE_DELTA_Y			global.__world_mouse_ymove
#macro MOUSE_HAS_MOVED			global.__world_mouse_has_moved

#macro CTL_MOUSE_X_PREVIOUS		((self[$ "draw_on_gui"] ?? false) ? GUI_MOUSE_X_PREVIOUS : MOUSE_X_PREVIOUS)
#macro CTL_MOUSE_Y_PREVIOUS		((self[$ "draw_on_gui"] ?? false) ? GUI_MOUSE_Y_PREVIOUS : MOUSE_Y_PREVIOUS)
#macro CTL_MOUSE_X				((self[$ "draw_on_gui"] ?? false) ? GUI_MOUSE_X			 : MOUSE_X)
#macro CTL_MOUSE_Y				((self[$ "draw_on_gui"] ?? false) ? GUI_MOUSE_Y			 : MOUSE_Y)
#macro CTL_MOUSE_DELTA_X		((self[$ "draw_on_gui"] ?? false) ? GUI_MOUSE_DELTA_X	 : MOUSE_DELTA_X)
#macro CTL_MOUSE_DELTA_Y		((self[$ "draw_on_gui"] ?? false) ? GUI_MOUSE_DELTA_Y	 : MOUSE_DELTA_Y)
#macro CTL_MOUSE_HAS_MOVED		((self[$ "draw_on_gui"] ?? false) ? GUI_MOUSE_HAS_MOVED  : MOUSE_HAS_MOVED)

GUI_MOUSE_X = device_mouse_x_to_gui(0);
GUI_MOUSE_Y = device_mouse_y_to_gui(0);
MOUSE_X_PREVIOUS = mouse_x;
MOUSE_Y_PREVIOUS = mouse_y

#macro WINDOW_SIZE_X			global.__window_size_x
#macro WINDOW_SIZE_Y			global.__window_size_y
#macro WINDOW_SIZE_DELTA_X		global.__window_size_xmove
#macro WINDOW_SIZE_DELTA_Y		global.__window_size_ymove
#macro WINDOW_SIZE_X_PREVIOUS	global.__window_size_xprevious
#macro WINDOW_SIZE_Y_PREVIOUS	global.__window_size_yprevious
#macro WINDOW_SIZE_HAS_CHANGED	global.__window_size_has_changed

WINDOW_SIZE_X			= window_get_width();
WINDOW_SIZE_Y			= window_get_height();
WINDOW_SIZE_DELTA_X		= 0;
WINDOW_SIZE_DELTA_Y		= 0;
WINDOW_SIZE_X_PREVIOUS	= WINDOW_SIZE_X;
WINDOW_SIZE_Y_PREVIOUS	= WINDOW_SIZE_Y;
WINDOW_SIZE_HAS_CHANGED	= false;

#macro DELTA_TIME_SECS			global.__delta_time_secs
DELTA_TIME_SECS = 0;

#endregion


/*
	----------------------
		CAMERA CONTROL
	----------------------
*/
#region CAMERA CONTROL

CAM_MIN_X	= 0;
CAM_MIN_Y	= 0;
CAM_MAX_X	= room_width;
CAM_MAX_Y	= room_height;

__screen_shaking = false;
/// @function					screen_shake(frames, xinstensity, yintensity, camera_index = 0)
/// @description				lets rumble! NOTE: Ignored, if already rumbling!
screen_shake = function(frames, xinstensity, yintensity, camera_index = 0) {
	if (__screen_shaking) {
		dlog($"Screen_shake ignored. Already shaking!");
		return undefined;
	}
	__screen_shaking = true;
	var a = new camera_action_data(camera_index, frames, __camera_action_screen_shake);
	a.no_delta		= {dx:0, dy:0}; // delta watcher if cam target moves while we animate
	a.xintensity	= xinstensity;
	a.yintensity	= yintensity
	a.xshake		= 0;
	a.yshake		= 0;
	a.xrumble		= 0;
	a.yrumble		= 0;
	camera_set_view_target(view_camera[camera_index], noone);
	a.__internal_finished_callback = function() {ROOMCONTROLLER.__screen_shaking = false;};
	// Return the action to our caller
	return a; 
}

/// @function					camera_zoom_to(frames, new_width, enqueue_if_running = true, camera_index = 0)
/// @description				zoom the camera animated by X pixels
camera_zoom_to = function(frames, new_width, enqueue_if_running = true, camera_index = 0) {
	var a = new camera_action_data(camera_index, frames, __camera_action_zoom, enqueue_if_running, true);
	// as this is an enqueued action, the data calculation must happen in the camera action on first call
	a.relative	= false; // not-relative tells the action to use a.new_width for calculation
	a.new_width	= new_width;
	// Return the action to our caller
	return a; 
}

/// @function					camera_zoom_by(frames, width_delta, min_width, max_width, enqueue_if_running = true, camera_index = 0)
/// @description				zoom the camera animated by X pixels
camera_zoom_by = function(frames, width_delta, min_width, max_width, enqueue_if_running = true, camera_index = 0) {
	var a = new camera_action_data(camera_index, frames, __camera_action_zoom, enqueue_if_running, true);
	// as this is an enqueued action, the data calculation must happen in the camera action on first call
	a.relative		= true; // relative tells the action to use a.new_width for calculation
	a.min_width		= min_width;
	a.max_width		= max_width;
	a.width_delta	= width_delta;
	// Return the action to our caller
	return a; 
}

/// @function					camera_move_to(frames, target_x, target_y, enqueue_if_running = true, camera_align = cam_align.top_left, camera_index = 0)
/// @description				move the camera animated to a specified position with an optional
///								alignment.
///								The cam_align enum can be used to specify a different alignment than
///								the default of top_left. For instance, if you specify align.middle_center here,
///								this function works like a kind of "look at that point", as the CENTER of the view
///								will be at target_x, target_y coordinates.
camera_move_to = function(frames, target_x, target_y, enqueue_if_running = true, camera_align = cam_align.top_left, camera_index = 0) {
	var a = new camera_action_data(camera_index, frames, __camera_action_move, enqueue_if_running);
	// as this is an enqueued action, the data calculation must happen in the camera action on first call
	a.relative		= false; // not-relative tells the action to use a.target* for calculation
	a.target_x		= target_x;
	a.target_y		= target_y;
	a.camera_align	= camera_align;
	// Return the action to our caller
	return a; 
}

/// @function					camera_move_by(frames, distance_x, distance_y, enqueue_if_running = true, camera_index = 0)
/// @description				move the camera animated by a specified distance
camera_move_by = function(frames, distance_x, distance_y, enqueue_if_running = true, camera_index = 0) {
	var a = new camera_action_data(camera_index, frames, __camera_action_move, enqueue_if_running);
	// as this is an enqueued action, the data calculation must happen in the camera action on first call
	a.relative		= true; // relative tells the action to use a.distance* for calculation
	a.distance_x	= distance_x;
	a.distance_y	= distance_y;
	// Return the action to our caller
	return a; 
}

/// @function					camera_look_at(frames, target_x, target_y, enqueue_if_running = true, camera_index = 0)
/// @description				move the camera animated so that target_x and target_y are in the center of the screen when finished.
camera_look_at = function(frames, target_x, target_y, enqueue_if_running = true, camera_index = 0) {
	return camera_move_to(frames, target_x, target_y, enqueue_if_running, cam_align.middle_center, camera_index);
}

#endregion

/*
	----------------------
	  TRANSITION CONTROL
	----------------------
*/
#region TRANSITION CONTROL
#macro __ACTIVE_TRANSITION		global.__active_transition
if (!variable_global_exists("__active_transition"))
	__ACTIVE_TRANSITION	= undefined;

#macro __ACTIVE_TRANSITION_STEP		global.__active_transition_step
if (!variable_global_exists("__active_transition_step"))
	__ACTIVE_TRANSITION_STEP = -1; // Step 0 = out, Step 1 = in and -1 means inactive

#macro TRANSITION_RUNNING		global.__transition_running
if (!variable_global_exists("__transition_running"))
	TRANSITION_RUNNING = false;

/// @function		transit(_transition, skip_if_another_running = false)
/// @description	Perform an animated transition to another room
///					See RoomTransitions script for more info
transit = function(_transition, skip_if_another_running = false) {
	if (skip_if_another_running && TRANSITION_RUNNING) {
		wlog($"*WARNING* Transition ignored, another one is running");
		return;
	}
	
	ilog($"Starting transit to '{room_get_name(_transition.target_room)}'");
	
	__ACTIVE_TRANSITION		 = _transition;
	__ACTIVE_TRANSITION_STEP = 0;
	TRANSITION_RUNNING = true;
}

/// @function onTransitFinished()
/// @description Invoked when a transition to this room is finished.
///				 Override (redefine) to execute code when a room is no longer animating
onTransitFinished = function() {
}

#endregion