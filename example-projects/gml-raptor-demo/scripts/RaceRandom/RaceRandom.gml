/*
	Utility methods that help with randomization.
	Requires juju's SNAP library and indieviduals Buffers scripts to work.
	
	(c)2022 Mike Barthold, indievidualgames, aka @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

/// @function					race_random_roll_dice(dice_count, sides)
/// @param {int} sides			How many sides the die has (6, 12, 20, etc)
/// @param {int=1} dice_count		How many dice to roll (default = 1)
/// @returns {array}			An array with the length of dice_count entries, each containing one die-result.
/// @description				Rolls one or more dice with a specified amount of sides.
function race_random_roll_dice(sides, dice_count = 1) {
	var rv = [];
	for (var i = 0; i < dice_count; i++)
		array_push(rv, irandom_range(1, sides));
	return rv;
}

/// @function					race_random_percent_hit(percent)
/// @param {real} percent		The percent chance to test
/// @returns {bool}				True, if the percent chance is hit, otherwise false.
/// @description				Convenience function to test whether a specific percent chance is hit.
///								Example: If some enemy has a 5% chance to go frenzy, you would write:
///								if (race_random_percent_hit(5)) { go_frenzy(); }
function race_random_percent_hit(percent) {
	return random_range(0, 100) <= percent;
}