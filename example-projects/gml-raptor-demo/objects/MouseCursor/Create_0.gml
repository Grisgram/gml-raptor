/// @description DOCS INSIDE!

/*
	There are two ways to work with the custom mouse cursor:
	1) Just drop it on *any* layer in your room (it will adapt its depth automatically)
	2) create an instance in code
	
	The MouseCursor will draw itself in the Draw_GUI_End event, so it is always drawn last.
	The depth will be set to 16000 (top most) upon creation but it will not be checked afterwards.
	If you tinker with the depth of the object it might be drawn below other UI elements, to best approach
	is, to not touch its depth at all.
	
	To change the cursor behavior at runtime:
	- Just assign it a new sprite, like you change any other object in your room
	- Adapt image_blend, scale, rotation freely, it's just a small object that draws at the mouse position,
	  there is no deeper logic behind, so feel free to do what you like with it.
	  
	COMPANION
	---------
	Sometimes, a cursor can have a companion (a second, smaller icon, most of the time displayed bottom-right of
	the mouse cursor). 
	To enable this, use the function set_companion(_sprite). To remove the companion, invoke clear_companion().
	
	NOTE: This will create a second object instance (MouseCursorCompanion) at the same depth of the mouse cursor!
	All animation rules of the sprite will execute, so you can even have animated companions!
	
	To fine control the position of the companion, adapt the companion_offset_x and companion_offset_y variable definitions.
	NOTE: This offset is IN ADDITION to the default position of "right edge, vertical center"!
	
	+-----+  <-- Mouse Cursor
	|     |
	|     +-----+  <-- Companion, vertically centered, at the right edge of the cursor
	|     |     |
	+-----+     |
	      |     |
		  +-----+

	The companion object is pooled, you don't have any performance issues with it, feel free to use it whenever you see fit.
	
	You can create a custom companion object (set MouseCursorCompanion as the parent) if you need more options, like Animations,
	blending or any other things, even particle effects are possible.
	To do this, set the companion_type (also a variable definition, so available at design time) of the mouse cursor to the type
	of object you want to be instantiated when a companion is created.
	
	COMPANION FUNCTIONS
	-------------------
	set_companion(_sprite, _type)	- create a default companion and assign the _sprite to it
									  NOTE: _type is by default undefined, so the setting of the companion_type is used.
	clear_companion()				- remove the companion object
	
*/

#macro __RAPTOR_MOUSE_COMPANION_POOL		"__raptor_mouse_companion_pool"

MOUSE_CURSOR			= self;

event_inherited();

window_set_cursor(cr_none);
// on top of everything else
depth = 16000;
visible = true;

sprite_index = sprite_to_use ?? sprite_index;

companion = undefined;

/// @function set_companion(_companion_sprite, _type = undefined)
set_companion = function(_companion_sprite, _type = undefined) {
	if (companion != undefined)
		pool_return_instance(companion);
	
	var typ = _type ?? companion_type;
	companion = pool_get_instance(__RAPTOR_MOUSE_COMPANION_POOL, typ, depth);
	if (_companion_sprite != undefined)
		companion.sprite_index = _companion_sprite;
}

/// @function clear_companion(reset_blend_color = true)
clear_companion = function(reset_blend_color = true) {
	if (companion != undefined) {
		pool_return_instance(companion);
		companion = undefined;
	}
	if (reset_blend_color)
		image_blend = c_white;
}

/// @function destroy()
/// @description remove this mouse cursor and restore default cursor
destroy = function() {
	window_set_cursor(cr_default);
	MOUSE_CURSOR = undefined;
	instance_destroy(self);
}