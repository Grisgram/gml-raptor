/*
    sizeable window control tree demo
*/

function UiDemoSizableTreeChild(_control) : ControlTree(_control) constructor {
}

function CreateUiDemoSizableTree(_control) {
	return new UiDemoSizableTreeChild(_control)
		.set_margin_all(8)
		.add_control(Label,dock.none,anchor.none,0.5,,{ text: "Ich bin ein Label oben"})
		.new_line()
		.add_control(ImageButton,dock.none,anchor.none,,,{
			sprite_to_use: sprLG_de, 
			on_left_click: function() {
				msg_show_ok("It's dynamic!", "Boom! (mic drop)");
			}
		})		
		.add_control(ImageButton,dock.none,anchor.none,,,{
			startup_width: 128,
			startup_height: 128,
			sprite_to_use: sprSnowflake, 
			on_left_click: function() {
				msg_show_ok("It's dynamic!", "Boom! (mic drop)");
			}
		})
		.add_control(ImageButton,dock.none,anchor.none,,,{
			sprite_to_use: sprLG_de, 
			on_left_click: function() {
				msg_show_ok("It's dynamic!", "Boom! (mic drop)");
			}
		})
		.new_line()
		.add_control(Label,dock.none,anchor.none,0.5,,{ text: "Ich bin ein Label unten"})
		.new_line()
		.add_control(RaptorSlider,dock.none,anchor.none,1)

	;
}