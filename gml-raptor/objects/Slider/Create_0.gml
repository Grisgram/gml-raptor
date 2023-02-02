/// @description DOCS inside!

/*
	A note on the on_value_changed callback:
	This function receives two parameters: new_value, old_value
	so you can always see, which value has been active before the change, in case you need it.
	
	There is also a variable value_percent available which holds the percentage_of_max of the current value.
	The value_percent ranges from 0 to 1, so for display you should multiply it by 100.
*/

#macro __SLIDER_IN_FOCUS		global._SLIDER_IN_FOCUS
__SLIDER_IN_FOCUS				= undefined;

enum slider_autotext {
	none = 0,
	text_is_value = 1,
	text_is_percent = 2
}

event_inherited();

replace_sprite(self, rail_sprite);

value_percent			= 0;

__knob_dims				= new SpriteDim(knob_sprite);
__knob_x				= 0;
__knob_y				= 0;
__knob_image_index		= 0;
__mouse_over_knob		= false;
__knob_grabbed			= false;
__outside_knob_cursor	= window_get_cursor();
__tilesize				= 0;
__knob_over_color		= draw_color_mouse_over;

/// @function check_mouse_over_knob()
check_mouse_over_knob = function() {
	// ** GUI FIX 2023.1 **
	xcheck = MOUSE_X;
	ycheck = MOUSE_Y;
	//xcheck = (draw_on_gui ? GUI_MOUSE_X : MOUSE_X);
	//ycheck = (draw_on_gui ? GUI_MOUSE_Y : MOUSE_Y);

	var over_before = __mouse_over_knob;
	
	__mouse_over_knob = 
		(is_between(xcheck, __knob_x - __knob_dims.origin_x * knob_xscale, __knob_x - __knob_dims.origin_x * knob_xscale + __knob_dims.width  * knob_xscale) &&
		 is_between(ycheck, __knob_y - __knob_dims.origin_y * knob_yscale, __knob_y - __knob_dims.origin_y * knob_yscale + __knob_dims.height * knob_yscale));

	__knob_image_index = (
		(
			(__mouse_over_knob && (__SLIDER_IN_FOCUS == undefined || __SLIDER_IN_FOCUS == self)) || __knob_grabbed
		) && 
		sprite_get_number(knob_sprite) > 1 ? 1 : 0);

	if (__mouse_over_knob != over_before) {
		if (__mouse_over_knob) {
			if (on_mouse_enter_knob != undefined) on_mouse_enter_knob();
		} else {
			if (on_mouse_leave_knob != undefined) on_mouse_leave_knob();
		}
	}
}

/// @function calculate_value_percent()
calculate_value_percent = function() {
	value_percent = (value - min_value) / max_value;
}

/// @function set_value()
set_value = function(new_value) {
	var old_val = value;
	value = clamp(new_value, min_value, max_value);
	calculate_value_percent();
	if (value != old_val) {
		if (auto_text == slider_autotext.text_is_value)		text = string(value); else
		if (auto_text == slider_autotext.text_is_percent)	text = string_format(value_percent * 100,3,0) + "%";
		if (on_value_changed != undefined) on_value_changed(value, old_val);
	}
}

/// @function __set_draw_colors()
__set_draw_colors = function() {
	if (draw_color != draw_color_mouse_over) {
		__knob_over_color = draw_color_mouse_over;
		draw_color_mouse_over = draw_color;
	}
}

/// @function draw_knob()
draw_knob = function() {
	__set_draw_colors();
	if (orientation_horizontal) {
		__knob_x = x - sprite_xoffset + nine_slice_data.left + (value - min_value) * __tilesize;
		__knob_y = y - sprite_yoffset + nine_slice_data.top  + nine_slice_data.height / 2;
	} else {
		__knob_x = x - sprite_xoffset + nine_slice_data.left   + nine_slice_data.width / 2;
		__knob_y = y - sprite_yoffset + nine_slice_data.bottom - (value - min_value) * __tilesize;
	}
	draw_sprite_ext(
		knob_sprite, __knob_image_index, 
		__knob_x, __knob_y, 
		knob_xscale, knob_yscale, 0,
		(__mouse_over_knob || __knob_grabbed) ? __knob_over_color : draw_color, 1);
}

// first, clamp the value in case the dev made a config error (like leaving value at 0 while setting min_value to 1)
value = clamp(value, min_value, max_value);
var initval = value;
value++; // just modify the value
set_value(initval);
