/// @description event
event_inherited();

race = new Race("racedemo")
	.on_load_finished(function() {
		ilog("Race async load finished");
	});
