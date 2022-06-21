/*
	CoordTranslator - translate gui to world coordinates and vice versa
*/

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

	var xfac = CAM_WIDTH  / VIEW_WIDTH;
	var yfac = CAM_HEIGHT / VIEW_HEIGHT;
	coord2.set(
		CAM_LEFT_EDGE + gui_x * xfac, 
		CAM_TOP_EDGE  + gui_y * yfac);
		
	return coord2;
}

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
		
	var xfac = VIEW_WIDTH  / CAM_WIDTH;
	var yfac = VIEW_HEIGHT / CAM_HEIGHT;
	coord2.set(
		(world_x - CAM_LEFT_EDGE) * xfac, 
		(world_y - CAM_TOP_EDGE)  * yfac);
		
	return coord2;
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

	var xfac = CAM_WIDTH  / VIEW_WIDTH;
	var yfac = CAM_HEIGHT / VIEW_HEIGHT;
	coord2.set(
		gui_x * xfac, 
		gui_y * yfac);
		
	return coord2;
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
		
	var xfac = VIEW_WIDTH  / CAM_WIDTH;
	var yfac = VIEW_HEIGHT / CAM_HEIGHT;
	coord2.set(
		world_x * xfac, 
		world_y * yfac);
		
	return coord2;
}
