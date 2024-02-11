/// @description Build Window on create
event_inherited();

control_tree
	.set_margin(16,0,0,20)
	.set_padding(16,0,0,0)
	.add_control(Label, {text:"=ui_demo/login_top_message"})
	.new_line()
	.add_control(Label, {text:"=ui_demo/login_user",scribble_text_align:"[fa_middle][fa_right]"}).set_spread(.3)
	.add_control(InputBox, {
		text_color: APP_THEME_BRIGHT,
		text_color_focus: APP_THEME_BRIGHT,
		tab_index: 0, 
		text: "", 
		startup_width: 240,
		startup_height: 32
	}).set_name("txtUser")
	.new_line()
	
	.add_control(Label, {text:"=ui_demo/login_pwd",scribble_text_align:"[fa_middle][fa_right]"}).set_spread(.3)
	.add_control(InputBox, {
		text_color: APP_THEME_BRIGHT,
		text_color_focus: APP_THEME_BRIGHT,
		tab_index: 1, 
		text: "", 
		startup_width: 240, 
		startup_height: 32,
		password_char: "*"
	}).set_name("txtPwd")
	.new_line()
	
	.add_control(CheckBox, {text:"=ui_demo/login_remember", checked: true}).set_name("chkRemember")
	.new_line()
	
	.add_control(Panel, {startup_height:80})
		.set_spread(1)
		.set_padding(32,16,32,48)
		.add_control(TextButton, {text:"=ui_demo/login_button", on_left_click: 
			function() {
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
		})
		.add_control(TextButton, {text:"=global_words/buttons/cancel", on_left_click: 
			function() {
				get_window().close();
			}
		})
		.step_out()
		
	.on_window_opened(function(_who) {
		vlog($"--- {MY_NAME} on_window_opened ---");
		get_element("txtUser").set_focus();
	})
	.on_window_closed(function(_who) {
		vlog($"--- {MY_NAME} on_window_closed ---");
	})
;
