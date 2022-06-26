/*
    button clicks
*/
function startButton_click() {
	room_goto("rmPlay");
}

function exitButton_click() {
	EXIT_GAME
}

function messageboxButton_click() {
	msg_show_ok_cancel("=main_menu/demo_message/title", "=main_menu/demo_message/text",
		function() {
			msg_show_ok("=main_menu/demo_message/click_title","=main_menu/demo_message/ok_clicked");
		},
		function() {
			msg_show_ok("=main_menu/demo_message/click_title","=main_menu/demo_message/cancel_clicked");
		}
	);
}

/*
    hotswap languages
*/
function languageButton_click(sender) {
	LG_hotswap(sender.locale_name);
}
