/*
    sizeable window control tree demo
*/

function UiDemoSizableTreeChild(_control) : ControlTree(_control) constructor {
}

function CreateUiDemoSizableTree(_control) {
	return new UiDemoSizableTreeChild(_control)
		.set_margin_all(8)
		.add_control(Label, { text: "Ich bin ein Label oben"}).set_spread(0.5)
		.add_control(Label, { text: "und ich rechts davon"}).set_spread(0.5)
		.new_line()
		.add_control(Panel, {startup_height:80,image_blend:c_red})
			.set_spread(1)
			.set_padding(41,0,0,0)
			.add_control(ImageButton, {
				sprite_to_use: sprLG_de, 
				on_left_click: function() {
					msg_show_ok("It's dynamic 1!", "Boom! (mic drop)");
				}
			})
			.add_control(ImageButton, {
				startup_width: 64,
				startup_height: 64,
				sprite_to_use: sprSnowflake, 
				on_left_click: function() {
					msg_show_ok("It's dynamic 2!", "Boom! (mic drop)");
				}
			})
			.add_control(ImageButton, {
				sprite_to_use: sprLG_de, 
				on_left_click: function() {
					msg_show_ok("It's dynamic 3!", "Boom! (mic drop)");
				}
			})
			.step_out()
		.new_line()
		.add_control(Label, { text: "Ich bin ein Label unten"}).set_spread(0.5)
		.new_line()
		.add_control(Slider, {
			startup_width: 24, 
			knob_xscale: 2.0,
			auto_text_position: slider_text.h_below
		}).set_spread(,.5)
	;
}