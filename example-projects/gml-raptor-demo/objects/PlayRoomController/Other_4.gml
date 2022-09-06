/// @description Show how-to-play
event_inherited();
#macro MAX_ENEMY_COUNT		10

scribble_score = undefined;

msg_show_ok("=play/how_to_play_states/title", "=play/how_to_play_states/text", function() {
	create_spawner_and_player();
});

gain_score = function(amount) {
	GLOBALDATA.score += amount;
	scribble_score = scribble("[fa_right][fa_middle]" + sprintf(LG("play/ui/score_view"), GLOBALDATA.score), "score_view");
}

create_spawner_and_player = function() {
	GLOBALDATA.enemy_count = 0;
	GLOBALDATA.score = 0;
	gain_score(0); // initialize the scribble object
	instance_create_layer(0,0,"Spawner",Spawner);
	instance_create_layer(0,0,"Actors",Player);
}

game_over = function() {
	msg_show_ok("=play/game_over/title", sprintf(LG("play/game_over/text"), GLOBALDATA.score), function() {
		room_goto(rmMain);
	});
}

