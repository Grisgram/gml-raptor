/*
    sizeable window control tree demo
*/

function UiDemoSizableTreeChild(_control) : ControlTree(_control) constructor {
}

function CreateUiDemoSizableTree(_control) {
	return new UiDemoSizableTreeChild(_control)
		.add_control(Label,dock.none,anchor.none,0.5,,{ text: "Ich bin ein Label"})
		.new_line()
		.add_control(ImageButton,dock.none,anchor.none,,,{
			sprite_to_use: sprLG_de, 
			on_left_click: function() {
				msg_show_ok("It's dynamic!", "Boom! (mic drop)");
			}
		})
	;
}