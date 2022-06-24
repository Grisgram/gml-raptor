/*
    button clicks
*/
function startButton_click(){
	room_goto("rmPlay");
}

function exitButton_click(){
	EXIT_GAME
}

/*
    hotswap languages
*/
function languageButton_click(sender) {
	LG_hotswap(sender.locale_name);
}
