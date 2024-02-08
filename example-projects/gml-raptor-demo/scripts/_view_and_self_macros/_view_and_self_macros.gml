// Controller globals for the macros
#macro CAM_INDEX					global.__macro_camera_index
#macro VIEWPORT_INDEX				global.__macro_viewport_index
CAM_INDEX							= 0; // Initialize with default
VIEWPORT_INDEX						= 0; // Initialize with default

// temporary variables for the two functions below
#macro __CAM_INDEX_PUSH_STACK		global.__pushstack_macro_camera_index
#macro __VIEWPORT_INDEX_PUSH_STACK	global.__pushstack_macro_viewport_index

/// @function				macro_camera_viewport_index_switch_to(camera_index = 0, viewport_index = 0)
/// @description			Set both globals for the CAM/VIEW macros in one step
/// @param {int} camera_index
/// @param {int} viewport_index
function macro_camera_viewport_index_switch_to(camera_index = 0, viewport_index = 0) {
	// push current values to temp-stack
	__CAM_INDEX_PUSH_STACK		= CAM_INDEX;
	__VIEWPORT_INDEX_PUSH_STACK = VIEWPORT_INDEX;
	// set new values
	CAM_INDEX		= camera_index;
	VIEWPORT_INDEX	= viewport_index;
}

/// @function				macro_camera_viewport_index_switch_back()
/// @description			Restore the values for camera and viewport that were active before
///							the last *_switch_to call (like stack.pop)
///							ATTENTION! This method crashes if you never called switch_to before!
function macro_camera_viewport_index_switch_back() {
	// pop values from the temp stack, whatever is stored there
	CAM_INDEX		= __CAM_INDEX_PUSH_STACK;
	VIEWPORT_INDEX	= __VIEWPORT_INDEX_PUSH_STACK;
}

// application things
#macro APP_SURF_WIDTH		surface_get_width(application_surface)
#macro APP_SURF_HEIGHT		surface_get_height(application_surface)

// camera things
#macro CAM					view_camera[CAM_INDEX]
#macro CAM_WIDTH			camera_get_view_width(CAM)
#macro CAM_HEIGHT			camera_get_view_height(CAM)
#macro CAM_CENTER_X			(CAM_LEFT_EDGE + CAM_WIDTH  / 2)
#macro CAM_CENTER_Y			(CAM_TOP_EDGE  + CAM_HEIGHT / 2)
#macro CAM_LEFT_EDGE		camera_get_view_x(CAM)
#macro CAM_TOP_EDGE			camera_get_view_y(CAM)
#macro CAM_RIGHT_EDGE		(CAM_LEFT_EDGE + CAM_WIDTH - 1)
#macro CAM_BOTTOM_EDGE		(CAM_TOP_EDGE  + CAM_HEIGHT - 1)
#macro CAM_ASPECT_RATIO		(CAM_WIDTH / CAM_HEIGHT)

// set the camera min/max positions. These are used by the ROOMCONTROLLERS' camera functions
// By default, the ROOMCONTROLLER sets these to 0/0-room_width/height when created
#macro CAM_MIN_X			global.__cam_min_x
#macro CAM_MAX_X			global.__cam_max_x
#macro CAM_MIN_Y			global.__cam_min_y
#macro CAM_MAX_Y			global.__cam_max_y

CAM_MIN_X					= 0;
CAM_MAX_X					= 0;
CAM_MIN_Y					= 0;
CAM_MAX_Y					= 0;


// View helpers - UI layer
#macro UI_VIEW_WIDTH				 display_get_gui_width()
#macro UI_VIEW_HEIGHT				 display_get_gui_height()
#macro UI_SCALE						1
#macro UI_VIEW_CENTER_X				(UI_VIEW_WIDTH  / 2 / UI_SCALE)
#macro UI_VIEW_CENTER_Y				(UI_VIEW_HEIGHT / 2 / UI_SCALE)
#macro UI_VIEW_ASPECT_RATIO			(UI_VIEW_WIDTH  / UI_VIEW_HEIGHT)
#macro UI_VIEW_WIDTH_SCALED			(UI_VIEW_WIDTH  / UI_SCALE)
#macro UI_VIEW_HEIGHT_SCALED		(UI_VIEW_HEIGHT / UI_SCALE)

// View helpers - viewport
#macro VIEW_WIDTH					view_wport[VIEWPORT_INDEX]
#macro VIEW_HEIGHT					view_hport[VIEWPORT_INDEX]
#macro VIEW_TOP_EDGE				 CAM_TOP_EDGE
#macro VIEW_LEFT_EDGE				 CAM_LEFT_EDGE
#macro VIEW_RIGHT_EDGE				(VIEW_LEFT_EDGE + UI_VIEW_WIDTH)
#macro VIEW_BOTTOM_EDGE				(VIEW_TOP_EDGE  + UI_VIEW_HEIGHT)
#macro VIEW_CENTER_X				(VIEW_LEFT_EDGE + VIEW_WIDTH / 2)
#macro VIEW_CENTER_Y				(VIEW_TOP_EDGE  + VIEW_HEIGHT / 2)
#macro VIEW_CENTER					VIEW_CENTER_X, VIEW_CENTER_Y
#macro VIEW_ASPECT_RATIO			(VIEW_WIDTH / VIEW_HEIGHT)

// SELF Coordinates (object dimensions only, without absolute screen position)
#macro SELF_WIDTH					sprite_width
#macro SELF_HEIGHT					sprite_height
#macro SELF_WIDTH_UNSCALED			sprite_get_width(sprite_index)
#macro SELF_HEIGHT_UNSCALED			sprite_get_height(sprite_index)
#macro SELF_CENTER_X				(sprite_width / 2 - sprite_xoffset)
#macro SELF_CENTER_Y				(sprite_height / 2 - sprite_yoffset)
#macro SELF_CENTER					SELF_CENTER_X, SELF_CENTER_Y
#macro SELF_LEFT_EDGE				-sprite_xoffset
#macro SELF_TOP_EDGE				-sprite_yoffset
#macro SELF_RIGHT_EDGE				(sprite_width - 1 - sprite_xoffset)
#macro SELF_BOTTOM_EDGE				(sprite_height - 1 - sprite_yoffset)
#macro SELF_ASPECT_RATIO			(SELF_WIDTH / SELF_HEIGHT)

#macro SELF_MOVE_DELTA_X			(x - xprevious)
#macro SELF_MOVE_DELTA_Y			(y - yprevious)
#macro SELF_HAVE_MOVED				(SELF_MOVE_DELTA_X != 0 || SELF_MOVE_DELTA_Y != 0)

// These include the absolute position (x/y of the object)
#macro SELF_VIEW_CENTER_X			(x + SELF_CENTER_X)
#macro SELF_VIEW_CENTER_Y			(y + SELF_CENTER_Y)
#macro SELF_VIEW_CENTER				SELF_VIEW_CENTER_X, SELF_VIEW_CENTER_Y
#macro SELF_VIEW_LEFT_EDGE			(x + SELF_LEFT_EDGE)
#macro SELF_VIEW_TOP_EDGE			(y + SELF_TOP_EDGE)
#macro SELF_VIEW_RIGHT_EDGE			(x + SELF_RIGHT_EDGE)
#macro SELF_VIEW_BOTTOM_EDGE		(y + SELF_BOTTOM_EDGE)
