/// @description 

#macro BOARD_LEFT_BORDER	224
#macro BOARD_TOP_BORDER		96

// Inherit the parent event
event_inherited();

states.add_state("idle");

// As a demonstration you can see here the "override" function,
// a useful tool if you redefine methods from parent objects.
// if you "override" a function, the original function is available as "base.function_name"
// and you can still call the parents' original implementation, as shown here.
// NOTE: overriding does not work recursively due to GML's object design.
// "base.function" will always contain only the DIRECT PARENTS' IMPLEMENTATION.
// All other levels get lost.
override("onQueryHit", function(first_query_table, current_query_table, item_dropped) {
	base.onQueryHit(first_query_table, current_query_table, item_dropped);
	
	// As soon as onQueryHit gets invoked, "data.race_data" is already populated,
	// so we look into the attributes of our race_data now and set our sprite
	sprite_index = asset_get_index(data.race_data.attributes.sprite);
	
	// Now appear with a quick fade-in and a delay based on the number of gems
	// already spawned.
	var col = GLOBALDATA.gem_count mod 8;
	var row = GLOBALDATA.gem_count div 8;
	x = BOARD_LEFT_BORDER + 128 * col;
	y = BOARD_TOP_BORDER  + 128 * row;
	image_alpha = 0;
	image_xscale = 0.75;
	image_yscale = 0.75;
	
	animation_run(self, GLOBALDATA.gem_count div 2, 30, acLinearAlpha);
	
	GLOBALDATA.gem_count++;
});
