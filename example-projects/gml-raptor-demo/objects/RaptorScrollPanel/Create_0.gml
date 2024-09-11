/// @description create scrollbars
event_inherited();

enum mouse_drag {
	none,
	left,
	middle,
	right
}

__base_draw_instance = __draw_instance;

__scissor			= undefined;
__vscroll			= { value: 0, value_percent: 0, min_value: 0, max_value: 100, };
__hscroll			= { value: 0, value_percent: 0, min_value: 0, max_value: 100, };
__ap_default		= [0, 0];		// app pos
__ap				= __ap_default;	// app pos
__aw				= 0;			// app width
__ah				= 0;			// app height
__clipw				= 0;
__cliph				= 0;
__drag_xmax			= 0;
__draw_ymax			= 0;
__mouse_delta		= 0;
__mouse_multi		= mouse_drag_inverted ? mouse_drag_multiplier : -mouse_drag_multiplier;
__mouse_in_content	= false;
__scale_x			= 1;
__scale_y			= 1;

__scrolldim			= new SpriteDim(object_get_sprite(Scrollbar));
__hbarsize			= (horizontal_scrollbar ? __scrolldim.height : 0);
__vbarsize			= (vertical_scrollbar ? __scrolldim.height : 0);
					
content				= undefined;
draw_method			= undefined

/// @func	set_content(_instance, _custom_draw_method = undefined)
/// @desc	sets the content instance for this scroll panel.
///			You may supply a method name in the instance to draw the
///			instance, if you have some custom draw mechanism.
///			If you don't specify one, GameMaker's "draw_self()"
///			method will be used to draw the clipped content.
///			By default, the "__draw_self()" of raptor's control classes
///			will be detected and invoked, you don't need to specify a
///			custom draw, when setting any raptor control as content.
set_content = function(_instance, _custom_draw_method = undefined) {
	content = _instance;
	draw_method = undefined;// = _custom_draw_method ?? vsget(content, "__draw_self");
	content.is_in_scrollpanel = true;
	//content.visible = false;
	//content.draw_on_gui = false;
	//draw_on_gui = false;
}

clear_content = function() {
	content.is_in_scrollpanel = false;
}

__mouse_in_content = function() {
	return point_in_rectangle(
		CTL_MOUSE_X, CTL_MOUSE_Y,
		SELF_VIEW_LEFT_EDGE, SELF_VIEW_TOP_EDGE,
		SELF_VIEW_LEFT_EDGE + __clipw - 1, SELF_VIEW_TOP_EDGE + __cliph - 1
	);
}

__update_scroller = function(_inst, _by) {
	_inst.value = clamp(_inst.value + _by, 0, 100);
	_inst.value_percent = (_inst.value - _inst.min_value) / _inst.max_value;
}

__draw_instance = function(_force = false) {
	if (!visible || is_null(content)) return;
	
	__clipw = sprite_width  - __vbarsize;
	__cliph = sprite_height - __hbarsize;
	
	__drag_xmax = content.sprite_width  - __clipw;
	__drag_ymax = content.sprite_height - __cliph;

	// how many % of the content size is the mouse delta?
	if (__mouse_delta) {
		drag_xoffset = clamp(drag_xoffset + CTL_MOUSE_DELTA_X * mouse_drag_multiplier, -__drag_xmax, 0);
		drag_yoffset = clamp(drag_yoffset + CTL_MOUSE_DELTA_Y * mouse_drag_multiplier, -__drag_ymax, 0);
		__hscroll.value_percent = -drag_xoffset / __drag_xmax;
		__vscroll.value_percent = -drag_yoffset / __drag_ymax;
		__hscroll.value = ceil(__hscroll.value_percent * 100);
		__vscroll.value = ceil(__vscroll.value_percent * 100);
	} else {	
		drag_xoffset = -__drag_xmax * __hscroll.value_percent;
		drag_yoffset = -__drag_ymax * __vscroll.value_percent;
	}
	
	content.x = x + content.sprite_xoffset + drag_xoffset;
	content.y = y + content.sprite_xoffset + drag_yoffset;

	// calculate scissor multiplier based on draw mode	
	if (draw_on_gui) {
		__ap		= application_get_position();
		__aw		= __ap[2] - __ap[0] + 1;
		__ah		= __ap[3] - __ap[1] + 1;
		__scale_x	= __aw / APP_SURF_WIDTH;
		__scale_y	= __ah / APP_SURF_HEIGHT;
	} else {
		__ap		= __ap_default;
		__scale_x	= 1;
		__scale_y	= 1;
	}
	
	__scissor = gpu_get_scissor();
	gpu_set_scissor(
		x * __scale_x + __ap[0], 
		y * __scale_y + __ap[1], 
		ceil(__clipw * __scale_x), 
		ceil(__cliph * __scale_y)
	);
	with(content) {
		if (other.draw_method != undefined) other.draw_method(); else draw_self();
	}
	gpu_set_scissor(__scissor.x, __scissor.y, __scissor.w, __scissor.h);
	
	__base_draw_instance(_force);
}

if (vertical_scrollbar)
	__vscroll = control_tree
	.add_control(Scrollbar, {
		orientation_horizontal: false,
		startup_width: __vbarsize,
		startup_height: sprite_height - (horizontal_scrollbar ? __hbarsize : 0) + 1,
		knob_autoscale: false,
		knob_xscale: 1,
		knob_yscale: 3,
		wheel_value_change: wheel_value_change,
	})
	.set_align(fa_top, fa_right)
	.set_anchor(anchor.top | anchor.bottom)
	.set_name("vscroll")
	.get_instance()
	;

if (horizontal_scrollbar)
	__hscroll = control_tree
	.add_control(Scrollbar, {
		orientation_horizontal: true,
		startup_width: sprite_width - (vertical_scrollbar ? __vbarsize : 0) + 1,
		startup_height: __hbarsize,
		knob_autoscale: false,
		knob_xscale: 3,
		knob_yscale: 1,
		wheel_value_change: wheel_value_change,
	})
	.set_align(fa_bottom, fa_left)
	.set_anchor(anchor.left | anchor.right)
	.set_name("hscroll")
	.get_instance()
	;

control_tree.build();

set_content(instance_create(0,0,"ui_instances",ImageButton,{
	sprite_to_use: sprDefaultFlag,
	autosize: false,
	startup_width: 400,
	startup_height: 300,
}));
