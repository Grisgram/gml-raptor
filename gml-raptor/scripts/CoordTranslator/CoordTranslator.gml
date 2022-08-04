/*
	CoordTranslator - translate gui to world coordinates and vice versa
*/

#region GUI TO WORLD
/// @function			translate_gui_to_world(gui_x, gui_y, coord2 = undefined)
/// @description		translate the specified ui coordinates to the current
///						camera's view world coordinates.
///						The optional coord2 parameter can be used to fill
///						an existing instance of Coord2 with the values and
///						therefore avoid creating new instances.
///						Consider this for performance and GC.
/// @param {real} gui_x
/// @param {real} gui_y
/// @param {Coord2=undefined} coord2
/// @returns {Coord2} the result
function translate_gui_to_world(gui_x, gui_y, coord2 = undefined) {
	if (coord2 == undefined)
		coord2 = new Coord2();

	var xfac = CAM_WIDTH  / UI_VIEW_WIDTH;
	var yfac = CAM_HEIGHT / UI_VIEW_HEIGHT;
	coord2.set(
		CAM_LEFT_EDGE + gui_x * xfac, 
		CAM_TOP_EDGE  + gui_y * yfac);
		
	return coord2;
}

/// @function			translate_gui_to_world_x(gui_x)
/// @description		translate the specified ui x-coordinate to the current
///						camera's view world coordinate.
/// @param {real} gui_x
/// @returns {real} world_x
function translate_gui_to_world_x(gui_x) {
	return CAM_LEFT_EDGE + gui_x * CAM_WIDTH  / UI_VIEW_WIDTH;
}

/// @function			translate_gui_to_world_y(gui_x)
/// @description		translate the specified ui y-coordinate to the current
///						camera's view world coordinate.
/// @param {real} gui_y
/// @returns {real} world_y
function translate_gui_to_world_y(gui_y) {
	return CAM_TOP_EDGE + gui_y * CAM_HEIGHT / UI_VIEW_HEIGHT;
}


/// @function			translate_gui_to_world_abs(gui_x, gui_y, coord2 = undefined)
/// @description		translate the specified ui coordinates to world coordinates.
///						This function ignores camera and view! It just converts from one
///						coordinate space to another.
///						The optional coord2 parameter can be used to fill
///						an existing instance of Coord2 with the values and
///						therefore avoid creating new instances.
///						Consider this for performance and GC.
/// @param {real} gui_x
/// @param {real} gui_y
/// @param {Coord2=undefined} coord2
/// @returns {Coord2} the result
function translate_gui_to_world_abs(gui_x, gui_y, coord2 = undefined) {
	if (coord2 == undefined)
		coord2 = new Coord2();

	var xfac = CAM_WIDTH  / UI_VIEW_WIDTH;
	var yfac = CAM_HEIGHT / UI_VIEW_HEIGHT;
	coord2.set(
		gui_x * xfac, 
		gui_y * yfac);
		
	return coord2;
}
#endregion

#region WORLD TO GUI
/// @function			translate_world_to_gui(world_x, world_y, coord2 = undefined)
/// @description		translate the specified world coordinates to gui coordinates.
///						The optional coord2 parameter can be used to fill
///						an existing instance of Coord2 with the values and
///						therefore avoid creating new instances.
///						Consider this for performance and GC.
/// @param {real} world_x
/// @param {real} world_y
/// @param {Coord2=undefined} coord2
/// @returns {Coord2} the result
function translate_world_to_gui(world_x, world_y, coord2 = undefined) {
	if (coord2 == undefined)
		coord2 = new Coord2();
		
	var xfac = UI_VIEW_WIDTH  / CAM_WIDTH;
	var yfac = UI_VIEW_HEIGHT / CAM_HEIGHT;
	coord2.set(
		(world_x - CAM_LEFT_EDGE) * xfac, 
		(world_y - CAM_TOP_EDGE)  * yfac);
		
	return coord2;
}

/// @function			translate_world_to_gui_x(world_x)
/// @description		translate the specified world x-coordinate to a	ui space coordinate.
/// @param {real} world_x
/// @returns {real} gui_x
function translate_world_to_gui_x(world_x) {
	return (world_x - CAM_LEFT_EDGE) * UI_VIEW_WIDTH / CAM_WIDTH;
}

/// @function			translate_world_to_gui_y(world_y)
/// @description		translate the specified world y-coordinate to a	ui space coordinate.
/// @param {real} world_y
/// @returns {real} gui_y
function translate_world_to_gui_y(world_y) {
	return (world_y - CAM_TOP_EDGE) * UI_VIEW_HEIGHT / CAM_HEIGHT;
}

/// @function			translate_world_to_gui_abs(world_x, world_y, coord2 = undefined)
/// @description		translate the specified world coordinates to gui coordinates.
///						This function ignores camera and view! It just converts from one
///						coordinate space to another.
///						The optional coord2 parameter can be used to fill
///						an existing instance of Coord2 with the values and
///						therefore avoid creating new instances.
///						Consider this for performance and GC.
/// @param {real} world_x
/// @param {real} world_y
/// @param {Coord2=undefined} coord2
/// @returns {Coord2} the result
function translate_world_to_gui_abs(world_x, world_y, coord2 = undefined) {
	if (coord2 == undefined)
		coord2 = new Coord2();
		
	var xfac = UI_VIEW_WIDTH  / CAM_WIDTH;
	var yfac = UI_VIEW_HEIGHT / CAM_HEIGHT;
	coord2.set(
		world_x * xfac, 
		world_y * yfac);
		
	return coord2;
}
#endregion