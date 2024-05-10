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
	var table = ROOMCONTROLLER.race.tables.match3_board;
	
	// This command resets the table to a state as if it would've been loaded freshly from the file
	table.reset();
	
	table.items.gemWhite .enabled = chkEnableGemWhite	.checked;
	table.items.gemRed   .enabled = chkEnableGemRed		.checked;
	table.items.gemPurple.enabled = chkEnableGemPurple	.checked;
	table.items.gemGreen .enabled = chkEnableGemGreen	.checked;
	table.items.gemBlue  .enabled = chkEnableGemBlue	.checked;
	table.items.gemYellow.enabled = chkEnableGemYellow	.checked;
	
	table.items.gemWhite .chance = real(txtChanceGemWhite	.text);
	table.items.gemRed   .chance = real(txtChanceGemRed		.text);
	table.items.gemPurple.chance = real(txtChanceGemPurple	.text);
	table.items.gemGreen .chance = real(txtChanceGemGreen	.text);
	table.items.gemBlue  .chance = real(txtChanceGemBlue	.text);
	table.items.gemYellow.chance = real(txtChanceGemYellow	.text);
	
	// We can set the loot count in the race json file too, this line here is only to demonstrate
	// how you can adapt the loot_count at runtime (most games don't have a static loot count)
	table.loot_count = 64; // 8x8 fields = 64 gems to drop
	
	// Filling the board is a single line of code if you use Controller+Table objects!
	table.query("PlayingField", "Gems");
}

function push_chances_to_textboxes() {
	var table = ROOMCONTROLLER.race.tables.match3_board;
	txtChanceGemWhite	.text = string_format(table.items.gemWhite .chance, 0, 2);
	txtChanceGemRed		.text = string_format(table.items.gemRed   .chance, 0, 2);
	txtChanceGemPurple	.text = string_format(table.items.gemPurple.chance, 0, 2);
	txtChanceGemGreen	.text = string_format(table.items.gemGreen .chance, 0, 2);
	txtChanceGemBlue	.text = string_format(table.items.gemBlue  .chance, 0, 2);
	txtChanceGemYellow	.text = string_format(table.items.gemYellow.chance, 0, 2);
}

function race_demo_exit_click() {
	room_goto(rmMain);
}
