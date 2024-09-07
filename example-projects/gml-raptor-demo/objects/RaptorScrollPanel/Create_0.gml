/// @description create scrollbars
event_inherited();

__vscroll = undefined;
__hscroll = undefined;
__panel = undefined;

__scrolldim = new SpriteDim(object_get_sprite(Scrollbar));
__barsize = __scrolldim.height;

if (vertical_scrollbar)
	__vscroll = control_tree
	.add_control(Scrollbar, {
		orientation_horizontal: false,
		startup_width: __barsize,
		startup_height: sprite_height - (horizontal_scrollbar ? __barsize : 0) + 2,
		on_mouse_enter_knob: function() {
			ilog($"--- {name} {x}/{y} {sprite_width}x{sprite_height}");
		}
	})
	.set_align(fa_top, fa_right, 1, -1)
	.set_anchor(anchor.top | anchor.bottom)
	.set_name("vscroll")
	.get_instance()
	;

ilog($"--- {MY_NAME} added {name_of(__vscroll)}");

if (horizontal_scrollbar)
	__hscroll = control_tree
	.add_control(Scrollbar, {
		orientation_horizontal: true,
		startup_width: sprite_width - (vertical_scrollbar ? __barsize : 0) + 2,
		startup_height: __barsize,
		on_mouse_enter_knob: function() {
			ilog($"--- {name} {x}/{y} {sprite_width}x{sprite_height}");
		}
	})
	.set_align(fa_bottom, fa_left, -1, 1)
	.set_anchor(anchor.left | anchor.right)
	.set_name("hscroll")
	.get_instance()
	;

ilog($"--- {MY_NAME} added {name_of(__hscroll)}");

__panel = control_tree
	.add_control(Panel, {
		sprite_index: spr1pxWhite64,
		startup_width: sprite_width - (horizontal_scrollbar ? __barsize : 0),
		startup_height: sprite_height - (vertical_scrollbar ? __barsize : 0),
	})
	.set_align(fa_top, fa_left)
	.set_anchor(anchor.all_sides)
	.set_name("panel")
	.step_out()
	.get_instance();

ilog($"--- {MY_NAME} added {name_of(__panel)} {__panel.x}/{__panel.y} {__panel.sprite_width}x{__panel.sprite_height}");
	
control_tree.build();

with(__panel) 
	control_tree.add_control(TextButton, {
		text: "Hello World!"
	}).set_dock(dock.fill).build();
	
ilog($"--- {MY_NAME} added {name_of(__panel)} {__panel.x}/{__panel.y} {__panel.sprite_width}x{__panel.sprite_height}");
