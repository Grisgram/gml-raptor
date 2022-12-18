/// @description Show how-to-play
event_inherited();
run_delayed(self, 1, function() {
	msg_show_ok("=play/how_to_play_race/title", "=play/how_to_play_race/text", function() {
		start_game();
	});
});

start_game = function() {
	push_chances_to_textboxes();
	race_demo_start_click(); // Fill one board at start completely random
}
