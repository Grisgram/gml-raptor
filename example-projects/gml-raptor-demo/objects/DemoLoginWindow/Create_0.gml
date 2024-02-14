/// @description Build Window on create
event_inherited();

control_tree
	//.set_margin(16,4,20,20)
	//.set_margin(0,0,20,0)
	.set_padding_all(12)
	.add_control(Label, {
			text:"=ui_demo/login_top_message",
			scribble_text_align:"[fa_middle][fa_center]"
		}).set_spread(1).set_dock(dock.top)
	.new_line()
	
	.add_control(Panel).set_spread(1).set_padding_all(12).set_dock(dock.top)
		.add_control(Panel).set_spread(.5).set_padding(0,0,8,0)
			.add_control(Label, {text:"=ui_demo/login_user",scribble_text_align:"[fa_middle][fa_right]"}).set_spread(1)
			.step_out()
		.add_control(Panel).set_spread(.5).set_padding(8,0,8,0)
			.add_control(InputBox, {
				text_color: APP_THEME_BRIGHT,
				text_color_focus: APP_THEME_BRIGHT,
				text_color_mouse_over: APP_THEME_BRIGHT,
				tab_index: 0, 
				text: "", 
				startup_height: 32
			}).set_name("txtUser").set_spread(1)
			.step_out()
		.new_line()
	
		.add_control(Panel).set_spread(.5).set_padding(0,0,8,0)
			.add_control(Label, {text:"=ui_demo/login_pwd",scribble_text_align:"[fa_middle][fa_right]"}).set_spread(1)
			.step_out()
		.add_control(Panel).set_spread(.5).set_padding(8,0,8,0)	
			.add_control(InputBox, {
				text_color: APP_THEME_BRIGHT,
				text_color_focus: APP_THEME_BRIGHT,
				text_color_mouse_over: APP_THEME_BRIGHT,
				tab_index: 1, 
				text: "", 
				startup_height: 32,
				password_char: "*"
			}).set_name("txtPwd").set_spread(1)
			.step_out()
		.step_out()
	.new_line()

	.add_control(CheckBox, {text:"=ui_demo/login_remember", checked: true})
		.set_name("chkRemember")
		.set_padding_all(8)
		.set_align(fa_bottom, fa_center)
	.new_line()
	
	.add_control(Panel, {startup_height:48}).set_dock(dock.bottom).set_padding_all(8)//.set_margin(0,0,0,8)
		.add_control(Panel).set_spread(.5).set_padding_all(8)//.set_padding(0,0,16,0)
			.add_control(TextButton, {
				text:"=ui_demo/login_button", 
				startup_height: 32,
				on_left_click: function() {
					with(get_window()) {
						msg_show_ok("=ui_demo/login_window_title", 
							$"{LG("=ui_demo/login_entered_values")}\n\n" +
							$"{LG("=ui_demo/login_user")} [ci_accent]{get_element("txtUser").text}[/]\n" +
							$"{LG("=ui_demo/login_pwd")} [ci_accent]{get_element("txtPwd").text}[/]\n" +
							$"{LG("=ui_demo/login_remember")}: [ci_accent]{get_element("chkRemember").checked}[/]\n"
						);
						close();
					}
				}
			}).set_spread(.5).set_align(fa_middle, fa_right)
			.step_out()
	
		.add_control(Panel).set_spread(.5).set_padding_all(8)//.set_padding(16,0,0,0)
			.add_control(TextButton, {
				text: "=global_words/buttons/cancel", 
				startup_height: 32,
				on_left_click: function() {
					get_window().close();
				}
			}).set_spread(.5).set_align(fa_middle, fa_left)
			.step_out()
		.step_out()
		
	.on_window_opened(function(_who) {
		vlog($"--- {MY_NAME} on_window_opened ---");
		get_element("txtUser").set_focus();
	})
	.on_window_closed(function(_who) {
		vlog($"--- {MY_NAME} on_window_closed ---");
	})
;
