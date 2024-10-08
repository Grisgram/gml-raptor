/// @description Build Window on create
event_inherited();

control_tree
	//.set_margin(16,4,20,20)
	//.set_margin(0,0,20,0)
	.set_padding_all(12)
	.add_control(Label, {
			text:"=ui_demo/login_top_message",
			scribble_text_align:"[fa_middle][fa_center]"
		}).set_dock(dock.top)
	
	// button row
	.add_control(Panel, { startup_height: 40 }).set_dock(dock.bottom)
		.add_control(Panel).set_spread(0.5, 1).set_margin(0,0,8,0).set_align(fa_top, fa_left)
			.add_control(TextButton, {
				text:"=ui_demo/login_button", 
				startup_height: 32,
				on_left_click: function() {
					with(get_window()) {
						msg_show_ok("=ui_demo/window_title_login", 
							$"{LG("=ui_demo/login_entered_values")}\n\n" +
							$"{LG("=ui_demo/login_user")} [ci_accent]{get_element("txtUser").text}[/]\n" +
							$"{LG("=ui_demo/login_pwd")} [ci_accent]{get_element("txtPwd").text}[/]\n" +
							$"{LG("=ui_demo/login_remember")}: [ci_accent]{get_element("chkRemember").checked}[/]\n"
						);
						close();
					}
				}
			})
			.set_spread(.5).set_align(fa_middle, fa_right)
			.step_out()
		.add_control(Panel).set_spread(0.5, 1).set_margin(8,0,0,0).set_align(fa_top, fa_right)
			.add_control(TextButton, {
				text: "=global_words/buttons/cancel", 
				startup_height: 32,
				on_left_click: function() {
					get_window().close();
				}
			}).set_spread(.5).set_align(fa_middle, fa_left)
			.step_out()
		.step_out()
		
	// input row
	.add_control(Panel).set_dock(dock.fill).set_margin_all(4)
		// left side of login: the two labels
		.add_control(Panel).set_spread(0.3, 0.6).set_margin(4,0,4,0).set_align(fa_top, fa_left)
			.add_control(Panel).set_spread(1, 0.5).set_margin(4,4,0,4).set_padding(0,0,8,0).set_align(fa_top, fa_left)
				.add_control(Label, {text:"=ui_demo/login_user",scribble_text_align:"[fa_middle][fa_right]"}).set_dock(dock.fill)
				.step_out()
			.add_control(Panel).set_spread(1, 0.5).set_margin(4,4,0,4).set_padding(0,0,8,0).set_align(fa_bottom, fa_left)
				.add_control(Label, {text:"=ui_demo/login_pwd",scribble_text_align:"[fa_middle][fa_right]"}).set_dock(dock.fill)
				.step_out()
			.step_out()
		// right side of login: the two input boxes
		.add_control(Panel).set_spread(0.7, 0.6).set_margin(4,0,4,0).set_align(fa_top, fa_right)
			.add_control(Panel).set_spread(0.8, 0.5).set_margin(4,4,0,4).set_padding(8,0,0,0).set_align(fa_top, fa_left)
				.add_control(InputBox, {
					text: "", 
				}).set_name("txtUser").set_spread(1).set_margin(4,4,0,4).set_align(fa_middle, fa_left)
				.step_out()
			.add_control(Panel).set_spread(0.8, 0.5).set_margin(4,4,0,4).set_padding(8,0,0,0).set_align(fa_bottom, fa_left)
				.add_control(InputBox, {
					text: "", 
					startup_height: 32,
					password_char: "*"
				}).set_name("txtPwd").set_spread(1).set_margin(4,4,0,4).set_align(fa_middle, fa_left)
				.step_out()
			.step_out()	
		// the remember-checkbox
		.add_control(Panel).set_spread(1, 0.4).set_margin(0,8,0,0).set_align(fa_bottom, fa_left)
			.add_control(Panel).set_spread(0.7, -1).set_margin(8,0,0,0).set_align(fa_top, fa_right)
				.add_control(CheckBox, {text:"=ui_demo/login_remember", checked: true})
					.set_name("chkRemember")
					.set_padding_all(8)
					.set_align(fa_top, fa_left)
				.step_out()
			.step_out()
		.step_out()
	.on_window_opened(function(_who) {
		vlog($"UiDemo: {MY_NAME} on_window_opened");
		get_element("txtUser").set_focus();
	})
	.on_window_closed(function(_who) {
		vlog($"UiDemo: {MY_NAME} on_window_closed");
	})
	.build()
;
