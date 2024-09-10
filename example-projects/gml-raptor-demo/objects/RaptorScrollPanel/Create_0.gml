/// @description create scrollbars
event_inherited();

enum mouse_drag {
	none,
	left,
	middle,
	right
}

__base_draw_instance = __draw_instance;

__scissor		= undefined;
__vscroll		= { value_percent: 0, max_value: 100, };
__hscroll		= { value_percent: 0, max_value: 100, };
__clipw			= 0;
__cliph			= 0;
__drag_xmax		= 0;
__draw_ymax		= 0;
__mouse_delta	= 0;

__scrolldim		= new SpriteDim(object_get_sprite(Scrollbar));
__hbarsize		= (horizontal_scrollbar ? __scrolldim.height : 0);
__vbarsize		= (vertical_scrollbar ? __scrolldim.height : 0);

content			= undefined;
draw_method		= undefined

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
	content.visible = false;
	//content.draw_on_gui = false;
	//draw_on_gui = false;
}

__draw_instance = function(_force = false) {
	if (!visible || is_null(content)) return;
	
	__clipw = sprite_width  - __vbarsize;
	__cliph = sprite_height - __hbarsize;
	
	__drag_xmax = content.sprite_width  - __clipw;
	__drag_ymax = content.sprite_height - __cliph;
	
	drag_xoffset = -__drag_xmax * __hscroll.value_percent;
	drag_yoffset = -__drag_ymax * __vscroll.value_percent;
	
	content.x = x + content.sprite_xoffset + drag_xoffset;// + CTL_MOUSE_DELTA_X * __mouse_delta;
	content.y = y + content.sprite_xoffset + drag_yoffset;// + CTL_MOUSE_DELTA_Y * __mouse_delta;

	__scissor = gpu_get_scissor();
	gpu_set_scissor(x, y, __clipw, __cliph);
	with(content) {
		if (other.draw_method != undefined) other.draw_method(); else draw_self();
	}
	gpu_set_scissor(__scissor.x, __scissor.y, __scissor.w, __scissor.h);
	
	__base_draw_instance(_force);

//draw_self();
//ilog($"--- {surface_get_width(application_surface)} {window_get_width()}");
//var srat = APP_SURF_WIDTH / APP_SURF_HEIGHT;
//var wrat = window_get_width() / window_get_height();
//var scx=1, scy;
//if (wrat < srat) {
//	ilog("blackbar on top");
	
//} else {
//	ilog("blackbar on the left");
//}
//scy = scx;
var scx = 1;
var scy = 1;
var ap = [0,0];
if (draw_on_gui) {
	ap = application_get_position();
	aw = ap[2] - ap[0] + 1;
	ah = ap[3] - ap[1] + 1;
	ilog($"--- {aw} {ah}");
	scx = aw/surface_get_width(application_surface);
	scy = ah/surface_get_height(application_surface);
}
//var scx = window_get_width()/surface_get_width(application_surface);
//var scy = window_get_height()/surface_get_height(application_surface);

//ilog($"--- {application_get_position()} {window_get_width()} {surface_get_width(application_surface)}");

__scissor = gpu_get_scissor();
//gpu_set_scissor(x, y, __clipw, __cliph);
//if (WINDOW_SIZE_HAS_CHANGED) ilog($"--- {scx} {scy} {window_get_width()} {surface_get_width(application_surface)}");
gpu_set_scissor(x * scx + ap[0], y * scy + ap[1], __clipw * scx, __cliph * scy);
//gpu_set_scissor((x - ap[0]) * scx, (y + ap[1]) * scy, __clipw * scx, __cliph * scy);
draw_set_color(c_red);
draw_set_alpha(0.5)
draw_rectangle(0,0,1920,1080,false)
draw_set_alpha(1)
draw_set_color(c_white)
gpu_set_scissor(__scissor.x, __scissor.y, __scissor.w, __scissor.h);	

draw_circle(x,y,16,false);
draw_circle(x+__clipw,y,16,false);
draw_circle(x,y+__cliph,16,false);
draw_circle(x+__clipw,y+__cliph,16,false);

draw_circle(0,0,32,false);
draw_circle(room_width,0,32,false);
draw_circle(0,room_height,32,false);
draw_circle(room_width,room_height,32,false);
}

if (vertical_scrollbar)
	__vscroll = control_tree
	.add_control(Scrollbar, {
		orientation_horizontal: false,
		startup_width: __vbarsize,
		startup_height: sprite_height - (horizontal_scrollbar ? __hbarsize : 0) + 1,
		on_mouse_enter_knob: function() {
			ilog($"--- {name} {x}/{y} {sprite_width}x{sprite_height}");
		}
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
		on_mouse_enter_knob: function() {
			ilog($"--- {name} {x}/{y} {sprite_width}x{sprite_height}");
		}
	})
	.set_align(fa_bottom, fa_left)
	.set_anchor(anchor.left | anchor.right)
	.set_name("hscroll")
	.get_instance()
	;

control_tree.build();

set_content(instance_create(0,0,"ui_instances",ImageButton,{
	sprite_to_use: sprDefaultFlag,
	autosize: true,
	startup_width: 800,
	startup_height: 600,
}));
