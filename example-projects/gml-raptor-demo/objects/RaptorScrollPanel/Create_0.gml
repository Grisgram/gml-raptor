/// @description create scrollbars
event_inherited();

__scissor	= undefined;
__vscroll	= undefined;
__hscroll	= undefined;
__clipw		= 0;
__cliph		= 0;

__scrolldim = new SpriteDim(object_get_sprite(Scrollbar));
__barsize = __scrolldim.height;

__base_draw_instance = __draw_instance;

content = undefined;

/// @func set_content(_instance)
/// @desc sets the content instance for this scroll panel
set_content = function(_instance) {
	content = _instance;
	content.visible = false;
}

__draw_instance = function(_force = false) {
	__base_draw_instance(_force);
	if (!visible || is_null(content)) return;
	
	content.x = x + content.sprite_xoffset + drag_xoffset;
	content.y = y + content.sprite_xoffset + drag_yoffset;

	__clipw = sprite_width - (horizontal_scrollbar ? __barsize : 0);
	__cliph = sprite_height - (vertical_scrollbar ? __barsize : 0);

	__scissor = gpu_get_scissor();
	gpu_set_scissor(x, y, __clipw, __cliph);
	with(content) {
		visible = true;
		depth = other.depth - 1;
		__draw_self();
		visible = false;
	}
	gpu_set_scissor(__scissor.x, __scissor.y, __scissor.w, __scissor.h);
}

if (vertical_scrollbar)
	__vscroll = control_tree
	.add_control(Scrollbar, {
		orientation_horizontal: false,
		startup_width: __barsize,
		startup_height: sprite_height - (horizontal_scrollbar ? __barsize : 0) + 1,
		on_mouse_enter_knob: function() {
			ilog($"--- {name} {x}/{y} {sprite_width}x{sprite_height}");
		}
	})
	.set_align(fa_top, fa_right)
	.set_anchor(anchor.top | anchor.bottom)
	.set_name("vscroll")
	.get_instance()
	;

ilog($"--- {MY_NAME} added {name_of(__vscroll)}");

if (horizontal_scrollbar)
	__hscroll = control_tree
	.add_control(Scrollbar, {
		orientation_horizontal: true,
		startup_width: sprite_width - (vertical_scrollbar ? __barsize : 0) + 1,
		startup_height: __barsize,
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

set_content(instance_create(0,0,"ui_instances",TextButton,{
	autosize: true,
	text: "Hello, World!",
	startup_width: 128,
	startup_height: 64,
}));

	
