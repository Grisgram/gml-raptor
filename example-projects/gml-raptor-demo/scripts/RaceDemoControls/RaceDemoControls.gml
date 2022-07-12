/*
    All control events of the Race Demo
*/

function race_demo_start_click() {	
	with(Gem)
		instance_destroy(self);
		
	// This counter is responsible for the spawn delay of the gems.
	// That's why they appear like a wave.
	GLOBALDATA.gem_count = 0;
	
	// Take all the values from the settings controls to the racetable.
	var table = match3Table.race_table;
	
	// This command resets the table to a state as if it would've been loaded freshly from the file
	race_table_reset(table);
	
	race_set_enabled(table, "gemWhite", chkEnableGemWhite	.is_checked);
	race_set_enabled(table, "gemRed",	chkEnableGemRed		.is_checked);
	race_set_enabled(table, "gemPurple",chkEnableGemPurple	.is_checked);
	race_set_enabled(table, "gemGreen", chkEnableGemGreen	.is_checked);
	race_set_enabled(table, "gemBlue",	chkEnableGemBlue	.is_checked);
	race_set_enabled(table, "gemYellow",chkEnableGemYellow	.is_checked);
	
	race_set_chance (table, "gemWhite", real(txtChanceGemWhite	.text));
	race_set_chance (table, "gemRed",	real(txtChanceGemRed	.text));
	race_set_chance (table, "gemPurple",real(txtChanceGemPurple	.text));
	race_set_chance (table, "gemGreen", real(txtChanceGemGreen	.text));
	race_set_chance (table, "gemBlue",	real(txtChanceGemBlue	.text));
	race_set_chance (table, "gemYellow",real(txtChanceGemYellow	.text));
	
	// We can set the loot count in the race json file too, this line here is only to demonstrate
	// how you can adapt the loot_count at runtime (most games don't have a static loot count)
	race_table_set_loot_count(table, 64); // 8x8 fields = 64 gems to drop
	
	// Filling the board is a single line of code if you use Controller+Table objects!
	match3Table.query();
}

function push_chances_to_textboxes() {
	var table = match3Table.race_table;
	txtChanceGemWhite	.text = string_format(race_get_chance(table, "gemWhite" ), 0, 2);
	txtChanceGemRed		.text = string_format(race_get_chance(table, "gemRed"   ), 0, 2);
	txtChanceGemPurple	.text = string_format(race_get_chance(table, "gemPurple"), 0, 2);
	txtChanceGemGreen	.text = string_format(race_get_chance(table, "gemGreen" ), 0, 2);
	txtChanceGemBlue	.text = string_format(race_get_chance(table, "gemBlue"  ), 0, 2);
	txtChanceGemYellow	.text = string_format(race_get_chance(table, "gemYellow"), 0, 2);
}

function gem_checkbox_clicked(sender) {
	sender.toggle_checked();
}

function race_demo_exit_click() {
	room_goto(rmMain);
}
