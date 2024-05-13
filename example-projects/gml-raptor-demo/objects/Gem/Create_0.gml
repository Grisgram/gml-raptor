/// @description 

#macro BOARD_LEFT_BORDER	224
#macro BOARD_TOP_BORDER		96

// Inherit the parent event
event_inherited();

states.add_state("idle");

onRaceDrop = function(_item_data) {
	
	// As soon as onQueryHit gets invoked, "data.race_data" is already populated,
	// so we look into the attributes of our race_data now and set our sprite
	sprite_index = asset_get_index(data.race_item.attributes.sprite);
	
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
};
